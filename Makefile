APPNAME := datereporter
CHARTS := \
			istio-base \
			istio-istiod \
			istio-gateway \
			flagger \
			prometheus

build:
	cd app/springboot/datereporter ; \
	./gradlew clean build ; \
	docker build -t $(APPNAME) .

install-local:
	helm upgrade -i \
		-n datereporter-dev \
		$(APPNAME) app/springboot/$(APPNAME)/deployment/$(APPNAME) \
		-f app/springboot/$(APPNAME)/deployment/$(APPNAME)/values-local.yaml

uninstall-local:
	helm -n datereporter-dev delete $(APPNAME);

port-forward:
	kubectl port-forward svc/$(APPNAME) 8080:8080

infra-local:
	cd infra/local ; \
	terraform init ; \
	terraform apply -var-file=local.json;

chart-dependency-build:
	for chart in $(CHARTS); do \
		cd infra/charts/$$chart && helm dependency build; \
		cd -; \
	done ;

clean:
	helm -n datereporter-dev delete $(APPNAME) || true;
	docker image rm -f $(APPNAME) || true;
	cd app/springboot/datereporter ; \
	./gradlew clean ;
