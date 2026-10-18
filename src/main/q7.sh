
#!/bin/bash
set -eu

input=${1:?需要输入目录}
output=${2:?需要输出目录}

mkdir -p "$output/received"

# 读取测试器提供的远程连接参数
source "$input/remote.env"

# 创建 SSH 客户端配置
cat > "$output/ssh_config" <<EOF
Host aim-sentry
    HostName $HOST
    Port $PORT
    User $REMOTE_USER
    IdentityFile "$KEY_PATH"
    UserKnownHostsFile "$KNOWN_HOSTS"
    StrictHostKeyChecking yes
    IdentitiesOnly yes
    BatchMode yes
    ConnectTimeout 4
EOF

chmod 600 "$output/ssh_config"

# 通过 SSH 执行远程命令
ssh -F "$output/ssh_config" aim-sentry whoami \
    > "$output/remote-user.txt"

# 使用 SCP 下载远程日志
scp -q -F "$output/ssh_config" \
    "aim-sentry:$REMOTE_LOG" \
    "$output/received/errors.log"
