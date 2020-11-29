from flask import Flask, render_template, request, session
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

@app.route('/signup/', methods=['GET', 'POST'])
def signup():
	if request.method == "POST":
		details = request.form
		print(details['userFirst'])
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
		username = request.form['user']
		password = request.form['password']
		cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
		cur.execute('SELECT * FROM MyUsers WHERE userEmail = % s AND userPassword = % s', (username, password, )) 
		account = cur.fetchone()
		if account:
			session['logged_in'] = True
			session['userFirst'] = account['userFirst']
			print(session['userFirst'])
			msg = "Logged in successfully !"
			return render_template('index.html', msg = msg)
		else:
			msg = "Incorrect email / password"
			return render_template('index.html', msg = msg)
		cur.close()
	return render_template('signin.html')

@app.route('/logout') 
def logout(): 
    session.pop('logged_in', None) 
    session.pop('userFirst', None) 
    return render_template('index.html')

@app.route('/books/', methods=['GET', 'POST'])
def books():
	return render_template('books.html')


@app.route('/cart/', methods=['GET', 'POST'])
def cart():
	htmlToAdd = ""
	cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
		cur.execute('SELECT product_ID FROM Cart_item WHERE cart_ID = Cart.customer_ID AND Cart.customer_ID = Customer.ID')
		item = cur.fetchone()
		while item is not None:
  			prodID = item
  			cur.execute('SELECT title, price, img FROM Book WHERE ISBN = %d', prodID)
  			details = cur.fetchone()
  			htmlToAdd += "<img src = \"%s\"><br>%s<br>%f", details.get('img'), details.get('title'), details.get('price')  
  			item = cursor.fetchone()
  	return render_template('cart.html', detailsHere = htmlToAdd)

if __name__ == '__main__':
    app.run(use_reloader=True)
