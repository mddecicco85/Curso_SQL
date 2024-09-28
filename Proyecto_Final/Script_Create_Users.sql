USE university;
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