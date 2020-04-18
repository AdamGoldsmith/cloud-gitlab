## How to use this?

### Set up

1. Export variables and values for them in your local env:

```bash
export GOOGLE_CLOUD_KEYFILE_JSON="path to your access key"
export GOOGLE_PROJECT=“project-id-goes-here”
# this is for bucket access
export GOOGLE_CREDENTIALS="path to your access key"
```

2. Go to backend-setup directory

3. Create `terraform.tfvars` file and populate it:

```terraform
name = "your-unique-bucket-name-here"
```

4. Run:

```terraform
terraform init

terraform plan

terraform apply
```

5. Go back to terraform directory.
6. Create `locals.tf` and populate it as follows:

```terraform
locals {
    vpc_name = "your-vpc-name"
    source_image = "projects/centos-cloud/global/images/family/centos-8"
    gitlab_cidr = "10.0.1.0/24"
    zone = "europe-west3-b"

    instance_name = random_pet.server_name.id
    instance_type = "n1-standard-1"
    ssh_user = "ansible"
    ssh_pubkey = "path-to-your-key"
    
}

resource "random_pet" "server_name" {
}
```

7. In `backend.tf` file change bucket name for your bucket (one that you created in previous step)

8. Create `terraform.tfvars` and populate it with service account email:

```terraform
service_account_email = "service-account-email-here"
```

8. Run terraform init, plan & apply

9. Grab a beer..oh no.. right.. it's too quick, no time for grabbing a beer!

### To do

1. Code clean up
2. Remove modules from tf registry as they are bit old and causing warnings
3. Check if networking is done properly
