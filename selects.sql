-- Свежие 15 обновлений пакетов
SELECT
    name,
    architecture,
    DATE(last_update) as updated
FROM packages
ORDER BY updated DESC
LIMIT 15;

-- Последние пять новостей для титульной страницы
SELECT
       title,
       (SELECT username FROM wiki_users WHERE news.author_id=wiki_users.id) AS author,
       DATE(updated_at) AS added
FROM news
ORDER BY added DESC
LIMIT 5;

-- Находим пакеты и юзеров, кто их добавил, с тэгами важность уязвимости - критическая и которые еще не пофикшены
SELECT
    p.name AS `package`,
    w.username AS `who added`,
    severity,
    status
FROM security
JOIN packages p
    ON security.package_id = p.id
JOIN wiki_users w
    ON security.author_id = w.id
WHERE severity='critical' AND status!='fixed';


-- Находим топ пять пользователей, обновивших пакеты, с подсчетом количества
SELECT
    wiki_users.id,
    wiki_users.username,
    COUNT(p.last_packager_id) AS number
FROM wiki_users
JOIN packages p on wiki_users.id = p.last_packager_id
GROUP BY wiki_users.id
ORDER BY number DESC
LIMIT 5;

-- В какой теме больше всего постов
SELECT
    forum_themes.id,
    forum_themes.name,
    COUNT(fp.theme_id) number
FROM forum_themes
LEFT JOIN forum_posts fp
    ON forum_themes.id = fp.theme_id
GROUP BY forum_themes.id, forum_themes.name
ORDER BY number DESC;

DESC bugs;

-- Показываем выборку с пользователями, зарепортившими баг. Разбивка по критичности бага, проценту
-- выполнения (не включаем 100%), и проценту от общего количества. Группировка по приоритетности.
SELECT wu.username,priority, percent,
       ROW_NUMBER() OVER (PARTITION BY priority) AS `ROW`,
       COUNT(*) OVER (PARTITION BY priority) / COUNT(*) OVER () * 100 AS `%`
FROM bugs
JOIN wiki_users wu
    ON wu.id = bugs.author_id
WHERE percent != 100
ORDER BY priority;
