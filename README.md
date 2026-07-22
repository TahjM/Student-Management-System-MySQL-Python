# Student Management System (Python + MySQL)

A role-based desktop application for managing student schedules and class rosters, built with Python, Tkinter, and MySQL.

## Overview

This application provides two distinct experiences depending on user role:
- **Students** can log in and view/manage their own class schedules
- **Managers** can view student schedules, manage class rosters (add/drop students), and add new students to the system

User authentication and role assignment are handled through a MySQL database, and core data operations are implemented as stored procedures rather than inline SQL queries, keeping business logic centralized in the database layer.

## Tech Stack

- Python
- MySQL
- Tkinter (GUI for student/manager menus)
- mysql-connector-python

## Project Structure


``` Login3.py # Handles authentication and routes users to the correct role-based menu
Student3.py # Student-facing menu and functionality
Manager3.py # Manager-facing menu and functionality (rosters, student records)
storedProc.py # Python wrappers for calling MySQL stored procedures
schema.sql # Database schema and stored procedure definitions
```

## How to Run

1. Set up a local MySQL database using `schema.sql` to create the schema and stored procedures.
2. Set the following environment variables with your MySQL credentials before running:
```bash
   export uname="your_mysql_username"
   export pname="your_mysql_password"
```
3. Run the application:
```bash
   python Login3.py
```
4. Log in with a valid username and password from the `ncat` database. The app will route you to the Student or Manager menu based on your role.

## Notes

This was originally built as a class project. A few things worth flagging for anyone reviewing the code:
- Passwords are currently stored and compared in plaintext. A production version would use password hashing (e.g., bcrypt) instead.
- Database credentials are now read from environment variables rather than hardcoded, but there's no `.env` file support yet — variables must be set manually in the terminal each session.
