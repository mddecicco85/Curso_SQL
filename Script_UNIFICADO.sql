CREATE DATABASE university;
USE university;
-- DROP SCHEMA university;

-- ***************************************************************************************************************************
-- ***************************************************************************************************************************
-- TABLES
-- ***************************************************************************************************************************
-- ***************************************************************************************************************************

CREATE TABLE professor (
id_prof INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR(50),
sex CHAR(1) -- Podría ser un enum('M', 'F')
);
-- DROP TABLE professor;

CREATE TABLE career (
id_career INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50),
duration_years INT
);
-- DROP TABLE career;

CREATE TABLE subject (
id_subject INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50),
career_id INT NOT NULL,
FOREIGN KEY (career_id) REFERENCES career (id_career)
);
-- DROP TABLE subject;

CREATE TABLE publisher (
id_pub INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50)
);
-- DROP TABLE publisher;

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
-- DROP TABLE book;

CREATE TABLE country (
id_country INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
name VARCHAR(50)
);
-- DROP TABLE country;

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
is_active INT
-- is_active TINYINT(1) DEFAULT 1, -- TINYINT(1) es lo mismo que booleano, y toma entre -128 y 127. Lo pongo activo por defecto.
-- CHECK (is_active IN (0, 1)) -- Digo que pueda tomar 0 ó 1 solamente.
);
-- DROP TABLE student;

CREATE TABLE professor_subject (
professor_id INT,
subject_id INT,
PRIMARY KEY (professor_id, subject_id),
FOREIGN KEY (professor_id) REFERENCES professor (id_prof),
FOREIGN KEY (subject_id) REFERENCES subject (id_subject)
);
-- DROP TABLE professor_subject;

CREATE TABLE student_career (
student_id INT,
career_id INT,
PRIMARY KEY (student_id, career_id),
CONSTRAINT fk_student_career FOREIGN KEY (student_id) REFERENCES student (id_student) ON DELETE CASCADE,
FOREIGN KEY (career_id) REFERENCES career (id_career)
);
-- DROP TABLE student_career;




-- ***************************************************************************************************************************
-- ***************************************************************************************************************************
-- VIEWS
-- ***************************************************************************************************************************
-- ***************************************************************************************************************************

-- VISTA QUE MUESTRA TODOS LOS DATOS DE LOS ALUMNOS DE ARGENTINA
CREATE VIEW vw_students_argentina AS
SELECT * FROM student WHERE country_id = 1;
-- DROP VIEW vw_students_argentina;

-- SELECT * FROM vw_students_argentina;


-- VISTA QUE LISTA LOS ALUMNOS JUNTO A SUS CARRERAS
CREATE VIEW vw_students_career AS
SELECT id_student, first_name, last_name, c.name FROM student s
JOIN student_career sc ON s.id_student = sc.student_id 
JOIN career c ON sc.career_id = c.id_career ORDER BY id_student;
-- DROP VIEW vw_students_career;

-- SELECT * FROM vw_students_career;


-- VISTA QUE MUESTRA LA CANTIDAD DE ALUMNOS EN CADA CARRERA (ACTIVOS)
CREATE VIEW vw_students_per_career AS
SELECT c.name AS career, SUM(s.is_active) AS active_students FROM student s 
JOIN student_career sc ON s.id_student = sc.student_id
JOIN career c ON sc.career_id = c.id_career 
GROUP BY c.id_career ORDER BY c.name;
-- DROP VIEW vw_students_per_career;

-- SELECT * FROM vw_students_per_career;


-- VISTA QUE MUESTRA LA CANTIDAD DE ALUMNOS EN CADA CARRERA (TOTALES)
CREATE VIEW vw_total_students_per_career AS
SELECT c.name AS career, COUNT(*) AS total_students
FROM student s JOIN student_career sc ON s.id_student = sc.student_id
JOIN career c ON sc.career_id = c.id_career GROUP BY c.id_career ORDER BY c.name;
-- DROP VIEW vw_total_students_per_career;

-- SELECT * FROM vw_total_students_per_career;


-- VISTA QUE MUESTRA LOS ALUMNOS ACTIVOS MAYORES DE 25 AÑOS
CREATE VIEW vw_elder_students AS
SELECT id_student, first_name, last_name, file_number, (SELECT FLOOR(DATEDIFF(CURRENT_DATE(), birth)/365)) AS age FROM student 
WHERE (SELECT DATEDIFF(CURRENT_DATE(), birth)/365 >= 25) AND is_active = 1 ORDER BY age;
-- DROP VIEW vw_elder_students;

-- SELECT * FROM vw_elder_students;


-- VISTA QUE MUESTRA LOS LIBROS PUBLICADOS DE 2010 EN ADELANTE
CREATE VIEW vw_recent_books AS
SELECT * FROM book WHERE year >= 2010 ORDER BY year DESC;
-- DROP VIEW vw_recent_books;

-- SELECT * FROM vw_recent_books;


-- VISTA QUE LISTA LOS PROFESORES JUNTO A SUS MATERIAS
CREATE VIEW vw_professors_subjects AS
SELECT id_prof, first_name, last_name, s.name FROM professor p
JOIN professor_subject ps ON p.id_prof = ps.professor_id
JOIN subject s ON ps.subject_id = s.id_subject ORDER BY id_prof;
-- DROP VIEW vw_professors_subjects;

-- SELECT * FROM vw_professors_subjects;




-- ***************************************************************************************************************************
-- ***************************************************************************************************************************
-- FUNCTIONS
-- ***************************************************************************************************************************
-- ***************************************************************************************************************************

-- FUNCIÓN QUE MUESTRA LA CANTIDAD DE ALUMNOS (TOTALES)
DELIMITER %%
CREATE FUNCTION fn_total_students () RETURNS INT
READS SQL DATA
BEGIN
	DECLARE total INT;
	SET total = (SELECT COUNT(id_student) FROM student);
    RETURN total;
END;
%%
DELIMITER ;
-- DROP FUNCTION fn_total_students;

-- SELECT fn_total_students() AS total_students;


-- FUNCIÓN QUE DA EL PORCENTAJE DE MUJERES INSCRIPTAS EN LA UNIVERSIDAD
DELIMITER %%
CREATE FUNCTION fn_women_percentage () RETURNS FLOAT
READS SQL DATA
BEGIN
	DECLARE percentage FLOAT;
	SET percentage = ROUND((SELECT COUNT(id_student) FROM student WHERE sex = 'F') * 100 / (SELECT COUNT(id_student) FROM student));
    RETURN percentage;
END;
%%
DELIMITER ;
-- DROP FUNCTION fn_women_percentage;

-- SELECT fn_women_percentage () AS women_percentage;


-- FUNCIÓN QUE DA EL PORCENTAJE DE ALUMNOS ACTIVOS EN TODA LA UNIVERSIDAD
DELIMITER %%
CREATE FUNCTION fn_active_percentage () RETURNS FLOAT
READS SQL DATA
BEGIN
	DECLARE percentage FLOAT;
	SET percentage = ROUND((SELECT COUNT(id_student) FROM student WHERE is_active = 1) * 100 / (SELECT COUNT(id_student) FROM student));
    RETURN percentage;
END;
%%
DELIMITER ;
-- DROP FUNCTION fn_active_percentage;

-- SELECT fn_active_percentage () AS active_percentage;


-- FUNCIÓN QUE DA EL NOMBRE DE LA CARRERA ELEGIDA
DELIMITER //
CREATE FUNCTION fn_name_career (id_num INT) RETURNS VARCHAR(50)
READS SQL DATA
BEGIN
	DECLARE max_id INT;
	DECLARE career_name VARCHAR(50);
    SELECT MAX(id_career) INTO max_id FROM career;
    IF (id_num < 1 OR id_num > max_id) THEN
		SET career_name = 'There is no career with that number.';
	ELSE
		SET career_name = (SELECT name FROM career WHERE id_career = id_num);
    END IF;
    RETURN career_name;
