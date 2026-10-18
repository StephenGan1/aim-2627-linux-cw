
#!/bin/bash
set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}

ws="$output/sentry_ws"

# 创建所需目录
mkdir -p "$ws/scripts" "$ws/config" "$ws/backup" "$ws/archive"

# 复制脚本和配置文件
cp "$input/hello.sh" "$ws/scripts/hello.sh"
cp "$input/robot.conf" "$ws/config/robot.conf"
cp "$input/robot.conf" "$ws/backup/robot.conf"

# 移动并重命名草稿配置
cp "$input/draft.conf" "$ws/config/draft.conf"
mv -f "$ws/config/draft.conf" "$ws/archive/draft.conf.old"

# 删除临时缓存目录
rm -rf "$ws/tmp"

# 设置精确文件权限
chmod 750 "$ws/scripts/hello.sh"
chmod 640 "$ws/config/robot.conf"

# 直接执行启动脚本，保存输出
"$ws/scripts/hello.sh" > "$output/hello-output.txt"
