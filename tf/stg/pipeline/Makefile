STACK_ENV = "stg"

.PHONY: all get init plan apply destroy

all:
	@echo "Available commands: \n\
		* plan \n\
		* apply \n\
		* destroy \
"

get:
	@terraform get -update

init: get
	@terraform init

upload-lambda:
	@../../scripts/upload_lambda.sh

plan: get
	@terraform plan -var "stack_env=${STACK_ENV}"

apply: get
	@terraform apply -var "stack_env=${STACK_ENV}"

destroy: get
	@terraform destroy -var "stack_env=${STACK_ENV}"
