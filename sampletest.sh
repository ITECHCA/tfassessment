app.config['MYSQL_DATABASE_HOST'] = '${var.dbendpoint}'

mysql -h ${var.dbendpoint} -P 3306 -u ${dbuser} -p${dbpassword} < /opt/application/MySQL.sql

mysql -h mysqldb.crgnsqn0yowh.ap-southeast-1.rds.amazonaws.com -P 3306 -u useradmin -pK6apazbRXNzTka8i < /opt/application/MySQL.sql

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


insert into customers(firstname, middlename, lastname, DOB, mobilenumber, gender, customernumber, countryofbirth, countryofresidence, customersegment) VALUES("Tom", "", "Hanks", "10-May-1978", "+6584321111", "M", "AU10042004", "US", "SG", "Retail")