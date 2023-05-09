# cloud-native-demo

A demonstration for a blue/green deployment using cloud native technologies.

### prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [helm](https://helm.sh/docs/intro/install/)
- [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [k6](https://k6.io/docs/get-started/installation/)

## Running locally

The local demo uses Kubernetes through Docker Desktop. Once Docker is running, you can enable kubernetes by going into Docker Settings -> Kubernetes -> Enable Kubernetes. You will also need to adjust some of the resources for Docker to be able to run the cluster services.

**Optional**: if you would like hostname resolution to be able to access services like Kiali, Grafana, and Prometheus, you can update your `/etc/hosts` file to include the following

```
127.0.0.1 datereporter.local.domain
127.0.0.1 productpage.local.domain
127.0.0.1 prometheus.local.domain
127.0.0.1 grafana.local.domain
127.0.0.1 kiali.local.domain
```

#### Deploy cluster services and v1 of app

The default command from the Makefile will handle deploying the cluster services and the initial datereporter application.

```bash
make
```

#### Begin the load tests

The load tests are executed using k6. If you have k6 installed, you can use the command

```bash
make load-test-docker-desktop
```

The tests will run 2 requests per second for 10 minutes.

#### Deploy v2 of app

To make an update to the application, you can change the message returned in the rest controller.

Open the file in `app/springboot/datereporter/src/main/java/com/jguzman/datereporter/DateController.java`. Change "hello world" to "automate all the things!".

```java
    resp.put("message", "hello world");
```

redeploy the application using the command

```
TAG=v2 make docker-build-deploy
```

## Cluster Services

| Service    | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| flagger    | Operator for automating the blue/green or canary deployments |
| grafana    | Dashboarding tool                                            |
| istio      | Service mesh for cluster. Handles traffic management         |
| kiali      | Service mesh visualization                                   |
| prometheus | Monitoring                                                   |

The cluster services are deployed using Terraform. The list of available TF vars are

| variable              | Description                                                 |
| --------------------- | ----------------------------------------------------------- |
| istio_enabled         | Flag for istio deployment                                   |
| istio_gateway_enabled | Flag for istio ingress gateway deployment                   |
| istio_gateway_values  | Path to a values override yaml file.                        |
| istio_base_values     | Path to a values override yaml file.                        |
| istio_base_chart      | Path to a chart directory.                                  |
| istio_istiod_values   | Path to a values override yaml file.                        |
| istio_istiod_chart    | Path to a chart directory.                                  |
| istio_gateway_chart   | Path to a chart directory.                                  |
| istio_sidecar         | Label for namespaces. Whether to auto inject Istio sidecars |
| flagger_enabled       | Flag for Flagger deployment                                 |
| flagger_values        | Path to a values override yaml file.                        |
| flagger_chart         | Path to a chart directory.                                  |
| grafana_enabled       | Flag for Grafana deployment                                 |
| grafana_values        | Path to a values override yaml file.                        |
| grafana_chart         | Path to a chart directory.                                  |
| kiali_enabled         | Flag for Kiali deployment                                   |
| kiali_values          | Path to a values override yaml file.                        |
| kiali_chart           | Path to a chart directory.                                  |
| prometheus_enabled    | Flag for Prometheus deployment                              |
| prometheus_values     | Path to a values override yaml file.                        |
| prometheus_chart      | Path to a chart directory.                                  |

## Roadmap

- [x] Demo application
- [x] Istio install locally
- [x] Prometheus install locally
- [x] Kiali install locally
- [x] Flagger install locally
- [x] Grafana install locally
- [x] Grafana dashboards and datasources IaC
- [ ] Prometheus Dashboard in Grafana
- [x] blue/green deployment
- [ ] Jenkins CI for steps
- [ ] AWS EKS Cluster
- [ ] Swap Terraform for ArgoCD
- [ ] External DNS install in EKS
- [ ] Cert-manager install in EKS
