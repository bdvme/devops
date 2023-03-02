FROM centos:7

RUN yum install python3 python3-pip -y
COPY ./requirements.txt /python_api/requirements.txt
WORKDIR /python_api
RUN pip3 install -r requirements.txt
COPY python-api.py python-api.py
CMD ["python3", "python-api.py"]