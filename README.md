# raspberry-pi-home-lab


## Set Up NAT (Network Address Translation)
### 1. Create the Firewall Rules Script
```bash
nano firewall-rules.sh  
```
### 2. Copy the content of the firewall-rules.sh file into it
### 3. Make it an executable
```bash
sudo chmod +x firewall-rules.sh 
```
### 4. Run the script
```bash
sudo ./firewallo-rules.sh
```

### 5. Step 4: Make the Rules Persistent

To ensure that the rules persist across reboots, you need to install iptables-persistent:

Install iptables-persistent:

```bash
sudo apt-get install iptables-persistent
```

During the installation, you will be prompted to save the current rules. Choose Yes for both IPv4 and IPv6 rules.

Verify the rules are saved:
The rules should be saved in /etc/iptables/rules.v4 and /etc/iptables/rules.v6. You can verify this by checking the contents of these files:
cat /etc/iptables/rules.v4  
cat /etc/iptables/rules.v6  

### 6. Reboot and restard the dnsmasq service


## Enable IP forwarding
```bash
sudo sysctl -w net.ipv4.ip_forward=1
```
To make this change permanent, edit the sysctl configuration file:
```bash
sudo nano /etc/sysctl.conf
``` 
Find the line:
#net.ipv4.ip_forward=1  
Uncomment it by removing the # at the beginning of the line, so it looks like this:

net.ipv4.ip_forward=1  
Save and close the file (CTRL + X, then Y, then Enter).
