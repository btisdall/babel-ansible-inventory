babel-ansible-inventory
=======================

Ansible is neat but the basic static inventory file format is very limiting - to take advantage of host selection syntax to target hosts based on multiple host attributes requires repeating yourself many times over. This code, inspired by the ec2 dynamic inventory plugin, takes an input inventory file in structured form and outputs JSON in the form expected by Ansible. The structure of the input inventory file should be hash, where the top level keys are 'hosts' & 'defaults'. The value of 'hosts' should be an array of hashes, within each member hash the only mandatory value is 'hostname' which should correspond to a hostname or IP address.

To see it work try something like:

```
ansible -i /path/to/babel-ansible-inventory/inventory.rb  'environment_production:&role_frontend' --list-hosts
```
