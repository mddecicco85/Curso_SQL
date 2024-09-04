USE university_bis;

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
('Sofía', 'Dieguez', 'F'),
('ROberto', 'Álvarez', 'M'),
('Estela', 'Santoro', 'F'),
('Matías', 'Brunetti', 'M');
-- 20 registros


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
-- 30 registros


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
-- 20 registros


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
('Recursos humanos', 4),
('Ingeniería en alimentos', 5);
-- 25 registros


INSERT INTO subject (name, career_id) VALUES
('Mecánica Elemental', 1),
('Mecánica Clásica', 6),
('Química I', 7),
('Industria Argentina en el siglo XX', 3),
('Filosofía antigua', 4),
('Derecho internacional', 5),
('Termodinámica', 6),
('Literatura griega', 23),
('La ionósfera', 13),
('Anatomía', 15),
('Lengua española', 23),
('Linux', 11),
('Sociedades del siglo XIX', 17),
('Cometas', 16),
('Química Orgánica I', 20),
('Irish Literature', 19),
('Lípidos', 25),
('Análisis funcional', 8),
('Relaciones internacionales', 18),
('Fisioterapia', 14);
-- 20 registros


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
('La fisioterapia en niños', 'Smith, Goerge', 14, 2019, 9782436765409, 20);
-- 20 registros


INSERT INTO student (first_name, last_name, sex, DNI, country_id, file_number, birth, address, phone, email, career_id) VALUES
('Martín', 'López', 'M', '23874908', 9, 213, '1997-12-03', 'Las Heras 2053', '5424798731', 'tincho@hotmail.com', 4),
('José', 'Torres', 'M', '32978865', 2, 3565, '1991-09-03', 'Belgrano 342', '6698208667', 'jose@hotmail.com', 25),
('María', 'Navarro', 'F', '29387334', 1, 2298, '1987-02-23', 'San Juan 2223', '2385859943', 'mary@gmail.com', 3),
('Jesús', 'Berra', 'M', '33987987', 9, 1234, '2001-12-12', 'Italia 531', '5638298871', 'jesus@yahoo.com.ve', 16),
('Felipe', 'De Marco', 'M', '36077343', 7, 435, '1987-10-09', 'Avellaneda 121', '3749047883', 'feli@yahoo.com.ar', 2),
('Lucila', 'Suárez', 'F', '32879980', 12, 678, '2002-01-14', 'Francia 5321', '7864718256', 'lucile@yahoo.com.ar', 10),
('Gimena', 'Rodríguez', 'F', '27188344', 15, 34, '1982-04-12', 'Sarmiento 3981', '3325784628', 'gime@hotmail.com', 1),
('Franco', 'Kim', 'M', '30897554', 3, 4335, '1984-11-02', 'Colón 1231', '6729811009', 'franco@yahoo.com.uy', 8),
('José', 'Di Stefano', 'M', '29746288', 11, 897, '1997-01-09', 'Paso 121', '7837197399', 'joseph@hotmail.com.ar', 21),
('Ignacio', 'Scarano', 'M', '33897876', 25, 42, '2007-05-11', 'Rodríguez Peña 2001', '3876510949', 'ignacio@gmail.com', 1),
('Rodrigo', 'Estévez', 'M', '31984563', 1, 712, '2003-11-01', 'Talcahuano 2222', '7839287197', 'feli@yahoo.com.ar', 12),
('Laura', 'De Carli', 'F', '39023487', 4, 287, '2001-02-09', 'Luro 123', '3762984090', 'laurita@yahoo.com.ar', 17),
('Santiago', 'Fustiñana', 'M', '29856748', 16, 4490, '2006-10-02', 'Sarmiento 1232', '1908749820', 'santi@gmail.com', 2),
('Bruno', 'Giménez', 'M', '32847392', 17, 1122, '1999-12-09', 'Vieytes', '8573928098', 'bruni@yahoo.com.ar', 21),
('Romina', 'Rojas', 'F', '33289765', 5, 1435, '2008-03-12', 'Garay 1968', '4673989876', 'romina@yahoo.com', 5),
('Mauro', 'Di Mauro', 'M', '36813773', 14, 555, '1989-11-09', 'Castelli 2662', '7462899234', 'maur23i@gamil.com', 22),
('Iván', 'Nociti', 'M', '31873678', 6, 111, '1997-01-17', 'Avellaneda 1221', '9887265478', 'ivancito@yahoo.com.ar', 7),
('Felipe', 'Rodríguez', 'M', '28884635', 19, 235, '2004-07-09', 'Belgrano 2118', '9720837592', 'feli@yahoo.com', 9),
('Jorgelina', 'Jiménez', 'F', '34339876', 18, 52, '1986-10-08', 'San Martín 3445', '9839027819', 'jor23@yahoo.com.ar', 1),
('Fernando', 'Ayuso', 'M', '33456456', 1, 75, '1977-10-09', 'Quintana 896', '7839850392', 'ferchu@hotmail.com', 5),
('Pedro', 'Juárez', 'M', '34088923', 12, 212, '2002-03-03', 'Laprida 2332', '5829487337', 'pedrito@hotmail.com', 11),
('José María', 'Peña', 'M', '32098976', 8, 33, '2002-09-09', 'Las Heras 2332', '6374829387', 'chema@hotmail.com', 16),
('Pablo', 'Mármol', 'M', '34478963', 9, 1213, '2005-07-03', 'Tucumán 332', '6734562716', 'pablito@hotmail.com.ar', 13),
('Francisco', 'Otero', 'M', '27784098', 2, 133, '2006-03-19', 'Rojas 122', '8723541678', 'panchito@hotmail.com', 7),
('Celina', 'García', 'F', '34923334', 4, 13, '2004-11-03', 'Solís 232', '8739813302', 'celina89@gmail.com', 4);
-- 25 registros

truncate table professor_subject;
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
(12, 12);
-- 35 registros

/*
SELECT * FROM PROFESSOR;
SELECT * FROM CAREER;
SELECT * FROM SUBJECT;
SELECT * FROM PUBLISHER;
SELECT * FROM BOOK;
SELECT * FROM COUNTRY;
SELECT * FROM STUDENT;
SELECT * FROM professor_subject;
*/