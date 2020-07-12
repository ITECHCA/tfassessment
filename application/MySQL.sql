create database if not exists CustomerData;

use CustomerData;

CREATE TABLE if not exists customers (
firstname varchar(20) NOT NULL,
middlename varchar(10),
lastname varchar(20) NOT NULL,
DOB varchar(20) NOT NULL,
mobilenumber varchar(20),
gender varchar(2) NOT NULL,
customernumber Varchar(10) UNIQUE,
countryofbirth varchar(10),
countryofresidence varchar(10),
customersegment varchar(10)
);

#Insert test data
insert ignore into customers(firstname, middlename, lastname, DOB, mobilenumber, gender, customernumber, countryofbirth, countryofresidence, customersegment) VALUES('Ragh', 'Test', 'Ram', '15-May-1990', '+6512345', 'M', 'AU10042002', 'US', 'SG', 'Retail');