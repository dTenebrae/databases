DROP DATABASE IF EXISTS archlinux;
CREATE DATABASE archlinux;
USE archlinux;

CREATE TABLE news (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL COMMENT 'Название новости',
    body TEXT NOT NULL COMMENT 'Сама новость',
    author_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на профиль автора',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время редактирования'
);

CREATE TABLE bugs (
    id SERIAL PRIMARY KEY,
    task_type VARCHAR(50) NOT NULL COMMENT 'Тип баг-репорта',
    category VARCHAR(255) NOT NULL COMMENT 'баг чего нашли',
    severity ENUM ('critical', 'high', 'medium', 'low', 'very low') NOT NULL COMMENT 'серьезность бага',
    summary VARCHAR(255) NOT NULL COMMENT 'Заголовок',
    body TEXT NOT NULL COMMENT 'описание бага',
    status ENUM ('unassigned', 'assigned', 'unconfirmed', 'waiting on response') COMMENT 'статус репорта',
    architecture VARCHAR(50) NOT NULL COMMENT 'Архитектура, на которой найден баг',
    priority ENUM ('high','normal', 'medium', 'low', 'very low') COMMENT 'приоритет задачи',
    assigned_to INT UNSIGNED NOT NULL COMMENT 'К кому прикреплен. Может быть несколько мейнтейнеров',
    percent TINYINT COMMENT 'Процент выполнения',
    votes INT UNSIGNED COMMENT 'Апвоуты',
    private BOOLEAN COMMENT 'приватность',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время редактирования'
);

CREATE TABLE packages (
    id SERIAL PRIMARY KEY,
    architecture ENUM ('any', 'x86_64') NOT NULL COMMENT 'Архитектура',
    repository ENUM ('community', 'community-testing', 'core', 'extra', 'KDE-unstable', 'multilib', 'multilib-testing',
        'testing') NOT NULL COMMENT 'тип репозитория',
    name VARCHAR(100) NOT NULL COMMENT 'Название пакета',
    version VARCHAR(50) NOT NULL COMMENT 'версия пакета',
    description TEXT NOT NULL COMMENT 'описание пакета',
    maintainers INT UNSIGNED NOT NULL COMMENT 'Может быть несколько мейнтейнеров',
    license VARCHAR(50) NOT NULL COMMENT 'Под лицензией GPL etc.',
    upstream_url VARCHAR(255) NOT NULL COMMENT 'Ссылка на файл',
    package_size INT NOT NULL COMMENT 'Размер пакета',
    install_size INT NOT NULL COMMENT 'Размер пакета после установки',
    last_packager INT UNSIGNED COMMENT 'Создатель последней упаковки',
    signed_by INT UNSIGNED COMMENT 'Подписано кем',
    dependencies INT UNSIGNED COMMENT 'Ссылки на зависимости. Многие ко многим',
    required_by INT UNSIGNED COMMENT 'Ссылки на обратные зависимости. Также многие ко многим',
    package_contents TEXT COMMENT 'Содержимое пакета',
    build_date DATETIME COMMENT 'Когда создан билд',
    signature_date DATETIME COMMENT 'Когда подписан',
    last_update DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE security (
    id SERIAL PRIMARY KEY,
    package VARCHAR(50) NOT NULL COMMENT 'Имя пакета',
    status ENUM ('vulnerable', 'not affected', 'fixed') NOT NULL COMMENT 'Статус уязвимости',
    severity ENUM ('critical', 'high', 'medium', 'low', 'very low') NOT NULL COMMENT 'серьезность уязвимости',
    remote BOOLEAN NOT NULL COMMENT 'Уязвимость уделенная?',
    type VARCHAR(100) NOT NULL COMMENT 'Тип уязвимости',
    affected VARCAR(20) NOT NULL COMMENT 'Версии подверженные уязвимости',
    fixed VARCHAR(20) COMMENT 'Если пофикшено, то в какой версии',
    current VARCHAR(20) NOT NULL COMMENT 'Текущая версия пакета',
    ticket VARCHAR(20) COMMENT 'номер тикета',
    description TEXT NOT NULL COMMENT 'Описание уязвимости',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания'
);

CREATE TABLE aur (
    id SERIAL PRIMARY KEY,
    git_clone_url VARCHAR(255) NOT NULL COMMENT 'Ссылка на клон-гит',
    package_base VARCHAR(50) NOT NULL COMMENT 'Название пакета',
    description TEXT NOT NULL COMMENT 'описание пакета',
    upstream_url VARCHAR(255) NOT NULL COMMENT 'Ссылка на основной гит',
    keywords JSON NOT NULL COMMENT 'Список ключевых слов',
    license VARCHAR(50) NOT NULL COMMENT 'Под лицензией GPL etc.',
    submitter VARCHAR(50) COMMENT 'Кто выложил',
    maintainer VARCHAR(50) COMMENT 'Кто выложил',
    last_packager VARCHAR(50) COMMENT 'Последний упаковщик',
    votes INT UNSIGNED COMMENT 'Сколько апвоутов',
    popularity TINYINT NOT NULL COMMENT 'Коэффициент популярности',
    dependencies INT UNSIGNED COMMENT 'Ссылки на зависимости. Многие ко многим',
    required_by INT UNSIGNED COMMENT 'Ссылки на обратные зависимости. Также многие ко многим',
    sources VARCHAR(255) COMMENT 'URL исходников',
    first_submitted DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'дата создания',
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE images (
    id SERIAL PRIMARY KEY,
    current_release VARCHAR(25) NOT NULL COMMENT 'Версия релиза',
    included_kernel VARCHAR(25) NOT NULL COMMENT 'Версия ядра linux',
    iso_size INT UNSIGNED NOT NULL COMMENT 'Размер образа',
    checksums VARCHAR(25) NOT NULL COMMENT 'Чексумма образа',
    mirrors INT UNSIGNED COMMENT 'Внешний ключ для таблицы зеркал',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE mirrors (
    id SERIAL NOT NULL PRIMARY KEY,
    mirror_url VARCHAR(50) NOT NULL COMMENT 'url зеркала',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);H
