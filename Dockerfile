# 使用单阶段构建，因为我们已经有了本地的k6二进制文件

# 基础镜像
FROM alpine:latest

# 安装必要的依赖
RUN apk add --no-cache ca-certificates

# 复制本地的k6 tar文件到镜像中
COPY k6-v0.49.0-linux-amd64.tar.gz /tmp/k6.tar.gz

# 解压k6 tar文件，并将k6二进制文件移动到/usr/bin
RUN tar -xzf /tmp/k6.tar.gz -C /tmp \
    && mv /tmp/k6-v0.49.0-linux-amd64/k6 /usr/bin/k6 \
    && rm -rf /tmp/k6-v0.49.0-linux-amd64 /tmp/k6.tar.gz

# 验证k6安装
RUN k6 version

# 将你的测试脚本复制到镜像中
COPY tests/simple.js /logstore-loggen-simple.js

# 为你的镜像设置默认的运行命令
ENTRYPOINT ["k6", "run", "/logstore-loggen-simple.js"]
