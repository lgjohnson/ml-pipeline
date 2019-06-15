STACK_ENV = "stg"

.PHONY: all get init plan apply destroy

all:
	@echo "Available commands: \n\
		* plan \n\
		* apply \n\
		* destroy \
"

init:
	@terraform init

plan: init
	@terraform plan -var "stack_env=${STACK_ENV}"

apply: init
	@terraform apply -var "stack_env=${STACK_ENV}"

destroy: init
	@terraform destroy -var "stack_env=${STACK_ENV}"
