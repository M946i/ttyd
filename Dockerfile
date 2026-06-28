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

RUN apk add --no-cache bash tini

COPY --from=builder /src/build/ttyd /usr/bin/ttyd
RUN chmod +x /usr/bin/ttyd

EXPOSE 7681
WORKDIR /root
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["ttyd", "-W", "bash"]
