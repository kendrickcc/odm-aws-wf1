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
    groups: sudo, docker
    ssh_authorized_keys:
      - ${ssh_key}

#
# run commands
runcmd:
  - sudo mkdir -p /odm/data
  - sudo chown -R odm:odm /odm
  - sudo --user=odm docker run -p 3000:3000 opendronemap/nodeodm