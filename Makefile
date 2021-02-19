.PHONY: create-vpc destroy-vpc all destroy-all
.SHELL := $(shell which bash)
CURRENT_FOLDER=$(shell basename "$$(pwd)")
BOLD=$(shell tput bold)
RED=$(shell tput setaf 1)
GREEN=$(shell tput setaf 2)
YELLOW=$(shell tput setaf 3)
RESET=$(shell tput sgr0)
aws:=$(shell command -v aws 2> /dev/null)

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

set-env:
	@if [ -z $(AWS_PROFILE) ] || [ -z $(STACK_NAME) ]; then \
		echo "$(BOLD)$(RED)AWS_PROFILE or $(BOLD)$(RED)STACK_NAME was not set$(RESET)"; \
		ERROR=1; \
	 fi
	 
	@if [ ! -z $${ERROR} ] && [ $${ERROR} -eq 1 ]; then \
		echo "$(BOLD)Example usage: \`AWS_PROFILE=demo STACK_NAME=jira-app make create-stacks\`$(RESET)"; \
		exit 1; \
	 fi

init: set-env ## Upload CFN templates to S3
	@echo "Upload CFN template"
	aws --profile $(AWS_PROFILE) s3 cp templates/ s3://cf-templates-6ofbp19dhk2c-us-east-1/ --recursive

create-stacks: set-env ## Create CFN stacks
	@echo "Create Stacks"
	aws cloudformation --profile $(AWS_PROFILE) deploy --stack-name $(STACK_NAME) --template-file templates/quickstart-jira-dc-with-vpc.template.yaml --parameter-overrides $$(cat params/params.ini) --capabilities CAPABILITY_NAMED_IAM
	
delete-stacks: set-env ## Delete CFN stacks
	@echo "Delete Stacks"
	aws cloudformation --profile $(AWS_PROFILE) delete-stack --stack-name $(STACK_NAME)

clean-up: set-env ## Clean up CFN templates in S3
	@echo "Clean up CFN templates in S3"
	aws --profile $(AWS_PROFILE) s3 rm s3://cf-templates-6ofbp19dhk2c-us-east-1/ --recursive --include "quickstart-*.yaml"

all: init create-stacks
delete-all: delete-stacks clean-up # Delete All
