FROM python:3.7.9-stretch

WORKDIR /home

RUN apt-get update && apt-get install -y python3-pip

RUN pip3 install jupyter apache-beam[interactive] pandas

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--allow-root"]