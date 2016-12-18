# Tools

For those not familiar with the tools we are using, here is a brief explanation and a link for further reading.

It is highly recommended that you take the time to establish at least a passing knowledge of how these tools work.

## terraform

Terraform is a cross-platform single-binary tool for managing infrastructure in a declarative and immutable way.

Declarative because the configuration files it runs describe the end-state that you want to achieve, terraform's job is to 
work out how to get there.

Immutable because the configuration is designed to spin up or tear down complete environments from testing/qa to production. 
Running terraform multiple times will not alter the final desired configuration.

Further reading [http://terraform.io](http://terraform.io)

### how we use it

Terraform is the starting point for creating the servers we need to run both applications and the shared infrastructure services
they consume.

By default we use `CoreOS` as the modern minimalist container-focused operating system for both the infrastructure servers and the 
application host servers. 

The container host operating systems can be changed although the bootstrapping scripts will likely vary across different linux distros. 

### for infrastructure

By default we create 3 infrastructure servers that run clusters for nomad, consul, træfɪk, vault, redis and eventstore.
In addition it runs fail-over instances of Identity Server. 

These represent the shared, highly available, fault-tolerance services that bind your services together into a cohesive whole.

### for applications 

The applications (your ServiceStack apps) are run in containers on the application servers. By default these are linux CoreOS servers.
Our goal is to run containerised ServiceStack applications on these application host servers.

## Consul

Consul is a cross platform single-binary tool for distributed key/value storage and service discovery.

Consul runs as either a server or an agent. A server should be configured as a cluster (datacenter) in production environments using 
an odd-number of instances.

The recommended number of server nodes in a datacenter is 3 or 5. Our configuration defaults to 3 to tolerate one server node failure 
but can be changed in the config.

Further reading [http://terraform.io](http://terraform.io)

### how we use it

Most of the tools use Consul for either service discovery or shared k/v store, including encrypted storage.

[TODO Add details]

## Nomad

Nomad is a cross-platform single-binary tool for managing and running 'jobs' from scheduled tasks, backups and most importantly
container-based applications.

It performs a similar role to other schedulers like docker swarm, mesos, kubernete or marathon.

### how we use it

[TODO Add details]

## Vault

Vault is a cross platform single-binary tool for storing secrets and can be used as a certificate store. By default we use our
Consul cluster as the back-end storage for Vault but this can be configured as needed.

[TODO Add details]

## Redis

[TODO Add details]

## Identify Server

[TODO Add details]
