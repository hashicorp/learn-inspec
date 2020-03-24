IMAGE_NAME="inspec-target"
DOCKER_USERNAME=hashieducation

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
	# open onepassword://search/ej6uodvxxvcetihbgwdy2wnoh4
	# export DOCKER_API_TOKEN=<the API Token field>
	@echo $(DOCKER_API_TOKEN) | \
		docker login --username $(DOCKER_USERNAME) --password-stdin
	@docker tag $(call GetImageID,$(IMAGE_NAME)) \
	  $(DOCKER_USERNAME)/$(IMAGE_NAME):latest
	@docker push \
	        $(DOCKER_USERNAME)/$(IMAGE_NAME):latest

.DEFAULT_GOAL := build

.PHONY: build push
