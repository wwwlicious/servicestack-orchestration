# Tools

For those not familiar with the tools we are using, here is a brief explanation and a link for further reading.

It is highly recommended that you take the time to establish at least a passing knowledge of how these tools work.

## terraform

Terraform is a cross-platform single-binary tool for managing infrastructure in a declarative and immutable way.

Declarative because the configuration files it runs describe the end-state that you want to achieve, terraform's job is to work out how to get there.

Immutable because the configuration is designed to spin up or tear down complete environments from testing/qa to production.
Running terraform multiple times will not alter the final desired configuration.

Further reading [http://terraform.io](http://terraform.io)

### how we use it

Terraform is the starting point for creating the servers we need to run both applications and the shared infrastructure services
they consume.

By default we use `CoreOS` as the modern minimalist container-focused operating system for both the infrastructure servers and the application host servers.

The container host operating systems can be changed although the bootstrapping scripts will likely vary across different linux distros.

### for infrastructure

By default we create 3 infrastructure servers per datacenter to run clusters of consul, nomad, træfɪk, vault, redis and eventstore.
In addition it runs fail-over instances of Identity Server.

These represent the shared, highly available, fault-tolerance services that help bind your services together into a cohesive whole.

### for applications

The applications (your ServiceStack apps) are run in containers on the application servers. By default these are linux CoreOS servers.
Our goal is to run containerised ServiceStack applications on these application host servers.

## Consul

Consul is a cross platform single-binary tool for distributed key/value storage and service discovery.

Consul runs as either a server or an agent. A server should be configured as a cluster (datacenter) in production environments using
an odd-number of instances. Each container host runs a copy of a consul agent.

The recommended number of server nodes in a datacenter is 3 or 5. 

Further reading [http://consul.io](http://consul.io)

### how we use it

Our configuration defaults to 3 which can tolerate a single server node failure, but can be changed in the config.

Most of the other tools/services use Consul for either service discovery or as a K/V store, including encrypted storage.

### for infrastructure

* Nomad - uses consul by default to bootstrap a cluster, nomad instances will find each other when Consul is configured
* Vault - uses consul distributed k/v store as a cross-platform CA for generating TLS certificates and keys which can auto-renew or rotate
* Redis - uses consul service discovery to expose a single redis-cluster endpoint
* Træfɪk - auto-wired into consul's service discovery and stores configuration in K/V store
* DNS - exposes Consul-based DNS

### for applications

* ServiceStack.Discovery.Consul - auto-registers ServiceStack DTO's for zero-configuration service to service calls plus configurable endpoint healthchecks
* ServiceStack.Redis.RateLimit - provides global configuration via Consul K/V for fine-grained control of api rate-limits on all ServiceStack endpoints
* ServiceStack.IntroSpec.ServiceCop - auto-watches Consul's service discovery catalog to provide ServiceStack contract validation and service suspension
* ServiceStack.IntroSpec.DocIt - auto-watches Consul's service discovery catalogue to provide global api documentation
* ServiceStack.Configuration.Consul - provides transparent appsettings storage and runtime reconfiguration via Consul's K/V store

[TODO Add details]

## Nomad

Nomad is a cross-platform single-binary tool for managing and running 'jobs'. From scheduled tasks, backups and most importantly
container-based applications.

It performs a similar role to other schedulers like docker swarm, mesos, kubernetes or marathon.

Further reading [https://www.nomadproject.io/](https://www.nomadproject.io/)

### how we use it

As a scheduler, nomad is responsible for running containers and executing scheduled-tasks

### for infrastructure

Nomad runs the period backup jobs for Consul, Redis, EventStore and Identity Server. Each backup job can point to a different local or cloud storage providers
for maximum resilience. As Consul is the configuration backing store for most services, this provides disaster recovery for catastrophic failures, 
however unlikely.

Nomad also ensures that infrastructure services running in containers are distributed across multiple hosts and/or cloud providers.
It can keep services on hot-backup to handle container crashes, unresponsiveness or redeployment as infrastructure Servers are added or removed.

### for applications

Nomad manages the running of containerised ServiceStack applications with fault-tolerance and elastic-scaling

## Vault

Vault is a cross platform single-binary tool for storing secrets and can be used as a certificate store. By default we use our
Consul cluster as the back-end storage for Vault but this can be configured as needed.

Further reading [https://www.vaultproject.io/](https://www.vaultproject.io/)

### how we use it

Vault (using consul as a backing store) provides a Certificate Authority (CA) which is added to the trusted roots on each server. 
This allows Vault to transparently generate individual certificates and auto-refresh them for both infrastructure services and containerised applications.

### for infrastructure

Every infrastructure service that supports TLS communication whether it is for cluster communication, admin interface endpoints or application usage is 
auto-wired with auto-renewing certificates from Vault's certificate authority.

### for applications

Our Servicestack.Authentication.Identityserver.Vault plugin for ServiceStack provides three different features that use Vault.

* A Certificate store that can generate and auto-renew X509 certificates on running services. 
* A Client secret store that 
  * combined with another plugin for Identity Server provide secure auth token exchange between services
  * a completely transparent encryption and decryption layer for OrmLite that can encrypt sensitive data on a column by column basis

## Redis

Redis is an open source (BSD licensed), in-memory data structure store, used as a database, cache and message broker.

Further reading [https://redis.io/](https://redis.io/)

### how we use it

Although we provide a production-ready Redis cluster, it is primarily used for caching and handling ServiceStack api rate-limiting. 
We do not recommend using a shared data model in your ServiceStack applications.

### for infrastructure

n/a

### for applications

Our ServiceStack.RateLimit.Redis plugin provides runtime-configurable, automatic and transparent rate-limiting for all ServiceStack endpoints.
By default we also use it for ServiceStack caching across all services.

## Identity Server

Identity Server is an open source OpenID Connect and OAuth 2.0 framework for .NET

Further reading [https://identityserver.io/](https://identityserver.io/)

### how we use it

All authentication and authorisation is handled with Identity Server providing single sign on (SSO) for multiple application types, federated gateways 
to link multiple external authentication providers and api access control including client to service, service to service and delegated impersonation.

### for infrastructure

Integrated with vault the default configuration provides auto-rotating token based access between infrastructure services.

### for applications

Every ServiceStack application can leverage the framework authentication and authorization which will transparently be configured to use Identity Server.
An admin UI endpoint is exposed for managing all infrastructure service and application permissions.

## træfɪk

Træfɪk is a modern HTTP reverse proxy and load balancer made to deploy microservices with ease and is available as a binary or docker container.

Further reading [https://docs.traefik.io/](https://docs.traefik.io/)

### how we use it

Traefik has native support for Consul and we use this to expose a single API Gateway endpoint which depending on your configuration can act as:

* a frontend/backend proxy
* a single ServiceStack Service Reference endpoint for development time DTO generation 
* a configurable load balancer

### for infrastructure

[TODO]

### for applications

[TODO]