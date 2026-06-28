FROM alpine

# 安装运行时依赖
RUN apk add --no-cache bash tini \
    libuv \
    json-c \
    libwebsockets \
    zlib \
    openssl

# 下载官方预编译二进制
RUN wget https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.x86_64 -O /usr/bin/ttyd && \
    chmod +x /usr/bin/ttyd

EXPOSE 7681
WORKDIR /root
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["ttyd", "-W", "--port", "7681", "--interface", "0.0.0.0", "bash"]
