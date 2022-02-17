# OpenDroneMap in AWS using GitHub workflow actions

## Setup

In AWS IAM, create a user with full access and create access keys. Download the file. Under GitHub settings, under secrets, create and enter AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.

Reference article on setting this up: https://medium.com/@kymidd/lets-do-devops-github-actions-terraform-aws-77ef6078e4f2


curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt install -y nodejs
cd /odm/ClusterODM
sudo npm install



sudo --user=odm docker run --rm -ti -p 3000:3000 -p 8080:8080 opendronemap/clusterodm