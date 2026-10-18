
#!/bin/bash
set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}

mkdir -p "$output"

# 设置独立的安装根目录
sysroot="$output/sysroot"

# 初始化本地 dpkg 数据库
mkdir -p "$sysroot/var/lib/dpkg"
touch "$sysroot/var/lib/dpkg/status"

# 无需 root 权限，将本地 Debian 包安装到 sysroot
dpkg --force-not-root \
    --log=/dev/null \
    --root="$sysroot" \
    --install "$input/aim-sentry-tools.deb" >/dev/null

# 运行真正安装后的程序
"$sysroot/usr/bin/aim-sentry-info" > "$output/tool-output.txt"
