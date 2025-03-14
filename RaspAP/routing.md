## Understanding and Adjusting Routing Metrics on Your Raspberry Pi Hotspot

The issue you encountered with routing metrics is directly related to how your Raspberry Pi decides which interface (wlan0 or wlx90de8088773b) to use when sending out traffic that isn't specifically directed by your `iptables` rules.  Here's a breakdown:

**1. Why Routing Metrics Matter**

*   **Multiple Network Interfaces:** Your Raspberry Pi has (at least) two network interfaces: `wlan0` (connected to the internet) and `wlx90de8088773b` (your hotspot's Wi-Fi dongle).  When the Pi needs to send a packet, and there isn't a specific rule dictating which interface to use, it relies on the routing table.
*   **Routing Table & Default Gateway:** The routing table contains entries that tell the Pi how to reach different networks.  Crucially, it includes a "default gateway" entry.  This is the "catch-all" route; if a destination IP address doesn't match any other entry in the routing table, the packet is sent to the default gateway.
*   **Metric (Cost):** Each entry in the routing table, including the default gateway entry, has a *metric*.  The metric is a numerical value representing the "cost" of using that route.  A *lower* metric is preferred. The Pi will always choose the route with the lowest metric to reach a destination.
*   **The Problem:** If your `wlx90de8088773b` interface (the hotspot interface) has a lower metric than your `wlan0` interface (the internet connection), the Pi might try to send *all* outgoing traffic (including traffic destined for the internet) through the hotspot interface.  This will obviously fail because the hotspot interface is designed to *receive* connections from client devices, not to connect to the internet itself.  Your internet traffic needs to go out through `wlan0`.

**2. Checking the Current Routing Table and Metrics**

You can use several commands to check the routing table and metrics:

*   **`route -n`**: This is the classic command.  The `-n` option shows IP addresses numerically instead of trying to resolve them to hostnames (which is faster and often clearer).

    ```bash
    route -n
    ```

    Example Output (yours will be different, but this illustrates the key parts):

    ```
    Kernel IP routing table
    Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
    0.0.0.0         192.168.1.1     0.0.0.0         UG    202    0        0 wlan0
    0.0.0.0         192.168.20.1    0.0.0.0         UG    303    0        0 wlx90de8088773b
    192.168.1.0     0.0.0.0         255.255.255.0   U     202    0        0 wlan0
    192.168.20.0    0.0.0.0         255.255.255.0   U     303    0        0 wlx90de8088773b
    ```

    *   **`0.0.0.0`**: Represents the default gateway (any destination not otherwise specified).
    *   **`Gateway`**: The IP address of the next hop router.
    *   **`Flags`**: `U` means the route is up, `G` means it's a gateway route.
    *   **`Metric`**: **This is the key column.**  In this example, `wlan0` has a metric of 202, and `wlx90de8088773b` has a metric of 303.  `wlan0` would be preferred (which is correct).  If it were reversed, you'd have the problem you described.
    *   **`Iface`**: The interface associated with the route.

*   **`ip route show`**:  This is the newer, more powerful command (and the preferred way).

    ```bash
    ip route show
    ```

    Example Output:

    ```
    default via 192.168.1.1 dev wlan0 proto dhcp metric 202
    default via 192.168.20.1 dev wlx90de8088773b proto static metric 303
    192.168.1.0/24 dev wlan0 proto dhcp scope link metric 202
    192.168.20.0/24 dev wlx90de8088773b proto kernel scope link metric 303
    ```

    This output is similar, but the `ip` command provides more detailed information (e.g., the `proto` field indicating how the route was learned). The important part, again, is the `metric`.

**3. Temporarily Modifying the Metric (for Testing)**

You can *temporarily* change the metric using either the `route` or `ip` command.  Changes made this way will be lost on reboot.

*   **Using `route` (less preferred, but still works):**

    ```bash
    # Delete the existing default route for the problematic interface (wlx...)
    sudo route del default gw 192.168.20.1 dev wlx90de8088773b  # Replace IP with the actual gateway

    # Add a new default route with a higher metric
    sudo route add default gw 192.168.20.1 dev wlx90de8088773b metric 1000
    ```
    First we delete the route because we can't modify the metric with route command.
    Note: If it is not the gateway of you wlx interface, `ip route show`will help you to find it

*   **Using `ip` (recommended):**

    ```bash
    sudo ip route change default via 192.168.20.1 dev wlx90de8088773b metric 1000
    ```
     Or, more directly, change it for all routes associated with the interface:
    ```bash
        sudo ip route change dev wlx90de8088773b metric 1000

    ```

    This command *changes* the existing default route associated with `wlx90de8088773b` and sets its metric to 1000 (a high value, making it less preferred). Replace `192.168.20.1` with the actual gateway IP address for your hotspot interface if it's different.  You can find the gateway IP using `ip route show`.

**4. Permanently Modifying the Metric**

To make the metric change permanent, you need to modify the network configuration files.  The specific method depends on how your network interfaces are configured (DHCP, static IP, NetworkManager, etc.).  Here are the most common scenarios:

*   **Scenario 1: Using `dhcpcd` (Raspberry Pi OS default)**

    Raspberry Pi OS uses `dhcpcd` by default to manage network interfaces.  You can modify its configuration file:

    ```bash
    sudo nano /etc/dhcpcd.conf
    ```

    Add or modify the following lines *at the end of the file*, specifically for your `wlx90de8088773b` interface:

    ```
    interface wlx90de8088773b
        metric 1000
    ```
    If an interface section already exists for wlx*, modify the metric value.

    Save the file (Ctrl+O, Enter, Ctrl+X) and reboot:

    ```bash
    sudo reboot
    ```
    This tells dhcpcd to always assign metric 1000 to wlx*