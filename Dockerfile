# 指定 n8n 版本，和你想用的 n8n 版本保持一致
ARG VERSION=1.123.4

############### 第 1 阶段：下载并解压中文前端 ################
FROM alpine:3.20 AS builder

ARG VERSION

# 安装 curl 和 tar，用来下载并解压汉化包
RUN apk add --no-cache curl tar \
  && mkdir -p /editor-ui-dist \
  && curl -L "https://github.com/other-blowsnow/n8n-i18n-chinese/releases/download/n8n%40${VERSION}/editor-ui.tar.gz" \
       -o /tmp/editor-ui.tar.gz \
  && tar -xzf /tmp/editor-ui.tar.gz -C /editor-ui-dist

############### 第 2 阶段：正式的 n8n 容器 ################
FROM n8nio/n8n:${VERSION}

# 提权成 root，才有权限覆盖 node_modules 里的文件
USER root

# 默认语言改成中文
ENV N8N_DEFAULT_LOCALE=zh-CN

# 关键的一句：把上一阶段准备好的中文前端，拷贝进 n8n 镜像里
COPY --from=builder /editor-ui-dist /usr/local/lib/node_modules/n8n/node_modules/n8n-editor-ui/dist

# 还原成官方的 node 用户运行，比较安全
USER node
