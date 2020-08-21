-- 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs
-- помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

DROP TABLE IF EXISTS logs;

CREATE TABLE logs (
    table_name VARCHAR(50) NOT NULL COMMENT 'Название таблицы, в которую происходит запись',
    primary_key INT UNSIGNED NOT NULL COMMENT 'Идентификатор первичного ключа',
    name VARCHAR(100) COMMENT 'Содержимое поля name',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=ARCHIVE;

DROP TRIGGER IF EXISTS arch_users;
DROP TRIGGER IF EXISTS arch_catalogs;
DROP TRIGGER IF EXISTS arch_products;
DELIMITER //

CREATE TRIGGER arch_users AFTER INSERT ON users
FOR EACH ROW
BEGIN
	INSERT INTO logs
		(table_name, primary_key, name)
	VALUES
		('users', new.id, new.name);
END//

CREATE TRIGGER arch_catalogs AFTER INSERT ON catalogs
    FOR EACH ROW
BEGIN
    INSERT INTO logs
    (table_name, primary_key, name)
    VALUES
    ('catalogs', new.id, new.name);
END//

CREATE TRIGGER arch_products AFTER INSERT ON products
    FOR EACH ROW
BEGIN
    INSERT INTO logs
    (table_name, primary_key, name)
    VALUES
    ('products', new.id, new.name);
END//

DELIMITER ;


-- 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.

DROP PROCEDURE IF EXISTS million;
DELIMITER //
CREATE PROCEDURE million()
BEGIN
    DECLARE i INT DEFAULT 0;
    WHILE i < 1000000
        DO
            INSERT INTO users (name, birthday_at)
            VALUES (CONCAT('user', ' ', i), (CURRENT_TIMESTAMP - INTERVAL FLOOR(1 + RAND() * 100) YEAR));
            SET i = i + 1;
        END WHILE;
END//
DELIMITER ;

CALL million();

-- 1. В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.

-- Для создания перечня ip адресов можно использовать HMSET, для подсчета - инкремент HINCRBY
HMSET ip 127.0.0.1 0 192.168.0.1 0 192.168.0.2 0
HINCRBY ip 127.0.0.1 1


-- 2. При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот, поиск электронного адреса пользователя по его имени.

-- Задачу можно решить созданием хэш-таблицы пользователей и обратной хэш-таблицы емэйлов
HMSET users usr1 usr1@mail.com usr2 usr2@mail.com usr3 usr3@mail.com
HMSEt emails usr1@mail.com usr1 usr2@mail.com usr2 usr3@mail.com usr3

-- 3. Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.

db.shop.insert({table: 'products'})
db.shop.insert({table: 'catalogs'})

db.shop.update({table: 'products'}, {$set: {id: 1, name: 'Intel Core i3-8100', description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel', price: 7890.0 }})
db.shop.update({table: 'products'}, {$set: {id: 2, name: 'Intel Core i5-7400', description: 'Процессор для настольных персональных компьютеров, основанных на платформе Intel', price: 12700.00 }})
db.shop.update({table: 'products'}, {$set: {id: 3, name: 'AMD FX-8320E', description: 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', price: 4780.00 }})
db.shop.update({table: 'products'}, {$set: {id: 4, name: 'AMD FX-8320', description: 'Процессор для настольных персональных компьютеров, основанных на платформе AMD.', price: 7120.00 }})
db.shop.update({table: 'products'}, {$set: {id: 5, name: 'ASUS ROG MAXIMUS X HERO', description: 'Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX', price: 19310.00 }})
db.shop.update({table: 'products'}, {$set: {id: 6, name: 'Gigabyte H310M S2H', description: 'Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX', price: 4790.00 }})
db.shop.update({table: 'products'}, {$set: {id: 7, name: 'MSI B250M GAMING PRO', description: 'Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX', price: 5060.00 }})

db.shop.update({table: 'catalogs'}, {$set: {id: 1, name: 'Процессоры'}})
db.shop.update({table: 'catalogs'}, {$set: {id: 2, name: 'Материнские платы'}})
db.shop.update({table: 'catalogs'}, {$set: {id: 3, name: 'Видеокарты'}})
db.shop.update({table: 'catalogs'}, {$set: {id: 4, name: 'Жесткие диски'}})
db.shop.update({table: 'catalogs'}, {$set: {id: 5, name: 'Оперативная память'}})

-- p.s. К сожалению, проверить работоспособность кода пока не могу, в репозиториях к моей OS mongoDB из бинарников не ставится, ставлю из исходников. Если верить вики, собираться будет около 7 часов.
