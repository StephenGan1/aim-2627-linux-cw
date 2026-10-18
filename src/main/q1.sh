#!/bin/bash
set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}

# 创建输出目录
mkdir -p "$output"

# 找到 handover 的真实绝对路径
cd "$input/handover"
pwd -P > "$output/location.txt"

# 读取隐藏的机器人编号
cat "$input/handover/.robot-id" > "$output/robot-id.txt"

# 读取欢迎文本
cat "$input/notes/welcome.txt" > "$output/welcome.txt"
