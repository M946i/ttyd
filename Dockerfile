FROM alpine AS builder

RUN apk add --no-cache \
    build-base cmake autoconf automake libtool git \
    libuv-dev json-c-dev zlib-dev libwebsockets-dev openssl-dev

WORKDIR /src
COPY . .

# 静态链接构建
RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release \
             -DCMAKE_EXE_LINKER_FLAGS="-static" && \
    make -j$(nproc) && \
    strip ttyd

# 最终极简镜像
FROM alpine

RUN apk add --no-cache bash tini

COPY --from=builder /src/build/ttyd /usr/bin/ttyd
RUN chmod +x /usr/bin/ttyd

EXPOSE 7681
WORKDIR /root
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["ttyd", "-W", "--port", "7681", "--interface", "0.0.0.0", "bash"]
