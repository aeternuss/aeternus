# Terraform - Getting Started

Terraform is a tool for building, changing, and versioning infrastructure safely and efficiently.

Key features of Terraform:

- Infrastructure as code
- Execution Plans
- Resource Graph
- Change Automation

## Introduction to Infrastructure as Code with Terraform

At a high level, Terraform allows operators to use HCL(HashiCorp Configuration Language)
to author files containing definitions of their desired resources on almost any provider
(AWS, GCP, GitHub, Docker, etc) and automates the creation of those resources at the time of apply.

### Workflows

A simpe workflow for deployment will follow closely to the steps below:

- Scope - Confirm what resources need to be created for a given project
- Author - Create the configuration file in HCL based on the scoped parameters
- Initialize - Run `terraform init` in the project directory with the configuration files.
- Plan & Apply - Run `terraform plan` to verify creation process and then `terraform apply` to create realresources
  as well as state file that compares future changes in your configuration files to what actually exists in your deployment enviroment.

### State Management

Terraform creates a state file when a project is first initialized.
Terraform uses this local state to create plans and make changes to your infrastructure.
  
## Installing Terraform

Terraform is distributed as a binary package for all supported platforms and architectures.

```bash
TERRAFORM_VERSION=0.12.18
wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/terraform_${TERRAFORM_VERSION}
ln -sf -T terraform_${TERRAFORM_VERSION} /usr/local/bin/terraform
```

## Build Infrastructure

### Configuration

The set of files used to describe infrastructure in Terraform is simply known as a Terraform configuration.

```HCL
# Filename: ec2.tf

provider "aws" {
    profile = "default"     # ~/.aws/credentials
    region  = "us-east-1"
}

resource "aws_instance" "example" {
    ami             = "ami-2757f631"
    instance_type   = "t2.micro"
}
```

#### Providers

A `provider` is responsible for creating and managing resources.
A provider is a plugin that Terraform uses to translate the API interactions with the service

Multiple provider blocks can exist if a Terraform configuration is composed of multiple providers.

#### Resources

The `resource` block defines a resource that exists within the infrastructure.

The resource block has two strings before opening the block:
the resource type and the resource name. Within the resource block itself is configuration for that resource.

### Initialization

The first command to run for a new confiuration -- or after checking out an existing configuration from version control --
is `terraform init`, which initializes various local settings and data that will be used by subsequent commands.

The provider plugin is downloaded and installed in a subdirectory of the current working directory,
along with various other book-keeping files.

### Formatting and Validating Configurations

The `terraform fmt -recursive` command enables standardization which automatically update configurations
for easy readability and consistency.

The `terraform validate` command will check and report errors within modules, attribute names, and value tyes.

### Apply Changes

Run `terraform apply` in the work directory.

The output shows the `execution plan`, describing which actions Terraform will take in order to
change real infrastructure to match the configuration. Executing the plan will apply these changes.

Terraform also wrote some data into the `terraform.tfstate` file.
This state file is extremely important: it keeps track of the IDs of created resources so that Terraform knows what it is managing.

You can inspect the current state using `terraform show`.

#### Manually Managing State

Terraform has a build in command called `terraform state` which is used for advanced state management.

### Provisioning

Many infrastructures still require some sort of initialization or software provisioning step. Terraform supports `provisioners`.

## Change Infrastructure

Infrastructure is continuously evolving, and Terraform was built to help manage and enact that changes.

As you change Terraform configurations, run the `terraform apply` Terraform builds an execution plan that only modifies what is necessary to reach your desired state.

## Destroy Infrastructure

Resources can be destroyed using the `terraform destroy` command, then all of the resources have been removed from the configuration.

## Resource Dependencies

- Implicit Dependencies
- Explicit Dependencies

```HCL
resource "aws_eip" "ip" {
    vpc = true
    instance = aws_instance.example.id
}
```

Terraform can automatically infer when one resource depends on another.
Terraform uses this dependency information to determine the corrent order in which to create the different resources.

`Implicit dependencies` via interpolcation expressions are the primary way to inform Terraform about these relationships, and should be used whenever poosible.

Sometimes there are depenedencies between resources that are not visable to Terraform. The `depends_on` argument is accepted by any resource and acceptes a list resources to create `explicit dependencies` for.

## Provision

If you're using an image-based infrastructure (perhaps with images create with `Packer`), then what you've learned so for is good enough.
But if you need to do some initial setup on your instances, then provisioners let you upload files,
run shell scripts, or install and trigger other software like configuration management tools, etc.

### Defining a Provisioner

Multiple `provisioner` blocks can be added to define multiple provisioning steps.

The `local-exec` provisioner executes a command locally on the machine running Terraform.

```HCL
resource "aws_instance" "example" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.example.public_ip} > ip_address.txt"
  }
}
```

The `remote-exec` provisioner invokes a script on a remote resource after it is created.
In order to use a `remote-exec` provisioner, you must choose an `ssh` or `winrm` connection in the form
of a `connection` block within the provisioner.

```HCL
resource "aws_key_pair" "example" {
  key_name = "examplekey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "web" {
  key_name = aws_key_pair.example.key_name
  # ...

  connection {
    type     = "ssh"
    user     = "root"
    private_key = file("~/.ssh/id_rsa")
    host     = self.ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo amazon-linux-extras enable nginx1.12",
      "sudo yum -y install nginx",
      "sudo systemctl start nginx"
    ]
  }
```

### Running Provisioners

Provisioners are only run when a resource is `created`.

