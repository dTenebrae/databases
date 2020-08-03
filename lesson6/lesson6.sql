USE vk;


-- 1. Создать все необходимые внешние ключи и диаграмму отношений.
-- 2. Создать и заполнить таблицы лайков и постов.
-- Таблица лайков
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов лайков
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES
  ('messages'),
  ('users'),
  ('media'),
  ('posts');

-- Заполняем лайки
INSERT INTO likes
  SELECT
    id,
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP
  FROM messages;

-- Создадим таблицу постов
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  head VARCHAR(255),
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  is_public BOOLEAN DEFAULT TRUE,
  is_archived BOOLEAN DEFAULT FALSE,
  views_counter INT UNSIGNED DEFAULT 0,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


-- Добавляем внешние ключи
ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT profiles_photo_id_fk
    FOREIGN KEY (photo_id) REFERENCES media(id)
      ON DELETE SET NULL;

ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk
    FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk
    FOREIGN KEY (to_user_id) REFERENCES users(id);


ALTER TABLE communities_users
	ADD CONSTRAINT communities_users_community_id_fk
		FOREIGN KEY (community_id) REFERENCES communities(id),
	ADD CONSTRAINT communities_users_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id);

ALTER TABLE media
	ADD CONSTRAINT media_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id),
	ADD CONSTRAINT media_media_type_id_fk
		FOREIGN KEY (media_type_id) REFERENCES media_types(id);

ALTER TABLE friendship
	ADD CONSTRAINT friendship_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id),
	ADD CONSTRAINT friendship_friend_id_fk
		FOREIGN KEY (friend_id) REFERENCES users(id),
	ADD CONSTRAINT friendship_status_id_fk
		FOREIGN KEY (status_id) REFERENCES friendship_statuses(id);


ALTER TABLE posts
	ADD CONSTRAINT posts_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id),
	ADD CONSTRAINT posts_community_id_fk
		FOREIGN KEY (community_id) REFERENCES communities(id),
	ADD CONSTRAINT posts_media_id_fk
		FOREIGN KEY (media_id) REFERENCES media(id);

-- target_id пока не создаем
ALTER TABLE likes
	ADD CONSTRAINT likes_user_id_fk
		FOREIGN KEY (user_id) REFERENCES users(id),
	ADD CONSTRAINT likes_target_type_id_fk
		FOREIGN KEY (target_type_id) REFERENCES target_types(id);



-- 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?
-- Находим пол пользователя, по соответствию user_id в таблице профилей и таблице лайков,
-- группируем по этой выборке и считаем количесво. Сортируем по убыванию, берем первую строку
SELECT
	(SELECT gender FROM profiles WHERE profiles.user_id = likes.user_id) AS genders,
	COUNT(*) AS total
	FROM
		likes
	GROUP BY
		genders
	ORDER BY
		total DESC
	LIMIT 1;

-- 4. Подсчитать количество лайков которые получили 10 самых молодых пользователей.
-- Решил через временную таблицу, полагаю, что неэффективное решение
-- Создаем временную таблицу, состоящую из возраста пользователей и их id. Выбираем тех, кто получил лайки 2го типа (таргет - пользователь),
-- группируем по id, сортируем по возрасту, берем 10 человек.
CREATE TEMPORARY TABLE youth_table
SELECT
	TIMESTAMPDIFF(YEAR, (SELECT birthday FROM profiles WHERE profiles.user_id = likes.target_id), NOW()) AS age,
	target_id
FROM
	likes
WHERE
	target_type_id = 2
GROUP BY
	target_id
ORDER BY
	age
LIMIT 10;

-- Считаем количество лайков 2го типа в таблице если id входит во временную таблицу
SELECT
	COUNT(*)
FROM
	likes
WHERE
	likes.target_id IN
		(SELECT target_id FROM youth_table) AND
	target_type_id = 2;

-- 5. Найти 10 пользователей, которые проявляют наименьшую активность в
-- использовании социальной сети
-- (критерии активности необходимо определить самостоятельно)

-- Находим пользователей, которых нет ни в лайках, ни в постах, ни в сообщениях. Критерии можно расширять (тут нашлось 2)
SELECT * FROM users
	WHERE id NOT IN (SELECT user_id FROM likes) AND
		  id NOT IN (SELECT from_user_id FROM messages) AND
		  id NOT IN (SELECT user_id FROM posts);
/*
+----+------------+-----------+--------------------------+----------------+---------------------+---------------------+
| id | first_name | last_name | email                    | phone          | created_at          | updated_at          |
+----+------------+-----------+--------------------------+----------------+---------------------+---------------------+
| 55 | Bianka     | Kshlerin  | florencio41@example.org  | 699-632-3057   | 2012-04-14 00:53:53 | 2019-11-29 23:11:46 |
| 59 | Cydney     | Reinger   | kutch.jaylin@example.org | 1-486-900-2887 | 2016-04-28 00:25:17 | 2019-11-08 04:23:12 |
+----+------------+-----------+--------------------------+----------------+---------------------+---------------------+
2 rows in set (0.01 sec)
*/

-- Расширяем круг поисков - создаем 3 временных таблицы с id пользователя и количеством его лайков, постом, сообщений. Далее, выбираем из этих
-- таблиц тех пользователей, количество активностей которых меньше либо равно двум, сортируем по времени последней активности и выбираем 10 самых старых

CREATE TEMPORARY TABLE lk
SELECT
	user_id, COUNT(*) AS total
FROM
	likes
GROUP BY
	user_id
ORDER BY
	total;

CREATE TEMPORARY TABLE mk
SELECT
	from_user_id AS user_id, COUNT(*) AS total
FROM
	messages
GROUP BY
	user_id
ORDER BY
	total;

CREATE TEMPORARY TABLE pk
SELECT
	user_id, COUNT(*) AS total
FROM
	posts
GROUP BY
	user_id
ORDER BY
	total;

SELECT * FROM users
	WHERE id IN (SELECT user_id FROM lk WHERE total <= 2 ) AND
		  id IN (SELECT user_id FROM mk WHERE total <= 2) AND
		  id IN (SELECT user_id FROM pk WHERE total <= 2)
	ORDER BY updated_at
	LIMIT 10;
