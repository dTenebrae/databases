-- Создаем триггеры, которые не позволяют вставлять значения зависимостей, при которых пакет ссылается на себя
DELIMITER //

DROP TRIGGER IF EXISTS depend_on_yourself_main //
CREATE TRIGGER depend_on_yourself_main BEFORE INSERT ON main_dependencies
    FOR EACH ROW
BEGIN
	IF new.package_id = new.depend_id THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled';
	END IF;
END//

DROP TRIGGER IF EXISTS depend_on_yourself_aur //
CREATE TRIGGER depend_on_yourself_aur BEFORE INSERT ON aur_dependencies
    FOR EACH ROW
BEGIN
	IF new.package_aur_id = new.depend_aur_id THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled';
	END IF;
END//

DELIMITER ;
