from flask import Flask, render_template, request
from flask_mysqldb import MySQL
import MySQLdb

app = Flask(__name__)

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
		print(request.form['password'])
		details = request.form
		print("details")
		
		firstName = details['fname']
		lastName = details['lname']
		email = details['email']
		pas = details['password']
		phone = details['phone']
		cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
		cur.execute("INSERT INTO MyUsers(firstName, lastName, email, pas, phone) VALUES (%s, %s, %s, %s, %d)", (firstName, lastName, email, pas, phone))
		mysql.connection.commit()
		cur.close()
	return render_template('signup.html')

@app.route('/signin/', methods=['GET', 'POST'])
def signin():
	if request.method == "POST":
		print(request.form['password'])
		username = request.form['user']
		password = request.form['password']
		cur = mysql.connection.cursor(MySQLdb.cursors.DictCursor)
		cur.execute("INSERT INTO users(username, passwrd) VALUES (%s, %s)", (username, password))
		mysql.connection.commit()
		cur.close()
	return render_template('signin.html')

@app.route('/books/', methods=['GET', 'POST'])
def books():
	return render_template('books.html')



if __name__ == '__main__':
    app.run(use_reloader=True)