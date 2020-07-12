Challenge:

task1: https://gist.github.com/houdinisparks/1e0fcdc9bb1c0d6d426e765ab6dc2abd

task2: https://gist.github.com/houdinisparks/b8dcd1d2b5b1179b45b0afe68351e027

Install terraform locally with latest version or any vervion above 0.12

choco install terraform -my

choco install terraform --version 0.12.5 -my

# Following are the versions used for TF providers
> terraform version

Terraform v0.12.28
+ provider.archive v1.3.0
+ provider.aws v2.69.0
+ provider.random v2.3.0
+ provider.template v2.1.2
+ provider.tls v2.1.1

# Execute the commands given below to achieve the desired state
##Important Note: Run all commands under parent directory as we have leveraged `terraform workspace` and `terraform-remote-state(s3)` for our examples, it should work only when you execute it from the parent directory, for example
if you extract the files under ~/terraform-assessment/
> tree ~/terraform-assessment
C:\USERS\<username>\TERRAFORM_ASSESSMENT
├───.terraform
│   ├───modules
│   └───plugins
│       └───windows_amd64
├───ansible-config
├───application
├───modules
│   ├───AutoScaling
│   │   ├───ASG
│   │   ├───ELB
│   │   └───LaunchConfiguration
│   ├───ec2
│   ├───file_upload_s3
│   ├───iam
│   │   ├───instance_profile
│   │   ├───instance_role
│   │   ├───policy
│   │   ├───policy_attachment
│   │   └───user
│   ├───keygen
│   ├───keypair
│   ├───network
│   │   ├───db_subnet_grp
│   │   ├───eip
│   │   ├───eipassocation
│   │   ├───igw
│   │   ├───natgw
│   │   ├───route
│   │   ├───rt
│   │   ├───rtassoc
│   │   ├───securitygroup
│   │   ├───sgrules
│   │   ├───subnets
│   │   └───vpc
│   ├───RDS
│   │   └───MYSQL
│   ├───s3
│   ├───secret-manager
│   ├───ssm
│   ├───ssm_associaton
│   └───ssm_document
├───scripts
├───task1
├───task2
└───terraform.tfstate.d
    ├───commonws
    ├───task1
    └───task2

The solutions to the above challenges resides under task1 and task2 dir.

Get AWS accesskey and secret key and store it in your preferred path with a profile name called `tfassessment`
for ex: C:\Users\<username>\.aws\credentials

In Windows
----------
Now go to file backend.tf and replace the string "<shared_cred_path>" with the below format "C:\\\Users\\<username>\\\.aws\\\credentials"

Do the same in task1\task1.tf and task2\task2.tf for authentication.

Steps to implement the solution
# Init terraform locally
> cd terraform-assessment
> terraform init

# create workspace called commonws if not exists
> terraform workspace new commonws
> terraform workspace new task1
> terraform workspece new task2

> terraform workspace select commonws

# View the workspace created
> terraform workspace list
  default
* commonws
  task1
  task2

# do validate the templates
> terraform validate

#run plan and apply for creating backed resouces(s3 and dynamodb), at this point the state file will be created in local
#dev.tfvars included user defined vairables for our environment

> cat dev.tfvars

#Master variable

#-----------------------------------------

create = "true"

#-----------------------------------------

"This is the master switch for creating the whole infra"


> terraform plan --var-file=dev.tfvars

> terraform apply --var-file=dev.tfvars --auto-approve

you can see a list of outputs, look for the output variable "state_bucket_id", which is the bucket name for our remote state management. Should be something like this.

state_bucket_id = [
  "tf-remote-state20200709180314971200000001",
]

As we know `Remote Backend` does not support interpolation we have to manually copy the bucket name and credentials path to the tf files. Copy the bucket name and go to the path task1\task1.tf, search and replace the string `<state_bucket_name>` with the copied string.
Enable the Backend config in both task1\task1.tf and task2\task2.tf file by removing `#` from line 2 to 12. We are going to execute the task in sequence hence it is advicable to enable one task at a time.

We can invoke both tasks in any order. Backend initialization is one time process assuming we have going in a sequence task1 and then task2, you dont have to perform `step 3` in task2 instructions and vice versa as it was done in task1.

