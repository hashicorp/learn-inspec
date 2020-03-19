IMAGE_NAME="inspec-target"
DOCKER_USERNAME=acidprime

define GetImageID
  `docker images --filter=reference=$(1) --format "{{.ID}}"`
endef

build:
	@echo "==> Building Docker image..."
	@docker login -u $(DOCKER_USERNAME)
	@docker build \
	 --rm \
	 -t \
	 $(IMAGE_NAME) \
	 .
	@docker tag $(call GetImageID,$(IMAGE_NAME)) \
	  $(DOCKER_USERNAME)/$(IMAGE_NAME):latest
	@docker push \
	        $(DOCKER_USERNAME)/$(IMAGE_NAME):latest

.DEFAULT_GOAL := build

.PHONY: build
