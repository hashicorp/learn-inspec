IMAGE_NAME="inspec"
DOCKER_USERNAME=hashieducation
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

define GetImageID
  `docker images --filter=reference=$(1) --format "{{.ID}}"`
endef


build:
	@echo "==> Building Docker image..."
	@docker build \
	 --rm \
	 -t \
	 $(IMAGE_NAME):$(BRANCH) \
	 .
push:
	# open onepassword://search/ej6uodvxxvcetihbgwdy2wnoh4
	# export DOCKER_API_TOKEN=<the API Token field>
	@echo $(DOCKER_API_TOKEN) | \
		docker login --username $(DOCKER_USERNAME) --password-stdin
	@docker tag $(call GetImageID,$(IMAGE_NAME):$(BRANCH)) \
	  $(DOCKER_USERNAME)/$(IMAGE_NAME):$(BRANCH)
	@docker push \
	        $(DOCKER_USERNAME)/$(IMAGE_NAME):$(BRANCH)

.DEFAULT_GOAL := build

.PHONY: build push
