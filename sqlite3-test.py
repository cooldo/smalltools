import sqlite3

db_conn = sqlite3.connect('test.db')
#db_conn = sqlite3.connect(":memory:")

# remove u from u'xxx' when print
db_conn.text_factory = str

def printDB():
	try:
		result = theCursor.execute("SELECT ID,FName,LName,Age,Address,Salary,HireDate FROM Employees")

		print ("show table")
		for row in result:
			print (row)

	except sqlite3.OperationalError:
		print("The table doesn't exist")
	except:
		print("Couldn't retrive data from database")


print("Database Created")

theCursor = db_conn.cursor()

theCursor.execute("DROP TABLE IF EXISTS Employees")

try:
	theCursor.execute("""CREATE TABLE Employees(
					ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
					FName TEXT NOT NULL,
					LName TEXT NOT NULL,
					Age INTEGER NOT NULL,
					Address TEXT,
					Salary REAL,
					HireDate TEXT
					);""")

	db_conn.commit()

except sqlite3.OperationalError:
	print("Table cannot be created")

print("Table Created")

theCursor.execute("INSERT INTO Employees (FName,LName,Age,Address,Salary,HireDate) VALUES ('Jone','Smith','35','Lake of Terry',80000,date('now'))")

db_conn.commit()


theCursor.execute("INSERT INTO Employees (FName,LName,Age,Address,Salary,HireDate) VALUES ('Jone','Snow','42','Lake of State',10000,date('now'))")

db_conn.commit()
printDB()

# Test sqlite injection
#symbol = "XiaoMing' ;drop table Employees"
#theCursor.execute("SELECT * FROM Employees WHERE FName = '%s'" % symbol)
#print(theCursor.fetchall())

#theCursor.execute("SELECT * FROM Employees")

#print(theCursor.fetchall())

try:
	theCursor.execute("UPDATE Employees SET Age = 18 WHERE ID = 1")
	db_conn.commit()

except sqlite3.OperationalError:
	print("Table couldn't be updated")
printDB()

try:
	theCursor.execute("DELETE FROM Employees WHERE ID = 1")
	db_conn.commit()

except sqlite3.OperationalError:
	print("Table couldn't be deleted")
printDB()
theCursor.execute("INSERT INTO Employees (FName,LName,Age,Address,Salary,HireDate) VALUES ('Jone','Smith','35','Lake of Terry',80000,date('now'))")
db_conn.commit()
printDB()
theCursor.execute("INSERT INTO Employees (FName,LName,Age,Address,Salary,HireDate) VALUES ('Jone','Smith','35','Lake of Terry',80000,date('now'))")
db_conn.commit()

theCursor.execute("INSERT INTO Employees (ID,FName,LName,Age,Address,Salary,HireDate) VALUES (1,'Apple','Huge','35','Lake of Terry',80000,date('now'))")
#db_conn.commit()
printDB()

# rollback means before commit, you can cancel the last execution
db_conn.rollback()
printDB()

try:
	# sqlite only support add column, and it refuses to delete column
	# if you want to delete a column, just create a new DB, and copy old data to it.
	theCursor.execute("ALTER TABLE Employees ADD COLUMN 'Image' BLOB DEFAULT NULL")
	db_conn.commit()

except sqlite3.OperationalError:
	print("Table couldn't be altered")
printDB()

try:
	theCursor.execute("PRAGMA TABLE_INFO(Employees)")
	#print(theCursor.fetchall())
except sqlite3.OperationalError:
	print("Table couldn't be altered")
rowNames = [nameTuple[1] for nameTuple in theCursor.fetchall()]
print(rowNames)

theCursor.execute("SELECT COUNT(*) FROM Employees")
numOfRow = theCursor.fetchall()
print("Num of rows :",numOfRow[0][0])

theCursor.execute("SELECT SQLITE_VERSION()")
sqlVersion = theCursor.fetchall()
print("sqlite3 version:",sqlVersion[0][0])

with db_conn:
	db_conn.row_factory = sqlite3.Row
	theCursor = db_conn.cursor();
	theCursor.execute("SELECT * FROM Employees")
	rows = theCursor.fetchall()
	for row in rows:
		#print (row['FName'],row['LName'])
		print ("{} {}".format(row['FName'],row['LName']))

with open('dump.sql','w') as f:
	for line in db_conn.iterdump():
		f.write("%s\n" % line)


db_conn.close()

print("Database Closed")
