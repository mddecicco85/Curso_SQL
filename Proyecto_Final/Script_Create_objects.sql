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