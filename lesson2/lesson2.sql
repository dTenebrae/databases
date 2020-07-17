/* Создайте базу данных example, разместите в ней таблицу users, состоящую из двух столбцов, числового id и строкового name.*/

CREATE DATABASE example;
/* Заходим в БД example:
$ mysql example */
CREATE TABLE users (id INT, name TEXT);
DESCRIBE users;
/*
+-------+------+------+-----+---------+-------+
| Field | Type | Null | Key | Default | Extra |
+-------+------+------+-----+---------+-------+
| id    | int  | YES  |     | NULL    |       |
| name  | text | YES  |     | NULL    |       |
+-------+------+------+-----+---------+-------+
2 rows in set (0.00 sec)*/

/*Создайте дамп базы данных example из предыдущего задания, разверните содержимое дампа в новую базу данных sample.*/
/*
Делаем дамп
$ mysqldump example > example.sql
 */
CREATE DATABASE sample;
/*
$ mysql sample < example.sql
*/
/* по желанию) Ознакомьтесь более подробно с документацией утилиты mysqldump. Создайте дамп единственной таблицы help_keyword
базы данных mysql. Причем добейтесь того, чтобы дамп содержал только первые 100 строк таблицы.

$ mysqldump mysql help_keyword --where="true limit 100" > help_keyword.sql */
