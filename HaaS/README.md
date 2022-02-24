# HaaS Cluster at IVRL

## Quick Start

### Login

You need to use the EPFL network to access the HaaS servers by `ssh <username>@iccluster<node id>.iccluster.epfl.ch` using your GASPAR.

For IVRL members, use the GASPAR to login [iccluster.epfl.ch](https://iccluster.epfl.ch) as the IVRL member.
The available servers are listed in the *My Servers* tab.
The clusters can be turned on/off or rebooted in the console.

### File System

The home directory is of the NTFS file system and may have issues in access control. Try to prevent installing software there.

The key results should be put in the `ivrldata1` volume mounted at `/ivrldata1`.
There may be several scratch volumes, e.g. `/scratch` and `/runai-ivrl-scratch`, for storing intermediate experimental results.
The `ivrldata1` and `runai-ivrl-scratch` volumes are shared across different nodes while the `/scratch` folder is local.

## Make a Reservation

In the console of [iccluster.epfl.ch](https://iccluster.epfl.ch), *Make a Reservation* is available in the *Reservation* tab.
The reservation can be extended in the *View my Reservations* tab.
The maximum duration of each reservation is 45 days.

## Setup a New Node

### Basic

Every node reserved must be set up first.
In the *Setup* under *My Servers* tab in the console, add the nodes for setup to the list, choose the boot option, customization (choose the IVRL customization) and confirm the setup.

**Once a node is reset, all the data in the local volume will be erased permanently. Network volumes such as `ivrldata1` and `runai-ivrl-scratch` will not be erased.**

### Customize the Setup Script

It is also possible to customize the setup script.
What you need to do is to add the URL containing the script to *%url-post-install-script%* variable in the *Environment* section under the *My Servers* tab.
This URL must contain the **pure text** of the script.

To run the customized script, choose *Own %url-post-install-script%* in the customization page during setup.

One example of the customized script is provided here.



