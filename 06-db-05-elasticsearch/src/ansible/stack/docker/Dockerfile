FROM centos:7

COPY elasticsearch-8.3.2-linux-x86_64.tar.gz .
COPY elasticsearch-8.3.2-linux-x86_64.tar.gz.sha512 .

RUN yum update -y && \
    yum install perl-Digest-SHA -y && \
    shasum -a 512 -c elasticsearch-8.3.2-linux-x86_64.tar.gz.sha512 && \
    tar -xzf elasticsearch-8.3.2-linux-x86_64.tar.gz && \
    cd elasticsearch-8.3.2/ && \
    useradd elasticuser && \
    chown -R elasticuser:elasticuser /elasticsearch-8.3.2/ && \
    rm -fr /elasticsearch-8.3.2-linux-x86_64.tar.gz.sha512 /elasticsearch-8.3.2-linux-x86_64.tar.gz

RUN mkdir /var/lib/{data,logs} && \
    chown -R elasticuser:elasticuser /var/lib/data && \
    chown -R elasticuser:elasticuser /var/lib/logs

WORKDIR /elasticsearch-8.3.2
RUN mkdir snapshots && \
    chown -R elasticuser:elasticuser snapshots

ADD elasticsearch.yml /elasticsearch-8.3.2/config/
RUN chown -R elasticuser:elasticuser /elasticsearch-8.3.2/config

USER elasticuser

EXPOSE 9200 9300

CMD ["./bin/elasticsearch", "-Ecluster.name=netology_cluster", "-Enode.name=netology_test"]
