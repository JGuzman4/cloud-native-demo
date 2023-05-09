TAG ?= v1
APPNAME := datereporter
CHARTS := \
			istio-base \
			istio-istiod \
			istio-gateway \
			flagger \
			grafana \
			kiali \
			prometheus

all: infra-docker-desktop docker-build-deploy

docker-build-deploy:
	cd app/springboot/datereporter ; \
	./gradlew clean build ; \
	docker build -t $(APPNAME):$(TAG) .;
	helm upgrade -i \
		-n datereporter-dev \
		$(APPNAME) app/springboot/$(APPNAME)/deployment/$(APPNAME) \
		-f app/springboot/$(APPNAME)/deployment/$(APPNAME)/values-dd.yaml \
		--set image.tag=$(TAG)

install-docker-desktop:
	helm upgrade -i \
		-n datereporter-dev \
		$(APPNAME) app/springboot/$(APPNAME)/deployment/$(APPNAME) \
		-f app/springboot/$(APPNAME)/deployment/$(APPNAME)/values-dd.yaml

uninstall-docker-desktop:
	helm -n datereporter-dev delete $(APPNAME);

port-forward:
	kubectl port-forward svc/$(APPNAME) 8080:8080

infra-docker-desktop:
	cd infra/docker-desktop ; \
	terraform init ; \
	terraform apply -var-file=docker-desktop.tfvars;

chart-dependency-build:
	for chart in $(CHARTS); do \
		cd infra/charts/$$chart && helm dependency build; \
		cd -; \
	done ;

kiali-token:
	kubectl -n platform create token kiali | pbcopy

grafana-password:
	kubectl -n platform get secret grafana -o jsonpath="{.data.admin-password}" | base64 -D | pbcopy

load-test-docker-desktop:
	export DATEREPORTER_URL="http://datereporter.local.domain"; \
	cd test; \
	npm install; \
	k6 run test.js

clean:
	helm -n datereporter-dev delete $(APPNAME) || true;
	docker image rm -f $(APPNAME) || true;
	cd app/springboot/datereporter ; \
	./gradlew clean ;
