# This make file builds and pushes the container
# The Github Action uses the container not the Dockerfile 
# to increase the speed of running the tests.
IMAGE_NAME="inspec"
DOCKER_USERNAME=acidprime

define GetImageID
  `docker images --filter=reference=$(1) --format "{{.ID}}"`
endef

build:
	@echo "==> Building Docker image..."
	@docker build \
	 --rm \
	 -t \
	 $(IMAGE_NAME) \
	 .
push:
	@docker login -u $(DOCKER_USERNAME)
	@docker tag $(call GetImageID,$(IMAGE_NAME)) \
	  $(DOCKER_USERNAME)/$(IMAGE_NAME):latest
	@docker push \
	        $(DOCKER_USERNAME)/$(IMAGE_NAME):latest

.DEFAULT_GOAL := build

.PHONY: build push
