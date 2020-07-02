FROM java:8-jre
LABEL maintainer="zdd1995@mail.ustc.edu.cn"
LABEL Description="mycat image"
ENV mycat-version Mycat-server-1.6.7.4-release-20200105164103-linux.tar.gz
USER root
RUN curl -SL https://github.com/MyCATApache/Mycat-Server/releases/download/Mycat-server-1.6.7.4-release/Mycat-server-1.6.7.4-release-20200105164103-linux.tar.gz | tar -zxC /
ENV MYCAT_HOME=/mycat
ENV PATH=$PATH:$MYCAT_HOME/bin
WORKDIR $MYCAT_HOME/bin
RUN chmod u+x ./mycat
EXPOSE 8066 9066
CMD ["./mycat","console"]