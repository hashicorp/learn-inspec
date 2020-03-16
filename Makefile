IMAGE="dind"

dind:
	@echo "==> Building Docker image..."
	@docker build \
        --rm \
        -t \
        $(IMAGE) \
        .
inspec:
	@echo "==> Building Docker image..."
	@docker build \
        --rm \
        -t \
		--file Dockerfile.inspec \
        inspec \
        .

.DEFAULT_GOAL := inspec 

.PHONY: build inspec
