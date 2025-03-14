# Set Up NAT (Network Address Translation)

## How to
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

## Explanation of the `iptables` Commands for RaspAP with Docker

These commands configure the Linux firewall (`iptables`) to allow your Raspberry Pi to act as a router, forwarding traffic between your Wi-Fi dongle (the hotspot) and your main internet connection (wlan0).  They are crucial for making the hotspot functional.

### 1. `iptables -I DOCKER-USER -i wlx90de8088773b -o wlan0 -j ACCEPT`

*   **`iptables`**: This is the command-line utility for configuring the Linux kernel's built-in firewall (netfilter).
*   **`-I DOCKER-USER`**: This inserts a rule at the *beginning* of the `DOCKER-USER` chain.  The `DOCKER-USER` chain is a special chain in `iptables` that Docker uses. Rules in this chain are processed *before* any Docker-specific rules.  This is important because it allows you to override or supplement Docker's default firewall behavior.  If you used `-A` (append), your rule might be overridden by Docker's rules.
*   **`-i wlx90de8088773b`**: This specifies the *input* interface.  `wlx90de8088773b` is your USB Wi-Fi dongle, which is acting as the access point for your hotspot.  This means the rule applies to traffic *coming in* from devices connected to your hotspot.
*   **`-o wlan0`**: This specifies the *output* interface. `wlan0` is your Raspberry Pi's built-in Wi-Fi, connected to your public internet.  This means the rule applies to traffic that is destined to go *out* to the internet.
*   **`-j ACCEPT`**: This is the *target* of the rule.  `ACCEPT` means that if a packet matches the rule's criteria (input interface and output interface), it should be allowed to pass through the firewall.

**In essence, this rule says:** "Allow any traffic coming from the hotspot (wlx90de8088773b) that is intended to go to the internet (wlan0)."  This is the fundamental rule that allows devices on your hotspot to access the internet. Without it, the traffic would be blocked by default.

### 2. `iptables -t nat -C POSTROUTING -o wlan0 -j MASQUERADE || iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE`

*   **`-t nat`**: This specifies that we're working with the `nat` table. The `nat` table is used for Network Address Translation.  NAT is essential for sharing a single public IP address (your Raspberry Pi's `wlan0` IP) among multiple devices on your private hotspot network.
*   **`-C POSTROUTING -o wlan0 -j MASQUERADE`**: This *checks* if a rule already exists in the `POSTROUTING` chain of the `nat` table.
    *   **`POSTROUTING`**:  This chain is used for modifying packets *after* routing has occurred, just before they leave the Raspberry Pi. This is the perfect place for NAT.
    *   **`-o wlan0`**:  Again, this specifies the output interface as `wlan0` (your internet connection).
    *   **`-j MASQUERADE`**: This is the key to NAT.  `MASQUERADE` dynamically changes the source IP address of outgoing packets to the Raspberry Pi's public IP address (`wlan0`).  It also keeps track of these changes so that when responses come back from the internet, it can correctly route them back to the original device on your hotspot.  This is a simpler form of NAT that's ideal for situations where your public IP address might change (e.g., if you get a dynamic IP from your ISP).
*   **`||`**: This is the logical OR operator.  It means "if the previous command fails (returns a non-zero exit code), execute the next command."  In this case, the `-C` command will fail if the rule doesn't exist.
*   **`iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE`**: This *adds* the `MASQUERADE` rule to the `POSTROUTING` chain if it doesn't already exist (due to the `||` operator).  `-A` appends the rule to the end of the chain.

**In essence, this line says:** "If there isn't already a rule to perform NAT on outgoing traffic, create one. Use MASQUERADE to share the internet connection on wlan0."  This is what allows multiple devices on your hotspot to share your single internet connection.

### 3. `iptables -C FORWARD -i wlan0 -o wlx90de8088773b -m state --state RELATED,ESTABLISHED -j ACCEPT || iptables -A FORWARD -i wlan0 -o wlx90de8088773b -m state --state RELATED,ESTABLISHED -j ACCEPT`

*   **`-C FORWARD ... || iptables -A FORWARD ...`**:  Similar to the previous line, this checks for an existing rule in the `FORWARD` chain and adds it if it doesn't exist.  The `FORWARD` chain is used for packets that are being routed *through* the Raspberry Pi (i.e., packets that are not destined for the Pi itself).
*   **`-i wlan0`**:  Input interface is `wlan0` (internet).
*   **`-o wlx90de8088773b`**: Output interface is `wlx90de8088773b` (hotspot).
*   **`-m state --state RELATED,ESTABLISHED`**: This uses the `state` connection tracking module.  This is a very important optimization.
    *   **`RELATED`**:  This matches packets that are related to an existing connection (e.g., a DNS response to a DNS query).
    *   **`ESTABLISHED`**: This matches packets that are part of an already established connection (e.g., data packets in an ongoing TCP stream).
*   **`-j ACCEPT`**: Allow the traffic.

**In essence, this line says:** "If a rule doesn't exist, create one to allow return traffic. Specifically, allow traffic coming *from* the internet that is part of an existing connection or related to an existing connection initiated by a device on the hotspot."  This is crucial for allowing responses to requests made by devices on your hotspot.  Without it, your devices could send requests, but they wouldn't receive the replies.

### 4. `iptables -C FORWARD -i wlx90de8088773b -o wlan0 -j ACCEPT || iptables -A FORWARD -i wlx90de8088773b -o wlan0 -j ACCEPT`

*   This line mirrors the logic of line 1 but operates within the `FORWARD` chain instead of the `DOCKER-USER` chain. It checks for and, if necessary, adds a rule. This line ensure any other connection that weren't catch by line n°3 will be accepted.
*   **`-C FORWARD ... || iptables -A FORWARD ...`**:  Checks and adds to the `FORWARD` chain.
*   **`-i wlx90de8088773b`**: Input interface is `wlx90de8088773b` (hotspot).
*   **`-o wlan0`**: Output interface is `wlan0` (internet).
*   **`-j ACCEPT`**: Allow the traffic.

**In essence, this line says:** "If a rule doesn't exist, create a rule in the `FORWARD` chain to allow traffic from the hotspot to the internet.  This act as a final rule to accept connection that weren't catch by rules n°3.

### 5. `iptables-save > /etc/iptables/rules.v4`

*   **`iptables-save`**: This command dumps the current `iptables` rules to standard output in a format that can be reloaded later.
*   **`> /etc/iptables/rules.v4`**: This redirects the output of `iptables-save` to the file `/etc/iptables/rules.v4`.  This file is a standard location on many Linux distributions (including Raspbian/Raspberry Pi OS) for storing `iptables` rules that should be loaded on boot.

**In essence, this line says:** "Save the current firewall rules to a file so they are automatically applied when the Raspberry Pi restarts."  This is critical for persistence