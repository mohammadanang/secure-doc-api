GOSEC_IMAGE := securego/gosec:latest
WORKDIR     := /workspace

.PHONY: gosec ci-gosec help

help:
	@echo "Perintah yang tersedia:"
	@echo "  make gosec    - Menjalankan gosec linter via Docker (Interactive)"
	@echo "  make ci-gosec - Menjalankan gosec linter via Docker (Tanpa TTY, cocok untuk CI/CD)"

gosec:
	docker run --rm -it -v $(PWD):$(WORKDIR) -w $(WORKDIR) $(GOSEC_IMAGE) ./...

ci-gosec:
	docker run --rm -v $(PWD):$(WORKDIR) -w $(WORKDIR) $(GOSEC_IMAGE) ./...