-- Создаем представление, находящее авторов и посты с наибольшим количеством комментариев
CREATE VIEW top_comments AS
SELECT forum_posts.id,
       fu.username,
       forum_posts.title,
       COUNT(fc.id) AS number
FROM forum_posts
RIGHT JOIN forum_comments fc
    ON forum_posts.id = fc.post_id
RIGHT JOIN forum_users fu
    ON fu.id = fc.author_id
GROUP BY forum_posts.title
ORDER BY number DESC
LIMIT 10;

-- Авторы с наибольшим количеством новостей
CREATE VIEW top_newsmakers AS
SELECT
    (SELECT username FROM wiki_users WHERE id=author_id),
    COUNT(id) number
FROM news
GROUP BY author_id
ORDER BY number DESC;
