USE vk;

-- Определить кто больше поставил лайков (всего) - мужчины или женщины?

SELECT p.gender,
       COUNT(*) as total
FROM profiles p
         JOIN likes l
              ON p.user_id = l.user_id
GROUP BY p.gender
ORDER BY total DESC
LIMIT 1;


-- Подсчитать количество лайков которые получили 10 самых молодых пользователей.

-- Соединяем таблицы users и  profiles по внешнему ключу, LEFT JOIN'ом, чтобы посчитать
-- юзеров и с отсутствующими лайками, присоединяем таблицу likes по внешнему ключу и условию,
-- что тип лайка - лайк пользователя.
-- Дальше - самое главное, при GROUP BY подсчет строк применяется в пределах подгруппы,
-- при user.id для каждого уникального пользователя считаются ячейки likes.target_id. Если NULL, то 0.


SELECT CONCAT(users.first_name, ' ', users.last_name) AS Name,
       profiles.birthday                              AS Birthday,
       COUNT(likes.target_id)                         AS 'Have likes'
FROM users
         JOIN profiles
              ON users.id = profiles.user_id
         LEFT JOIN likes
                   ON likes.target_id = users.id
                       AND target_type_id = 2
GROUP BY users.id
ORDER BY birthday DESC
LIMIT 10;


-- Найти 10 пользователей, которые проявляют наименьшую активность в
-- использовании социальной сети
-- (критерии активности необходимо определить самостоятельно)

-- По аналогии с предыдущим заданием, LEFT JOIN'ом соединяем интересующие нас таблицы
-- (лайки, посты, медиа, и сообщения) и считаем сколько у каждого пользователя сумму строк в них.

SELECT users.id,
       CONCAT(first_name, ' ', last_name)                     AS name,
       COUNT(l.id) + COUNT(p.id) + COUNT(m.id) + COUNT(ms.id) AS alive
FROM users
         LEFT JOIN likes l ON l.user_id = users.id
         LEFT JOIN posts p ON p.user_id = users.id
         LEFT JOIN media m ON m.user_id = users.id
         LEFT JOIN messages ms ON ms.from_user_id = users.id
GROUP BY users.id
ORDER BY alive
LIMIT 10;
