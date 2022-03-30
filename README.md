# 🇺🇦 Nenka - a self-hosted VPN for family and friends

This repo contains recipes to set up a [Wireguard](https://www.wireguard.com) VPN for yourself, or for a close group of people

## Why Wireguard

- it's fast
- it's simple to set up
- its privacy concerns (it keeps a list of peer IPs is irrelevant for family use)

## Prerequisites

First, you need a server. I recomend [Vultr](https://www.vultr.com) or [Hetzner](https://www.hetzner.com). You can use a server that you already own, too.

The server must run Ubuntu.

Crucial points for choosing a server:

- traffic is free or cheap; estimate how much traffic you need per month and what it will cost
- the server is in a region that fits you (all traffic from the VPN will originate in the server's region.)
- the server is reasonably close to you (all traffic from you will go to the server first, to the internet second.)
- after setup, make sure the services you need don't block you server IP. I encountered blocks from Apple App Store.

Secondly, install `wg-tools` and `qrencode` on your local machine. On a Mac, use [Homebrew](https://brew.sh):

```sh
brew install wg-tools qrencode
```

You also need [Ruby](https://www.ruby-lang.org/en/) and [Bundler](https://bundler.io).

## Installing

1. Run `rake init` to generate some keys and a basic config file.
2. Open the file and write server's IP address into `host`.
3. Log into the server, run `ifconfig`, make sure that the default network interface matches value in `network_interface` (i saw `eth0` and `enp1s0` as possible values)
4. If this is an existing server, update `ssh_port` with the port you use to login with SSH
5. If this is a new server, I suggest you keep the non-standard port and run `rake init_ssh` to update server-side configuration to switch to the non-standard port.
6. Use `rake addkeys` to generate as many client configs as you need. You will receive zip files with configs. Use [Wireguard apps](https://www.wireguard.com/install/) to add configs on your devices. Each config must be added to one device only. For desktop apps, add the .conf file. For mobile apps, you can open the qr code and scan it with the phone's camera.
7. Run `rake apply` to deploy the configuration to your server.
8. Done! Now you can use Wireguard apps to connect to your new VPN.
9. When you need to add more keys, run `rake addkeys` and `rake apply` again.

## Tasks reference

```
❯ rake -T
rake addkeys   # Generate keys; rake addkeys NAME=mom COUNT=3
rake apply     # Apply all changes without asking
rake dry_run   # Dry run - list changes to apply, without applying them
rake init_ssh  # Switch SSH to the non-standard port defined in the config
rake ssh       # Connect to the server using SSH
```

---
