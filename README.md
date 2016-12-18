# ServiceStack Orchestration

bootstrapping superpowers for your multi-cloud container-based infrastructure with:

* terraform
* consul
* nomad
* træfɪk
* identity server
* vault
* redis
* eventstore

For more background and context on these tools, please see [Tools](.docs/tools.md)

## Why?

Distributed services infrastructure is not simple, it's operational complexity made real.

It is almost never discussed in specifics (oh the glue-stuff is complex ... but but microservices).
The glue stuff though is what really matters when building scalable and distributed services, as without it...well good luck!

The aim of this project is simplify the complex process of setting up a secure, well-configured, scalable, manageable multi-cloud infrastructure 
where fault-tolerant distributed or shared concerns are available to use in ServiceStack via the plugin model relatively painlessly.

The concerns that are handled cover the following areas:

* logging
* service discovery
* security
* centralised configuration
* centralised data storage
* tracing
* certificate management
* key auto-rotation
* reverse-routing / api gateway
* CQRS with event sourcing

NOTE: The initial version will focus only on Azure, but will support adding alternative cloud-providers for a multi-cloud infrastructure.

## What it isn't...

A hello-world demo app.

This repo will bootstrap and manage an enterprise-level, securely configured, fault-tolerant, highly available, distributed set of infrastructure services
and container hosts for you to deploy ServiceStack instances into.

## What it does?

In simple terms, it does one or more of the following, depending on how you configure it:

* sets up a cloud connections for terraform 
* sets up infrastructure servers in the cloud
* One or more datacenter server clusters to
  * configure the servers with a consul cluster for service discovery and distributed configuration
  * configure the servers with a nomad cluster for managing and deploying container-based apps
  * configure the servers for encrypted certificate, key and secret storage with vault using consul as the backing store
  * configure the servers with a redis cluster for api rate-limiting and ormLite storage
  * configure the servers with an eventstore cluster for easy event-sourcing with servicestack
  * configure the servers with identity server endpoints for authentication and authorisation
  * configure elastic-scaling server instances to deploy and run your container-based (ServiceStack) apps into
  * configure backups for the infrastructure services configuration and data, to one or more cloud-storage providers

To fully cover why and how all these things are used is beyond the scope of this readme. For more information on this, please 
view my series of blog posts on ServiceStack @ [http://wwwlicious.com](http://wwwlicious.com)

## Prerequisites

* Powershell v5 - the main bootstrap script is written for powershell v5.0, check your version using `$PSVersionTable`
* Azure account - the default cloud-provider is azure, depending on demand, other providers can be added
* Ability to download / proxy access - the windows binary for terraform is downloaded
* A suitable network group in Azure to attach the VM's to
* Some background knowledge - the purpose of this bootstrapper is to help you shortcut some of the specifics of the service configuration but is not a replacement for your own research

[PLEASE NOTE: The terraform configuration will create and configure virtual machines that cost money to run]

## Getting started

clone the repo

```
cd <EnterWorkingDirHere>
git clone https://github.com/wwwlicious/servicestack-orchestration.git
```

### First up, setting up terraform

It all starts with the `azure-setup.ps1` script. There are two options to choose from:

* `azure-setup.ps1 requirements` - This will check that you have the requisite powershell module for managing azure remotely.
* `azure-setup.ps1 setup` - This will guide you through creating the terraform azure connection and download the terraform windows binary

lets get started shall we.

first, launch powershell in the repo cloned directory.

```
powershell
```

#### requirements 

Skip this step if you already have the azurerm powershell module installed.

```
.\azure-setup.ps1 requirements 
```

#### setup

Gets the terraform binary and creates a terraform `azure-connection.tf` file.
You will be asked to:

* login to Azure
* select the correct subscription
* (optional) override the default name (terraform) for an Azure AD App Registration service principal. This the principal which will allow terraform to manage the resources in it's configuration.
* (optional) override the default .net generated client secret

```
.\azure-setup.ps1 setup
```

If you run both these commands and follow the directions, you should now have:

* the terraform executable in a `.tools` directory.
* a valid `azure-connection.tf` to azure that terraform will use to create azure resources.

Next up we will cover the default config and how to customise it
before we go ahead and create our cloud-resources (the things that cost you money)

## Default config

For the next step, you should review and modify the default config as required.

* `SS-Orc.tfvars` - This is the main configuration file, open this file in your preferred text editor

The file contains documentation in the comments. By default, most of the setup is commented out to prevent
accidentally spinning up cloud resources.

[WIP]


## Bootstrapper

Now, we will cover in more detail the steps the bootstrapper performs along with some background information and the configuration points.
It all starts with the `azure-setup.ps1` script

### Setup

The `azure-setup.ps1` script container two options:

1. `azure-setup.ps1 requirements` - This will check that you have the requisite powershell module for managing azure remotely.
2. `azure-setup.ps1 setup` - This will guide you through creating the terraform azure connection and download the terraform windows binary
