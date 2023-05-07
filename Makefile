APPNAME := datereporter

build:
	cd app/springboot/datereporter ; \
	./gradlew clean build ; \
	docker build -t $(APPNAME) .

deploy-local:
	helm upgrade -i \
		$(APPNAME) app/springboot/$(APPNAME)/deployment/$(APPNAME) \
		-f app/springboot/$(APPNAME)/deployment/$(APPNAME)/values-local.yaml

port-forward:
	kubectl port-forward svc/$(APPNAME) 8080:8080

clean:
	helm delete $(APPNAME) || true;
	docker image rm -f $(APPNAME) || true;
	cd app/springboot/datereporter ; \
	./gradlew clean ; \
