FROM python:3.12-alpine AS ansible
ARG ANSIBLE_VERSION=10.0
RUN apk -U upgrade --available &&\
    apk add --virtual=build --no-cache --update gcc musl-dev libffi-dev openssl-dev &&\
    apk add --no-cache openssh-client ca-certificates bash coreutils &&\
    pip install --no-cache-dir --upgrade pip &&\
    pip install --no-cache-dir ansible==${ANSIBLE_VERSION}.* ansible-runner~=2.4 &&\
    apk del build &&\
    rm -rf /var/cache/apk/*

ENV SHELL=/bin/bash
ENV HOME=/ansible
RUN mkdir -p /ansible && chown 1983:1983 /ansible

# Set bash as default shell
SHELL ["/bin/bash", "-c"]

FROM ansible AS base
USER root
CMD ["/bin/bash"]

FROM ansible AS gcp
RUN pip install --no-cache-dir requests==2.* google-auth==2.*
USER 1983
CMD ["/bin/bash"]

FROM ansible AS aws
RUN pip install --no-cache-dir boto3==1.*
USER 1983
CMD ["/bin/bash"]

FROM ansible AS azure
RUN apk add --virtual=build --no-cache gcc musl-dev linux-headers &&\
    pip install --no-cache-dir azure-cli==2.* &&\
    apk del build &&\
    rm -rf /var/cache/apk/*
USER root
CMD ["/bin/bash"]
