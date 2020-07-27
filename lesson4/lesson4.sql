-- Выбираем БД
USE vk;

-- Вносим предложенные студентами правки
DESC  friendship;
ALTER TABLE friendship DROP COLUMN created_at;

DESC messages;
ALTER TABLE messages ADD COLUMN is_modified BOOLEAN AFTER is_delivered;

DESC profiles;
ALTER TABLE profiles DROP COLUMN created_at;

DESC media_types;
ALTER TABLE media_types DROP COLUMN updated_at;

SHOW tables;

DESC users;
SELECT * FROM users LIMIT 10;
-- Обновляем время апдейта на текущее в тех строках, где оно меньше времени создания
UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE created_at > updated_at;

DESC profiles;
SELECT * FROM profiles LIMIT 10;
-- делаем photo_id рандомным в диапазоне 1-100
UPDATE profiles SET photo_id = FLOOR(1 + RAND() * 100);
-- создаем временную таблицу полов
CREATE TEMPORARY TABLE genders (name CHAR(1));
INSERT INTO genders VALUES ('m'), ('f');
-- рандомно присваиваем значения из этой таблицы полю gender
UPDATE profiles SET gender = (SELECT name FROM genders ORDER BY RAND() LIMIT 1);

DESC messages;
SELECT * FROM messages LIMIT 10;
-- заполняем новый столбец булевыми значениями
UPDATE messages SET is_modified = FLOOR(RAND() + 0.5);

DESC media_types;
SELECT * FROM media_types;
-- очищаем таблицу с удалением значения инкремента
TRUNCATE media_types;
-- Добавляем новые значения
INSERT INTO media_types (name) VALUES
	('photo'),
	('video'),
	('audio'),
	('other')
;

DESC media;
SELECT * FROM media LIMIT 10;
-- Меняем на новые рандомные значения в диапазоне 1-4, так как мы поменяли таблицу типов
UPDATE media SET media_type_id = FLOOR(1 + RAND() * 4);
-- Создаем временную таблицу расширений
CREATE TEMPORARY TABLE extensions (name VARCHAR(10));
INSERT INTO extensions VALUES
	('jpeg'),
	('png'),
	('avi'),
	('mp3'),
	('mkv')
;
SELECT * FROM extensions;
-- Пишем в имя файла новые значения, состоящие из URL, имени файла, точки и расширения, взятого из временной таблицы
UPDATE media SET filename = CONCAT(
	'https://vk.gov/media/',
	filename,
	'.',
	(SELECT name FROM extensions ORDER BY RAND() LIMIT 1)
);
-- Пишем новые значения в размер файла, если размер меньше 1000
UPDATE media SET `size` = FLOOR(10000 + RAND() * 100000) WHERE size < 1000;
-- В метаданные пишем JSON подобную информацию
UPDATE media SET metadata = CONCAT(
	'{"owner":"',
	(SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE id = user_id),
	'"}');
-- Обновляем тип этого поля на JSON
ALTER TABLE media MODIFY COLUMN metadata JSON;

DESC friendship_statuses;
SELECT * FROM friendship_statuses;
-- Очищаем таблицу статусов и пишем данные, приближенные к боевым
TRUNCATE friendship_statuses;
INSERT INTO friendship_statuses (name) VALUES
	('requested'),
	('confirmed'),
	('rejected')
;


DESC friendship;
SELECT * FROM friendship LIMIT 10;
-- Обновляем значения статусов, так как мы поменяли таблицу с ними
UPDATE friendship SET status_id = FLOOR(1 + RAND() * 3);
-- Правим значения user_id
UPDATE friendship SET user_id = FLOOR(1 + RAND() * 100);
-- Меняем значение friend_id если дружит сам с собой
UPDATE friendship SET friend_id = friend_id + 1 WHERE friend_id = user_id;
UPDATE friendship SET confirmed_at = CURRENT_TIMESTAMP WHERE requested_at > confirmed_at;

DESC communities;
SELECT * FROM communities;
DELETE FROM communities WHERE id > 20;
UPDATE communities SET updated_at = CURRENT_TIMESTAMP WHERE created_at > updated_at;

DESC communities_users;
SELECT * FROM communities_users;
UPDATE communities_users SET community_id = FLOOR(1 + RAND() * 20);

-- Таблицы постов и лайков

USE vk;

SHOW tables;

DROP TABLE IF EXISTS posts;

-- Можно было добавить счетчики лайков, репостов и комментариев, но проще их вытащить из соответствующих таблиц
CREATE TABLE posts(
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	author_id INT UNSIGNED NOT NULL COMMENT 'id автора поста',
	body TEXT NOT NULL COMMENT 'Текст поста, включая гипертекстовые ссылки на медиа-данные',
	view_count INT UNSIGNED COMMENT 'Количество просмотров',
	is_pinned BOOLEAN COMMENT 'Флаг закрепленного поста',
	is_modified BOOLEAN COMMENT 'Флаг модифицированного поста',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица должна обслуживать неограниченное количество других таблиц, то есть бы должны ставить лайк постам, медиа, статусам и т.п.
-- В случае с лайками к одному виду данных - таблица сводится до user_id, liked_id, created_at
CREATE TABLE likes (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
	id_liked INT UNSIGNED NOT NULL COMMENT 'id медиа или поста, которому поставили лайк',
	user_id INT UNSIGNED NOT NULL COMMENT 'id пользователя, поставившего лайк',
	liked_type VARCHAR (20) NOT NULL COMMENT 'Самая проблемная часть таблицы - должна быть некая ссылка на таблицу,
	из которой мы по liked_id берем информацию.',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

