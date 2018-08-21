
## Bastion
* The Bastion server will use the same SSH key as the nginx instances.
* In order to conect to nginx instances use the following:

```bash
eval `ssh-agent`
ssh-add <SSH KEY PATH>
ssh ubuntu@$(terraform output bastion) -A 
# This will connect you to the Bastion
ssh ec2-user@<nginx instance id>
```

To test the the ELB you need to run
``` terraform output nginx_elb_domain | xargs curl ```
