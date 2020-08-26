-- Функция, возращающая количество пакетов, которые обновил пользователь packager_name
DELIMITER //
DROP FUNCTION IF EXISTS find_packager_number //
CREATE FUNCTION find_packager_number(packager_name VARCHAR(255))
    RETURNS INT
BEGIN
    DECLARE pac_number INT;
    CREATE TEMPORARY TABLE tmp_count
        SELECT wu.username,
                          COUNT(name) number
                   FROM packages
                            JOIN wiki_users wu on wu.id = packages.last_packager_id
                   WHERE wu.username = packager_name
                   GROUP BY wu.username;
    SET pac_number = (SELECT number FROM tmp_count);

    RETURN pac_number;
END //

SELECT find_packager_number('lon49');
