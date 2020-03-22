# Deployment of a dockerized Web Application with Database in Kubernetes

## Enviroment

In this experimental deployment a minikube kubernetes cluster is used.

The minikube will be installed in a Virtual Machine and started in the Bare Metal mode.

> sudo minikube start --driver=none

Enable the ingress controller

> sudo minikube addons enable ingress

kubectl needs to be installed in the system,

## Deployment Characteristics

The deployment will consist on a dockerized java based web application called webapp that uses a MySQL database.

In this deployment we will use a replica set of 2 instances for the webapp.

he databases will not be replicated.
The database will be persistent in a hostPath location.

The exposed url will be www.mywebdomain.com/webapp/ in the TCP port 80.

The deployment will be automatized ...


## Spec files

###


## Deployment guide

The sripted and manual deployments do exactly the same steps. The should be equivalent.

### Scripted deployment

Launch minikube

> sudo minikube start --driver=none

Excute the deployment script in creation mode.

> 

### Manual deployment

Launch minikube

> sudo minikube start --driver=none

Create the hostPath directory in the host machine

> mkdir 

