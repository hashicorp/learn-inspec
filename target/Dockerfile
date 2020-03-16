FROM hashicorp/terraform:latest as terraform
FROM hashicorp/packer:latest as packer
FROM consul as consul
FROM djenriquez/nomad as nomad
FROM vault:latest as vault
COPY --from=terraform / /
COPY --from=packer / /
COPY --from=consul / /
COPY --from=nomad / /

COPY . /
RUN apk add --no-cache bash

ENTRYPOINT ["tail", "-f", "/dev/null"]
