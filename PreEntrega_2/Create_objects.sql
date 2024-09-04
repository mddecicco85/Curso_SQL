CREATE DATABASE university_bis;
USE university_bis;
-- DROP SCHEMA university_bis;


-- TABLES

CREATE TABLE professor (
id_prof INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR (50),
sex CHAR(1) -- Podría ser un enum('M', 'F')
);
-- DROP TABLE PROFESSOR;

CREATE TABLE career (
id_career INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50),
duration_years INT
);
-- DROP TABLE CAREER;

CREATE TABLE subject (
id_subject INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50),
-- prof_id INT NOT NULL,
career_id INT NOT NULL,
-- FOREIGN KEY (prof_id) REFERENCES professor (id_prof),
FOREIGN KEY (career_id) REFERENCES career (id_career)
);
-- DROP TABLE SUBJECT;

CREATE TABLE publisher (
id_pub INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50)
);
-- DROP TABLE PUBLISHER;

CREATE TABLE book (
id_book INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(80),
author VARCHAR(80),
publisher_id INT NOT NULL,
year INT NOT NULL,
ISBN VARCHAR(13),
subject_id INT NOT NULL,
FOREIGN KEY (publisher_id) REFERENCES publisher (id_pub),
FOREIGN KEY (subject_id) REFERENCES subject (id_subject)
);
-- DROP TABLE BOOK;

CREATE TABLE country (
id_country INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50)
);
-- DROP TABLE COUNTRY;

CREATE TABLE student (
id_student INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
sex CHAR(1),
DNI VARCHAR(8),
country_id INT NOT NULL,
FOREIGN KEY (country_id) REFERENCES country (id_country),
file_number INT,
birth DATE,
address VARCHAR(30),
phone VARCHAR(15),
email VARCHAR(50),
career_id INT NOT NULL,
FOREIGN KEY (career_id) REFERENCES career (id_career)
);
-- DROP TABLE STUDENT;

CREATE TABLE professor_subject (
professor_id INT,
subject_id INT,
PRIMARY KEY (professor_id, subject_id),
FOREIGN KEY (professor_id) REFERENCES professor (id_prof),
FOREIGN KEY (subject_id) REFERENCES subject (id_subject)
);
-- DROP TABLE professor_subject;




-- VIEWS

-- VISTA QUE MUESTRA LA CANTIDAD DE ALUMNOS TOTALES
CREATE VIEW total_students AS
(SELECT COUNT(*) AS students_total FROM student);
-- DROP VIEW total_students;

-- SELECT * FROM total_students;


-- VISTA QUE MUESTRA TODOS LOS DATOS DE LOS ALUMNOS DE ARGENTINA
CREATE VIEW students_argentina AS
SELECT * FROM student WHERE country_id = 1;
-- DROP VIEW students_argentina;

-- SELECT * FROM students_argentina;


-- VISTA QUE LISTA LOS ALUMNOS JUNTO A SUS CARRERAS
CREATE VIEW student_career AS
SELECT id_student, first_name, last_name, c.name FROM student s JOIN career c ON s.career_id = c.id_career;
-- DROP VIEW student_career;

-- SELECT * FROM student_career;


-- VISTA QUE MUESTRA LOS ALUMNOS MAYORES DE 25 AÑOS
CREATE VIEW elder_students AS
SELECT id_student, first_name, last_name, file_number, (SELECT FLOOR(DATEDIFF(CURRENT_DATE(), birth)/365)) AS age FROM student WHERE (SELECT DATEDIFF(CURRENT_DATE(), birth)/365 >= 25) ORDER BY age;
-- SELECT id_student, first_name, last_name, file_number FROM student WHERE (SELECT DATEDIFF(CURRENT_DATE(), birth)/365 >= 25);
-- DROP VIEW elder_students;

-- SELECT * FROM elder_students;


