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
	@terraform plan

apply: init
	@terraform apply

destroy: init
	@terraform destroy
