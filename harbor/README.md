# Harbor Configuration.

Prerequisites.
  1. Install Docker and put the daemon.json file in /etc/docker. Change the IP address accordingly. Also install docker compose plugin.
  2. Download and untar somewhere (generally in /opt) the Harbor Registry archive.
  3. Copy in the folder the harbor.yml with the configuration set to your needs.

## 1. Installation.
Assuming you have untarred the archive in /opt/harbor, launch the install.sh script:
  
    ./install.sh --with-trivy --with-chartmuseum

Trivy is the security scanner for Docker images, chartmuseum is the old way of storing Helm charts on a Docker Registry.

## 2. Configuring systemd in order to start the Harbor Registry.
At the next reboot, Harbor probably will break. This happens because Harbor is launched through Docker Compose and it won't start 
following the correct order for services. To fix this, link the Harbor software to the systemd utility.

   a. Copy the harbor.service file in /etc/systemd/system/harbor.service and edit the paths inside it.

    [Unit]
    Description=Harbor
    After=docker.service systemd-networkd.service systemd-resolved.service
    Requires=docker.service
    Documentation=http://github.com/vmware/harbor
 
    [Service]
    Type=simple
    Restart=on-failure
    RestartSec=5
    ExecStart=/usr/local/bin/docker-compose -f /opt/harbor/docker-compose.yml up
    ExecStop=/usr/local/bin/docker-compose -f /opt/harbor/docker-compose.yml down
    
    [Install]
    WantedBy=multi-user.target
   
   b. Go in the harbor directory and stop it through docker compose:
      
      docker compose down 
   
   c. Enable the Harbor service:
   
    systemctl enable --now harbor
   
   d. Verify the service is up and running:
    
    systemctl status harbor