Task1: (Problem #1 and Problem #2 combined)
-------------------------------------------

Execute the following commands from parent folder i.e: ~\terraform-assessment
1. Change the parameter `task1` in task1\task1.tfvars file to `true`; This is to enable and implement task1 solution.
2. Now switch to task1 workspace by invoking `terraform workspace select task1` and do `terraform init task1` .
3. This is the important step as we are migrating the existing tf state to remote backend. Input `yes` to migrate our current state from local to s3. It will copy all state info including the workspaces created to s3 backend.
4. From now on whatever resources we create it will be safely located in s3.
5. do validate your tf files `terraform validate`
6. Perform terraform plan with the parameters from the parent directory, `terraform plan --var-file=dev.tfvars --var-file=task1.tfvars`
7. Please be informed we need both `dev.tfvars` and `task1.tfvars` to create resources.
7. If there isnt any errors it will produce your the list of resources we trying to create for task1.
8. Review the plan, and do `terraform apply --auto-approve --var-file=dev.tfvars --var-file=task1.tfvars`
9. After successful completion you can see the output for the resources created, look for the output `apache_home_page` and click the link provided. It will navigate you to the instance apache default page. Note: If you dont see any page, give it sometime as the instance is invoking ansible scripts for apache, tomcat, mysql.
10. Now look for output string `tomcat_home_page` and click to open tomcat home page.
11. Log in to the console and navigate to `System Manager --> Parameter Store`, you can see your ec2 private key stored in there.
12. Copy and store it in your local to connect to ec2.
13. Now do `telnet localhost 8080`, `telnet localhost 80`, `telnet localhost 3306` to validate the task1 objective.


With this we have successfully completed task1.
---------------------------------------------------------------------------------------------------------------------------------------

Task2: (Architecture Problem)
-----------------------------

Execute the following commands from parent folder i.e: ~\terraform-assessment
1. Change the parameter `task2` in task2\task2.tfvars file to `true`; This is to enable and implement task2 solution.
2. Now switch to task2 workspace by invoking `terraform workspace select task2` and do `terraform init task2` .
3. This is the important step as we are migrating the existing tf state to remote backend. Input `yes` to migrate our current state from local to s3. It will copy all state info including the workspaces created to s3 backend.
4. From now on whatever resources we create it will be safely located in s3.
5. do validate your tf files `terraform validate`
6. Perform terraform plan with the parameters from the parent directory, `terraform plan --var-file=dev.tfvars --var-file=task2.tfvars`
7. Please be informed we need both `dev.tfvars` and `task2.tfvars` to create resources.
7. If there isnt any errors it will produce your the list of resources we trying to create for task2.
8. Review the plan, and do `terraform apply --auto-approve --var-file=dev.tfvars --var-file=task2.tfvars`
9. After successful completion you can see the output for the resources created, look for the output `customers_page` and click the link provided. It will navigate you to the application default response which is listing customers details from DB(RDS). Note: If you dont see any page, give it sometime as the instance is invoking userdata.
10. For performing CRUD opertation, install postman software in local and click `New -> Request` In the request window select `POST` method and enter the value copied from the tf output `add_customer` i.e: http://elbdns-xxxx.aws.amazon.com/add.
11. In the below window select `Body` tab Click `raw` radio button and select JSON from the dropdown, copy paste the below JSON file to add new customer details to DB. and click `Send`

{
"first-name":"Tom", 
 "middle-name":"",
"last-name":"Hanks",
"date-of-birth":"10-May-1978",
"mobile-number":"+6584321111",
"gender":"M",
"customer-number":"AU10042004",
"country-of-birth":"US",
"country-of-residence":"SG",
"customer-segment":"Retail"
}

12. Successfull response will return `Customer added successfully!` in the below output window.
13. To retreive the customer details, notedown the {customer-number} from the above json payload and perform the following in Postman terminal.
14. Select `GET` method and paste the url http://elbdns-xxxx.aws.amazon.com/customer/{customer-number} e.g:http://elbdns-xxxx.aws.amazon.com/customer/AU10042004
15. Successful execution will result in fetching the data inserted in the previous step. You can do the step 14 in your browser as well.
16. For updating the record, select `PUT` http://elbdns-xxxx.aws.amazon.com/update with updated JSON payload as in step 11.
17. For deleting the record, select `DELETE` http://elbdns-xxxx.aws.amazon.com/delete/{customer-number} e.g: http://elbdns-xxxx.aws.amazon.com/delete/AU10042004


With this we have successfully completed task2.
---------------------------------------------------------------------------------------------------------------------------------------

For Kubernetes task:
Navigate to kubernetes-assessment directory and invoke the below command. This solution is implemented in `Docker for Desktop` Kubernetes context

1. kubectl apply -k .
2. kubectl get all -n nginx-demo
3. type localhost:30008 in the browser to see the desired page.

---------------------------------------------------------------------------------------------------------------------------------------