END
//
DELIMITER ;
-- DROP FUNCTION fn_name_career;

-- SELECT fn_name_career(3) AS career;


-- FUNCIÓN QUE DA EL NOMBRE DE LA CARRERA CON MÁS ALUMNOS ACTIVOS
DELIMITER $$
CREATE FUNCTION fn_career_most_active () RETURNS VARCHAR(50)
READS SQL DATA
BEGIN
	DECLARE career_most VARCHAR(50);
    SET career_most = (SELECT career FROM (SELECT c.name AS career, COUNT(*) AS total_students FROM student s 
        JOIN student_career sc ON s.id_student = sc.student_id
        JOIN career c ON sc.career_id = c.id_career 
        WHERE s.is_active = 1 GROUP BY c.id_career ORDER BY total_students DESC) AS active_students LIMIT 1);
	RETURN career_most;
END;
$$
DELIMITER ;
-- DROP FUNCTION fn_career_most_active;

-- SELECT fn_career_most_active () AS career_most_active;




-- ***************************************************************************************************************************
-- ***************************************************************************************************************************
-- STORED PROCEDURES
-- ***************************************************************************************************************************
-- ***************************************************************************************************************************


-- SP QUE MUESTRA LOS NOMBRES DE ALUMNOS DE UNA CARRERA DADA (id) (TOTALES)
DELIMITER $$
CREATE PROCEDURE sp_career_students_list (IN id INT, OUT message VARCHAR(40))
BEGIN
	DECLARE max_id INT;
    SELECT MAX(id_career) INTO max_id FROM career; -- Asigno el valor a max_id con SELECT INTO.
    IF (id < 1 OR id > max_id) THEN
		SET message = 'There is no career with that number.';
	ELSE
		SET @roster = CONCAT('SELECT s.id_student, s.first_name, s.last_name, s.file_number FROM student s 
        JOIN student_career sc ON s.id_student = sc.student_id
        JOIN career c ON sc.career_id = c.id_career 
        WHERE id_career = ', id);
        SET message = 'Successful query.';
        PREPARE roster FROM @roster;
		EXECUTE roster;
		DEALLOCATE PREPARE roster;
	END IF;
END
$$
DELIMITER ;
-- DROP PROCEDURE sp_career_students_list;

-- CALL sp_career_students_list (4, @message);
-- SELECT @message AS result; -- @ indica que message es una variable.

-- CALL sp_career_students_list (33, @message);
-- SELECT @message AS result;


-- SP QUE MUESTRA LOS NOMBRES DE ALUMNOS DE UNA CARRERA DADA (id) (ACTIVOS)
DELIMITER $$
CREATE PROCEDURE sp_career_active_list (IN id INT, OUT message VARCHAR(40))
BEGIN
	DECLARE max_id INT;
    SELECT MAX(id_career) INTO max_id FROM career;
    IF (id < 1 OR id > max_id) THEN
		SET message = 'There is no career with that number.';
	ELSE
		SET @roster = CONCAT('SELECT s.id_student, s.first_name, s.last_name, s.file_number FROM student s 
        JOIN student_career sc ON s.id_student = sc.student_id
        JOIN career c ON sc.career_id = c.id_career 
        WHERE id_career = ', id, ' AND s.is_active = 1');
        SET message = 'Successful query.';
        PREPARE roster FROM @roster;
		EXECUTE roster;
		DEALLOCATE PREPARE roster;
		END IF;
END
$$
DELIMITER ;
-- DROP PROCEDURE sp_career_active_list;

-- CALL sp_career_active_list (4, @message);
-- SELECT @message AS result; -- @ indica que message es una variable.

-- CALL sp_career_active_list (33, @message);
-- SELECT @message AS result;


-- SP QUE MUESTRA LA CANTIDAD DE ALUMNOS DE UNA CARRERA DADA (id) (TOTALES)
DELIMITER //
CREATE PROCEDURE sp_career_total_students (IN id INT, OUT message VARCHAR(40))
BEGIN
	DECLARE max_id INT;
    SELECT MAX(id_career) INTO max_id FROM career;
    IF (id < 1 OR id > max_id) THEN
		SET message = 'There is no career with that number.';
	ELSE
		SET @roster = CONCAT('SELECT c.name AS career, COUNT(*) AS total_students FROM student s 
        JOIN student_career sc ON s.id_student = sc.student_id
        JOIN career c ON sc.career_id = c.id_career 
        WHERE id_career = ', id);
        SET message = 'Successful query.';
        PREPARE roster FROM @roster;
		EXECUTE roster;
		DEALLOCATE PREPARE roster;
		END IF;
END;
//
DELIMITER ;
-- DROP PROCEDURE sp_career_total_students;

-- CALL sp_career_total_students (4, @message);
-- SELECT @message AS result;

-- CALL sp_career_total_students (-3, @message);
-- SELECT @message AS result;


-- SP QUE MUESTRA LA CANTIDAD DE ALUMNOS EN CADA CARRERA (TOTALES)
/*DELIMITER //
CREATE PROCEDURE sp_total_students_per_career ()
BEGIN
		SET @roster = CONCAT('SELECT c.name AS career, COUNT(*) AS total_students
        FROM student s JOIN student_career sc ON s.id_student = sc.student_id
        JOIN career c ON sc.career_id = c.id_career GROUP BY c.id_career ORDER BY c.name');
        PREPARE roster FROM @roster;
		EXECUTE roster;
		DEALLOCATE PREPARE roster;
END;
//
DELIMITER ;*/
-- DROP PROCEDURE sp_total_students_per_career;

-- CALL sp_total_students_per_career ();


/*-- SP QUE MUESTRA LA CANTIDAD DE ALUMNOS EN CADA CARRERA (ACTIVOS)
DELIMITER //
CREATE PROCEDURE sp_students_per_career ()
BEGIN
		SET @roster = CONCAT('SELECT c.name AS career, COUNT(*) AS total_students FROM student s 
        JOIN student_career sc ON s.id_student = sc.student_id
        JOIN career c ON sc.career_id = c.id_career 
        WHERE s.is_active = 1 GROUP BY c.id_career ORDER BY c.name');
        PREPARE roster FROM @roster;
		EXECUTE roster;
		DEALLOCATE PREPARE roster;
END;
//
DELIMITER ;*/
-- DROP PROCEDURE sp_students_per_career;

-- CALL sp_students_per_career (); -- No muestra el 0. Las que tienen 0 no aparecen.
-- CALL sp_total_students_per_career ();


-- SP QUE LISTA LAS ASIGNATURAS DE UNA CARRERA DADA (id) (VERIFICA QUE EL id CORRESPONDA A UNA CARRERA)
DELIMITER $$
CREATE PROCEDURE sp_career_subjects (IN id INT)
BEGIN
	DECLARE max_id INT;
    SELECT MAX(id_career) INTO max_id FROM career;
	IF (id < 1 OR id > max_id) THEN
		SET @message = 'There is no career with that number.';
	ELSE
		-- DECLARE clausula VARCHAR(250); -- No hace falta. Si pongo DECLARE, y SET sin @, no anda.
		SET @clausula = CONCAT('SELECT s.name AS subjects FROM subject s 
        JOIN career c ON s.career_id = c.id_career 
        WHERE career_id = ', id);
		PREPARE clause FROM @clausula;
		EXECUTE clause;
		DEALLOCATE PREPARE clause;
        SET @message = 'Successful query.';
	END IF;
END
$$
DELIMITER ;
-- DROP PROCEDURE sp_career_subjects;

-- CALL sp_career_subjects(25);
-- SELECT @message AS result;


-- SP QUE LISTA LA BIBLIOGRAFÍA DE UNA CARRERA DADA (id)
DELIMITER $$
CREATE PROCEDURE sp_career_books (IN id INT)
BEGIN
	DECLARE max_id INT;
    SELECT MAX(id_career) INTO max_id FROM career;
	IF (id < 1 OR id > max_id) THEN
		SET @message = 'There is no career with that number.';
	ELSE
		SET @clausula = CONCAT('SELECT b.title, b.author FROM book b 
        JOIN subject s ON b.subject_id = s.id_subject
        JOIN career c ON s.career_id = c.id_career
        WHERE career_id = ', id);
		PREPARE clause FROM @clausula;
		EXECUTE clause;
		DEALLOCATE PREPARE clause;
        SET @message = 'Successful query.';
	END IF;
END
$$
DELIMITER ;
-- DROP PROCEDURE sp_career_books;

-- CALL sp_career_books (22);
-- SELECT @message AS result;


-- SP QUE LISTA LOS PROFESORES DE UNA CARRERA DADA (id)
DELIMITER $$
CREATE PROCEDURE sp_career_professors (IN id INT)
BEGIN
	DECLARE max_id INT;
    SELECT MAX(id_career) INTO max_id FROM career;
	IF (id < 1 OR id > max_id) THEN
		SET @message = 'There is no career with that number.';
	ELSE
		SET @clausula = CONCAT('SELECT p.id_prof, p.first_name, p.last_name FROM professor p
        JOIN professor_subject ps ON p.id_prof = ps.professor_id
        JOIN subject s ON ps.subject_id = s.id_subject
        JOIN career c ON s.career_id = c.id_career
        WHERE career_id = ', id);
		PREPARE clause FROM @clausula;
		EXECUTE clause;
		DEALLOCATE PREPARE clause;
        SET @message = 'Successful query.';
	END IF;
END
$$
DELIMITER ;
-- DROP PROCEDURE sp_career_professors;

-- CALL sp_career_professors (22);
-- SELECT @message AS result;


-- SP QUE MUESTRA LAS CARRERAS QUE CURSA UN ALUMNO DADO (file_number)
DELIMITER $$
CREATE PROCEDURE sp_student_careers (IN file_num INT)
BEGIN
	DECLARE id INT;
    SET id = (SELECT id_student FROM student WHERE file_number = file_num);
	IF (id IS NULL) THEN
		SET @message = 'There is no student with that file number.';
	ELSE
		SET @clausula = CONCAT('SELECT c.name FROM career c
        JOIN student_career sc ON c.id_career = sc.career_id
        JOIN student s ON sc.student_id = s.id_student
        WHERE id_student = ', id);
		PREPARE clause FROM @clausula;
		EXECUTE clause;
		DEALLOCATE PREPARE clause;
        SET @message = 'Successful query.';
	END IF;
END
$$
DELIMITER ;
-- DROP PROCEDURE sp_student_careers;

-- CALL sp_student_careers (777);
-- SELECT @message AS result;

-- CALL sp_student_careers (99);
-- SELECT @message AS result;


-- SP PARA INGRESAR ALUMNOS, CON VALIDACIÓN DE CAMPOS
DELIMITER %%
CREATE PROCEDURE sp_check_student (IN first_name VARCHAR(50), IN last_name VARCHAR(50), IN sex CHAR(5), IN DNI VARCHAR(8), IN country_id INT,
IN file_num INT, IN birth DATE, IN address VARCHAR(30), IN phone VARCHAR(15), IN email VARCHAR(50), IN is_active INT)
BEGIN
        -- START TRANSACTION;
			-- Me fijo que no exista un alumno con ese legajo.
			IF NOT EXISTS (SELECT id_student FROM student WHERE file_number = file_num) THEN
				BEGIN
                IF UCASE(sex) <> 'M' AND UCASE(sex) <> 'F' THEN  -- Reviso que haya ingresado sexo M o F.
                        SELECT 'Incorrect sex entry.' AS 'Error';
                    ELSE IF LENGTH(DNI) < 6 OR LCASE(DNI) <> UCASE(DNI) OR DNI < 0 THEN  -- Reviso que el DNI sea válido.
						SELECT 'Please enter a valid DNI.' AS 'Error';
						ELSE IF country_id < 1 OR country_id > 30 THEN  -- Reviso que el país exista.
							SELECT CONCAT('There is no country with id ', country_id, '.') AS 'Error';
                            ELSE IF (file_num < 0) THEN  -- Reviso que el legajo no sea un número negativo.
								SELECT 'The file number must be positive.' AS 'Error';
                                ELSE IF BINARY LCASE(phone) <> BINARY UCASE(phone) THEN  -- Reviso que no haya letras en el teléfono.
									SELECT 'The telephone number is incorrect.' AS 'Error';
                                    ELSE IF email not LIKE '%@%' THEN  -- Reviso que el correo tenga la @.
										SELECT 'Please enter a valid email.' AS 'Error';
										ELSE IF is_active <> 0 AND is_active <> 1 THEN  -- Reviso que sea true o false.
											SELECT 'Enter 1 for active or 0 for inactive.' AS 'Error';
											ELSE
												INSERT INTO student (id_student, first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, is_active)
												VALUES (null, first_name, last_name, sex, DNI, country_id, file_num, birth, address, phone, email, is_active);
											END IF;
                                        END IF;
									END IF;
                                END IF;
                            END IF;
						END IF;
					END IF;
                END;
			ELSE
				SELECT 'There is already a student with that file number.' AS 'Error';
            END IF;
END;
%%
DELIMITER ;
-- DROP PROCEDURE sp_check_student;

-- CALL sp_check_student ('Felipe', 'Pérez', 'G', '37398201', 11, 453, '1986-10-09', 'Avellaneda 1212', '3748934567', 'feli34@yahoo.com.ar', '1');


-- SP QUE CAPTURA ERRORES AL INTENTAR INSERTAR ALUMNOS
DELIMITER %%
CREATE PROCEDURE sp_add_student (IN first_name VARCHAR(50), IN last_name VARCHAR(50), IN sex VARCHAR(50), IN DNI VARCHAR(50), IN country_id VARCHAR(50),
IN file_num VARCHAR(50), IN birth VARCHAR(50), IN address VARCHAR(50), IN phone VARCHAR(50), IN email VARCHAR(50), IN is_active VARCHAR(50))
BEGIN
    DECLARE EXIT HANDLER FOR SQLSTATE '22001' -- Error 1406, string muy largo.
		BEGIN
			ROLLBACK;
            SELECT 'Data too long for column sex.' AS 'Error'; -- No hace falta porque verifica con un IF.
        END;
	DECLARE EXIT HANDLER FOR SQLSTATE '22007' -- Error 1292, fecha incorrecta.
		BEGIN
			ROLLBACK;
            SELECT 'Incorrect date value on birth.' AS 'Error';
        END;
	DECLARE EXIT HANDLER FOR SQLSTATE 'HY000' -- Error 1366, puso letra en vez de entero.
		BEGIN
			ROLLBACK;
            SELECT 'Incorrect integer value' AS 'Error';
        END;
	DECLARE EXIT HANDLER FOR SQLStATE '01000' -- Error 1265, data truncated.
		BEGIN
			ROLLBACK;
            SELECT 'Incorrect value' AS 'Error'; -- También soluciona si el DNI es muy largo.
        END;
        START TRANSACTION;
			CALL sp_check_student (first_name, last_name, sex, DNI, country_id, file_num, birth, address, phone, email, is_active);
			COMMIT;
END;
%%
DELIMITER ;
-- DROP PROCEDURE sp_add_student;

-- CALL sp_add_student ('Felipe', 'Pérez', 'M', '39378201', '1', '453', '1986-10-09', 'Avellaneda 1212', '3748934567', 'feli34@yahoo.com.ar', '1');

-- SELECT UCASE('374893456e') = LCASE('374893456e'); -- Esto es TRUE, no diferencia. Lo mismo con LIKE.
-- SELECT BINARY UCASE('374893456e') = BINARY LCASE('374893456e'); -- Esto es FALSO. Sí diferencia mayúsculas de minúsculas.


-- SP PARA INGRESAR PROFESORES
DELIMITER //
CREATE PROCEDURE sp_add_professor (IN surname VARCHAR(50), IN name VARCHAR(50), IN sex CHAR(4))
-- Pongo CHAR(4) para que saltee el Error 1406, en que el string es más largo que la capacidad.
BEGIN
	IF UCASE(sex) <> 'M' AND UCASE(sex) <> 'F' THEN
		SET @message = 'Please enter a valid sex option.';
	ELSE
		INSERT INTO professor (first_name, last_name, sex) VALUES (name, surname, sex);
        SET @message = 'Successful entry.';
	END IF;
END;
//
DELIMITER ;
-- DROP PROCEDURE sp_add_professor;

-- CALL sp_add_professor ('Quinterno', 'Dante', 'M');
-- SELECT @message AS result;

-- DELETE FROM professor WHERE id_prof = 41;


-- ***************************************************************************************************************************
-- ***************************************************************************************************************************
-- TRIGGERS
-- ***************************************************************************************************************************
-- ***************************************************************************************************************************

-- TRIGGER QUE GUARDA LOS INGRESOS DE LOS ALUMNOS AL SISTEMA EN UNA TABLA DE AUDITORÍA

-- TABLA NECESARIA PARA AUDITORÍA
CREATE TABLE new_students (
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
DELIMITER //
CREATE TRIGGER tr_audit_students
AFTER INSERT ON student
FOR EACH ROW
INSERT INTO new_students (first_name, last_name, file_number, entry_dt, user_id) -- No le paso id_student de la otra, porque no ingreso ese valor.
VALUES (NEW.first_name, NEW.last_name, NEW.file_number, CURRENT_TIMESTAMP(), USER());
//
DELIMITER ;
-- DROP TRIGGER tr_audit_students;

-- INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, is_active) VALUES
-- ('Felipe', 'Pérez', 'M', '37398201', 11, 451, '1986-10-09', 'Avellaneda 1212', '3748934567', 'feli34@yahoo.com.ar', 1);


-- TRIGGER QUE GUARDA LOS ALUMNOS ELIMINADOS DEL SISTEMA EN UNA TABLA DE AUDITORÍA

-- TABLA NECESARIA PARA AUDITORÍA
CREATE TABLE old_students (
id_student INT PRIMARY KEY AUTO_INCREMENT,
first_name VARCHAR(50),
last_name VARCHAR(50),
file_number VARCHAR(8),
entry_dt datetime,
user_id VARCHAR(50)
);
-- DROP TABLE old_students;

-- SELECT * FROM student;
-- SELECT * FROM old_students;

-- TRIGGER
DELIMITER $$
CREATE TRIGGER tr_audit_deleted_students
BEFORE DELETE ON student
FOR EACH ROW
INSERT INTO old_students (first_name, last_name, file_number, entry_dt, user_id)
VALUES (OLD.first_name, OLD.last_name, OLD.file_number, CURRENT_TIMESTAMP(), USER());
$$
DELIMITER ;
-- DROP TRIGGER tr_audit_deleted_students;

-- DELETE FROM student WHERE file_number = 213 AND id_student <> 0;

-- SELECT * FROM student ORDER BY file_number;
-- SELECT * FROM old_students;




-- ***************************************************************************************************************************
-- ***************************************************************************************************************************
-- USERS
-- ***************************************************************************************************************************
-- ***************************************************************************************************************************

-- USE mysql;  -- Uso esta DB para gestionar los usuarios.


-- USUARIO PARA LOS ALUMNOS

CREATE USER 'alumno@localhost' IDENTIFIED BY 'alumno1234';

-- Quiero que puedan ver solamente la información general de la universidad, y lo concerniente a ellos mismos.
GRANT SELECT ON university.book TO 'alumno@localhost';
GRANT SELECT ON university.career TO 'alumno@localhost';
GRANT SELECT ON university.country TO 'alumno@localhost';
-- No quiero que vean todos los datos de los profesores. Igualmente, por ahora la DB tiene solo nombre, apellido y sexo de ellos.
GRANT SELECT (id_prof, first_name, last_name) ON university.professor TO 'alumno@localhost';
GRANT SELECT ON university.professor_subject TO 'alumno@localhost';
GRANT SELECT ON university.publisher TO 'alumno@localhost';
-- No le otorgo permisos para la tabla student. No quiero que vea los datos de todos los alumnos.
-- Ídem tabla student_career.
GRANT SELECT ON university.subject TO 'alumno@localhost';

-- USE mysql;
-- SHOW GRANTS FOR 'alumno@localhost';

-- SELECT * FROM mysql.user WHERE user LIKE 'alumno@localhost';

-- DROP USER 'alumno@localhost';


-- ***************************************************************************************************************************

-- USUARIO PARA LOS PROFESORES

CREATE USER 'profesor@localhost' IDENTIFIED BY 'profesor1234';

-- Quiero que puedan ver solamente la información general de la universidad, y algunos datos de los alumnos.
GRANT SELECT ON university.book TO 'profesor@localhost';
GRANT SELECT ON university.career TO 'profesor@localhost';
GRANT SELECT ON university.country TO 'profesor@localhost';
-- No quiero que vea todos los datos de los profesores. Igualmente, por ahora la DB tiene solo nombre, apellido y sexo de ellos.
GRANT SELECT (id_prof, first_name, last_name) ON university.professor TO 'profesor@localhost';
GRANT SELECT ON university.professor_subject TO 'profesor@localhost';
GRANT SELECT ON university.publisher TO 'profesor@localhost';
-- No quiero que vea todos los datos de los alumnos.
GRANT SELECT (id_student, first_name, last_name, file_number, email, is_active) ON university.student TO 'profesor@localhost';
GRANT SELECT ON university.student_career TO 'profesor@localhost';
GRANT SELECT ON university.subject TO 'profesor@localhost';

-- USE mysql;
-- SHOW GRANTS FOR 'profesor@localhost';

-- SELECT * FROM mysql.user WHERE user LIKE 'profesor@localhost';

-- DROP USER 'profesor@localhost';


-- ***************************************************************************************************************************

-- USUARIO PARA SECRETARÍA GENERAL

CREATE USER 'secretaria@localhost' IDENTIFIED BY 'secretaria1234';

-- Quiero que la secretaria pueda consultar toda la información de la DB sin modificarla.
GRANT SELECT ON university.* TO 'secretaria@localhost';  -- Puede consultar todas las tablas y vistas.
-- Le permito ejecutar todas las funciones, para consultar información.
GRANT EXECUTE ON FUNCTION university.fn_total_students TO 'secretaria@localhost';
GRANT EXECUTE ON FUNCTION university.fn_women_percentage TO 'secretaria@localhost';
GRANT EXECUTE ON FUNCTION university.fn_active_percentage TO 'secretaria@localhost';
GRANT EXECUTE ON FUNCTION university.fn_name_career TO 'secretaria@localhost';
GRANT EXECUTE ON FUNCTION university.fn_career_most_active TO 'secretaria@localhost';
-- Le permito ejecutar todos los procedimientos excepto los que ingresan alumnos y profesores.
GRANT EXECUTE ON PROCEDURE university.sp_career_students_list TO 'secretaria@localhost';
GRANT EXECUTE ON PROCEDURE university.sp_career_active_list TO 'secretaria@localhost';
GRANT EXECUTE ON PROCEDURE university.sp_career_total_students TO 'secretaria@localhost';
GRANT EXECUTE ON PROCEDURE university.sp_career_subjects TO 'secretaria@localhost';
GRANT EXECUTE ON PROCEDURE university.sp_career_books TO 'secretaria@localhost';
GRANT EXECUTE ON PROCEDURE university.sp_career_professors TO 'secretaria@localhost';
GRANT EXECUTE ON PROCEDURE university.sp_student_careers TO 'secretaria@localhost';

-- USE mysql;
-- SHOW GRANTS FOR 'secretaria@localhost';

-- SELECT * FROM mysql.user WHERE user LIKE 'secretaria@localhost';

-- DROP USER 'secretaria@localhost';


-- ***************************************************************************************************************************

-- USUARIO PARA LA OFICINA DIVISIÓN ALUMNOS

-- Esta oficina tiene permitido hacer todas las operaciones sobre las tablas. Funciones y procedimientos, sólo puede ejecutarlos.
CREATE USER 'division_alumnos@localhost' IDENTIFIED BY 'division_alumnos1234';

GRANT ALL PRIVILEGES ON university.* TO 'division_alumnos@localhost';  -- Todos los privilegios en la DB.

-- USE mysql;
-- SHOW GRANTS FOR 'division_alumnos@localhost';

-- SELECT * FROM mysql.user WHERE user LIKE 'division_alumnos@localhost';

-- DROP USER 'division_alumnos@localhost';


-- ***************************************************************************************************************************

-- USE mysql;
-- SHOW tables;
-- SELECT * FROM user;




-- ***************************************************************************************************************************
-- ***************************************************************************************************************************
-- INSERTS
-- ***************************************************************************************************************************
-- ***************************************************************************************************************************

USE university;

INSERT INTO professor (first_name, last_name, sex) VALUES
('Guillermo', 'Rodríguez', 'M'),
('Gimena', 'Suárez', 'F'),
('Ignacio', 'Peña', 'M'),
('Alejandro', 'González', 'M'),
('Mónica', 'Latorre', 'F'),
('Rodrigo', 'Coda', 'M'),
('Juan Carlos', 'Álvarez', 'M'),
('Marcela', 'Torres', 'F'),
('Pedro', 'Robles', 'M'),
('Álvaro', 'Rojas', 'M'),
('Elsa', 'Aráuz', 'F'),
('Marisa', 'Di Marco', 'F'),
('Néstor', 'Coppola', 'M'),
('Norberto', 'Sánchez', 'M'),
('Horacio', 'Cozzolino', 'M'),
('Ignacio', 'Aguilar', 'M'),
('Sofía', 'Diéguez', 'F'),
('ROberto', 'Álvarez', 'M'),
('Estela', 'Santoro', 'F'),
('Matías', 'Brunetti', 'M'),
('Silvia', 'Pereira', 'F'),
('Lorena', 'Basso', 'F'),
('Matías', 'Larocca', 'M'),
('Martín', 'Rodríguez', 'M'),
('Lauriano', 'Vázquez', 'M'),
('Sandra', 'Duarte', 'F'),
('Susana', 'Estévez', 'F'),
('Roque', 'Martin', 'M'),
('Santiago', 'Baccelli', 'M'),
('Rosario', 'De Palma', 'F'),
('Marcos', 'Pichetto', 'M'),
('Sofía', 'Vergara', 'M'),
('Margarita', 'Tuñón', 'F'),
('Norberto', 'Lanata', 'M'),
('Pedro', 'Suárez', 'M'),
('Sonia', 'Battistín', 'F'),
('Eva', 'Bergonti', 'F'),
('Rogelio', 'Martínez', 'M'),
('Mateo', 'Matera', 'M'),
('Silvio', 'Carreras', 'M');
-- 40 registros professor


INSERT INTO country (name) VALUES
('Argentina'),
('Chile'),
('Uruguay'),
('Paraguay'),
('Bolivia'),
('Perú'),
('Colombia'),
('Brasil'),
('Venezuela'),
('Ecuador'),
('Estado Unidos'),
('México'),
('Costa Rica'),
('Belice'),
('Nicaragua'),
('Panamá'),
('Honduras'),
('Surinam'),
('Guyana Francesa'),
('Guyana Inglesa'),
('El Salvador'),
('Cuba'),
('Jamaica'),
('República Dominicana'),
('Haití'),
('Puerto Rico'),
('Trinidad y Tobago'),
('Barbados'),
('Martinica'),
('Islas Vírgenes');
-- 30 registros country


INSERT INTO publisher (name) VALUES
('Aique'),
('Losada'),
('McGraw-Hill'),
('Dover'),
('Taschen'),
('MacMillan'),
('Eudeba'),
('Penguin'),
('Valdemar'),
('Collins'),
('Óptima'),
('Edhasa'),
('Gradifco'),
('Planeta'),
('Vergara'),
('Bantam'),
('Batsford'),
('Simon & Schuster'),
('DeBolsillo'),
('Atlántida');
-- 20 registros publisher


INSERT INTO career (name, duration_years) VALUES
('Ingeniería Mecánica', 5),
('Ingeniería Electrónica', 5),
('Ingeniería Industrial', 5),
('Filosofía', 4),
('Derecho', 4),
('Licenciatura en Física', 5),
('Licenciatura en Química', 5),
('Licenciatura en Matemática', 5),
('Psicología', 5),
('Diseño Gráfico', 4),
('Licenciatura en Sistemas', 5),
('Diseño Industrial', 4),
('Ciencias de la atmósfera', 5),
('Kinesiología', 5),
('Medicina', 5),
('Astronomía', 4),
('Sociología', 4),
('Ciencias políticas', 4),
('Profesorado de Inglés', 4),
('Farmacia', 5),
('Comunicación social', 4),
('Literatura', 4),
('Letras', 4),
('Profesorado de Historia', 4),
('Ingeniería en alimentos', 5);
-- 25 registros career


INSERT INTO subject (name, career_id) VALUES
('Mecánica elemental', 1),
('Mecánica clásica', 6),
('Química I', 7),
('Industria Argentina en el siglo XX', 3),
('Filosofía antigua', 4),
('Derecho internacional', 5),
('Termodinámica', 6),
('Literatura griega', 22),
('La ionósfera', 13),
('Anatomía', 15),
('Lengua española', 23),
('Linux', 11),
('Sociedades del siglo XIX', 17),
('Cometas', 16),
('Química médica I', 20),
('Literatura irlandesa', 19),
('Lípidos', 25),
('Análisis funcional', 8),
('Relaciones internacionales', 18),
('Fisioterapia', 14),
('Diseño I', 12),
('Electrotecnia I', 2),
('Medios televisivos', 21),
('Psiquiatría', 9),
('Electrotecnia II', 2),
('Diseño publicitario', 10),
('Historiografía', 24),
('Álgebra lineal II', 8),
('Aspectos psicosociales de la adolescencia', 9),
('Biología I', 20),
('Mecánica del continuo', 1),
('Lenguaje proyectual II', 12),
('Probabilidad y estadística', 8),
('Literatura romana', 22),
('Tecnología I', 12),
('Mediciones eléctricas', 2),
('Lenguaje proyectual I', 12),
('Historia contemporánea', 24),
('Ecuaciones diferenciales', 8),
('Redes sociales', 21),
('Álgebra lineal I', 8),
('Interfaz de usuario', 10),
('Mecánica racional', 1),
('Psicoanálisis', 9),
('Logoterapia', 9),
('Variable compleja', 8),
('Química inorgánica I', 7),
('Código civil', 5),
('Introducción a la física', 6),
('Energías renovables', 3),
('Química inorgánica II', 7),
('Química orgánica I', 7),
('Introducción a la programación', 11),
('Química orgánica II', 7),
('Seguridad e higiene', 3),
('Química II', 7),
('Filosofía moderna', 4),
('Filosofía presocrática', 4),
('Gases atmosféricos', 13),
('Ciclones', 13),
('Luxaciones', 14),
('Anatomía normal y funcional', 14),
('Oftalmología', 15),
('Clínica médica', 15),
('Exoplanetas', 16),
('Enanas blancas', 16),
('Civilizaciones antiguas', 17),
('El radicalismo', 18),
('Política griega antigua', 18),
('Inglés americano', 19),
('Literatura inglesa', 19),
('Biología molecular', 20),
('Histología', 20),
('Ortografía', 23),
('Veganismo', 25);
-- 75 registros subject


INSERT INTO book (title, author, publisher_id, year, ISBN, subject_id) VALUES
('Classical Mechanics', 'Goldstein, Richard', 4, 2005, 9780486715409, 2),
('La diplomacia', 'Roberts, William', 9, 2020, 9780989054786, 19),
('Anatomía humana', 'Testut, David', 18, 1910, 9783309876909, 10),
('Física I', 'Hetcht, Herbert', 2, 1987, 9788503817409, 1),
('Historia de la literatura griega', 'Bowra, Claude', 19, 1980, 9784562290878, 8),
('Classical Thermodynamics', 'Hill, Joseph', 10, 2010, 9785830098444, 7),
('El cometa', 'Sagan, Carl', 15, 1982, 9784533667521, 14),
('Fisicoquímica', 'Resnick, Paul', 2, 2001, 9788390766543, 3),
('Los carbohidratos', 'Greenberg, Charles', 17, 2018, 9783455227651, 15),
('La filosofía de Marco Aurelio', 'Reyes, Alfonso', 9, 1985, 9787762099811, 5),
('Análisis funcional', 'Cauchy, Claude', 15, 1996, 9784336751890, 18),
('El derecho en el Mercosur', 'Morales, Esteban', 7, 2023, 9787446389012, 6),
('Estudio sobre la ionósfera', 'Richards, John', 12, 2021, 9783334528765, 9),
('Sistemas Operativos', 'Williams, John', 8, 2011, 9783451120945, 12),
('Dracula', 'Stoker, Bram', 5, 2013, 9783578907890, 16),
('Los filósofos griegos', 'Guthrie, Oswald', 4, 1999, 9787392086675, 5),
('La sociedad contemporánea', 'Romero, José Luis', 11, 1967, 9784487390987, 13),
('Las grasas saturadas', 'Beckham, David', 17, 2012, 9786700321876, 17),
('Estudio de la lengua española', 'Cortés, Jorge', 10, 1951, 9787739871243, 11),
('La fisioterapia en niños', 'Smith, George', 14, 2019, 9782436765409, 20),
('Diseño tridimensional', 'Smith, Wolfgang', 18, 2003, 9787739208744, 21),
('Circuitos eléctricos', 'Panofsky, Ernest', 12, 1998, 9783847299810, 22),
('Los noticieros de los años 70s', 'Rodríguez, Claudio', 5, 2012, 9783891776302, 23),
('El cerebro humano', 'Richards, Louis', 11, 2023, 9786722897667, 24),
('Cicuitos complejos', 'Holland, Peter', 20, 2008, 9783432676982, 25),
('La publicidad en el siglo XXI', 'Ramírez, Enzo', 17, 2021, 9788940938755, 26),
('Los problemas historiográficos', 'Patterson, Roger', 9, 2001, 9788382827654, 27),
('Álgebra lineal', 'Roberts, Paul', 3, 1984, 9782938716654, 28),
('La adolescencia', 'Suárez, Ernesto', 13, 1999, 9788899333776, 29),
('Los procesos biológicos', 'Albert, James', 15, 2011, 9787738567109, 30),
('Mecánica del continuo', 'Timoshenko, Stephen', 3, 1984, 9786473378226, 31),
('El lenguaje del diseño', 'Benítez, Laura', 18, 2014, 9783489874632, 32),
('Estudio de la probabilidad', 'Di Marco, Romina', 4, 2013, 9787788336542, 33),
('Procesos estocásticos', 'Davis, Richard', 19, 2020, 9783844772890, 33),
('Polibio - Obras completas', 'Stevens, Angela', 1, 2000, 9787623674556, 34),
('Los metales', 'De Cicco, Germán', 16, 2019, 9787783662909, 35),
('Polímeros', 'Aráuz, Emilia', 2, 2022, 9782738665492, 35),
('Instrumentos de medición', 'Suárez, Juan Carlos', 8, 1987, 9781287443372, 36),
('El error experimental', 'Anderson, Sophie', 6, 2004, 9783487990456, 36),
('El dibujo en el diseño', 'De Andrea, Lorena', 17, 2009, 9786473392012, 37),
('La revolución francesa', 'Ramírez, Pablo', 13, 2011, 9783847494023, 38),
('La revolución industrial', 'Peterson, Claudia', 12, 1981, 9783327866540, 38),
('La independencia de los Estados Unidos', 'Hemingway, Arthur', 18, 2001, 9783899726652, 38),
('Ecuaciones diferenciales ordinarias', 'López, Carlos', 4, 1996, 9782389764893, 39),
('Ecuaciones diferenciales parciales', 'Roberts, Stephanie', 7, 1999, 9783899675309, 39),
('Ecuaciones diferenciales de orden superior', 'Anderson, Leslie', 6, 2023, 9783489467612, 39),
('El boom de Facebook', 'Zivano, Lorenzo', 9, 2013, 9783892099843, 40),
('El fenómeno Twitter', 'Garay, Anabella', 1, 2019, 9788947678903, 40),
('Álgebra desde cero', 'Roberts, Paul', 13, 1989, 9788473991287, 41),
('Las aplicaciones modernas', 'Rogers, Steve', 15, 2024, 9783922877390, 42),
('Mecánica racional', 'Landau, Paul', 8, 1977, 9784349119876, 43),
('El psicoanálisis', 'Freud, Edmund', 3, 1998, 9783894461728, 44),
('La hipnosis en el psicoanálisis', 'McMiller, Anna', 3, 2020, 9781128873909, 44),
('El hombre en busca de sentido', 'Frankl, Viktor', 3, 1984, 9788793828763, 45),
('El hombre en busca del sentido último', 'Frankl, Viktor', 3, 1989, 9781928374659, 45),
('Los números complejos', 'Moure, Magdalena', 9, 1993, 9783283927188, 46),
('Las sales', 'Grossmann, Pedro ', 11, 1999, 9783887992744, 47),
('Código civil de la República Argentina', 'VV.AA.', 1, 1983, 9783498338002, 48),
('Física para principiantes', 'Resnick, Paul', 14, 2011, 9788937655278, 49),
('Física clásica', 'Resnick, Paul', 14, 2009, 9783928770021, 49),
('La energía eólica', 'McArthur, Silvia', 18, 2022, 9782387197748, 50),
('Química inorgánica', 'González, Carolina', 6, 1999, 9787755839280, 51),
('Las proteínas', 'Evans, Peter', 19, 2000, 9782278445098, 52),
('La lógica de programación', 'Edwards, Joseph', 8, 2015, 9783884992765, 53),
('Programación en Pascal', 'Edwards, Joseph', 8, 2016, 9783487398023, 53),
('La cadena de ADN', 'Lorentz, James', 20, 1988, 9781249938772, 54),
('Los residuos industriales', 'Borges, Celina', 7, 2008, 9787766339820, 55),
('Química general', 'Connors, William', 15, 1994, 9782865229810, 56),
('Termodinámica del equilibrio', 'Atkins, Robert', 4, 1995, 9783392076451, 7),
('Obras completas', 'Sófocles', 3, 2001, 9783892204487, 8),
('Las siete tragedias', 'Esquilo', 3, 2001, 9783829448829, 8),
('Tragedias I', 'Eurípides', 3, 2001, 9783726773371, 8),
('Tragedias II', 'Eurípides', 3, 2001, 9782900338194, 8),
('Tragedias III', 'Eurípides', 3, 2001, 9789473381104, 8),
('Menandro - Fragmentos', 'Menandro', 3, 2001, 9787293301943, 8),
('Teatro completo', 'Wilde, Oscar', 12, 2010, 9781564882273, 16),
('La filosofía de Kant', 'Reynolds, Samuel', 2, 2014, 9783488226615, 57),
('Los presocráticos', 'Murray, Sabrina', 2, 2013, 9781236548799, 58),
('Los gases de la atmósfera', 'Rodríguez, Pedro', 9, 2021, 9784467728991, 59),
('Los ciclones en el mar Caribe', 'Williams, Ernest', 6, 2022, 9783499553387, 60),
('Luxaciones en miembro inferior', 'Robertson, Susan', 16, 2021, 9788877351132, 61),
('Anatomía funcional', 'Pérez, Alfredo', 17, 2004, 9783498276655, 62),
('Oftalmología', 'Gauss, Homer', 5, 2000, 9783982817654, 63),
('Medicina clínica', 'Sommerset, Helen', 1, 1994, 9787844536671, 64),
('El sistema solar', 'Davidson, Anna', 12, 2010, 9783362771009, 65),
('Las estrellas', 'Pavard, Hernán', 8, 2019, 9784452271185, 66),
('Estado y sociedad en el mundo antiguo', 'Romero, José Luis', 15, 1996, 9783382997164, 67),
('El nacimiento de la UCR', 'López, Augusto', 4, 2011, 9787446109223, 68),
('La polis griega', 'Finley, Adam', 19, 1997, 9782873926541, 69),
('Las variaciones del inglés americano', 'Phillips, Damian', 10, 2018, 9785566772891, 70),
('Las nieves del Kilimanjaro', 'Hemingway, Ernest', 14, 1998, 9786335519983, 71),
('Grandes esperanzas', 'Dickens, Charles', 8, 1996, 9788447110232, 71),
('Los compuestos orgánicos', 'Chaparro, Lucila', 11, 2017, 9783338820912, 72),
('Histología', 'De Cecco, Mauro', 20, 2003, 9783391104728, 73),
('La ortografía del español', 'Saavedra, Ignacio', 16, 2014, 9787722610043, 74),
('Alimentación vegana saludable', 'Murray, Sabrina', 2, 2013, 9781236548799, 75),
('La Eneida', 'Virgilio', 5, 2009, 9782671166524, 34),
('La energía hidráulica', 'Mitchun, Sandra', 14, 2023, 9787833550023, 50),
('La Atenas de Pericles', 'Bowra, Claude', 13, 1995, 9783379300673, 69),
('Física general', 'Tippler, Edward', 17, 2001, 9788946378112, 49);
-- 100 registros book


INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, is_active) VALUES
('Martín', 'López', 'M', '23874908', 9, 213, '1997-12-03', 'Las Heras 2053', '5424798731', 'tincho@hotmail.com', 1),
('José', 'Torres', 'M', '32978865', 2, 3565, '1991-09-03', 'Belgrano 342', '6698208667', 'jose@hotmail.com', 0),
('María', 'Navarro', 'F', '29387334', 1, 2298, '1987-02-23', 'San Juan 2223', '2385859943', 'mary@gmail.com', 0),
('Jesús', 'Berra', 'M', '33987987', 9, 1234, '2001-12-12', 'Italia 531', '5638298871', 'jesus@yahoo.com.ve', 1),
('Felipe', 'De Marco', 'M', '36077343', 7, 435, '1987-10-09', 'Avellaneda 121', '3749047883', 'feli@yahoo.com.ar', 1),
('Lucila', 'Suárez', 'F', '32879980', 12, 678, '2002-01-14', 'Francia 5321', '7864718256', 'lucile@yahoo.com.ar', 1),
('Gimena', 'Rodríguez', 'F', '27188344', 15, 34, '1982-04-12', 'Sarmiento 3981', '3325784628', 'gime@hotmail.com', 1),
('Franco', 'Kim', 'M', '30897554', 3, 4335, '1984-11-02', 'Colón 1231', '6729811009', 'franco@yahoo.com.uy', 0),
('José', 'Di Stefano', 'M', '29746288', 11, 897, '1997-01-09', 'Paso 121', '7837197399', 'joseph@hotmail.com.ar', 1),
('Ignacio', 'Scarano', 'M', '33897876', 25, 42, '2007-05-11', 'Rodríguez Peña 2001', '3876510949', 'ignacio@gmail.com', 1),
('Rodrigo', 'Estévez', 'M', '31984563', 1, 712, '2003-11-01', 'Talcahuano 2222', '7839287197', 'feli@yahoo.com.ar', 1),
('Laura', 'De Carli', 'F', '39023487', 4, 287, '2001-02-09', 'Luro 123', '3762984090', 'laurita@yahoo.com.ar', 1),
('Santiago', 'Fustiñana', 'M', '29856748', 16, 4490, '2006-10-02', 'Sarmiento 1232', '1908749820', 'santi@gmail.com', 0),
('Bruno', 'Giménez', 'M', '32847392', 17, 1122, '1999-12-09', 'Vieytes', '8573928098', 'bruni@yahoo.com.ar', 0),
('Romina', 'Rojas', 'F', '33289765', 5, 1435, '2008-03-12', 'Garay 1968', '4673989876', 'romina@yahoo.com', 0),
('Mauro', 'Di Mauro', 'M', '36813773', 14, 555, '1989-11-09', 'Castelli 2662', '7462899234', 'maur23i@gamil.com', 1),
('Iván', 'Nociti', 'M', '31873678', 6, 111, '1997-01-17', 'Avellaneda 1221', '9887265478', 'ivancito@yahoo.com.ar', 1),
('Felipe', 'Rodríguez', 'M', '28884635', 19, 235, '2004-07-09', 'Belgrano 2118', '9720837592', 'feli@yahoo.com', 0),
('Jorgelina', 'Jiménez', 'F', '34339876', 18, 52, '1986-10-08', 'San Martín 3445', '9839027819', 'jor23@yahoo.com.ar', 1),
('Fernando', 'Ayuso', 'M', '33456456', 1, 75, '1977-10-09', 'Quintana 896', '7839850392', 'ferchu@hotmail.com', 0),
('Pedro', 'Juárez', 'M', '34088923', 12, 212, '2002-03-03', 'Laprida 2332', '5829487337', 'pedrito@hotmail.com', 0),
('José María', 'Peña', 'M', '32098976', 8, 33, '2002-09-09', 'Las Heras 2332', '6374829387', 'chema@hotmail.com', 1),
('Pablo', 'Mármol', 'M', '34478963', 9, 1213, '2005-07-03', 'Tucumán 332', '6734562716', 'pablito@hotmail.com.ar', 1),
('Francisco', 'Otero', 'M', '27784098', 2, 133, '2006-03-19', 'Rojas 122', '8723541678', 'panchito@hotmail.com', 1),
('Celina', 'García', 'F', '34923334', 4, 13, '2004-11-03', 'Solís 232', '8739813302', 'celina89@gmail.com', 0),
('Ornela', 'Vicente', 'F', '39487124', 17, 100, '2002-02-03', 'Bolívar 2153', '2398337509', 'ornela@yahoo.com', 0),
('Jacinto', 'De Paul', 'M', '41888594', 23, 250, '2004-12-23', 'Luro 3553', '4309682187', 'jacinto_23@yahoo.com.ar', 1),
('Victora', 'Rawson', 'F', '44989043', 8, 60, '2000-01-28', 'La Rioja 2233', '9229875638', 'vicky@hotmail.com', 1),
('Elena', 'Lospenato', 'F', '28940387', 5, 291, '1999-02-28', 'Olavarría 458', '2387847362', 'elenita17@yahoo.com.ve', 1),
('Fausto', 'Tonn', 'M', '34872990', 11, 3878, '2001-11-03', 'Catamarca 7877', '4478392809', 'fausti@yahoo.com', 0),
('Emilia', 'Piñero', 'F', '42998235', 19, 2100, '1998-07-13', 'Garay 1968', '3476289817', 'emi_98@hotmail.com.ar', 1),
('Ximena', 'Odetto', 'F', '33887365', 3, 1001, '2000-01-01', 'Independencia 1234', '9083987612', 'xime@yahoo.com.pe', 1),
('Lorena', 'Gutiérrez', 'F', '45990345', 29, 1810, '2006-05-23', 'Rawson 376', '1234567891', 'lore@yahoo.com.uy', 0),
('Francisco', 'Gaspari', 'M', '45339810', 28, 1002, '2003-09-07', 'Gascón 123', '3498111234', 'panchito@hotmail.com', 1),
('Ignacio', 'Lorusso', 'M', '32099126', 12, 305, '1997-01-07', 'Falucho 4523', '5893028657', 'nachito@hotmail.com', 1),
('Rodrigo', 'Grosembacher', 'M', '34989568', 21, 802, '2000-12-31', 'Yrigoyen 2233', '2398587443', 'rodri@hotmail.com.ar', 1),
('Lucila', 'La Rocca', 'F', '31876345', 2, 953, '2003-04-09', 'Jujuy 444', '2398456633', 'luli@gmail.com', 1),
('Natalia', 'Echeverría', 'F', '34557728', 15, 777, '2001-02-17', 'Salta 45', '2244763892', 'nati@yahoo.com', 1),
('Pablo', 'Scarano', 'M', '34833945', 13, 243, '1996-01-07', 'España 4712', '4593049832', 'pablito@hotmail.com', 0),
('Marcelo', 'Taylor', 'M', '27849302', 22, 333, '1986-11-02', 'Río Negro 456', '4309448929', 'marce_86@gmail.com', 1),
('Julieta', 'Capul', 'F', '36289456', 7, 387, '1991-08-07', 'Moreno 335', '8477392809', 'julita@hotmail.com', 1),
('Lisandro', 'Di Muro', 'M', '39145998', 9, 3105, '1999-04-01', 'Entre Ríos 229', '3482990758', 'lichu@yahoo.com.py', 1),
('Lorenzo', 'Rojas', 'M', '46299834', 19, 2175, '1999-01-27', 'Quintana 478', '2378498389', 'lorenzo99@hotmail.com', 0),
('Daniel', 'Brunetti', 'M', '41985898', 14, 1985, '1994-06-02', 'Saavedra 7878', '2374787643', 'danielito@hotmail.com.uy', 1),
('Bruno', 'Rodríguez', 'M', '38444767', 16, 1287, '1996-01-29', 'Jara 1212', '4498209483', 'bruni@hotmail.com', 1),
('Ramón', 'Olmedo', 'M', '23863945', 12, 2123, '1979-10-01', 'Mateotti 333', '4398506948', 'ramon@hotmail.com.ar', 0),
('Laura', 'Álvarez', 'F', '33887722', 5, 1387, '1994-01-27', 'San Luis 4612', '4903829348', 'juli94@gmail.com', 1),
('Sofía', 'Lastorta', 'F', '29846423', 18, 343, '1990-12-03', '9 de Julio 3498', '3928485719', 'sofata@yahoo.com', 1),
('Roberto', 'Gil', 'M', '41763998', 23, 1206, '1981-03-31', 'Corrientes 3456', '3892038475', 'robert@hotmail.com', 1),
('Julieta', 'Capuletto', 'F', '34892019', 21, 563, '1998-01-23', '25 de Mayo 3466', '2385744093', 'julieta_cap@hotmail.com', 1),
('Romeo', 'Montesco', 'M', '34985448', 28, 1328, '2003-08-22', 'San Lorenzo 3468', '5392057833', 'romeo_mont@hotmail.com', 1),
('Azul', 'Peña', 'F', '43982488', 6, 2109, '2004-09-01', 'Colón 7641', '9483710987', 'azul_04@gmail.com', 0),
('Belén', 'Suárez', 'F', '41097394', 1, 1187, '2005-05-11', 'Dellepiane 421', '3489561209', 'belu@hotmail.com.ar', 1),
('Anabella', 'Lenzetti', 'F', '33892487', 15, 187, '2001-08-08', 'Buenos Aires 2300', '7823578025', 'ana_lenzetti@yahoo.com', 1),
('María José', 'Fernández', 'F', '34098476', 9, 879, '1997-02-07', 'Alvarado 2542', '3939489923', 'majo@hotmail.com', 0);
-- 55 registros student


INSERT INTO professor_subject (professor_id, subject_id) VALUES
(1, 6),
(2, 17),
(12, 5),
(1, 2),
(11, 3),
(4, 6),
(7, 6),
(10, 1),
(10, 9),
(8, 3),
(20, 13),
(17, 7),
(13, 5),
(4, 11),
(8, 16),
(2, 4),
(3, 7),
(3, 8),
(9, 9),
(10, 5),
(12, 8),
(5, 20),
(14, 2),
(15, 8),
(6, 19),
(18, 9),
(18, 1),
(20, 6),
(11, 9),
(2, 18),
(7, 10),
(9, 12),
(11, 14),
(13, 15),
(12, 12),
(21, 56),
(21, 34),
(22, 27),
(23, 44),
(23, 32),
(24, 51),
(25, 21),
(25, 25),
(26, 41),
(26, 26),
(27, 53),
(27, 48),
(28, 23),
(29, 35),
(30, 45),
(30, 46),
(31, 22),
(31, 55),
(32, 24),
(33, 33),
(34, 50),
(34, 21),
(35, 30),
(35, 52),
(36, 29),
(36, 36),
(37, 31),
(38, 39),
(39, 42),
(39, 49),
(39, 50),
(40, 40),
(16, 28),
(11, 37),
(5, 38),
(14, 43),
(20, 47),
(13, 54),
(7, 11),
(9, 24);
-- 75 registros professor_subject

INSERT INTO student_career (student_id, career_id) VALUES
(1, 4),
(1, 22),
(2, 3),
(3, 16),
(3, 10),
(4, 1),
(5, 8),
(6, 21),
(7, 1),
(7, 4),
(8, 12),
(9, 17),
(10, 2),
(10, 19),
(11, 21),
(12, 5),
(12, 1),
(13, 22),
(14, 7),
(15, 9),
(16, 1),
(16, 25),
(17, 12),
(17, 5),
(18, 11),
(19, 16),
(20, 13),
(20, 8),
(21, 7),
(21, 4),
(22, 11),
(23, 9),
(24, 14),
(24, 15),
(25, 17),
(25, 2),
(26, 12),
(26, 3),
(27, 7),
(28, 2),
(29, 13),
(30, 15),
(31, 23),
(32, 16),
(33, 7),
(34, 1),
(34, 6),
(35, 8),
(36, 11),
(37, 19),
(38, 17),
(38, 22),
(38, 5),
(39, 24),
(40, 13),
(41, 14),
(41, 18),
(42, 3),
(43, 20),
(44, 5),
(44, 7),
(45, 12),
(46, 17),
(47, 11),
(47, 2),
(48, 19),
(49, 15),
(50, 11),
(51, 18),
(52, 24),
(52, 23),
(53, 8),
(54, 13),
(55, 25),
(55, 16);
-- 75 registros student_career

/*
SELECT * FROM PROFESSOR;
SELECT * FROM CAREER;
SELECT * FROM SUBJECT;
SELECT * FROM PUBLISHER;
SELECT * FROM BOOK;
SELECT * FROM COUNTRY;
SELECT * FROM STUDENT;
SELECT * FROM professor_subject;
SELECT * FROM student_career ORDER BY student_id;
SELECT * FROM student_career ORDER BY career_id;
SELECT * FROM new_students;
SELECT * FROM old_students;
*/