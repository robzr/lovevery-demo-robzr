# lovevery-demo-robzr
---
Lovevery SRE demo app by @robzr

# Overview
This repo contains a simple Dockerized "Hello World" Ruby on Rails app and
supporting files that can be used to build, test & deploy to Docker or
Kubernetes.

# Usage
Development, building and deployment has been tested on MacOS 14 with Docker
Desktop v4.24.0

A `Makefile` is used in order to manage building the Docker images and running
basic Rails commands inside docker, so all Ruby and Rails commands are done in
containers.

## Local Development
For basic local development usage, a single container can be run in Docker
Desktop by simply running `make run` - this will create all requisite images
and run a server instance.

## Kubernetes in Docker Desktop
Deploying and running in Kubernetes in Docker Desktop requires a few more
steps, and can be done with or without Terraform. Unless specified, all commands
should be run from the top level directory of this repo.

1. [Enable Kubernetes in Docker Desktop][1]
2. Add the destination hostname to your local hosts file:
```
sudo sh -c 'echo "127.0.0.1\tlovevery-demo-robzr.local" >> /etc/hosts'
```
3. In the top level of the repository, make the app image:
```
make
```

### Deploying With Terraform
1. Terraform can be used to deploy to Kubernetes by running the following from the
`terraform` subdirectory:
```
terraform init
terraform apply
```
2. Test by visiting [http://lovevery-demo-robzr.local][3]

### Deploying Without Terraform
1. [Install the Nginx Ingress Controller][2] - this can be done by running:
```
helm install \
  --namespace kube-system \
  nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx
```
2. Deploy the Helm chart to Kubernetes
```
helm upgrade \
  --create-namespace \
  --install \
  --namespace lovevery-demo \
  lovevery-demo-robzr \
  helm/lovevery-demo-robzr
```
3. Test by visiting [http://lovevery-demo-robzr.local][3]


## Notes
### Thoughts on Terraform 
#### State Management
Currently, the Terraform config is setup to use local state with no workspaces.
While this is sufficient for local usage in a single development environment, it
does not scale to multiple users, multiple environments, or production
environments. 

There is no single "right" way to manage state, but in general terms a secure
state storage backend with locking should be implemented, along with a convention
that allows multiple configurations and workspaces to cleanly share the backend
without collision. How the convention is implemented depends on the storage
backend used (ie: storage buckets simply use a hierarchical path structure,
while Terraform Cloud uses a more flexible system involving naming and selector
labels).

In addition to the more cleanly implemented state and workspace organization
paradigm implemented by Terraform Cloud, the access control system allows for
easily and securely sharing state with multiple users or teams. Outputs from
state can be shared without sharing the entire state, which enables a flow for
dynamic provisioning data across access boundaries without exposing state
internals, which often has security implications. Terraform Cloud also offers
lock management via UI, remote runners, input variable and secrets management,
and many other features. Because of these factors, if cost is not an object, my
preference for managing state in a production environment is with Terraform
Cloud. A subset of these features can be implemented using other backends, but
access control in particular is much more limited and difficult to manage.

#### Input Variables
Like state, there is no "right" way to manage input variables, but there are
some patterns that I have found to work well in different use cases. 
- Terraform Cloud offers web UI (or Terraform/API) based management of input
variables, which can be a user-friendly way to manage a small set of static
values.
- When possible, instead of using input variables, being able to parse metadata
from naming conventions or contexts, sourcing data from upstream Terraform state
outputs (via remote state lookup or Terragrunt), or sourcing data from existing
sources of truth helps prevent duplicating values and avoids the risks
associated with duplication. The easiest input variable to manage is no input
variable!
- The use of `tfvars` files (`terraform.tfvars` & `*.auto.tfvars`) files in 
JSON or HCL format can be easily managed in CI flows, via scripts, hooks,
or manually (ex: a CI step that symlinks a `${workspace}.tfvars` file before
running Terraform).
- In some cases, instead of managing multiple sets of input variables for
different workspaces/environments, a single set of variables can include
hashmaps, key'd on the workspace or environment name, which is then looked
up at runtime. This can be a clean and simple solution when there are not large
amounts of divergence across the workspaces/environment input values.
- For large and/or complex input value data sets, I have found a pattern that
works very well for GitOps based CI/CD flows. At the top level of the same
repo that contains the Terraform config, per-workspace YAML files are a great
way to store large or complex data (ie: can benefit from YAML reference based
deduplication/patterns). At runtime, the Terraform config selects, reads &
decodes the appropriate YAML file, and passes the raw data structures to a
module with suitable input variable definitions for validation. This same module
can also transform data as needed before outputting it back to the top level
config. This pattern works well for GitOps flows used by people without HCL or
Terraform experience.

#### Secrets
The handling of secrets is hugely consequential both for use in Terraform as
well as in general. Risks of improper secrets handling includes security
breaches, outages, data leakage, and insufficient credential rotation - which
can violate best practices or even specific benchmark requirements.

I am a proponent of using thoughtful authorization patterns to either access
single sourced secrets, or using automation flows to deterministically
propogate secrets to appropriate destination stores for use by local consumers.
Manual duplication of secrets tends to risk drift errors and decreases the
liklihood of appropriate credential rotation due to perceived or actual overhead
and risk. Incorporating an extensible and thoughtful secrets management paradigm
early on can result in a large savings of tech debt down the road.

Specific to Terraform, secrets must be handled with more care than general
provisioning data. Any secrets handled during a Terraform flow may be stored
unencrypted in the state file. Access paradigms for secrets should consider
Principle of Least Priviledge, and thoughtfully leveraging authentication
relationships to balance siloing of access with simplicity, extensibility,
and overhead.

Some considerations and mechanisms for handling secrets in Terraform include:
- Generally consider state data to be a secret, which means incorporating
thoughtful access controls and siloing around your state store(s).
- The use of siloed state backends, or a backend that allows for fine grained
access control can reduce the risk of secrets leaking from state.
- When feasible, leverage service accounts and trust relationships to
dynamically access cloud provider secret stores via data lookups, instead of
managing secrets lookups externally.
- In some use cases, secrets can passed through Terraform as encrypted fragments
or references, to be decrypted or dereferenced by the downstream consumer.

# Sources
For more info, see:
- [Dockerized Ruby](https://hub.docker.com/_/ruby)
- [Rails Gem](https://rubygems.org/gems/rails)

[1]: <https://docs.docker.com/desktop/kubernetes/#turn-on-kubernetes> "Turning On Kubernetes in Docker Desktop"
[2]: <https://kubernetes.github.io/ingress-nginx/deploy/#docker-for-mac> "Installing Nginx Ingress on Docker for Mac"
[3]: <http://lovevery-demo-robzr.local>
