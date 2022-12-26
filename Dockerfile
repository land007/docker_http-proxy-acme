FROM land007/http-proxy:latest

MAINTAINER Jia Yiqiu <yiqiujia@hotmail.com>

RUN echo $(date "+%Y-%m-%d_%H:%M:%S") >> /.image_times && \
	echo $(date "+%Y-%m-%d_%H:%M:%S") > /.image_time && \
	echo "land007/http-proxy-acme" >> /.image_names && \
	echo "land007/http-proxy-acme" > /.image_name

RUN apt-get --allow-releaseinfo-change update && apt-get install -y cron
#RUN curl https://get.acme.sh | sh -s email=land_007@163.com
RUN cd / && curl https://gitcode.net/cert/cn-acme.sh/-/raw/master/install.sh?inline=false | sh -s email=land_007@163.com

ENV ACME_URL https://acme.freessl.cn/v2/DV90/directory/ICOAy3RLUDtrGPT
RUN echo "acme.sh --issue -d ${DOMAIN_NAME} --key-file /node/cert/${DOMAIN_NAME}_key.key --fullchain-file /node/cert/${DOMAIN_NAME}_chain.crt --dns dns_dp --server ${ACME_URL}" >> /task.sh

CMD /check.sh /node && /node/start.sh

#docker build -t land007/http-proxy-acme:latest .
#> docker buildx build --platform linux/amd64,linux/arm64/v8,linux/arm/v7 -t land007/http-proxy-acme --push .
