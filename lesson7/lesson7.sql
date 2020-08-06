-- 1. Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
SELECT
	u.name
FROM
	orders as o
JOIN
	users AS u
ON
	o.user_id = u.id
GROUP BY
	u.name;

-- 2. Выведите список товаров products и разделов catalogs, который соответствует товару.
SELECT
	p.name,
	c.name
FROM
	products p
JOIN
	catalogs c
ON
	p.catalog_id = c.id;


-- 3. (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name).
-- Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.

CREATE TABLE flights (
	id SERIAL PRIMARY KEY,
	from_city VARCHAR(255),
	to_city VARCHAR(255)
);

CREATE TABLE cities(
	label VARCHAR(255) PRIMARY KEY NOT NULL,
	name VARCHAR(255)
);

INSERT INTO flights VALUES
	(NULL, 'moscow', 'omsk'),
	(NULL, 'novgorod', 'kazan'),
	(NULL, 'irkutsk', 'moscow'),
	(NULL, 'omsk', 'irkutsk'),
	(NULL, 'moscow', 'kazan');

INSERT INTO cities VALUES
	('moscow', 'Москва'),
	('irkutsk', 'Иркутск'),
	('novgorod', 'Новгород'),
	('kazan', 'Казань'),
	('omsk', 'Омск');

-- Через вложенные запросы
SELECT
	(SELECT name FROM cities WHERE flights.from_city = cities.label) AS 'Откуда',
	(SELECT name FROM cities WHERE flights.to_city = cities.label) AS 'Куда'
FROM
	flights;

-- Через JOIN
SELECT
	c.name AS 'Откуда',
	c2.name AS 'Куда'
FROM
	flights AS f
JOIN
	cities AS c
JOIN
	cities AS c2
ON
	c.label = f.from_city
AND
	c2.label = f.to_city;
