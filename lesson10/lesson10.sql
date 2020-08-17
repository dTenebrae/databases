-- 1. Проанализировать какие запросы могут выполняться наиболее часто в процессе работы приложения и добавить необходимые индексы.

-- В таблице Users id - первичный ключ, email и phone - уникальные, следовательно индексы для них не требуются. Из оставшихся полей
-- чаще всего в запросы может попасть поле last_name
CREATE INDEX users_last_name_idx ON users(last_name);

-- По аналогии:
CREATE INDEX profiles_birthday_idx ON profiles(birthday);
CREATE INDEX profiles_city_idx ON profiles(city);

-- Для таблицы messages не вижу смысла содавать дополнительные индексы(первичный и внешние ключи проиндексированы, по телу сообщения
-- поиск происходит реже)

-- Таблицу friendship пропускаем, в ней в основном ключи.
-- frienship_statuses, communities, communities_users, media_types тоже: ключи и уникальное значение имени

-- В медиа считаю возможным создание индекса только на размер. Метадата - json тип, сортировка по нему малоэффективна
CREATE INDEX media_size_idx ON media(size);

-- В постах запросы ожидаю по количеству просмотров и заголовкам
CREATE INDEX posts_head_idx ON posts(head);
CREATE INDEX posts_views_counter_idx ON posts(views_counter);


-- 2. Построить запрос, который будет выводить следующие столбцы:
-- имя группы
-- среднее количество пользователей в группах
-- самый молодой пользователь в группе
-- самый старший пользователь в группе
-- общее количество пользователей в группе
-- всего пользователей в системе
-- отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100

-- Использовал то же окно, что и на уроке, так как окна типа города, страны, года рождения слишком маленькие (1-3), а пол - слишком большое


SELECT
        LEFT(birthday, 3) AS NAME, AVG(NUMBER_IN_GROUPS) OVER() AS AVERAGE, YOUNGEST, OLDEST, NUMBER_IN_GROUPS, TOTAL, t.`%`
FROM
(SELECT birthday,
       ROW_NUMBER() OVER w AS ROW,
       TIMESTAMPDIFF(YEAR, LAST_VALUE(birthday) OVER (PARTITION BY LEFT(birthday, 3)), NOW()) AS YOUNGEST,
       TIMESTAMPDIFF(YEAR, FIRST_VALUE(birthday) OVER (PARTITION BY LEFT(birthday, 3)), NOW()) AS OLDEST,
       COUNT(*) OVER (PARTITION BY LEFT(birthday, 3)) AS NUMBER_IN_GROUPS,
       COUNT(*) OVER() AS TOTAL,
       COUNT(*) OVER (PARTITION BY LEFT(birthday, 3)) / COUNT(*) OVER() * 100 AS '%'
FROM profiles
    WINDOW w AS (PARTITION BY LEFT(birthday, 3) ORDER BY birthday)) AS t
ORDER BY t.birthday;

-- 3. (по желанию) Задание на денормализацию
-- Разобраться как построен и работает следующий запрос:
-- Найти 10 пользователей, которые проявляют наименьшую активность
-- в использовании социальной сети.

-- SELECT users.id,
--      COUNT(DISTINCT messages.id) +
--      COUNT(DISTINCT likes.id) +
--      COUNT(DISTINCT media.id) AS activity
-- FROM users
-- LEFT JOIN messages
--      ON users.id = messages.from_user_id
-- LEFT JOIN likes
--      ON users.id = likes.user_id
-- LEFT JOIN media
--      ON users.id = media.user_id
-- GROUP BY users.id
-- ORDER BY activity
-- LIMIT 10;

-- Правильно-ли он построен?
-- Какие изменения, включая денормализацию, можно внести в структуру БД
-- чтобы существенно повысить скорость работы этого запроса?

-- Предложения по оптимизации:
-- 1. Включить таблицы likes и target_types в таблицу users. Лайки ставят в любом случае только пользователи. Для этого потребуется перенести таблицу
-- likes в json формат, а справочную таблицу target_types в ENUM.
-- 2. В случае регулярной оценки активности пользователей имеет смысл внести счетчики в профили, тогда задача сведется до тривиального суммирования
