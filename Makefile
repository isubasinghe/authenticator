GOOS=linux
BINARY_NAME=authenticator
SECRET_FILE=secret.json

.PHONY: clean

build:	
	go build -o $(BINARY_NAME)
	zip $(BINARY_NAME).zip $(BINARY_NAME) $(SECRET_FILE)

plan: build
	cd tf && terraform plan -destroy -var='firebase_cred_file=$(SECRET_FILE)' -var='lambda_zip=$(BINARY_NAME).zip' -var='lambda_handler=$(BINARY_NAME)'

deploy: build
	cd tf && terraform apply -var='firebase_cred_file=$(SECRET_FILE)' -var='lambda_zip=$(BINARY_NAME).zip' -var='lambda_handler=$(BINARY_NAME)'

clean:
	rm $(BINARY_NAME) $(BINARY_NAME).zip