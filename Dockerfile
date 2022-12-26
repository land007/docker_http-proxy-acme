FROM land007/http-proxy:latest

MAINTAINER Jia Yiqiu <yiqiujia@hotmail.com>

RUN echo $(date "+%Y-%m-%d_%H:%M:%S") >> /.image_times && \
	echo $(date "+%Y-%m-%d_%H:%M:%S") > /.image_time && \
	echo "land007/http-proxy-acme" >> /.image_names && \
	echo "land007/http-proxy-acme" > /.image_name

RUN apt-get --allow-releaseinfo-change update && apt-get install -y cron
#RUN apt-get install -y initscripts
#RUN curl https://get.acme.sh | sh -s email=land_007@163.com
RUN cd / && curl https://gitcode.net/cert/cn-acme.sh/-/raw/master/install.sh?inline=false | sh -s email=land_007@163.com

ENV DOMAIN_NAME=wrt.qhkly.com
ENV ACME_URL https://acme.freessl.cn/v2/DV90/directory/ICOAy3RLUDtrGPT
#RUN echo 'acme.sh --issue -d ${DOMAIN_NAME} \
#--key-file /node/cert/${DOMAIN_NAME}_key.key \
#--fullchain-file /node/cert/${DOMAIN_NAME}_chain.crt \
#--reloadcmd "service nginx force-reload" \
#--dns dns_dp --server ${ACME_URL}' >> /task.sh
RUN echo 'service cron start' >> /task.sh
RUN echo '/root/.acme.sh/acme.sh --issue -d ${DOMAIN_NAME} --key-file /node/cert/${DOMAIN_NAME}_key.key --fullchain-file /node/cert/${DOMAIN_NAME}_chain.crt --dns dns_dp --server ${ACME_URL} || true' >> /task.sh
RUN sed -i 's/node_modules/node_modules -e node,js,key,crt/g' /node_/start.sh
#crontab -l
#service cron status

CMD /check.sh /node && /task.sh && /node/start.sh

#docker build -t land007/http-proxy-acme:latest .
#> docker buildx build --platform linux/amd64,linux/arm64/v8,linux/arm/v7 -t land007/http-proxy-acme --push .