-- VISTA QUE MUESTRA LOS LIBROS PUBLICADOS DE 2010 EN ADELANTE
CREATE VIEW recent_books AS
SELECT * FROM book WHERE year >= 2010 ORDER BY year DESC;
-- DROP VIEW recent_books;

-- SELECT * FROM recent_books;




-- FUNCTIONS

-- FUNCIÓN QUE INDICA LA PRIMER MATERIA DE LA CARRERA, SEGÚN LA TABLA DE ASIGNATURAS
DELIMITER %%
CREATE FUNCTION subjects_in_career (id_num INT) RETURNS VARCHAR(250)
READS SQL DATA
BEGIN
	DECLARE carrera VARCHAR(50);
	DECLARE subjects VARCHAR(250);
	SET carrera = (SELECT name FROM career WHERE id_career = id_num); -- Toma el nombre de la carrera con ese ID.
	SET subjects = (SELECT s.name AS carrera FROM subject s JOIN career c ON s.career_id = c.id_career WHERE career_id = id_num LIMIT 1);
	-- Pongo LIMIT 1 porque no puede tomar un conjunto de valores.
	-- SET subjects = CONCAT('HOLA', 'COMO', 'ESTAS'); -- Esto no hace saltos de línea.
	-- SET subjects = CONCAT('HOLA', CHAR(10), 'COMO', CHAR(10), 'ESTAS'); Esto debería hecer saltos, pero no anda dentro de una función.
	-- SET subjects = "HOLA\nCOMO\nESTAS"; -- Este es igual al de arriba, pero sin la función CONCAT.
	RETURN subjects;
END
%%
-- DROP FUNCTION subjects_in_career;
-- DROP FUNCTION IF EXISTS subjects_in_career;


-- FUNCIÓN QUE DA EL NOMBRE DE LA CARRERA ELEGIDA
DELIMITER //
CREATE FUNCTION name_career (id_num INT) RETURNS VARCHAR(50)
READS SQL DATA
BEGIN
	DECLARE career_name VARCHAR(50);
	SET career_name = (SELECT name FROM career WHERE id_career = id_num LIMIT 1);
	RETURN career_name;
END
//
-- DROP FUNCTION name_career;

-- SELECT name_career(6) AS career;


-- FUNCIÓN QUE DA LA CANTIDAD DE ALUMNOS EN UNA CARRERA DADA
DELIMITER //
CREATE FUNCTION number_students_on_career (career_ide INT) RETURNS INT
READS SQL DATA
BEGIN
	DECLARE total INT;
	SET total = (SELECT COUNT(*) FROM student s JOIN career c ON s.career_id = c.id_career WHERE id_career = career_ide);
    RETURN total;
END
//
-- DROP FUNCTION number_students_on_career;

-- SELECT number_students_on_career(1) AS total_students;




-- STORED PROCEDURES

-- SP QUE INDICA EL ÚLTIMO ID DE CARRERAS
DELIMITER %%
CREATE PROCEDURE career_max_id ()
BEGIN
-- SELECT COUNT(*) FROM career;
	SET @max_id = 'SELECT MAX(id_career) FROM career';
	PREPARE maximo FROM @max_id;
	EXECUTE maximo;
	DEALLOCATE PREPARE maximo;
END
%%
-- DROP PROCEDURE career_max_id;

-- CALL career_max_id();


-- SP QUE LISTA LOS ALUMNOS DE UNA CARRERA DADA
DELIMITER //
CREATE PROCEDURE career_students (IN id INT)
BEGIN
	SET @roster = CONCAT('SELECT s.id_student, s.first_name, s.last_name, s.file_number FROM student s JOIN career c ON s.career_id = c.id_career WHERE id_career = ', id);
    PREPARE roster FROM @roster;
    EXECUTE roster;
    DEALLOCATE PREPARE roster;
END
//
-- DROP PROCEDURE career_students;

-- CALL career_students(1);


