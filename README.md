# Rainey-Ansible

These are ansible scripts to set up the Rainey site.

Start with the bootstrap script. This will set up the initial configuration to allow everything else to run smoothly.

    ansible-playbook -i hosts bootstrap.yml --ask-become-pass

Then, to set up the rest of the site, run the following. This will set up all the servers with the required packages and configuration.

    ansible-playbook -i hosts site.yml

Note that this makes several assumptions about how the site is set up. Read below.

## Assumptions

The site assumes we have a `compute` group of GPU-enabled machines with a local user `ladmin` which has the same password across the machines. The `ladmin` user has a home directory at `/local/home/ladmin` instead of the default to allow for NFS homes of users.

The hosts file should look something like this:

    [compute]
    <compute nodes>

    [compute:vars]
    ansible_user=ladmin


## TODOs
- Ensure cockpit is loaded and enabled
- Enroll in IPA realm on each machine
- Set up IPA automounts