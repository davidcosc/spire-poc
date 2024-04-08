
FROM golang

RUN apt update && apt upgrade -y && apt install git && apt install make && apt install wget
RUN git clone https://github.com/boxboat/spire-tpm-plugin.git
RUN cd spire-tpm-plugin && make build && cd ..
RUN wget https://github.com/spiffe/spire/releases/download/v1.9.4/spire-1.9.4-linux-amd64-musl.tar.gz && tar zvxf spire-1.9.4-linux-amd64-musl.tar.gz && cp -r spire-1.9.4/. /opt/spire/ && ln -s /opt/spire/bin/spire-server /usr/bin/spire-server && ln -s /opt/spire/bin/spire-agent /usr/bin/spire-agent
RUN mkdir -p /opt/spire/data/server && mkdir -p /opt/spire/data/agent && mkdir -p /opt/spire/data/plugin
RUN cp /go/spire-tpm-plugin/build/linux/amd64/* /opt/spire/data/plugin
RUN ls -lah /opt/spire/bin && ls -lah /opt/spire/data && ls -lah /opt/spire/data/plugin
