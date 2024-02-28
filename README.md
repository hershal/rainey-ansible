# Rainey-Ansible

These are ansible scripts to set up the Rainey site.

Start with the bootstrap script. This will set up the initial configuration to allow everything else to run smoothly.

    ansible-playbook -i hosts bootstrap.yml --ask-pass --ask-become-pass

Then, to set up the rest of the site, run the following. This will set up all the servers with the required packages and configuration. Make sure you have the vault password handy, or just decrypt the `ipa-sensitive-data.yml` beforehand.

    ansible-playbook -i hosts site.yml --ask-vault-pass

Note that this makes several assumptions about how the site is set up. Read below.

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

## TODOs
- Set up slurm and enroot/singularity on `compute` nodes with controllers on `server` nodes.
- Set up LDAP-enabled VPN services on `server` nodes.
- Set up some kind of metrics aggregation service on `server` nodes.
- Fix/investigate why automount autoconfiguration via IPA module does not work (works when manually running `ipa-client-automount --location nas0 -U`)
- Investigate DNS misconfiguration on compute nodes when on VPN (likely due to dns config on `ipaclient` module). May just need to remove `/etc/NetworkManager/conf.d/zzz-ipa.conf`