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
# groups
groups:
  - docker: ubuntu

#
# users
users:
  - default
  - name: odm
    sudo:  ALL=(ALL) NOPASSWD:ALL
    groups: docker
    ssh_import_id:
      - gh:id_rsa_webodm

write_files:
  - path: /etc/systemd/system/webodm.service
    owner: odm:odm
    content: |
      [Unit]
      Description=WebODM
      After=network.target
      After=systemd-user-sessions.service
      After=network-online.target
      [Service]
      Type=simple
      ExecStart=/odm/WebODM/webodm.sh start --media-dir /odm/data
      ExecStop=/odm/WebODM/webodm.sh stop
      TimeoutSec=30
      Restart=on-failure
      RestartSec=30
      StartLimitInterval=350
      StartLimitBurst=10
      [Install]
      WantedBy=multi-user.target
  - path: /home/ubuntu/webodm.pem
    owner: ubuntu:ubuntu
      - ${pem_key}

#
# run commands
runcmd:
  - sudo mkdir -p /odm/data
  - git clone https://github.com/OpenDroneMap/WebODM --config core.autocrlf=input --depth 1 /odm/WebODM
  - sudo chown -R odm:odm /odm
  - sudo --user=odm docker run -d --rm -ti -p 3000:3000 -p 10000:10000 -p 8080:8080 opendronemap/clusterodm
  
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