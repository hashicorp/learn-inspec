IMAGE="inspec"

build:
	@echo "==> Building Docker image..."
	@docker build \
        --rm \
        -t \
        $(IMAGE) \
        .

.DEFAULT_GOAL := build 

.PHONY: build
