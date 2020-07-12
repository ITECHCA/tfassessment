#!/bin/bash
sudo yum update -y
sudo yum upgrade -y
#Install Python3Mysql
EC2_AVAIL_ZONE=`curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone`
EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
curl -O https://bootstrap.pypa.io/get-pip.py
#Intall packages
python3 get-pip.py --user
sudo yum install python3 -y
sudo yum install mysql -y
sudo python3 -m pip install pymysql
sudo python3 -m pip install Flask
sudo python3 -m pip install flask_table
sudo python3 -m pip install flask_mysql
sudo python3 -m pip install boto3
pip3 install awscli
#Install git
sudo yum install git -y
app_dir="/opt/application"
mkdir $app_dir
rdsendpoint=`echo ${dbendpoint} | cut -d ":" -f1`
port=`echo ${dbendpoint} | cut -d ":" -f2`
aws s3 cp s3://${bucket_name} $app_dir/

cd $app_dir && unzip application.zip

echo "app.config['MYSQL_DATABASE_USER'] = '${dbuser}'
app.config['MYSQL_DATABASE_PASSWORD'] = '${dbpassword}'
app.config['MYSQL_DATABASE_DB'] = 'CustomerData'
app.config['MYSQL_DATABASE_HOST'] = '"$rdsendpoint"'
mysql.init_app(app)" >> /opt/application/db_config.py
#Run sql script
mysql --host=$rdsendpoint --port=$port --password=${dbpassword} --user=${dbuser} < /opt/application/MySQL.sql
#Run Py application
sudo python3 /opt/application/main.py