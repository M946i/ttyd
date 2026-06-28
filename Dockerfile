FROM alpine AS builder

RUN apk add --no-cache \
    build-base cmake autoconf automake libtool git \
    libuv-dev json-c-dev zlib-dev libwebsockets-dev openssl-dev

WORKDIR /src
COPY . .

RUN mkdir build && cd build && \
    cmake .. -DCMAKE_BUILD_TYPE=Release && \
    make -j$(nproc) && \
    strip ttyd

# 最终镜像
FROM alpine

# 必须包含所有运行时库
RUN apk add --no-cache \
    bash tini \
    libuv \
    json-c \
    libwebsockets \
    zlib \
    openssl \
    libgcc   # 防止 musl 相关问题

COPY --from=builder /src/build/ttyd /usr/bin/ttyd
RUN chmod +x /usr/bin/ttyd

EXPOSE 7681
WORKDIR /root
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["ttyd", "-W", "--port", "7681", "--interface", "0.0.0.0", "bash"]
