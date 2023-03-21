MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
IS_IN_CONTAINER := $(shell sh -c 'test -f /.dockerenv && echo 0 || echo 1')

.SILENT: pre-command

.PHONY: pre-command
pre-command:
	if [ $(IS_IN_CONTAINER) -ne 0 ]; then \
		echo "Please run this command in the container."; \
		exit 1; \
	fi;

# https://qiita.com/sonodar/items/ddeeb98525ef4c03d48e#%E4%BD%BF%E3%81%84%E6%96%B9
.PHONY: watch
watch: pre-command
	inotifywait -m -e modify -e create -e delete -r $(MAKEFILE_DIR) --format '%T %w %f %e' --timefmt '%F %T' --include ".+?\.(tf|hcl|tfvars)$$" | \
	while read EVENTS; do make fmt && make lint; done \

# TODO: validate?
.PHONY: lint
lint: tf-validate tflint tfsec
	@terraform fmt -check -recursive

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
	@tfsec . --tfvars-file terraform.tfvars && echo "tfsec succeeded."

.PHONY: apply
apply: pre-command lint
	@terraform apply

.PHONY: destroy
destroy: pre-command lint
	@terraform destroy

.PHONY: random-string-lower
random-string-lower:
	@cat /dev/urandom | tr -dc '[:alnum:]' | head -c 40 | tr '[:upper:]' '[:lower:]';

.PHONY: migrate-state
migrate-state:
	@BC_PATH=remote-state/backend-config.auto.tfvars; \
	if [ ! -e $${BC_PATH} ]; then \
		echo "create $${BC_PATH} first."; >&2 \
		exit 1; \
	fi; \
	terraform init -backend-config=$${BC_PATH} -migrate-state

.PHONY: login
login:
	ssh -F ssh_config bastion

.PHONY: dep_graph
dep_graph:
	terraform graph | dot -Tpng > graph.png
