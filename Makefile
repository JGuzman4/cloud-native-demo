.PHONY: infra destroy install uninstall generate-certs vault-bootstrap clean-consul help
TAG ?= v1
KUBECONTEXT ?= docker-desktop
ORCHESTRATION ?= tf
APPNAME ?= datereporter
APP_URL ?= http://datereporter.local.domain
CHARTS ?= \
			argocd \
			consul \
			istio-base \
			istio-istiod \
			istio-gateway \
			flagger \
			grafana \
			jenkins \
			kiali \
			prometheus \
			vault

default: help

all: bootstrap infra build deploy

bootstrap: # pull chart dependencies
	helm repo update ;
	for chart in $(CHARTS); do \
		cd infra/charts/$$chart && helm dependency build --skip-refresh; \
		cd -; \
	done ;

build: # build the app
	cd app/springboot/datereporter ; \
	./gradlew clean build ; \
	docker build -t $(APPNAME):$(TAG) .;

deploy: build # deploy the app
	helm upgrade -i \
		-n $(APPNAME)-dev \
		$(APPNAME) app/springboot/$(APPNAME)/deployment/$(APPNAME) \
		-f app/springboot/$(APPNAME)/deployment/$(APPNAME)/values-dd.yaml

uninstall: # tear down app 
	helm -n $(APPNAME)-dev delete $(APPNAME);
	docker image rm -f $(APPNAME) || true;
	cd app/springboot/datereporter ; \
	./gradlew clean ;

infra: # create infra resources
	cd infra/$(KUBECONTEXT)/$(ORCHESTRATION) ; \
	terraform init ; \
	terraform apply -var-file=inputs.tfvars;

destroy: # destroy infra resources
	cd infra/$(KUBECONTEXT)/$(ORCHESTRATION) ; \
	terraform init ; \
	terraform destroy -var-file=inputs.tfvars;

generate-certs: # generate ca resources
	# Create a Certificate Authority
	cfssl gencert -initca infra/certs/config/ca-csr.json | cfssljson -bare infra/certs/ca ;
	# Create a private key and a TLS certificate for Consul
	cfssl gencert \
    -ca=infra/certs/ca.pem \
    -ca-key=infra/certs/ca-key.pem \
    -config=infra/certs/config/ca-config.json \
    -profile=default \
    infra/certs/config/consul-csr.json | cfssljson -bare infra/certs/consul ;
	# Do the same for Vault
	cfssl gencert \
    -ca=infra/certs/ca.pem \
    -ca-key=infra/certs/ca-key.pem \
    -config=infra/certs/config/ca-config.json \
    -profile=default \
    infra/certs/config/vault-csr.json | cfssljson -bare infra/certs/vault ;

consul-bootstrap: generate-certs # generate ca resources and consul gossip encryption key
	export GOSSIP_ENCRYPTION_KEY=$$(consul keygen) ; \
	kubectl create secret generic consul \
		-n platform \
		--from-literal="gossip-encryption-key=$$GOSSIP_ENCRYPTION_KEY" \
		--from-file=infra/certs/ca.pem \
		--from-file=infra/certs/consul.pem \
		--from-file=infra/certs/consul-key.pem ;

vault-bootstrap: # vault ca resources
	kubectl create secret generic vault \
		-n platform \
		--from-file=infra/certs/ca.pem \
		--from-file=infra/certs/vault.pem \
		--from-file=infra/certs/vault-key.pem ;

load-test: # run k6s load tests
	cd test;
	npm install;
	k6 run test.js ;

token-kiali: # retrieve kiali login token
	kubectl -n platform create token kiali | pbcopy ;

password-grafana: # retrieve grafana admin password
	kubectl -n platform get secret grafana -o jsonpath="{.data.admin-password}" | base64 -D | pbcopy ;

password-argocd: # retrieve argocd password
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D | pbcopy ;

password-jenkins: # retrieve the admin password for jenkins
	kubectl -n platform get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -D | pbcopy ;

jenkins-jobs: # deploy jobs to jenkins usinc CasC
	helm upgrade -i -n platform jenkins-jobs infra/$(KUBECONTEXT)/tf/jobs ;

clean-consul: # destroy consul ca resources
	kubectl delete -n platform secret consul ;
	rm -rf infra/certs/*.pem infra/certs/*.csr ;

clean-infra: # clean terraform state and cache
	rm -rf infra/$(KUBECONTEXT)/tf/.terraform ;
	rm -rf infra/$(KUBECONTEXT)/tf/terraform.state* ;

clean: uninstall clean-consul clean-infra # clean all

help:
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done
