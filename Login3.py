import mysql.connector
from mysql.connector import errorcode
import Student3
import Manager3
from storedProc import get_all_users
import os

# Global connection variables
uname = os.environ.get("uname")
pname = os.environ.get("pname")

# Database Connection
try:
    connection = mysql.connector.connect(
        host="localhost",
        user=uname,
        password=pname,
        database="ncat",
        auth_plugin="mysql_native_password"
    )
except mysql.connector.Error as err:
    if err.errno == errorcode.ER_ACCESS_DENIED_ERROR:
        print("Invalid credentials")
    elif err.errno == errorcode.ER_BAD_DB_ERROR:
        print("Database not found")
    else:
        print("Cannot connect to database")
    exit()

# --- Login Function ---
def login(connection):
    users = get_all_users(connection)

    # users from database
    print("Users fetched from DB:", users)

    # Validate structure of returned users
    if not users or not all(isinstance(user, tuple) and len(user) == 3 for user in users):
        print("Error: Invalid user data format.")
        exit()

    user_dict = {user[0]: (user[1], user[2]) for user in users}  # {username: (password, role)}

    attempt = 0
    while attempt < 3:
        username = input("Enter your username: ")
        password = input("Enter your password: ")

        if username in user_dict and password == user_dict[username][0]:
            role = user_dict[username][1]
            print(f"Login successful! Role: {role}")

            if role == "stu":
                Student3.displayStudentMenu(username, connection)
            elif role == "mgr":
                Manager3.display_manager_menu(username, connection)
            else:
                print("Unknown role.")
                exit()
            return
        else:
            print("Login failed. Try again.")
            attempt += 1

    print("Too many failed attempts. Exiting.")
    exit()

# Run Login
login(connection)

# Close connection after application exits
connection.close()
