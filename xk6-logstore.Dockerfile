# 使用 Go 官方镜像作为构建环境
FROM --platform=linux/amd64 golang:1.21.5 as build-env

# 设置 GOPROXY 环境变量
ENV GOPROXY=https://goproxy.cn,direct
ENV GOOS=linux

# 设置工作目录
WORKDIR /src

# 拷贝本地代码到容器中
COPY . /src

# 安装 xk6
RUN go install go.k6.io/xk6/cmd/xk6@latest

# 使用 Makefile 构建自定义的 k6 二进制文件
RUN make k6

# 使用 alpine 镜像作为最终运行环境
FROM alpine:latest

# 在容器中创建一个目录来存放 k6 测试脚本
WORKDIR /tests

# 从构建环境中复制生成的 k6 二进制文件
COPY --from=build-env /src/k6 /tests/k6

# 复制测试脚本到容器中
COPY --from=build-env /src/tests /tests

# 设置环境变量，确保在运行时 k6 可以找到测试脚本
ENV PATH="/tests:${PATH}"

# 容器启动时执行 k6 测试
CMD ["./k6", "run", "simple.js"]
