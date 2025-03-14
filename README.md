# Remote control of Raspbery-pi through SSH

[Check this guide guide](https://www.instructables.com/Remotely-Control-Your-Raspberry-Pi-Via-SSH-From-an/)


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
