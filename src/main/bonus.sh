
#!/bin/bash
set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}
action=${3:-start}

# 读取测试器生成的参数
source "$input/bonus.env"

mkdir -p "$output"
log_file="$output/bonus.log"

if [ "$action" = "start" ]; then

    # 避免重复启动同一个会话
    if tmux -L "$TMUX_SOCKET" has-session -t "=$SESSION" 2>/dev/null; then
        exit 0
    fi

    # 初始化日志
    : > "$log_file"

    # 构造安全的运行命令
    printf -v command 'exec python3 %q --token %q --log %q' \
        "$WORKER_TOOL" "$TOKEN" "$log_file"

    # 后台创建分离的 tmux 会话
    tmux -L "$TMUX_SOCKET" new-session -d -s "$SESSION" "$command"

elif [ "$action" = "stop" ]; then

    if tmux -L "$TMUX_SOCKET" has-session -t "=$SESSION" 2>/dev/null; then

        # 找到 tmux 窗格中的采集器进程
        pid=$(tmux -L "$TMUX_SOCKET" display-message \
            -p -t "=$SESSION" '#{pane_pid}')

        # 正常停止进程
        kill -TERM "$pid" 2>/dev/null || true

        # 等待采集器写入 STOP 日志
        for _ in {1..50}; do
            if grep -Fxq "STOP $TOKEN" "$log_file" 2>/dev/null; then
                break
            fi
            sleep 0.1
        done

        # 清理 tmux 会话
        tmux -L "$TMUX_SOCKET" kill-session -t "=$SESSION" \
            2>/dev/null || true
    fi

else
    echo "Unknown action: $action" >&2
    exit 2
fi

