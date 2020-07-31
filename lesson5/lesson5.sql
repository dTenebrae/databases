-- 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
-- Обновляем значения требуемых полей по условию, что в created_at значение NULL. Можно идти по номерам id, etc.
UPDATE users SET created_at = NOW(), updated_at = NOW() WHERE created_at is NULL;

-- 2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое
-- время помещались значения в формате 20.10.2017 8:10. Необходимо преобразовать поля к типу DATETIME, сохранив введённые ранее значения.
-- Создаем временные столбцы с корректным типом данных, пишем в них сконвертированные данные, удаляем старые, переименовываем новые
ALTER TABLE users ADD COLUMN tmp_create DATETIME;
ALTER TABLE users ADD COLUMN tmp_update DATETIME;
UPDATE users SET tmp_create = STR_TO_DATE(created_at, '%d.%m.%Y %h:%i');
UPDATE users SET tmp_update = STR_TO_DATE(updated_at, '%d.%m.%Y %h:%i');
ALTER TABLE users DROP COLUMN created_at;
ALTER TABLE users DROP COLUMN updated_at;
ALTER TABLE users RENAME COLUMN tmp_create TO created_at;
ALTER TABLE users RENAME COLUMN tmp_update TO updated_at;

-- 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0,
-- если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом,
-- чтобы они выводились в порядке увеличения значения value. Однако нулевые запасы должны выводиться в конце, после всех записей.
SELECT value FROM storehouses_products ORDER BY value = 0;

-- 4.(по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы в виде списка английских названий (may, august)
SELECT * FROM users WHERE DATE_FORMAT(birthday_at, '%M') IN ('May', 'August');

-- 5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2);
-- Отсортируйте записи в порядке, заданном в списке IN.
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2);


-- Агрегация данных
-- 1. Подсчитайте средний возраст пользователей в таблице users.
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) FROM users;

-- 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы
-- дни недели текущего года, а не года рождения.
-- Несколько костыльно получилось. Основная идея в том, чтобы взять день и месяц рождения юзера, пришить к этому значению текущий год,
-- перевести в дату, взять название дня недели у этого значения и посчитать их количество.
SELECT
	COUNT(DAYNAME(DATE(CONCAT(DATE_FORMAT(birthday_at, '%d.%m'),'.' ,DATE_FORMAT(NOW(),'%Y'))))),
	DAYNAME(DATE(CONCAT(DATE_FORMAT(birthday_at, '%d.%m'),'.' ,DATE_FORMAT(NOW(),'%Y'))))
	FROM users GROUP BY DAYNAME(DATE(CONCAT(DATE_FORMAT(birthday_at, '%d.%m'), '.', DATE_FORMAT(NOW(), '%Y'))));


-- 3. (по желанию) Подсчитайте произведение чисел в столбце таблицы.
-- Сумма логарифмов чисел равна логарифму произведения чисел. Не работает на отрицательных значениях
SELECT exp(sum(log(id))) FROM users;

