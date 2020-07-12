 #!/bin/bash
 echo "Hello Terraform!"
 EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
 EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
 curl -O https://bootstrap.pypa.io/get-pip.py
 sudo yum update -y
 sudo yum install python3 -y
 sudo yum install telnet -y
 python3 get-pip.py --user
 sudo pip3 install ansible
 pip3 install awscli
 aws s3 cp s3://${bucket_name} /opt
 cd /opt
 unzip ansible.zip
 ansible-playbook simple.yaml -i hosts.ini > /var/log/ansible-output.log
 