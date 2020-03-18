IMAGE_NAME="inspec-target"

define GetImageID
  `docker images --filter=reference=$(1) --format "{{.ID}}"`
endef

build:
	@echo "==> Building Docker image..."
	@echo $(GITHUB_TOKEN) | \
		docker login docker.pkg.github.com -u acidprime --password-stdin
	@docker build \
        --rm \
        -t \
        $(IMAGE_NAME) \
        .
	@docker tag $(call GetImageID,$(IMAGE_NAME)) \
         docker.pkg.github.com/hashicorp/learn-inspec/$(IMAGE_NAME):latest
	@docker push \
		docker.pkg.github.com/hashicorp/learn-inspec/$(IMAGE_NAME):latest

.DEFAULT_GOAL := build 

.PHONY: build
