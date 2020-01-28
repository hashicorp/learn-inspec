build:
	@echo "==> Building Docker image..."
	@docker build \
        --rm \
        -t \
        inspec \
        .

.DEFAULT_GOAL := build 

.PHONY: build
