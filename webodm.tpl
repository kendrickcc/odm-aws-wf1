#cloud-config

#
# package update and upgrade
package_update: true
package_upgrade: true

#
# install packages
packages:
  - docker
  - docker.io
  - docker-compose

#
# users
users:
  - default
  - name: odm
    sudo:  ALL=(ALL) NOPASSWD:ALL
    groups: docker
    ssh_authorized_keys:
      - ${ssh_key}

#
# run commands
runcmd:
  - sudo mkdir -p /odm/data
  - git clone https://github.com/OpenDroneMap/WebODM --config core.autocrlf=input --depth 1 /odm/WebODM
  - sudo chown -R odm:odm /odm
  - sudo --set-home --user=odm /odm/WebODM/webodm.sh start --detached --default-nodes 0 --media-dir /odm/data
  - sudo --set-home --user=odm docker run --detach --rm --publish 3001:3000 opendronemap/nodeodm
  - sudo --set-home --user=odm docker run --detach --rm --tty --publish 3000:3000 --publish 10000:10000 --publish 8080:8080 opendronemap/clusterodm

#  - sudo systemctl enable webodm.service
#  - sudo systemctl start webodm.service
#  - git clone https://github.com/OpenDroneMap/ClusterODM /odm/ClusterODM
#  - curl -fsSL https://deb.nodesource.com/setup_14.x | sudo -E bash -
#  - sudo apt-get install -y nodejs
#  - cd /odm/ClusterODM
#  - sudo npm install
# following command does not really speed up loading
#  - cd /webodm/WebODM
#  - sudo docker-compose -f docker-compose.yml -f docker-compose.nodeodm.yml up --no-start
# sudo --user=odm docker run --rm -ti -p 3000:3000 -p 8080:8080 opendronemap/clusterodm