There are `not` a replacement for configuration management which you should use Terraform provisioning
to invoke a real configuration management solution.

### Failed Provisioners and Tainted Resources

If a resource successfully creates but fails during provisioning.
Terraform will error and mark the resource as `tainted`.

When you generate your next execution plan, Terraform will not attempt to restart provisioning on the same resource
because it isn't guaranteed to be safe.
Instead, Terraform will remove ant tainted resources and create new resources, attempting to provision them again after creation.

#### Manually Tainting Resources

In cases where you want tot manually destroy and recreate a resource, Terraform has a built in `taint` function in the CLI.

```bash
terraform taint aws_instance.example
```

### Destroy Provisioners

Provisioners can also be defined that run only during a destroy operation.
These are useful for performing system cleanup, extracting data, etc.

## Input Variables

To become truly shareable and version controlled, we nned to parameterize the configurations.

### Defining Variables

```HCL
# Filename: variables.tf

# String
variable "region" {
    type    = string
    default = "us-east-1"
}

# List
variable "cidrs"  { default = [] }
variable "cidrs2" { type = list }
variable "cidrs3" {
    default = ["10.0.0.0/16", "10.1.0.0/16 ]
}

# Maps
# Maps are a way to create variables that are loopup tables
variable "amis" {
    type = "map"
    default = {
        "us-east-1" = "ami-b374d5a5"
        "us-west-2" = "ami-4b32be2b"
    }
}
```

### Using Variables in Configuration

```HCL
provider "aws" {
    region = var.region
}

resource "aws_instance" "example" {
    ami           = var.amis[var.region]
    instance_type = "t2.micro"
}
```

### Assigning Variables

The following is the descending order of precedence in which variables are considered.

#### Command-line flags

You can set variables directory on the command-line with the `-var` flag.

```bash
terraform apply -var "regon=us-east-2"
```

#### From a file

To persist variable values, createa file and assign variables within this file.

```bash
terraform apply -var-file="secret.tfvars" -var-file="prod.tfvars"
```

For all files which match `terraform.tfvars` or `*.auto.tfvars` present in the current directory,
Terraform automatically loads them to populate variables.

#### From environment variables

Terraform will read environment variables in the form of `TF_VAR_name` to find the value for a variable.

For example, the `TF_VAR_region` variable can be set to set the `region` variable.

#### UI Input

If you execute `terraform apply` with certain variables unspecified, Terraform will ask you to input their values interactively.

#### Variable Defaults

If no value is assigned to a variable via any of these methods and
the variable has a `default` key in its declaration, that value will be used for the variable.

## Output Variables

Output variables is a way to organize data to be easily queried and shown back to the Terraform user.

The data is outputted when `apply` is called, and can be queried using the `terraform output` command.

### Defining Outputs

Multiple `output` blocks can be defined to specify multiple output variables.

```HCL
output "ip" {
    value = aws_eip.ip.public_ip
}
```

### Viewing Ouputs

Run `terraform apply` to populate the output.

You can also query the outputs after apply-time using `terraform output`.

## Modules

`Modules` in Terraform are self-contained packages of Terraform configurations that are managed as a group.
Modules are used to create reusable components, improve organization, and to treat pieces of infrastructure as a black box.

### Using Modules

The [Terraform Registry](https://registry.terraform.io/) includes a directory of ready-to-use modules for various common purposes.

```HCL
terraform {
  required_version = "0.11.11"
}

provider "aws" {
  access_key = "AWS ACCESS KEY"
  secret_key = "AWS SECRET KEY"
  region     = "us-east-1"
}

module "consul" {
  source      = "hashicorp/consul/aws"
  num_servers = "3"
}
```

The `source` attribute tells Terraform where the modules can be retrieved.
Terraform automatically downloads and manages modules for you.

Terraform can also retrieve modules from a variety of sources, including private modules registries or directory
from Git, Mercurial, HTTP, and local files.

### Module Versioning

After adding a new module to configuration, it is necesary to run (or re-run) `terraform init`
to obtain and install the new modules's sources code.

By default, this command dose not check for new module versions that may be available.
The `-upgrade` option will additionally check for any newer versions of existing modules and providers that may be available.

You can use the `version` attrubite in the module block to specify version:

```HCL
module "consul" {
  source  = "hashicorp/consul/aws"
  version = "0.7.3"

  servers = 3
}
```

Modules can be nested to decompose complex systems into manageable components.

### Module Outputs

Module can also produce output values, similar to resource attrubites.

```HCL
output "consul_server_asg_name" {
  value = module.consul.asg_name_servers
}
```

## Remote State Storage

In production environments it is considered a best practice to store state elsewhere than your local machine.

Terraform supports team-based workflows with a feature known as `remote backends`
which allow Terraform to use a shared storage space for state data.

### How to Store State Remotely

First, we'll use Terraform Cloud as our backend. Sign up an account from Terraform Cloud.

Next, Configure the backend in your configuration.

```HCL
terraform {
    backend "remote" {
        organization = "<ORG_NAME>"

        workspaces {
            name = "example-workspace"
        }
    }
}
```

You'll also need a user token to authenticate with Terraform Cloud.
You can generate one on the user settings page.

Save the user token to Terraform CLI Configuration file (`~/.terraform.rc`)

```HCL
credentials "app.terraform.io" {
    token = "<ACCESS_TOKEN>"
}
```

Then, run `terraform init` to setup Terraform.
It should ask if you want to migrate your state to Terraform Cloud.

## Reference

- [Learn Terraform](https://learn.hashicorp.com/terraform)
