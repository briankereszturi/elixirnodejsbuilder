FROM node:6.10.3

ENV CACHE_BUST 2
ENV CLOUDSDK_PYTHON_SITEPACKAGES 1
ENV ERLANG_VERSION 19.3
ENV ELIXIR_VERSION 1.4.1
ENV HELM_VERSION v2.4.1
ENV PATH $PATH:/opt/elixir-${ELIXIR_VERSION}/bin
ENV PATH "/google-cloud-sdk/bin:$PATH"

# Install deps 
RUN \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  unzip \
  wget \
  ca-certificates \
  gcc \
  make \
  libc-dev \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/*

# Install erlang
RUN \
	apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
  libwxbase3.0-0 \
  libwxgtk3.0-0 \
  libsctp1 \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/*

RUN \
  wget --no-check-certificate -O erlang.deb https://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_${ERLANG_VERSION}-1~debian~jessie_amd64.deb \
  && dpkg -i erlang.deb \
  && rm erlang.deb

# Install elixir
RUN \
  wget --no-check-certificate https://github.com/elixir-lang/elixir/releases/download/v${ELIXIR_VERSION}/Precompiled.zip \
  && mkdir -p /opt/elixir-${ELIXIR_VERSION}/ \
  && unzip Precompiled.zip -d /opt/elixir-${ELIXIR_VERSION}/ \
  && rm Precompiled.zip

RUN mix local.hex --force && mix local.rebar --force

# Add docker repo
RUN \
	apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		apt-transport-https \
		curl \
		software-properties-common \
	&& curl -fsSL https://apt.dockerproject.org/gpg | apt-key add - \
	&& add-apt-repository "deb https://apt.dockerproject.org/repo/ debian-$(lsb_release -cs) main" \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/*

RUN \
	apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		docker-engine \
		openssh-client \
		python \
		python-openssl \
    socat \
    openssl \
	&& apt-get clean -y \
	&& rm -rf /var/lib/apt/lists/*

RUN \
	mkdir -p "${HOME}/.ssh" \
	&& curl -L -o google-cloud-sdk.zip https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.zip \
	&& unzip google-cloud-sdk.zip \
	&& rm google-cloud-sdk.zip \
	&& google-cloud-sdk/install.sh \
		--usage-reporting=true \
		--path-update=true \
		--bash-completion=true \
		--rc-path=/.bashrc \
		--disable-installation-options \
	&& gcloud --quiet components update \
		alpha \
		app \
		beta \
		kubectl \
		pkg-go \
		pkg-java \
		pkg-python \
		preview \
	&& gcloud --quiet config set component_manager/disable_update_check true

# Install Helm
RUN \
  wget --no-check-certificate -O /tmp/helm.tgz https://kubernetes-helm.storage.googleapis.com/helm-${HELM_VERSION}-linux-amd64.tar.gz \
  && tar -zxvf /tmp/helm.tgz -C /tmp \
  && mv /tmp/linux-amd64/helm /bin/helm \
  && rm -rf /tmp

COPY scripts/ /usr/bin/

WORKDIR /data

CMD ["/bin/bash"]
