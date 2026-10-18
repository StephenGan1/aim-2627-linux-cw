
#!/bin/bash
set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}
action=${3:-repair}

mkdir -p "$output"
state_dir="$output/http-service"

# cleanup：停止之前启动的 HTTP 服务
if [ "$action" = "cleanup" ]; then
    if [ -f "$state_dir/pid" ]; then
        pid=$(cat "$state_dir/pid")

        kill -TERM "$pid" 2>/dev/null || true

        for _ in {1..40}; do
            state=$(ps -p "$pid" -o stat= 2>/dev/null || true)
            if [ -z "$state" ] || [[ "$state" == Z* ]]; then
                break
            fi
            sleep 0.1
        done
    fi
    exit 0
fi

if [ "$action" != "repair" ]; then
    echo "Unknown action: $action" >&2
    exit 2
fi

# 读取测试器提供的进程和服务参数
source "$input/process.env"

# 检查目标采集器的进程信息
proc_user=$(ps -p "$TARGET_PID" -o user= | awk '{$1=$1; print}')
proc_state=$(ps -p "$TARGET_PID" -o stat= | awk '{print $1}')
proc_command=$(ps -p "$TARGET_PID" -o args=)

printf 'pid=%s\nuser=%s\nstate=%s\ncommand=%s\n' \
    "$TARGET_PID" "$proc_user" "$proc_state" "$proc_command" \
    > "$output/process.txt"

# 保存采集器日志
cp "$WORKER_LOG" "$output/collector-sample.log"

# 只停止指定采集器，不影响其他进程
kill -TERM "$TARGET_PID"

# 等待采集器正常写入 STOP 记录
for _ in {1..40}; do
    if grep -Fxq "STOP $TARGET_TOKEN" "$WORKER_LOG"; then
        break
    fi
    sleep 0.1
done

# 停止原来配置错误的 HTTP 服务
kill -TERM "$SERVICE_PID"

for _ in {1..40}; do
    state=$(ps -p "$SERVICE_PID" -o stat= 2>/dev/null || true)
    if [ -z "$state" ] || [[ "$state" == Z* ]]; then
        break
    fi
    sleep 0.1
done

# 修复端口与路由配置
printf 'bind=127.0.0.1\nport=%s\nroute=/status\n' \
    "$TARGET_PORT" > "$output/server.conf"

# 启动修复后的 HTTP 服务
bash "$START_TOOL" "$output/server.conf" "$state_dir"

# 等待服务可访问，保存真实 HTTP 响应
success=0

for _ in {1..40}; do
    if curl --noproxy '*' -fsS --max-time 1 \
        -o "$output/http-body.txt" \
        -w '%{http_code}\n' \
        "http://127.0.0.1:$TARGET_PORT/status" \
        > "$output/http-status.txt" 2>/dev/null; then
        success=1
        break
    fi
    sleep 0.1
done

if [ "$success" -ne 1 ]; then
    echo "HTTP service failed to become ready" >&2
    exit 1
fi
