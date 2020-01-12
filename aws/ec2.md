# Amazon EC2

Amazon Elastic Compute Cloud (Amazon EC2) provides scalable computing capacity in the Amazon Web Services (AWS) cloud.

## Features

- Preconfigured templates for your instances, known as `Amazon Machine Images (AMIs)`.
- Various configurations of CPU, memory, storage and networking capacity known as `instance type`.
- Secure login information for your instances using `key pairs`.
- Storage volumes for temporary data that's deleted when you stop or terminate your instance, known as `instance store volumes`.
- Persistent storage volumes for your data using Amazon Elastic Block Store (Amazon EBS), known as `Amazon EBS volumes`.
- A firewall that enables you to specify the protocols, ports and source IP ranges that can reach your instances using `security groups`.
- Static IPv4 addresses for dynamic cloud computing, known as `Elastic IP addresses`.
- Metadata, known as `tags`, that you can create and assign to your Amazon EC2 resources.
- Virtual networks you can create that are logically isolated from the rest of the AWS cloud, and that you can optionally connect to your own network, known as `virtual private clouds (VPCs)`.

## Security Best Practices

- Use AWS Identity and Access Management (IAM) to control access to your AWS resources.
- Restrict access by only allowing trusted hosts or networks to access ports on your instance.
- Review the rules in your security groups regularly, and ensure that you apply the principle of `least privilege`--only open up permissions that you require.
- Disable password-based logins for instances launched from your AMI.

## Terminating an instance

When an instance is terminated, the instance performs a normal shutdown. The root device volume is deleted by default, but any attached Amazon EBS volumes are preserved by default, determined by each volume's `deleteOnTermination` attribute setting. The instance itself is also deleted, and you can't start the instance again at a later time.

To prevent accidental termination, you can disable instance termination. If you do so, ensure that the `disableApiTermination` attribute is set to true for the instance. To control the behavior of an instance shutdown, such as shutdown -h in Linux or shutdown in Windows, set the `instanceInitiatedShutdownBehavior` instance attribute to stop or terminate as desired. Instances with Amazon EBS volumes for the root device default to stop, and instances with instance-store root devices are always terminated as the result of an instance shutdown.

## Regions, Availability Zones, and Local Zones

Amazon EC2 is hosted in multiple locations world-wide. These locations are composed of Regions, Availability Zones, and Local Zones.

Each Region is completely independent. Each Availability Zone is isolated, but the Availability Zones in a Region are connected through low-latency links. A Local Zone is an AWS infrastructure deployment that places select services closer to your end users.

![Image](../../image/aws_regions.png)

## Amazon EC2 Root Device Volume

You can launch an instance from either an instance store-backed AMI or an Amazon EBS-backed AMI.

Any data on the instance store volumes persists as long as the instance is running, but this data is deleted when the instance is terminated (instance store-backed instances do not support the Stop action) or if it fails (such as if an underlying drive has issues).

An Amazon EBS-backed instance can be stopped and later restarted without affecting data stored in the attached volumes.

## Best Practices for Amazon EC2

Security and Network:

- Manage access to AWS resources and APIs using identity federation, IAM users, and IAM roles.
- Implement the least permissive rules for your security group.
- Regularly patch, update, and secure the operating system and applications on your instance.

Storage:

- Undertand the implications of the root device type for data persistence, backup, and recovery.
- Use separate Amazon EBS volumes for the operating system versus your data.
- Use the instance store available for your instance to store temporary data.
- Encrypt EBS volumes and snapshots.

Resource Management:

- Use instance metadata and custom resource tags to track and identify your AWS resources.
- View your current limits for Amazon EC2.

Backup and Recovery:

- Regularly backup your EBS volumes using Amazone EBS snapshots, and create on Amazon Machine Image (AMI) from your instance to save the configuration as a template for launching future instances.
- Deploy critical components of your application across mutiple Availability Zone, and replicate your data appropriately.
- Design your applications to handle dynamic IP addressing when your instance restarts.
- Monitor and respond to events.
- Ensure that you are prepared to handle failover.
- Regularly test the process of recovering your instances and Amazon EBS volumes if the fail.

## Storage

- Amazon Elastic Block Store
- Amazon EC2 Instance Store
- Amazon Elastic File System
- Amazon Simple Storage Service

![image](../../image/aws_architecture_storage.png)

EBS volumes are created in a specific Availability Zone, and can then be attached to any instances in that same Availability Zone.


## Reference

- [AWS EC2](https://docs.aws.amazon.com/ec2/?id=docs_gateway)
