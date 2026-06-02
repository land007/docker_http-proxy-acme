# Base image is overridable so CI can build on a specific freshly-pushed base version
ARG BASE_IMAGE=land007/http-proxy:latest
FROM ${BASE_IMAGE}

MAINTAINER Jia Yiqiu <yiqiujia@hotmail.com>

RUN echo $(date "+%Y-%m-%d_%H:%M:%S") >> /.image_times && \
	echo $(date "+%Y-%m-%d_%H:%M:%S") > /.image_time && \
	echo "land007/http-proxy-acme" >> /.image_names && \
	echo "land007/http-proxy-acme" > /.image_name

RUN apt-get --allow-releaseinfo-change update && apt-get install -y cron rsync
#RUN apt-get install -y initscripts
##https://github.com/acmesh-official/acme.sh
#RUN cd / && curl https://gitcode.net/cert/cn-acme.sh/-/raw/master/install.sh?inline=false | sh -s email=land_007@163.com
RUN cd / && curl https://get.acme.sh | sh -s email=land_007@163.com

ENV DOMAIN_NAME=wrt.qhkly.com
ENV ACME_URL https://acme.freessl.cn/v2/DV90/directory/ICOAy3RLUDtrGPT
#RUN echo 'acme.sh --issue -d ${DOMAIN_NAME} \
#--key-file /node/cert/${DOMAIN_NAME}_key.key \
#--fullchain-file /node/cert/${DOMAIN_NAME}_chain.crt \
#--reloadcmd "service nginx force-reload" \
#--dns dns_dp --server ${ACME_URL}' >> /task.sh
RUN echo 'service cron start' >> /task.sh

RUN echo 'mkdir -p /node_/cert /node_/backups' >> /task.sh
RUN echo '[ -n "${DOMAIN_NAME}" ] && [ -f "/root/.acme.sh/${DOMAIN_NAME}/${DOMAIN_NAME}.key" ] && /root/.acme.sh/acme.sh --install-cert -d ${DOMAIN_NAME} --key-file /node_/cert/${DOMAIN_NAME}_key.key --fullchain-file /node_/cert/${DOMAIN_NAME}_chain.crt || true' >> /task.sh
# proxy 与 admin-api 都从 /node_ 跑（沿用 base 的 start-simple.sh），
# 让 supervisor 同时监视证书/密钥变化，ACME 网页签发后自动重载
RUN sed -i 's#supervisor -w /node_/ -i node_modules#supervisor -w /node_/ -i node_modules -e node,js,key,crt#' /node_/start-simple.sh
#crontab -l
#service cron status

VOLUME ["/root/.acme.sh", "/node_/cert", "/node_/backups"]

# 先跑 ACME 任务(cron + 已有证书安装)，再以 /node_ 为根启动 admin-api + proxy
CMD ["/bin/bash", "-c", "bash /task.sh && /node_/start-simple.sh"]

#cp /root/.acme.sh/docx.qhkly.com/docx.qhkly.com.cer /node/cert/docx.qhkly.com_chain.crt
#cp /root/.acme.sh/docx.qhkly.com/docx.qhkly.com.key /node/cert/docx.qhkly.com_key.key
#/root/.acme.sh/acme.sh --install-cert -d docx.qhkly.com --key-file /node/cert/docx.qhkly.com_key.key --fullchain-file /node/cert/docx.qhkly.com_chain.crt

#docker build -t land007/http-proxy-acme:latest .
#> docker buildx build --platform linux/amd64,linux/arm64/v8,linux/arm/v7 -t land007/http-proxy-acme:new --push .
