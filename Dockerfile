# Base lambda image
FROM public.ecr.aws/lambda/nodejs:latest

USER root
RUN mkdir -p /opt
WORKDIR /tmp

#
# Tools
#

RUN yum update -y \
    && yum install -y zip

#
# Copy the handler code
#
RUN mkdir -p /opt/handler
COPY /handler /opt/handler

#
# Install `http-proxy-agent` using NPM
#
RUN cd /opt/handler && npm install

#
# Create the bundle
#

RUN cd /opt/handler \
    && zip --symlinks -r ../../handler.zip * \
    && echo "/handler.zip is ready" \
    && ls -alh ../../handler.zip;

WORKDIR /
ENTRYPOINT [ "/bin/bash" ]
