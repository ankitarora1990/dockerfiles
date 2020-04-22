FROM golang:1.14-buster

ARG BUILD_TERRAFORM_VERSION="0.12.23"
ARG BUILD_AZURECLI_VERSION="2.2.*"

ENV TERRAFORM_VERSION=${BUILD_TERRAFORM_VERSION}

RUN set -ex && apt-get update && apt-get install --no-install-recommends -y unzip=6.0* \
	ca-certificates=20190110 \
	curl=7.64.* \
	apt-transport-https=1.8.2 \
	lsb-release=10.* \
	gnupg=2.2.* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN set -ex \
  && curl -OLs "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && unzip "terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -d /usr/local/bin \
  && rm -f "terraform_${TERRAFORM_VERSION}_linux_amd64.zip"

ENV PATH /usr/local/go/bin:$GOPATH/bin:$PATH

# Setup up golang build cache directory
RUN mkdir /.cache && chmod a+rw /.cache

# Install Azure Cli
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null \
  && AZ_REPO=$(lsb_release -cs) \
  && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list	

RUN set -ex && apt-get update && apt-get install --no-install-recommends -y azure-cli=${BUILD_AZURECLI_VERSION} \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*