-- SP QUE LISTA LOS ALUMNOS DE UNA CARRERA DADA (VERIFICA QUE EL ID CORRESPONDA A UNA CARRERA)
DELIMITER $$
CREATE PROCEDURE career_students_list (IN id INT, OUT message VARCHAR(40))
BEGIN
	DECLARE max_id INT;
    SELECT MAX(id_career) INTO max_id FROM career; -- Asigno el valor a max_id con SELECT INTO.
    IF (id < 1 OR id > max_id) THEN
		SET message = 'There is no career with that number.';
	ELSE
		SET @roster = CONCAT('SELECT s.id_student, s.first_name, s.last_name, s.file_number FROM student s JOIN career c ON s.career_id = c.id_career WHERE id_career = ', id);
        SET message = 'Successful query.';
        PREPARE roster FROM @roster;
		EXECUTE roster;
		DEALLOCATE PREPARE roster;
		END IF;
END
$$
-- DROP PROCEDURE career_students_list;

-- CALL career_students_list (1, @message);
-- SELECT @message AS result;

-- CALL career_students_list (33, @message);
-- SELECT @message AS result;


-- SP QUE LISTA LAS ASIGNATURAS DE CADA CARRERA
DELIMITER $$
CREATE PROCEDURE career_subjects (IN id INT)
BEGIN
	-- DECLARE clausula VARCHAR(250); -- No hace falta. Si pongo DECLARE, y SET sin @, no anda.
    SET @clausula = CONCAT('SELECT s.name AS subjects FROM subject s JOIN career c ON s.career_id = c.id_career WHERE career_id = ', id);
    PREPARE clause FROM @clausula;
    EXECUTE clause;
    DEALLOCATE PREPARE clause;
END
$$
-- DROP PROCEDURE career_subjects;

-- CALL career_subjects(6);




-- TRIGGERS

-- TRIGGER QUE GUARDA LOS INGRESOS DE LOS ALUMNOS AL SISTEMA EN UNA TABLA DE AUDITORÍA

-- TABLA
CREATE TABLE new_students (
id_student INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50),
last_name VARCHAR(50),
file_number VARCHAR(8),
entry_dt datetime,
user_id VARCHAR(50)
);
-- DROP TABLE new_students;

-- TRIGGER
CREATE TRIGGER audit_students
AFTER INSERT ON student
FOR EACH ROW
INSERT INTO new_students (first_name, last_name, file_number, entry_dt, user_id) -- No le paso id_student de la otra, porque no ingreso ese valor.
VALUES (NEW.first_name, NEW.last_name, NEW.file_number, CURRENT_TIMESTAMP(), USER());
-- DROP TRIGGER audit_students;

-- INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, career_id) VALUES
-- ('Felipe', 'Pérez', 'M', '37398201', 11, 451, '1986-10-09', 'Avellaneda 1212', '3748934567', 'feli34@yahoo.com.ar', 2);


-- TRIGGER QUE GUARDA LOS ALUMNOS ELIMINADOS DEL SISTEMA EN UNA TABLA DE AUDITORÍA

-- TABLA
CREATE TABLE old_students (
id_student INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50),
last_name VARCHAR(50),
file_number VARCHAR(8),
entry_dt datetime,
user_id VARCHAR(50)
);
-- DROP TABLE new_students;

-- SELECT * FROM student;
-- SELECT * FROM new_students;

-- TRIGGER
CREATE TRIGGER audit_deleted_students
BEFORE DELETE ON student
FOR EACH ROW
INSERT INTO old_students (first_name, last_name, file_number, entry_dt, user_id)
VALUES (OLD.first_name, OLD.last_name, OLD.file_number, CURRENT_TIMESTAMP(), USER());
-- DROP TRIGGER audit_deleted_students;

-- DELETE FROM student WHERE file_number = 435 AND id_student <> 0;

-- SELECT * FROM student;
-- SELECT * FROM old_students;


-- SP QUE MUESTRA LA CANTIDAD DE ALUMNOS POR CARRERA