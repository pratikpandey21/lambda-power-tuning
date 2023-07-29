.PHONY: build

build:
	GOOS=linux GOARCH=amd64 go build -mod=readonly -ldflags='-s -w' -o build/bin/compute_intensive .

init:
	terraform init

plan:
	terraform plan

apply:
	terraform apply --auto-approve

# Uncomment if you want to destroy
#destroy:
#	terraform destroy --auto-approve
