# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

FROM docker.mirror.hashicorp.services/hashicorp/terraform as terraform
FROM docker.mirror.hashicorp.services/hashicorp/packer as packer
FROM docker.mirror.hashicorp.services/consul as consul
FROM docker.mirror.hashicorp.services/djenriquez/nomad as nomad
FROM docker.mirror.hashicorp.services/vault:latest as vault
COPY --from=terraform / /
COPY --from=packer / /
COPY --from=consul / /
COPY --from=nomad / /

COPY . /
RUN apk add --no-cache bash
RUN apk add --no-cache go 
RUN apk add --no-cache libc-dev
RUN go get -u github.com/fatih/hclfmt 

ENV PATH="/root/go/bin:$PATH"

ENTRYPOINT ["tail", "-f", "/dev/null"]
