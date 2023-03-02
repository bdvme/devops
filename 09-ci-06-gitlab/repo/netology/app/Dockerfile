FROM centos:7

RUN yum install gcc openssl-devel bzip2-devel libffi-devel zlib-devel xz-devel wget make -y
RUN cd /usr/src && \  
    wget https://www.python.org/ftp/python/3.7.11/Python-3.7.11.tgz && \
    tar xzf Python-3.7.11.tgz && \
    cd Python-3.7.11 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    rm /usr/src/Python-3.7.11.tgz && \
    ln -sfn /usr/local/bin/python3.7 /usr/bin/python3.7 && \
    ln -sfn /usr/local/bin/pip3.7 /usr/bin/pip3.7 && \
    python3.7 -m pip install --upgrade pip

COPY ./requirements.txt /python_api/requirements.txt
WORKDIR /python_api
RUN pip3.7 install -r requirements.txt
COPY python-api.py python-api.py
CMD ["python3.7", "python-api.py"]