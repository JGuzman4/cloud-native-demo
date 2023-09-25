.PHONY: help infra destroy install uninstall generate-certs vault-bootstrap clean-consul vault-unseal
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
	cfssl gencert -initca infra/key-management/certs/config/ca-csr.json | cfssljson -bare infra/key-management/certs/ca ;
	# Create a private key and a TLS certificate for Consul
	cfssl gencert \
    -ca=infra/key-management/certs/ca.pem \
    -ca-key=infra/key-management/certs/ca-key.pem \
    -config=infra/key-management/certs/config/ca-config.json \
    -profile=default \
    infra/key-management/certs/config/consul-csr.json | cfssljson -bare infra/key-management/certs/consul ;
	# Do the same for Vault
	cfssl gencert \
    -ca=infra/key-management/certs/ca.pem \
    -ca-key=infra/key-management/certs/ca-key.pem \
    -config=infra/key-management/certs/config/ca-config.json \
    -profile=default \
    infra/key-management/certs/config/vault-csr.json | cfssljson -bare infra/key-management/certs/vault ;

consul-bootstrap: generate-certs # generate ca resources and consul gossip encryption key
	export GOSSIP_ENCRYPTION_KEY=$$(consul keygen) ; \
	kubectl create secret generic consul \
		-n platform \
		--from-literal="gossip-encryption-key=$$GOSSIP_ENCRYPTION_KEY" \
		--from-file=infra/key-management/certs/ca.pem \
		--from-file=infra/key-management/certs/consul.pem \
		--from-file=infra/key-management/certs/consul-key.pem ;

vault-bootstrap: # vault ca resources
	kubectl create secret generic vault \
		-n platform \
		--from-file=infra/key-management/certs/ca.pem \
		--from-file=infra/key-management/certs/vault.pem \
		--from-file=infra/key-management/certs/vault-key.pem ;

vault-unseal: # unseal vault
	kubectl exec -n platform vault-0 -- \
		vault operator init \
		-key-shares=1 \
		-key-threshold=1 \
		-format=json > infra/key-management/cluster-keys.json ;
	kubectl exec -n platform vault-0 -- \
		vault operator unseal $$(cat infra/key-management/cluster-keys.json | jq -r ".unseal_keys_b64[]") ;

jenkins-jobs: # deploy jobs to jenkins usinc CasC
	helm upgrade -i -n platform jenkins-jobs infra/$(KUBECONTEXT)/tf/jobs ;

load-test: # run k6s load tests
	cd test;
	npm install;
	k6 run test.js ;

password-grafana: # retrieve grafana admin password
	kubectl -n platform get secret grafana -o jsonpath="{.data.admin-password}" | base64 -D | pbcopy ;

password-argocd: # retrieve argocd password
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D | pbcopy ;

password-jenkins: # retrieve the admin password for jenkins
	kubectl -n platform get secret jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 -D | pbcopy ;

token-kiali: # retrieve kiali login token
	kubectl -n platform create token kiali | pbcopy ;

token-vault: # retrieve vault login token
	cat infra/key-management/cluster-keys.json | jq -r ".root_token" | pbcopy ;

clean-consul: # destroy consul ca resources
	kubectl delete -n platform secret consul ;
	rm -rf infra/key-management/certs/consul*.pem infra/certs/key-management/consul*.csr ;

clean-vault: # destroy consul ca resources
	kubectl delete -n platform secret vault ;
	rm -rf infra/key-management/certs/vault*.pem infra/key-management/certs/vault*.csr ;
	rm -rf infra/key-management/cluster-keys.json ;

clean-infra: # clean terraform state and cache
	rm -rf infra/$(KUBECONTEXT)/tf/.terraform ;
	rm -rf infra/$(KUBECONTEXT)/tf/terraform.state* ;

clean: uninstall clean-consul clean-infra # clean all

help:
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done
