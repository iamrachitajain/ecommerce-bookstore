from flask import Flask, render_template, request, session, redirect
from flask_mysqldb import MySQL

import MySQLdb

app = Flask(__name__)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'
app.config['MYSQL_HOST'] = '127.0.0.1'
app.config['PORT'] = '3306'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'root'
app.config['MYSQL_DB'] = 'project'

mysql = MySQL(app)

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/home/', methods=['GET', 'POST'])
def home():
    return render_template('index.html')

@app.route('/signup/', methods=['GET', 'POST'])
def signup():
	if request.method == "POST":
		details = request.form
		userEmail = details['userEmail']
		userPassword = details['userPassword']
		userRepeatPassword = details['userRepeatPassword']
		userFirst = details['userFirst']
		userLast = details['userLast']
		userPhone = details['userPhone']
		cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
		cur.execute("INSERT INTO MyUsers VALUES (%s, %s, %s, %s, %s, %s)", (userEmail, userPassword, userRepeatPassword, userFirst, userLast, userPhone))
		mysql.connection.commit()
		cur.close()
	return render_template('signup.html')

@app.route('/signin/', methods=['GET', 'POST'])
def signin():
	msg = ""
	if request.method == "POST":
		acc = request.form['account']
		username = request.form['user']
		password = request.form['password']
		cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
		if acc == "customer":
			cur.execute('SELECT * FROM MyUsers WHERE userEmail = % s AND userPassword = % s', (username, password, )) 
			account = cur.fetchone()
			if account:
				session['logged_in'] = True
				session['userFirst'] = account['userFirst']
				msg = "Logged in successfully !"
				return render_template('index.html', msg = msg)
			else:
				session['logged_in'] = False
				msg = "Incorrect email / password"
				return render_template('signin.html', msg = msg)
		else:
			cur.execute('SELECT * FROM administrator WHERE adminEmail = % s AND adminPassword = % s', (username, password, )) 
			account = cur.fetchone()
			if account:
				session['logged_in'] = True
				session['adminFirst'] = account['adminFirst']
				msg = "Logged in successfully !"
				return redirect('admindashboard')
				return render_template('admindashboard.html', msg = msg)
			else:
				msg = "Incorrect email / password"
		cur.close()
	return render_template('signin.html', msg = msg)

@app.route('/logout') 
def logout(): 
    session.pop('logged_in', None) 
    session.pop('userFirst', None) 
    return render_template('index.html')

@app.route('/books/', methods=['GET', 'POST'])
def books():
	cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
	cur.execute('SELECT * FROM Book') 
	data = cur.fetchall()
	return render_template('books.html', data=data)

@app.route('/cart/', methods=['GET', 'POST'])
def cart():
	return render_template('cart.html')

@app.route('/signin/admindashboard/', methods=['GET', 'POST'])
def admindashboard():
	cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
	cur.execute('SELECT * FROM MyUsers') 
	data = cur.fetchall()
	return render_template('admindashboard.html', data=data)

@app.route('/delete/<id>', methods=['POST'])
def delete(id):
	cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
	cur.execute("delete FROM MyUsers where userEmail = %s",(id, ) )
	mysql.connection.commit()
	cur.close()
	return render_template('admindashboard.html')

@app.route('/add/<id>', methods=['POST'])
def add_to_cart(id):
	prod = {}
	cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
	cur.execute("select * FROM Book where ISBN = %s", (id,) )
	data = cur.fetchone()
	prod['title'] = data['title']
	prod['price'] = data['price']
	prod['total'] = data['price']
	return render_template('cart.html', data=prod)

if __name__ == '__main__':
    app.run(use_reloader=True)