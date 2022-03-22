# kubernetes_on_hyperv
Local Development Cluster based on Rancher 2.x and Hyper-V VMs with Static IPs.

Prerequisites:
  1. Internal Switch configured in the Hyper-V Manager (We use the LabSwitch name for the switch as an example).
  2. All VMs are configured using static IP addresses. 
  3. One configuration Hyper-V VM used to spin-up a Kubernetes cluster through Rancher Kubernetes Engine (RKE). 
  4. More VMs, depending on how many nodes your cluster must have :-)

1. Configuring an Internal Switch for the Hyper-V VMs.
------------------------------------------------------
This will allow to have internet connectivity inside the virtual machines, plus it allows you to configure a static IP address.
Using a PowerShell console, launch the following commands:
# Creates a new virtual switch.
# This internal switch is associated to an adapter which will use a NAT to translate internal addresses for external communication.
New-VMSwitch -SwitchName LabSwitch -SwitchType Internal

# Lists all switches, including the one created before showing also its InterfaceIndex number for reference.
Get-NetAdapter

# Creates a new IP address associated with the adapter created before. This IP is the gateway while
# the prefixlenghth represents the netmask (24 = 255.255.255.0). The InterfaceIndex is the value associated with the Network Adapter
# shown by the previous command. The following command will allow to map the VMs with the 192.169.0.xxx IP addresses.
New-NetIPAddress -IPAddress 192.169.0.1 -PrefixLength 24 -InterfaceIndex 51

# Creates a new NAT associated to the adapter and using the IP range specified in the adapter.
New-NetNat -Name LabNAT -InternalIPInterfaceAddressPrefix 192.169.0.0/24

# If you want to cleanup all the previous created objects, you can launch the following commands:
Remove-NetIPAddress -InterfaceAlias "vEthernet (LabSwitch)" -IPAddress 192.169.0.1  
Remove-VMSwitch "LabSwitch"
Get-NetNat
Remove-NetNat LabNAT
Get-VMSwitch

2. Static IP addresses for VMs.
-------------------------------
Assuming you're using a RHEL compatible Linux distribution, you can associate a static IP address to the VM using the nmtui command tool.
You just modify the eth0 network interface and you specify that you want to configure an IP manually instead of retrieving it from the DHCP.
Address: 192.169.0.5/24 (for the IP address, based on the IP address set on the network adapter configured previously)
Gateway: 192.169.0.1
DNS Server: 8.8.8.8 (any dns server is good)

3. Configuration VM (used with RKE to spin up a Kubernetes Cluster)
This VM should be able to connect to other VMs through SSH and in a passwordless way.

# The following command will generate a new 4096 bits SSH key pair using your email address for the comment section.
ssh-keygen -t rsa -b 4096 -C "your_email@domain.com"

# Now that you have generated an SSH key pair, in order to be able to login to your server without a password you need to copy 
# the public key to the server you want to manage.
ssh-copy-id remote_username@server_ip_address

# Login to the server
ssh remote_username@server_ip_address

3. Installing a Rancher cluster through RKE.
You're now ready to launch a RKE Kubernetes cluster. Just follow rancher/README.md file.
