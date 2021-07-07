-- Дополнение по заданию 4
SELECT
	(SELECT COUNT(*) FROM likes WHERE likes.target_id = profiles.user_id AND target_type_id = 2 ORDER BY target_id) AS likes_count,
	birthday
FROM
	profiles
ORDER BY
	birthday DESC
LIMIT 10;
/*
mysql> SELECT (SELECT COUNT(*) FROM likes WHERE likes.target_id = profiles.user_id AND target_type_id = 2 ORDER BY target_id) AS likes_count, birthday
FROM profiles ORDER BY birthday DESC LIMIT 10;
+-------------+------------+
| likes_count | birthday   |
+-------------+------------+
|           0 | 2020-05-04 |
|           0 | 2020-03-05 |
|           0 | 2020-02-11 |
|           0 | 2019-09-13 |
|           0 | 2019-02-04 |
|           2 | 2019-01-01 |
|           0 | 2017-11-26 |
|           1 | 2017-10-13 |
|           0 | 2016-12-13 |
|           0 | 2016-05-19 |
+-------------+------------+
10 rows in set (0.00 sec)
*/

-- Далее считаем количество
SELECT SUM(likes_count)
	FROM(SELECT
		(SELECT COUNT(*) FROM likes WHERE likes.target_id = profiles.user_id AND target_type_id = 2 ORDER BY target_id) AS likes_count,
		birthday
		FROM
			profiles
		ORDER BY
		birthday DESC
		LIMIT 10) as tabl;
/*mysql> SELECT SUM(likes_count) FROM(SELECT (SELECT COUNT(*) FROM likes WHERE likes.target_id = profiles.user_id AND target_type_id = 2 ORDER BY target_id) AS likes_count, birthday FROM profiles ORDER BY birthday DESC LIMIT 10) as tabl;
+------------------+
| SUM(likes_count) |
+------------------+
|                3 |
+------------------+
1 row in set (0.00 sec)
*/
