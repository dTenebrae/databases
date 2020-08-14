-- Практическое задание по теме “Транзакции, переменные, представления”


-- 1. В базе данных shop и sample присутствуют одни и те же таблицы учебной базы данных. Переместите запись id = 1 из
-- таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
INSERT INTO sample.users SELECT * FROM shop.users WHERE shop.users.id = 1;
-- Если именно переместить - то удаляем запись из исходной таблицы
DELETE FROM shop.users WHERE shop.users.id = 1;
COMMIT;


-- 2. Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее
-- название каталога name из таблицы catalogs.

CREATE VIEW name_1 AS
SELECT p.name AS product, c.name AS catalog
FROM shop.products p
         JOIN shop.catalogs c on p.catalog_id = c.id;

SELECT * FROM name_1;


-- 3. (по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи
-- за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный
-- список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она
-- отсутствует.

-- Наворотил кучу таблиц, вроде не должно, но каким то образом оно работает. Создаю таблицу calendar_table с датами
-- августа 2018. Потом с помощью LEFT JOIN'a и слова божьего получаю результат в виде столбца с датами за август 2018,
-- столбца из таблицы products с 4 датами августа того же года, и столбец COUNT, который по группировке выставляет 0/1.

CREATE TABLE calendar_table
(
    dt      DATE      NOT NULL PRIMARY KEY,
);

CREATE TABLE ints
(
    i tinyint
);

INSERT INTO ints
VALUES (0),
       (1),
       (2),
       (3),
       (4),
       (5),
       (6),
       (7),
       (8),
       (9);
SELECT *
FROM ints;

INSERT INTO calendar_table (dt)
SELECT DATE('2018-08-01') + INTERVAL a.i * 10000 + b.i * 1000 + c.i * 100 + d.i * 10 + e.i DAY
FROM ints a
         JOIN ints b
         JOIN ints c
         JOIN ints d
         JOIN ints e
WHERE (a.i * 10000 + b.i * 1000 + c.i * 100 + d.i * 10 + e.i) <= DATEDIFF('2018-08-31', '2018-08-01')
ORDER BY 1;

SELECT ct.dt, p.created_at, COUNT(p.created_at)
FROM calendar_table ct
    LEFT JOIN calendar_table act ON ct.dt = act.dt
         LEFT JOIN products p ON p.created_at = ct.dt
GROUP BY ct.dt, p.created_at
ORDER BY ct.dt;


-- 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет
-- устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

USE vk_clone;

CREATE TEMPORARY TABLE some_table
    SELECT * FROM posts ORDER BY created_at DESC LIMIT 5;

SELECT @5th := created_at FROM some_table ORDER BY created_at LIMIT 1;

DELETE FROM posts WHERE created_at < @5th;


-- Практическое задание по теме “Администрирование MySQL” (эта тема изучается по вашему желанию)

-- 1. Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read должны быть доступны
-- только запросы на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop.

CREATE USER shop_read;
CREATE USER shop;
GRANT ALL ON shop.* TO shop;
GRANT USAGE, SELECT ON shop.* TO shop_read;


-- 2. (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ,
-- имя пользователя и его пароль. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name.
-- Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из
-- представления username.

CREATE VIEW username AS SELECT id, name FROM accounts;
CREATE USER user_read;
GRANT SELECT ON shop.username TO user_read;

-- Практическое задание по теме “Хранимые процедуры и функции, триггеры"

-- 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".


DELIMITER //
DROP FUNCTION IF EXISTS hello//
CREATE FUNCTION hello ()
RETURNS VARCHAR(20)
BEGIN
	DECLARE hour int DEFAULT hour(now());
	IF hour BETWEEN 6 AND 11 THEN
  		RETURN 'Доброе утро';
	ELSEIF hour BETWEEN 12 AND 17 THEN
  		RETURN 'Добрый день';
  	ELSEIF hour BETWEEN 18 AND 23 THEN
  		RETURN 'Добрый вечер';
  	ELSEIF hour BETWEEN 0 AND 5 THEN
  		RETURN 'Доброй ночи';
	END IF;
END//

SELECT hello()//

-- 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие
-- обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры,
-- добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо
-- отменить операцию.

DELIMITER //

DROP TRIGGER IF EXISTS not_null_update //
-- Триггер на обновление имеющихся данных
CREATE TRIGGER not_null_update BEFORE UPDATE ON products
    FOR EACH ROW
BEGIN
	IF new.name IS NULL THEN
		SET NEW.name = COALESCE(NEW.name, OLD.name);
	END IF;
	IF new.description IS NULL THEN
		SET NEW.description = COALESCE(NEW.description, OLD.description);
	END IF;
END//

DROP TRIGGER IF EXISTS not_null_insert //
-- Триггер на добавление новых
CREATE TRIGGER not_null_insert BEFORE INSERT ON products
    FOR EACH ROW
BEGIN
    IF NEW.name IS NULL OR NEW.description IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled';
    END IF;
END//

-- 3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. Числами Фибоначчи называется
-- последовательность в которой число равно сумме двух предыдущих чисел. Вызов функции FIBONACCI(10) должен возвращать число 55.

DELIMITER //
DROP FUNCTION IF EXISTS fib//
CREATE FUNCTION fib (value INT)
RETURNS BIGINT
BEGIN
    DECLARE Counter, One, Two INT;
    SET Two = 1;
    IF (value > 2) THEN
        SET Counter = 3;
        SET One = 1;
        WHILE value >= Counter DO
            SET Two = One + Two;
			SET One = Two - One;
			SET Counter = Counter + 1;
            END WHILE;
    END IF;
    RETURN Two;
END //

SELECT fib(10);
