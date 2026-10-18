
#!/bin/bash
set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}

mkdir -p "$output"

# 读取测试环境提供的参数
source "$input/launch.env"

# 分别捕获标准输出、错误输出及真实退出码
if bash "$LAUNCH_TOOL" "$MODEL_PATH" "$CAMERA_PATH" \
    > "$output/stdout.log" 2> "$output/stderr.log"; then
    exit_code=0
else
    exit_code=$?
fi

printf '%s\n' "$exit_code" > "$output/exit-code.txt"

# 根据退出码判断故障
case "$exit_code" in
    0)
        result="SUCCESS"
        reason="NONE"
        ;;
    10)
        result="FAILED"
        reason="MODEL_MISSING"
        ;;
    20)
        result="FAILED"
        reason="CAMERA_DENIED"
        ;;
    *)
        result="FAILED"
        reason="UNKNOWN"
        ;;
esac

# 生成诊断报告
printf 'result=%s\nexit_code=%s\nreason=%s\n' \
    "$result" "$exit_code" "$reason" > "$output/report.txt"
