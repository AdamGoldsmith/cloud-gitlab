### Work in Progress Notes

Rough progress tracking file

#### Achievements

* Able to create GCP cloud bucket for remote state
  * Currently done using Ansible to create the bucket. Might move this fully into terraform however doing it using Ansible removes chicken & egg for initial state file
  * Able to parameterize and send the GCP bucket data to terraform via the `terraform` module

#### To do

* Lots!
* Get a grip on all the non-DRY variables - saw this [blog post](https://troylindsayblog.wordpress.com/2018/04/12/one-way-to-implement-global-variables-in-terraform/) suggesting writing a terraform module that does nothing but spit out static variables to be referenced via standard `module.<module_name>` methodology (add `terraform/modules/global_variables/` to .gitignore)
* Use `gcp_data['ssh_user']` & `gcp_data['ssh_pubkey']` when passing to terraform (needed for instance creation)
* Consider moving instance creation into a DRY reusable module directory
* Check if all network tiers can be set to STANDARD
* Remove repeated playbook tasks - maybe keep the `terraform.yml` task file. This will require setting base service data correctly in localhost `gcp.yml` file
* Consider making the bucket creation a single one-time project initiation event - move it out of base
* Create a bucket-removal task for complete project resource removal
* Add health check for vault load balancer

#### Done

* Consider renaming terraform dir "vpc" to "base" so it can be referenced by service_name variable from Ansible
