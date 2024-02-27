# Rainey-Ansible

These are ansible scripts to set up the Rainey site.

Start with the bootstrap script. This will set up the initial configuration to allow everything else to run smoothly.

    ansible-playbook -i hosts bootstrap.yml --ask-become-pass

Then, to set up the rest of the site, run the following. This will set up all the servers with the required packages and configuration. Make sure you have the vault password handy, or just decrypt the `ipa-sensitive-data.yml` beforehand.

    ansible-playbook -i hosts site.yml --ask-vault-pass

Note that this makes several assumptions about how the site is set up. Read below.

## Assumptions

The site assumes we have a `compute` group of GPU-enabled machines with a local user `ladmin` which has the same password across the machines. The `ladmin` user has a home directory at `/local/home/ladmin` instead of the default to allow for NFS homes of users. Take a look at the hosts file for more information about how this is set up.

## TODOs
- Set up slurm and enroot/singularity on compute nodes
- Set up utils mount points