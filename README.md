# pomelo_fashion

The whole configuration is written in Terraform and can be found in the main.tf.

The access key and secret key needs to be entered into the Github dashboard for the terraform to apply its changes to a aws account.

Before triggering a deployment an s3 bucket needs to be created with the name pomelo-production-terraform-state in the aws account so that the terraform state can be saved.

After this configuration is finished a github action can be triggered with either a git push or a manual run on the git hub dashboard.

* Additional non-default VPC with internet gateway and route table
    The Terraform code has the configuration to create a non default VPC together with an internet gateway, a NAT gateway and two route tables 
* Private and Public Subnets
    There is a public subnet configured with its own route table for the publicly accessible website and two private subnets with its own route table for the database instance
* SSH Key Setup
    SSH keys are setup with Terraform as well and is installed in the web server
* Virtual Compute instances that run a web service
    AN EC2 instance is configured with terraform in the public instance with nginx and a sample html website which is configured during boot up of the instance with the help of a userdata file
* Virtual Compute instances that run a database, bonus points for leveraging an external source such as RDS
    RDS is leveraged for the database and is deployed with the terraform config
* Render a simple website that shows information being either pulled out of the data layer or from some 3rd party API
    A simple html website is configured which can be accessed publicly
* Logging enabled to a central place
    Cloudwatch agent is configured when the ec2 instance is deployed to send the nginx access/error logs to cloudwatch logs to centralize logging. Proper Iam roles are also configured for authentication