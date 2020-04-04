# Deployment of a dockerized Web Application with Database in Kubernetes

## Enviroment

In this experimental deployment a minikube kubernetes cluster is used.

The minikube will be installed in a Virtual Machine and started in the Bare Metal mode.

> sudo minikube start --driver=none

Enable the ingress controller

> sudo minikube addons enable ingress

kubectl needs to be installed in the system,

## Deployment

### Deployment Characteristics

The deployment will consist on a dockerized java based web application called webapp that uses a MySQL database.

In this deployment we will use a replica set of 2 instances for the webapp.

he databases will not be replicated.
The database will be persistent in a hostPath location.

The exposed url will be www.mywebdomain.com/webapp/ in the TCP port 80.

The deployment will be automatized ...


### Helm

#### Manual deployment

Create a folder for the system and add an entry in the /etc/hosts for a domain
> mkdir /mnt/data/antoniocamas
> echo -e "$(minikube ip)\twww.mywebdomain.com" >> /etc/hosts

Deploy the web app with helm

> cd webapp-kubernetes-deployment
> helm install --name helm-deployed-webapp-antonio-camas charts/webapp

#### Scripted

All the above steps are automatized by the deployment script.

Deploy with
> sudo ./deployment_manager.sh --mode helm -o create  -v

Check status
> sudo ./deployment_manager.sh -s

Delete deployment
> sudo ./deployment_manager.sh --mode helm -o delete  -v

### Specs

#### Manual deployment

Create a folder for the system and add an entry in the /etc/hosts for a domain
> mkdir /mnt/data/antoniocamas
> echo -e "$(minikube ip)\twww.mywebdomain.com" >> /etc/hosts

Deploy the web app using the specs and kubectl

> cd webapp-kubernetes-deployment
> kubectl create -f specs/step_1_volumes.yaml
> kubectl create -f specs/step_2_webapp_and_database.yaml
> kubectl create -f specs/step_3_ingress.yaml

Show the status with
> kubectl get pods,deployments,services,pv,pvc,ingress

Delete the deployment with

> cd webapp-kubernetes-deployment
> kubectl delete -f specs/step_3_ingress.yaml
> kubectl delete -f specs/step_2_webapp_and_database.yaml
> kubectl delete -f specs/step_1_volumes.yaml

#### Scripted

All the above steps are automatized by the deployment script.

Deploy with
> sudo ./deployment_manager.sh --mode specs -o create  -v

Check status
> sudo ./deployment_manager.sh -s

Delete deployment
> sudo ./deployment_manager.sh --mode specs -o delete  -v
