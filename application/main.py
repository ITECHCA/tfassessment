import pymysql
from app import app
from db_config import mysql
from flask import jsonify
from flask import flash, request
import werkzeug
		
@app.route('/add', methods=['POST'])
def add_user():
	try:
		json = request.json
		firstname = json['first-name']
		middlename = json['middle-name']
		lastname = json['last-name']
		DOB = json['date-of-birth']
		mobilenumber = json['mobile-number']
		gender = json['gender']
		customernumber = json['customer-number']
		countryofbirth = json['country-of-birth']
		countryofresidence = json['country-of-residence']
		customersegment = json['customer-segment']
                # validate the received values
		if firstname and DOB and mobilenumber and request.method == 'POST':
			# save edits
			sql = "insert into customers(firstname, middlename, lastname, DOB, mobilenumber, gender, customernumber, countryofbirth, countryofresidence, customersegment) VALUES(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)"
			data = (firstname, middlename, lastname, DOB, mobilenumber, gender, customernumber, countryofbirth, countryofresidence, customersegment)
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.execute(sql, data)
			conn.commit()
			resp = jsonify('Customer added successfully!')
			resp.status_code = 200
			return resp
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()
		
@app.route('/customers')
def users():
	try:
		conn = mysql.connect()
		cursor = conn.cursor(pymysql.cursors.DictCursor)
		cursor.execute("select * from customers")
		rows = cursor.fetchall()
		resp = jsonify(rows)
		resp.status_code = 200
		return resp
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()
		
@app.route('/customer/<id>')
def user(id):
	try:
		conn = mysql.connect()
		cursor = conn.cursor(pymysql.cursors.DictCursor)
		cursor.execute("SELECT * FROM customers WHERE customernumber=%s", id)
		row = cursor.fetchone()
		resp = jsonify(row)
		resp.status_code = 200
		return resp
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()

@app.route('/update', methods=['PUT'])
def update_user():
	try:
		json = request.json
		firstname = json['first-name']
		middlename = json['middle-name']
		lastname = json['last-name']
		DOB = json['date-of-birth']
		mobilenumber = json['mobile-number']
		gender = json['gender']
		customernumber = json['customer-number']
		countryofbirth = json['country-of-birth']
		countryofresidence = json['country-of-residence']
		customersegment = json['customer-segment']		
		# validate the received values
		if firstname and DOB and mobilenumber and request.method == 'PUT':
			# save edits
			sql = "UPDATE customers SET firstname=%s, middlename=%s, lastname=%s, DOB=%s, mobilenumber=%s, gender=%s, customernumber=%s, countryofbirth=%s, countryofresidence=%s, customersegment=%s where customernumber=%s"
			data = (firstname, middlename, lastname, DOB, mobilenumber, gender, customernumber, countryofbirth, countryofresidence, customersegment, customernumber)
			conn = mysql.connect()
			cursor = conn.cursor()
			cursor.execute(sql, data)
			conn.commit()
			resp = jsonify('Customer data updated successfully!')
			resp.status_code = 200
			return resp
		else:
			return not_found()
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()
		
@app.route('/delete/<id>')
def delete_user(id):
	try:
		conn = mysql.connect()
		cursor = conn.cursor()
		cursor.execute("DELETE FROM customers WHERE customernumber=%s", id)
		conn.commit()
		resp = jsonify('Customer data deleted successfully!')
		resp.status_code = 200
		return resp
	except Exception as e:
		print(e)
	finally:
		cursor.close() 
		conn.close()
		
@app.errorhandler(404)
def not_found(error=None):
    message = {
        'status': 404,
        'message': 'Not Found: ' + request.url,
    }
    resp = jsonify(message)
    resp.status_code = 404

    return resp
		
if __name__ == "__main__":
    app.run(debug=True,host='0.0.0.0')
