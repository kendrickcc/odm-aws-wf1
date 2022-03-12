# OpenDroneMap build using Terraform in AWS using GitHub workflow actions

Provision EC2 instances in AWS to run OpenDroneMap. This can all be ran from GitHub using Actions. No need to install Terraform on a local machine. It uses a S3 bucket to manage the Terraform state file.

A typical GitHub action will automatically run when a commit is posted. I opted to change the workflows to manual as I often only run a plan to check code, and more importantly, destroy the entire environment when done. I do not keep anything provisioned or running, aside from the S3 backend. The backend can be destroyed between builds. It is most needed when trying to destroy the environment.

This build also uses ***cloud-init*** to configure the instances, using file `webodm.tpl` and `nodeodm.tbl`. It is important to note that the build will indicate complete but the machine will still need time to download containers and launch. More information on [cloud-init](https://cloud-init.io). This has taken about 5 minutes for all containers to download and launch.

Why Terraform: This provides a fresh clean build for each project. And can easily be decommissioned to save on cloud costs. It allows for testing of software upgrades that may come. In addition, some changes can be made on the fly once provisioned. Port 22 is left closed, but can easily be opened if needed, then simply running the Apply workflow to enable. If changes are made outside of Terraform, i.e. in the AWS Dashboard, then the Destroy workflow may not work. 

## Setup

### Create IAM user with access key

***CAUTION***: The access keys generated grant access to AWS. Take care with these keys. Do not write the key to a file in the repository. Once committed, and even edited out, the history can still expose the key.

In AWS IAM, create a user with full access and create access keys. Download the file. Under GitHub settings, under secrets, create and enter AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.

Reference article on setting this up: (https://medium.com/@kymidd/lets-do-devops-github-actions-terraform-aws-77ef6078e4f2)

### Create SSH keys

This can be done under IAM section, but I've found it necessary to have both keys. I don't recall getting both the private and public keys when I created a SSH key within IAM. Use `ssh-keygen` to create a new key, suggest not to use the default `id_rsa` as you will want to destroy and generate a new set of keys for this environment. 

It may be confusing why the public key is used twice....

For the EC2 build in `webodm.tf`, the public key is pulled from EC2 - Key Pairs and placed into the root user account, which for this instance is `ubuntu`. The files `webodm.tpl` and `nodeodm.tpl` uses the key again, but to create the `odm` user account and then adds the key there.

### Create the S3 backend store

The S3 bucket is needed to manage the Terraform state file. Without this, it is very difficult to make changes to the build while running, or simply the destroy of the entire environment. The state file can contain sensitive build information i.e. credentials, so this probably is best accomplished manually. and is really simple to setup. Refer to this article: (https://www.golinuxcloud.com/configure-s3-bucket-as-terraform-backend/). Since this is a single user setup, I did not setup the DynmoDB table. If there are multiple users, then probably want the table for state locking.

The bucket name is recorded as a secret in the repository.

### (Optional) Install Terraform and AWS CLI locally

If making a lot of changes to the build, it may be faster to have Terraform running locally to debug code. And since connected to AWS, the CLI for AWS will be needed. Even with the backend in AWS, one can still check code against the environment. If using the S3 backend is not desired, then simply comnent out the backend section of the build.

For more information on how to setup Terraform and AWS CLI, refer to this article: (https://learn.hashicorp.com/tutorials/terraform/aws-build)

## Use

### Configuration

1. Generate a new SSH key. I suggest renaming the private key to have a `.pem` extension. This will help keep keys more easily identified going forward. Once the public key is generated, update the file `variables.tf` for the `pub_key` name. 
2. Upload the public key to AWS under EC2 - Key Pairs. This name must match what is in the `variables.tf` file for `pub_key`.
3. Review the `variables.tf` data and adjust. For example, update the repo name, owner and project. This information is used to add tags to the resources in AWS and will help with billing.
4. Verify the AWS region you will be working in. Check `webodm.tf` and `variables.tf` to confirm the region. Note: For the S3 backend, a variable could not be used.
5. Verify the instance type size. The build will add a 100 GiB drive to the build, but you will want to select the appropriate vCPU and memory for the job. I've added a number of sizes in the `variables.tf` for ease. I've not verified all of them. Edit as needed.
6. Check `webodm.tpl` and `nodeodm.tpl` and edit the instance build as needed. This is using ***cloud-init***.
7. Commit all changes back to the repository.

### GitHub setup

- GitHub Secrets: In the repository, navigate to Settings, then under Security, select `secrets`. Create new secrets for the following:

	- AWS_ACCESS_KEY_ID (As mentioned above)
	- AWS_SECRET_ACCESS_KEY (As mentioned above)
	- BUCKET (The S3 bucket name)
	- WEBODM_PUB (Contents of public SSH key)

Also be sure to upload the public key data and name it to match what is in `variables.tf`.

### Plan

- In the GitHub repo, under Actions, select the `A - Terraform Plan` action, then click `Run Workflow` and select the appropriate branch, then `Run Workflow`.

After a few moments, the workflow will begin. Click on the job to watch progress. If fail, check the error messages. If successful, then ready to move to apply. The run has to be successful, and green before it can move to the next phase.

### Apply

- Once the plan workflow is good, repeat the same process for `B - Terraform Apply`.

Progress of the build can be monitored. When complete, navigate to the completed run, then `terraform_apply`, and expand `Terraform Apply`. Scroll to bottom. There should be found the public IP address of the build.

***Note:*** It will take a few moments before the web interface is accessible as all the docker containers need to be retrieved. I've found that is 5 minutes. If after 5 minutes, then should access the instance using SSH. Since the IP address changes with each build, your local `known_hosts` file can get a little messy. Therefore I typically launch SSH with the command below.

    ssh -q -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/[yourPrivateKey].pem ubuntu@[AWS public IP address]

### Output

This workflow is simply there if you need to check the IP addresses again. However, since this is pulled from the `terraform.tfstate` file, it won't reflect any changes if made from the AWS console.

### Destroy

- Once jobs are complete and data retrieved, then the environment can be brought down by running the action `X - Terraform Destroy`. If job is successful, then all resources brought up (exception VPC - DHCP options set) will be removed.

***Note***: The `destroy` workflow has a cron entry to destroy everynight at midnight. This is prevent resources from being provisioned for long periods of time. Maybe forgetting to destroy after a job, or could not access consoles, etc.. Simply a measure to keep costs down.

### Terraform State Destroy

Sometimes the state file becomes out of sync, probably due to a change outside of Terraform, i.e. using the AWS Dashboard. This will be evident when Destroy workflow fails. Run this workflow to reset everything.

## OpenDroneMap

After 5 minutes, WebODM, ClusterODM and nodeODM nodes should be ready to acesss. Open the `B - Terraform Apply` action, and select `Terraform Apply` until you see `Terraform Output`. Expand this section and you should see IP addresses for the nodes. A public IP address for WebODM, then private IP addresses for ClusterODM and any nodes. 

- [public ip]:8000 WebODM
- [public ip]:8001 ClusterODM (Yes, this is changed from the default port of 10000)

Open a browser to the ClusterODM port and add in the nodes using the private IP address. Use port 3001 for the node that is on the WebODM/ClusterODM server, then port 3000 for the other nodes.

Then open port 8000 to access the WebODM portal, and add the ClusterODM using the private IP address and port 8080.