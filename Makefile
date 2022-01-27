IMAGE_NAME=inspec
DOCKER_USERNAME=hashieducation

define GetImageID
$$(docker images --filter=reference=$(1) --format "{{.ID}}" | awk '{getline;print}')
endef

# Otherwise we just use what the user gave us
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
ifeq ($(BRANCH),master)
    DOCKER_TAG += "master" 
else
    DOCKER_TAG += $(BRANCH)
endif

build:
	@echo "==> Building Docker image..."
	@docker build \
	 --rm \
	 -t \
	 $(IMAGE_NAME):$(DOCKER_TAG) \
	 .
push: build
	# open onepassword://search/ej6uodvxxvcetihbgwdy2wnoh4
	# export DOCKER_API_TOKEN=<the API Token field>
	@echo $(DOCKER_API_TOKEN) | \
		docker login --username $(DOCKER_USERNAME) --password-stdin
	@docker tag $(call GetImageID,$(IMAGE_NAME):$(DOCKER_TAG)) \
	  $(DOCKER_USERNAME)/$(IMAGE_NAME):$(DOCKER_TAG)
	@docker push \
	        $(DOCKER_USERNAME)/$(IMAGE_NAME):$(DOCKER_TAG)

.DEFAULT_GOAL := build

.PHONY: build push
