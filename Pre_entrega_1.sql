CREATE DATABASE university;
USE university;

CREATE TABLE professor (
id_prof INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50),
last_name VARCHAR (50),
sex CHAR(1)
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
prof_id INT NOT NULL,
career_id INT NOT NULL,
FOREIGN KEY (prof_id) REFERENCES professor (id_prof),
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
file_number VARCHAR(8),
birth DATE,
address VARCHAR(30),
phone VARCHAR(15),
email VARCHAR(50),
career_id INT NOT NULL,
FOREIGN KEY (career_id) REFERENCES career (id_career)
);
-- DROP TABLE STUDENT;

SELECT * FROM PROFESSOR;
SELECT * FROM CAREER;
SELECT * FROM SUBJECT;
SELECT * FROM PUBLISHER;
SELECT * FROM BOOK;
SELECT * FROM COUNTRY;
SELECT * FROM STUDENT;


INSERT INTO professor (first_name, last_name, sex) VALUES ('Juan', 'Pérez', 'M');
INSERT INTO professor (first_name, last_name, sex) VALUES ('Guillermo', 'Rodríguez', 'M');
INSERT INTO professor (first_name, last_name, sex) VALUES ('Gimena', 'Suárez', 'F');
INSERT INTO professor (first_name, last_name, sex) VALUES ('Ignacio', 'Peña', 'M');
INSERT INTO professor (first_name, last_name, sex) VALUES ('Alejandro', 'González', 'M');
INSERT INTO professor (first_name, last_name, sex) VALUES ('Mónica', 'Latorre', 'F');
INSERT INTO professor (first_name, last_name, sex) VALUES ('Rodrigo', 'Coda', 'M');
INSERT INTO professor (first_name, last_name, sex) VALUES ('Juan Carlos', 'Álvarez', 'M');
INSERT INTO professor (first_name, last_name, sex) VALUES ('Marcela', 'Torres', 'F');
INSERT INTO professor (first_name, last_name, sex) VALUES ('Pedro', 'Robles', 'M');

INSERT INTO country (name) VALUES ('Argentina');
INSERT INTO country (name) VALUES ('Chile');
INSERT INTO country (name) VALUES ('Uruguay');
INSERT INTO country (name) VALUES ('Paraguay');
INSERT INTO country (name) VALUES ('Bolivia');
INSERT INTO country (name) VALUES ('Perú');
INSERT INTO country (name) VALUES ('Colombia');
INSERT INTO country (name) VALUES ('Brasil');
INSERT INTO country (name) VALUES ('Venezuela');
INSERT INTO country (name) VALUES ('Ecuador');

INSERT INTO publisher (name) VALUES ('Aique');
INSERT INTO publisher (name) VALUES ('Losada');
INSERT INTO publisher (name) VALUES ('McGraw-Hill');
INSERT INTO publisher (name) VALUES ('Dover');
INSERT INTO publisher (name) VALUES ('Taschen');
INSERT INTO publisher (name) VALUES ('MacMillan');
INSERT INTO publisher (name) VALUES ('Eudeba');
INSERT INTO publisher (name) VALUES ('Penguin');
INSERT INTO publisher (name) VALUES ('Valdemar');
INSERT INTO publisher (name) VALUES ('Collins');

INSERT INTO career (name, duration_years) VALUES ('Ingeniería Mecánica', 5);
INSERT INTO career (name, duration_years) VALUES ('Ingeniería Electrónica', 5);
INSERT INTO career (name, duration_years) VALUES ('Ingeniería Industrial', 5);
INSERT INTO career (name, duration_years) VALUES ('Filosofía', 4);
INSERT INTO career (name, duration_years) VALUES ('Derecho', 4);
INSERT INTO career (name, duration_years) VALUES ('Licenciatura en Física', 5);
INSERT INTO career (name, duration_years) VALUES ('Licenciatura en Química', 5);
INSERT INTO career (name, duration_years) VALUES ('Licenciatura en Matemática', 5);
INSERT INTO career (name, duration_years) VALUES ('Psicología', 5);
INSERT INTO career (name, duration_years) VALUES ('Diseño Gráfico', 4);

