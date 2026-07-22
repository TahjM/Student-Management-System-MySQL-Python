-- Drop views and tables
DROP VIEW IF EXISTS view_class_roster_data;
DROP VIEW IF EXISTS view_student_schedule_data;
DROP TABLE IF EXISTS rosterclass;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roster;
DROP TABLE IF EXISTS major;
DROP TABLE IF EXISTS roles;

-- Create major table
CREATE TABLE major (
  id INT NOT NULL,
  major VARCHAR(30) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert into major
INSERT INTO major (id, major) VALUES
(1,'Computer Science'),
(2,'Electrical Engineering'),
(3,'Business Administration'),
(4,'Biology');

-- Create roles table
CREATE TABLE roles (
  id VARCHAR(30) NOT NULL,
  role VARCHAR(30) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert into roles
INSERT INTO roles (id, role) VALUES
('mgr','manager'),
('stu','student');

-- Create roster table
CREATE TABLE roster (
  id INT NOT NULL AUTO_INCREMENT,
  class VARCHAR(30) DEFAULT NULL,
  code VARCHAR(50) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert into roster
INSERT INTO roster (id, class, code) VALUES
(1,'Database Systems','COMP267'),
(2,'Calculus I','MATH131'),
(3,'College Writing','ENGL100'),
(4,'Introduction to Biology','BIO101');

-- Create users table
CREATE TABLE users (
  id INT NOT NULL AUTO_INCREMENT,
  username VARCHAR(30) DEFAULT NULL,
  userpassword VARCHAR(30) DEFAULT NULL,
  roleid VARCHAR(30) DEFAULT NULL,
  fname VARCHAR(30) DEFAULT NULL,
  lname VARCHAR(30) DEFAULT NULL,
  majorid INT DEFAULT NULL,
  PRIMARY KEY (id),
  KEY (roleid),
  KEY (majorid),
  CONSTRAINT users_ibfk_2 FOREIGN KEY (majorid) REFERENCES major(id)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert into users
INSERT INTO users (id, username, userpassword, roleid, fname, lname, majorid) VALUES
(1,'manager1','AggiePride1','mgr','manager','quiz',NULL),
(2,'student1','AggiePride2','stu','student','test',2),
(3,'jCena','wrestler2','stu','John','Cena',2),
(4,'cAmerica','superhero2','stu','Captain','America',3),
(5,'bObama','president1','mgr','Barack','Obama',NULL),
(6,'kSparta','warrior1','mgr','Kratos','Sparta',NULL),
(7,'bWayne','detective2','stu','Bruce','Wayne',2),
(8,'dGrayson','sidekick2','stu','Dick','Grayson',4),
(9,'pParker','spiderman2','stu','Peter','Parker',2),
(10,'jGrey','phoenix2','stu','Jean','Grey',3);

-- Create rosterclass table
CREATE TABLE rosterclass (
  rosterid INT DEFAULT NULL,
  userid INT DEFAULT NULL,
  KEY (userid),
  KEY (rosterid),
  CONSTRAINT fk_RosterClass_RosterID FOREIGN KEY (rosterid) REFERENCES roster(id),
  CONSTRAINT fk_RosterClass_UserID FOREIGN KEY (userid) REFERENCES users(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Insert into rosterclass
INSERT INTO rosterclass (rosterid, userid) VALUES
(2,2),
(2,4),
(1,3),
(1,7),
(1,10),
(4,10),
(3,10);

-- Create view for class rosters (Manager sees students in a class)
CREATE VIEW view_class_roster_data AS
SELECT 
    rc.rosterid,
    r.code AS classcode,
    r.class AS classname,
    u.username,
    u.fname,
    u.lname
FROM rosterclass rc
JOIN users u ON rc.userid = u.id
JOIN roster r ON rc.rosterid = r.id;

-- Create view for student schedules (Student sees classes they take)
CREATE VIEW view_student_schedule_data AS
SELECT
    u.username,
    r.code AS classcode,
    r.class AS classname
FROM rosterclass rc
JOIN users u ON rc.userid = u.id
JOIN roster r ON rc.rosterid = r.id;

-- Create stored procedures
DELIMITER $$

CREATE PROCEDURE AddRoster(IN p_username VARCHAR(30), IN p_code VARCHAR(20))
BEGIN
    DECLARE v_userid INT;
    DECLARE v_rosterid INT;
    SELECT id INTO v_userid FROM users WHERE username = p_username;
    SELECT id INTO v_rosterid FROM roster WHERE code = p_code;
    INSERT INTO rosterclass (userid, rosterid)
    VALUES (v_userid, v_rosterid);
END$$

CREATE PROCEDURE AddStudent(
    IN p_username VARCHAR(30),
    IN p_password VARCHAR(30),
    IN p_fname VARCHAR(30),
    IN p_lname VARCHAR(30),
    IN p_roleid VARCHAR(30),
    IN p_majorid INT
)
BEGIN
    INSERT INTO users (username, userpassword, fname, lname, roleid, majorid)
    VALUES (p_username, p_password, p_fname, p_lname, p_roleid, p_majorid);
END$$

CREATE PROCEDURE DropRoster(IN p_username VARCHAR(30), IN p_code VARCHAR(20))
BEGIN
    DECLARE v_userid INT;
    DECLARE v_rosterid INT;
    SELECT id INTO v_userid FROM users WHERE username = p_username;
    SELECT id INTO v_rosterid FROM roster WHERE code = p_code;
    DELETE FROM rosterclass
    WHERE userid = v_userid AND rosterid = v_rosterid;
END$$

CREATE PROCEDURE DropStudentClass(IN p_username VARCHAR(30), IN p_code VARCHAR(20))
BEGIN
    DECLARE v_userid INT;
    DECLARE v_rosterid INT;
    SELECT id INTO v_userid FROM users WHERE username = p_username;
    SELECT id INTO v_rosterid FROM roster WHERE code = p_code;
    DELETE FROM rosterclass
    WHERE userid = v_userid AND rosterid = v_rosterid;
END$$

CREATE PROCEDURE GetAllUsers()
BEGIN
    SELECT username, userpassword, roleid
    FROM users;
END$$

CREATE PROCEDURE ViewClassRoster(IN p_classcode VARCHAR(20))
BEGIN
    SELECT CONCAT(fname, ' ', lname) AS full_name
    FROM view_class_roster_data
    WHERE classcode = p_classcode;
END$$

CREATE PROCEDURE ViewStudentSchedule(IN p_username VARCHAR(30))
BEGIN
    SELECT classcode, classname
    FROM view_student_schedule_data
    WHERE username = p_username;
END$$

DELIMITER ;
