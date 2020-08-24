-- Задание на оптимизацию (на самостоятельную проработку, можете показывать в личку):
-- Провести анализ плана выполнения и провести работу по оптимизации для запроса
-- 10 пользователей с наибольшим количеством лайков за медиафайлы
SELECT users.id, first_name, last_name, COUNT(target_types.id) AS total_likes
FROM users
LEFT JOIN media
    ON users.id = media.user_id
LEFT JOIN likes
    ON media.id = likes.target_id
LEFT JOIN target_types
    ON likes.target_type_id = target_types.id
    AND target_types.name = 'media'
GROUP BY users.id
ORDER BY total_likes DESC
LIMIT 10;

-- Обрабатывает по 100 строк в users и likes. При этом в users обращение идет по индексу, кроме того нам в любом случае нужны все строки этой таблицы.
-- Оптимизируем likes, добавляем внешний ключ:

ALTER TABLE likes
	ADD CONSTRAINT likes_media_id_fk
		FOREIGN KEY (target_id) REFERENCES media(id);