INSERT INTO subject (name, prof_id, career_id) VALUES ('Mecánica Elemental', 3, 1);
INSERT INTO subject (name, prof_id, career_id) VALUES ('Mecánica Clásica', 5, 6);
INSERT INTO subject (name, prof_id, career_id) VALUES ('Química I', 6, 7);
INSERT INTO subject (name, prof_id, career_id) VALUES ('La industria Argentina en el siglo XX', 2, 3);
INSERT INTO subject (name, prof_id, career_id) VALUES ('Filosofía antigua', 8, 4);
INSERT INTO subject (name, prof_id, career_id) VALUES ('Derecho internacional', 1, 5);
INSERT INTO subject (name, prof_id, career_id) VALUES ('Termodinámica', 4, 6);

INSERT INTO book (title, author, publisher_id, year, ISBN, subject_id) VALUES ('Classical Mechanics', 'Goldstein, Richard', 4, 2005, 9780486715409, 2);
INSERT INTO book (title, author, publisher_id, year, ISBN, subject_id) VALUES ('Física I', 'Hetcht, Herbert', 2, 1987, 9788503817409, 1);
INSERT INTO book (title, author, publisher_id, year, ISBN, subject_id) VALUES ('Los filósofos griegos', 'Guthrie, Oswald', 4, 1999, 9787392086675, 5);
INSERT INTO book (title, author, publisher_id, year, ISBN, subject_id) VALUES ('Classical Thermodynamics', 'Hill, Joseph', 10, 2010, 9785830098, 7);
INSERT INTO book (title, author, publisher_id, year, ISBN, subject_id) VALUES ('El derecho en el Mercosur', 'Morales, Esteban', 7, 2023, 9787446389012, 6);
INSERT INTO book (title, author, publisher_id, year, ISBN, subject_id) VALUES ('Fisicoquímica', 'Resnick, Paul', 2, 2001, 9788390766543, 3);
INSERT INTO book (title, author, publisher_id, year, ISBN, subject_id) VALUES ('La filosofía de Marco Aurelio', 'Reyes, Alfonso', 9, 1985, 9787762099811, 5);

INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, career_id) VALUES ('Martín', 'López', 'M', '23874908', 9, 213, '1997-12-03', 'Las Heras 2053', '5424798731', 'tincho@hotmail.com', 4);
INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, career_id) VALUES ('José', 'Torres', 'M', '32978865', 2, 3565, '1991-09-03', 'Belgrano 342', '6698208667', 'jose@hotmail.com', 2);
INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, career_id) VALUES ('María', 'Navarro', 'F', '29387334', 1, 2298, '1987-02-23', 'San Juan 2223', '2385859943', 'mary@gmail.com', 1);
INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, career_id) VALUES ('Jesús', 'Berra', 'M', '33987987', 9, 1234, '2001-12-12', 'Italia 531', '5638298871', 'jesus@yahoo.com.ve', 6);
INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, career_id) VALUES ('Lucila', 'Suárez', 'F', '32879980', 1, 678, '2002-01-14', 'Francia 5321', '7864718256', 'lucile@yahoo.com.ar', 10);
INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, career_id) VALUES ('Gimena', 'Rodríguez', 'F', '27188344', 5, 34, '1982-04-12', 'Sarmiento 3981', '3325784628', 'gime@hotmail.com', 1);
INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, career_id) VALUES ('Franco', 'Kim', 'M', '30897554', 3, 4335, '1984-11-02', 'Colón 1231', '6729811009', 'franco@yahoo.com.uy', 8);

SELECT * FROM PROFESSOR;
SELECT * FROM CAREER;
SELECT * FROM SUBJECT;
SELECT * FROM PUBLISHER;
SELECT * FROM BOOK;
SELECT * FROM COUNTRY;
SELECT * FROM STUDENT;