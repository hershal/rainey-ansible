# Rainey-Ansible

These are ansible scripts to set up the Rainey site.

Note that this entire setup makes several assumptions about the site layout. Read below.

# Setup

Most of everything that's needed for this is already installed in the base ansible install, except for `community.general.dnf_config_manager`.

On your ansible machine, run

    ansible-galaxy collection install community.general

After doing that you should be able to run all the playbooks.

## Assumptions

The site assumes we have a `compute` group of GPU-enabled machines with a local user `ladmin` which has the same password across the machines. The `ladmin` user has a home directory at `/local/home/ladmin` instead of the default to allow for NFS homes of users. Take a look at the hosts file for more information about how this is set up. You may need to run `sudo setenforce 0` on any new nodes prior to running the bootstrap script, because by default RHEL9-based distros don't set up selinux on non-default home directories properly. The bootstrap script fixes this and it will no longer be an issue on later runs.

### Hosts

There are multiple hosts configured here.

There's an `ipaserver` which is the master IPA server. Then there is an `ipareplica` which is the secondary IPA server. Both of these have the main DNS entries pointing externally. All other hosts point two these servers for their own DNS entries. This is required for IPA to work.

Then we have the three other host groups:
- `server`: minimal install with only base server utilities installed to run controller daemons, container-based services, and so on.
- `workstation`: CPU-based workstations which are for development and/or desktop use. These will be a graphical install suitable for testing VMs or desktops, mainly for interactive use.
- `compute`: GPU-enabled servers which will serve as the compute cluster.

These host groups cascade so that `compute` is a superset of `workstation`, which is a superset of `server`, etc.


## New machine install procedure

First, install the new OS with the following considerations:
- Make sure you set up an `ladmin` user with home at `/local/home/ladmin` and with a password that is the same across the site
- Set up the network with a static IP, DNS pointing to the IPA server and replica, and a unique FQDN hostname.

Boot the machine and run `setenforce 0`. Then install the VM guest utils if you need to. Finally, SSH to the host from your ansible machine to populate the `known_hosts` file.

Now we can provision the server. Start with the bootstrap script. This will set up the initial configuration to allow everything else to run smoothly.

    ansible-playbook -i hosts bootstrap.yml --ask-pass --ask-become-pass

Then, to set up the rest of the site, run the following. This will set up all the servers with the required packages and configuration. Make sure you have the vault password handy, or just decrypt the `ipa-sensitive-data.yml` beforehand.

    ansible-playbook -i hosts site.yml --ask-vault-pass

After that, you'll have to set up the automounts on the new machine since there are upstream bugs ([1](https://github.com/freeipa/ansible-freeipa/issues/1166), [2](https://github.com/freeipa/ansible-freeipa/issues/151)) that won't be fixed until 12.2 is released. Consider using CentOS Stream for your ansible machine in the meantime. If not, use this to add automounts on the new machine:

    sudo ipa-client-automount --location nas0 -U

And you're done! The new machine is ready for work.


## Updates

Updating is pretty simple. Just run

    ansible-playbook -i hosts update-site.yml

If you want to download updates first (makes doing a whole-site upgrade faster), run

    ansible-playbook -i hosts update-site-downloadonly.yml


## TODOs
- Set up slurm and enroot/singularity on `compute` nodes with controllers on `server` nodes.
- Set up LDAP-enabled WireGuard services on `server` nodes.
- Set up some kind of metrics aggregation service on `server` nodes.
