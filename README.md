# lovevery-demo-robzr-backend
---
backend component of Lovevery Demo app for @robzr

# Overview
This repo contains a simple "Hello World" Ruby on Rails app and supporting files,
described below, that can be used to build, test & deploy using Ruby in Docker.

# Installation
Development, building and deployment has been tested on MacOS 14 with Docker
Desktop v4.24.0

## Local Development
A `Makefile` is used in order to manage building the Docker images and running
basic Rails commands inside docker, so all Ruby and Rails commands are done in
containers.

For basic local development usage, a single container can be run in Docker
Desktop by simply running `make run` - this will create all requisite images
and run a server instance.

## Kubernetes in Docker Desktop
Deploying and running in Kubernetes in Docker Desktop requires a few more
steps

1. [Enable Kubernetes in Docker Desktop][1]
2. [Install the Nginx Ingress Controller][2] - this can be done by running:
```
helm install \
  --namespace kube-system \
  nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx
```
3. Add the destination hostname to your local hosts file:
```
sudo sh -c 'echo "127.0.0.1\tlovevery-demo-robzr.local" >> /etc/hosts'
```
4. In the top level of the repository, make the app image:
```
make image
```
5. Deploy the Helm chart to Kubernetes
```
helm upgrade \
  --create-namespace \
  --install \
  --namespace lovevery-demo \
  lovevery-demo-robzr \
  helm/lovevery-demo-robzr
```
6. Test by visiting [http://lovevery-demo-robzr.local](http://lovevery-demo-robzr.local)


# Sources
For more info, see:
- [Dockerized Ruby](https://hub.docker.com/_/ruby)
- [Rails Gem](https://rubygems.org/gems/rails)

[1]: <https://docs.docker.com/desktop/kubernetes/#turn-on-kubernetes> "Turning On Kubernetes in Docker Desktop"
[2]: <https://kubernetes.github.io/ingress-nginx/deploy/#docker-for-mac> "Installing Nginx Ingress on Docker for Mac"
