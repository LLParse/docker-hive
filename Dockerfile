FROM llparse/hadoop-base:2.0.0-hadoop3.3.1-java8

MAINTAINER Yiannis Mouchakis <gmouchakis@iit.demokritos.gr>
MAINTAINER Ivan Ermilov <ivan.s.ermilov@gmail.com>

# Allow buildtime config of HIVE_VERSION
ARG HIVE_VERSION
# Set HIVE_VERSION from arg if provided at build, env if provided at run, or default
# https://docs.docker.com/engine/reference/builder/#using-arg-variables
# https://docs.docker.com/engine/reference/builder/#environment-replacement
ENV HIVE_VERSION=${HIVE_VERSION:-2.3.8}

ARG JDBC_VERSION
ENV JDBC_VERSION=${JDBC_VERSION:-42.3.2}

ENV HIVE_HOME /opt/hive
ENV PATH $HIVE_HOME/bin:$PATH
ENV HADOOP_HOME /opt/hadoop-$HADOOP_VERSION

WORKDIR /opt

#Install Hive and PostgreSQL JDBC
RUN apt-get update && apt-get install -y wget procps && \
	wget https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz && \
	tar -xzvf apache-hive-${HIVE_VERSION}-bin.tar.gz && \
	mv apache-hive-${HIVE_VERSION}-bin hive && \
	wget https://jdbc.postgresql.org/download/postgresql-${JDBC_VERSION}.jar -O $HIVE_HOME/lib/postgresql-${JDBC_VERSION}.jar && \
	rm -f ${HIVE_HOME}/lib/postgresql-*.jre7.jar && \
	rm apache-hive-${HIVE_VERSION}-bin.tar.gz && \
	apt-get --purge remove -y wget && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

#Spark should be compiled with Hive to be able to use it
#hive-site.xml should be copied to $SPARK_HOME/conf folder

#Custom configuration goes here
ADD conf/ $HIVE_HOME/conf

COPY startup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/startup.sh

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 10000
EXPOSE 10002

ENTRYPOINT ["entrypoint.sh"]
CMD startup.sh
