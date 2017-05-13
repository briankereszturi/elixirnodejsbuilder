FROM node:6.10.3-alpine

ENV REFRESHED_AT 2017-05-13
ENV ELIXIR_VERSION 1.4.1
ENV PATH $PATH:/opt/elixir-${ELIXIR_VERSION}/bin

RUN apk --update upgrade
RUN apk --no-cache add --virtual build-dependencies erlang wget ca-certificates && \
    wget --no-check-certificate https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip && \
    mkdir -p /opt/elixir-${ELIXIR_VERSION}/ && \
    unzip Precompiled.zip -d /opt/elixir-${ELIXIR_VERSION}/ && \
    rm Precompiled.zip && \
    apk del build-dependencies && \
    rm -rf /etc/ssl

RUN apk --no-cache add erlang-crypto erlang-syntax-tools erlang-parsetools erlang-inets erlang-ssl \
    erlang-public-key erlang-eunit erlang-asn1 erlang-sasl erlang-erl-interface erlang-dev erlang-xmerl docker
RUN rm -rf /var/cache/apk/*

RUN mix local.hex --force && mix local.rebar --force

WORKDIR /data

CMD ["/bin/sh"]
