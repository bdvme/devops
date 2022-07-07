FROM centos:7

ADD https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.3.1-linux-x86_64.tar.gz /
ADD curl https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.3.1-linux-x86_64.tar.gz.sha512 /

RUN yum update -y && \
    yum install perl-Digest-SHA -y && \
    shasum -a 512 -c elasticsearch-8.3.1-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.3.1-linux-x86_64.tar.gz && \
    cd elasticsearch-8.3.1/ && \ && \
    useradd elasticuser && \
    chown -R elasticuser:elasticuser /elasticsearch-8.3.1/ && \
    rm -fr /elasticsearch-8.3.1-linux-x86_64.tar.gz.sha512 /elasticsearch-8.3.1-linux-x86_64.tar.gz

RUN mkdir /var/lib/{data,logs} && \
    chown -R elasticuser:elasticuser /var/lib/data && \
    chown -R elasticuser:elasticuser /var/lib/logs

WORKDIR /elasticsearch-8.3.1
RUN mkdir snapshots && \
    chown -R elasticuser:elasticuser snapshots

ADD elasticsearch.yml /elasticsearch-8.3.1/config/
RUN chown -R elasticuser:elasticuser /elasticsearch-8.3.1/config

USER elasticuser

EXPOSE 9200 9300

CMD ["./bin/elasticsearch", "-Ecluster.name=my_cluster", "-Enode.name=my_test"]
