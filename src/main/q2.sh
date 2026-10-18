
#!/bin/bash
set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}

ws="$output/sentry_ws"

# 创建四个子目录
mkdir -p "$ws/scripts" "$ws/config" "$ws/logs" "$ws/tmp"

# 创建两个空文件
: > "$ws/logs/.keep"
: > "$ws/tmp/scratch.txt"

# 创建启动脚本
printf '#!/bin/bash\necho "Hello, AIM Linux!"\n' > "$ws/scripts/hello.sh"

# 创建配置文件
printf 'robot=sentry\nmode=training\nlog_level=INFO\n' > "$ws/config/robot.conf"

