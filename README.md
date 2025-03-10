# raspberry-pi-home-lab


## Update firewall routing
1. Create the Firewall Rules Script
```bash
nano firewall-rules.sh  
```
2. Copy the content of the firewall-rules.sh file into it
3. Make it an executable
```bash
sudo chmod +x firewall-rules.sh 
```
4. Run the script
```bash
sudo ./firewallo-rules.sh
```

5. Step 4: Make the Rules Persistent

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

6. Reboot
