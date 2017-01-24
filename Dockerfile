FROM ubuntu:16.04

ARG TELEPORT_COMMIT_SHA256

# gcc for cgo + curl and zip to fetch and bundle releases
RUN apt-get update && apt-get install -y --no-install-recommends \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
    zip \
    curl \
    ca-certificates \
    git \
	&& rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.7.4
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA256 47fda42e46b4c3ec93fa5d4d4cc6a748aa3f9411a2a2b7e08e3a6d80d753ec8b

RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
	&& echo "$GOLANG_DOWNLOAD_SHA256  golang.tar.gz" | sha256sum -c - \
	&& tar -C /tmp -xzf golang.tar.gz \
	&& rm golang.tar.gz

RUN export GOPATH=/tmp/gopath \
  && export GOROOT=/tmp/go \
  && export PATH=/tmp/go/bin:$PATH \
  && mkdir "${GOPATH}" \
  && mkdir -p "${GOPATH}/src/github.com/gravitational" \
  && cd "${GOPATH}/src/github.com/gravitational" \
  && git clone https://github.com/gravitational/teleport.git \
  && cd teleport \
  && git checkout "${TELEPORT_COMMIT_SHA256}" \
  && make release \
  && tar -C /tmp -xzf teleport*.tar.gz \
  && cd /tmp/teleport \
  && make install \
  && rm -rf /tmp/*

RUN apt-get -y --auto-remove purge \
		g++ \
		gcc \
		libc6-dev \
		make \
		pkg-config \
    zip \
    curl \
    git \
  && apt-get -y autoremove \
	&& rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /usr/local/bin/

EXPOSE 3022 3023 3024 3025 3080
VOLUME /var/lib/teleport
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

