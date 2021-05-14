CONTAINER_RUNTIME ?= docker
CONTAINER_IMAGE := "ghcr.io/swiftwasm/swiftwasm-action:5.3"

containerized-build: clean
ifndef CONTAINER_RUNTIME
	@printf "Please install either docker or podman"
	exit 1
endif
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/code --entrypoint /bin/bash $(CONTAINER_IMAGE) -c "cd /code && swift build --triple wasm32-unknown-wasi"

test:
ifndef CONTAINER_RUNTIME
	@printf "Please install either docker or podman"
	exit 1
endif
	$(CONTAINER_RUNTIME) run --rm -v $(PWD):/code --entrypoint /bin/bash $(CONTAINER_IMAGE) -c "cd /code && carton test"

containerized-docs:
	$(CONTAINER_RUNTIME) run -ti --rm -v $(PWD):/code swiftdoc/swift-doc generate /code --module-name "Kubewarden SDK" --format html --output /code/docs

clean:
	rm -rf .build
