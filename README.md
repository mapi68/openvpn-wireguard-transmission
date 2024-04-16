# openvpn-wireguard-transmission

* [Overview](#overview)
* [Installation](#installation)
* [License](#license)

## Overview
<b>openvpn-transmision and wireguard-transmission are two scripts that start OpenVPN or Wireguard and transmission-daemon. If OpenVPN or Wireguard crash or server is not available, the scripts stop transmission-daemon service.</b>


## Installation

```bash
wget https://raw.githubusercontent.com/mapi68/openvpn-wireguard-transmission/master/openvpn-transmission.bash
wget https://raw.githubusercontent.com/mapi68/openvpn-wireguard-transmission/master/wireguard-transmission.bash
sudo chmod +x openvpn-transmission.bash wireguard-transmission.bash
sudo ./openvpn-transmission.bash help
sudo ./wireguard-transmission.bash help

```


## License
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
