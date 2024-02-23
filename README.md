# Rainey-Ansible

These are ansible scripts to set up the Rainey site.

Start with
> ansible-playbook -i hosts bootstrap.yml --ask-become-pass

To bootstrap everything. Then run

> ansible-playbook -i hosts site.yml

To set up all the servers.

## Assumptions

The site assumes we have a `compute` group of GPU-enabled machines with a local user `ladmin` which has the same password across the machines. The `ladmin` user also has a home directory at `/local/home/ladmin` instead of the default (to allow for NFS homes).

## TODOs
- Ensure cockpit is loaded
- Enroll in IPA realm on each machine
- Set up IPA automounts