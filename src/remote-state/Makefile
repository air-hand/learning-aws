MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
IS_IN_CONTAINER := $(shell sh -c 'test -f /.dockerenv && echo 0 || echo 1')

all: lint

.SILENT: pre-command

.PHONY: pre-command
pre-command:
	if [ $(IS_IN_CONTAINER) -ne 0 ]; then \
		echo "Please run this command in the container."; \
		exit 1; \
	fi;

.PHONY: lint
lint: tf-validate tflint tfsec

.PHONY: plan
plan: lint
	terraform plan

.PHONY: tf-validate
tf-validate: pre-command
	@terraform validate

.PHONY: fmt
fmt: pre-command
	@terraform fmt --recursive

.PHONY: tflint
tflint: pre-command
	@tflint --init; \
	tflint -f compact && echo "tflint succeeded."; \

.PHONY: tfsec
tfsec: pre-command
	@tfsec . --tfvars-file backend-config.auto.tfvars && echo "tfsec succeeded."

.PHONY: apply
apply: pre-command lint
	@terraform apply

.PHONY: destroy
destroy:
	@echo "DO NOT DESTROY backend resources!" >&2
