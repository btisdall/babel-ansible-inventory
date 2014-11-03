babel-ansible-inventory
=======================

Ansible is neat but the basic static inventory file format is very limiting - if you want to take advantage of host selection syntax to target hosts you end up repeating yourself many times over. This code, inspired the ec2 plugin, takes an inventory file in a structured form and outputs JSON in the form expected by Ansible.

To see it work try something like:

```
ansible -i /path/to/babel-ansible-inventory/inventory.rb  'environment_production:&role_frontend' --list-hosts
```
