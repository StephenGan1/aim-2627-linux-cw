
#!/bin/bash
set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}

mkdir -p "$output"

# 合并启动日志与运行日志
cat "$input/boot.log" "$input/run.log" > "$output/all.log"

# 只提取级别字段为 ERROR 的行
grep '^ERROR ' "$output/all.log" > "$output/errors.log" || true

# 提取 ERROR 和 WARN 行
grep -E '^(ERROR|WARN) ' "$output/all.log" > "$output/attention.log" || true

# 提取最后五行
tail -n 5 "$output/all.log" > "$output/recent.log"

# 提取前三条 ERROR
head -n 3 "$output/errors.log" > "$output/first-errors.log"

# 统计 ERROR 数量
awk 'END {print NR}' "$output/errors.log" > "$output/error-count.txt"

