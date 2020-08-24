DROP DATABASE IF EXISTS archlinux;
CREATE DATABASE archlinux;
USE archlinux;
SHOW tables;

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
    author_id INT UNSIGNED NOT NULL COMMENT 'id автора',
    status ENUM ('unassigned', 'assigned', 'unconfirmed', 'waiting on response') COMMENT 'статус репорта',
    architecture VARCHAR(50) NOT NULL COMMENT 'Архитектура, на которой найден баг',
    priority ENUM ('high','normal', 'medium', 'low', 'very low') COMMENT 'приоритет задачи',
    assigned_to_id INT UNSIGNED NOT NULL COMMENT 'К кому прикреплен. Может быть несколько мейнтейнеров',
    percent TINYINT COMMENT 'Процент выполнения',
    votes INT UNSIGNED COMMENT 'Апвоуты',
    private BOOLEAN COMMENT 'приватность',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания',
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Время редактирования'
);

CREATE TABLE security (
    id SERIAL PRIMARY KEY,
    package INT UNSIGNED NOT NULL COMMENT 'id пакета',
    author_id INT UNSIGNED NOT NULL COMMENT 'id автора',
    status ENUM ('vulnerable', 'not affected', 'fixed') NOT NULL COMMENT 'Статус уязвимости',
    severity ENUM ('critical', 'high', 'medium', 'low', 'very low') NOT NULL COMMENT 'серьезность уязвимости',
    remote BOOLEAN NOT NULL COMMENT 'Уязвимость удаленная?',
    type VARCHAR(100) NOT NULL COMMENT 'Тип уязвимости',
    affected VARCHAR(20) NOT NULL COMMENT 'Версии подверженные уязвимости',
    fixed VARCHAR(20) COMMENT 'Если пофикшено, то в какой версии',
    current VARCHAR(20) NOT NULL COMMENT 'Текущая версия пакета',
    ticket VARCHAR(20) COMMENT 'номер тикета',
    description TEXT NOT NULL COMMENT 'Описание уязвимости',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Время создания'
);

-- Таблица многие ко многим для создания отношения баги - мэйнтейнеры
CREATE TABLE assignment (
    user_id INT UNSIGNED NOT NULL COMMENT 'Пользователь',
    bug_id INT UNSIGNED NOT NULL COMMENT 'Баг',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, bug_id)
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
    license VARCHAR(50) NOT ULL COMMENT 'Под лицензией GPL etc.',
    upstream_url VARCHAR(255) NOT NULL COMMENT 'Ссылка на файл',
    package_size INT NOT NULL COMMENT 'Размер пакета',
    install_size INT NOT NULL COMMENT 'Размер пакета после установки',
    last_packager INT UNSIGNED COMMENT 'Создатель последней упаковки',
    signed_by INT UNSIGNED COMMENT 'Подписано кем',
    package_contents TEXT COMMENT 'Содержимое пакета',
    build_date DATETIME COMMENT 'Когда создан билд',
    signature_date DATETIME COMMENT 'Когда подписан',
    last_update DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
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
    sources VARCHAR(255) COMMENT 'URL исходников',
    first_submitted DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'дата создания',
    last_updated DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Таблица многие ко многим для определения зависимостей пакетов
CREATE TABLE main_dependencies (
    package_id INT UNSIGNED NOT NULL COMMENT 'id пакета',
    depend_id INT UNSIGNED NOT NULL COMMENT 'id пакета, от которого зависит',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (package_id, depend_id)
);

CREATE TABLE aur_dependencies (
    package_aur_id INT UNSIGNED NOT NULL COMMENT 'id пакета',
    depend_aur_id INT UNSIGNED NOT NULL COMMENT 'id пакета, от которого зависит',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (package_aur_id, depend_aur_id)
);

CREATE TABLE images (
    id SERIAL PRIMARY KEY,
    author_id INT UNSIGNED NOT NULL COMMENT 'кто выложил',
    current_release VARCHAR(25) NOT NULL COMMENT 'Версия релиза',
    included_kernel VARCHAR(25) NOT NULL COMMENT 'Версия ядра linux',
    iso_size INT UNSIGNED NOT NULL COMMENT 'Размер образа',
    checksums VARCHAR(25) NOT NULL COMMENT 'Чексумма образа',
    mirrors INT UNSIGNED COMMENT 'Внешний ключ для таблицы зеркал',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE mirrors (
    id SERIAL PRIMARY KEY,
    mirror_url VARCHAR(50) NOT NULL COMMENT 'url зеркала',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


CREATE TABLE wiki_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL COMMENT 'Никнейм пользователя',
    password VARCHAR(100) NOT NULL COMMENT 'пароль',
    email VARCHAR(100) NOT NULL COMMENT 'эл. почта',
    group_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на таблицу групп пользователей',
    number_of_edits INT UNSIGNED COMMENT 'Количество правок вики документов',
    real_name VARCHAR(255) COMMENT 'Реальное имя пользователя',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wiki_groups (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT 'Имя группы',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE wiki_groups_users (
    group_id INT UNSIGNED NOT NULL COMMENT 'id группы',
    user_id INT UNSIGNED NOT NULL COMMENT 'id пользователя',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (group_id, user_id) COMMENT 'Составной первичный ключ'
);

CREATE TABLE wiki_contents (
    id SERIAL PRIMARY KEY,
    category ENUM ('Arch linux', 'FAQ', 'Installation guide', 'General recommendations', 'List of applications') COMMENT 'Категория статьи',
    title VARCHAR(100) NOT NULL COMMENT 'Заголовок статьи',
    body_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на таблицу со статьями',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wiki_bodys (
    id SERIAL PRIMARY KEY,
    subtitle VARCHAR(100) NOT NULL COMMENT 'Подзаголовок',
    body TEXT NOT NULL COMMENT 'Сама статья',
    author_id INT UNSIGNED NOT NULL COMMENT 'id автора',
    editors JSON COMMENT 'Список редакторов',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_update DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE  CURRENT_TIMESTAMP
);

CREATE TABLE forum_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL COMMENT 'Имя пользователя',
    password VARCHAR(100) NOT NULL COMMENT 'Пароль',
    email VARCHAR(100) NOT NULL COMMENT 'эл. почта',
    timezone ENUM ('AKDT', 'PDT', 'MDT', 'CDT', 'EDT', 'ADT', 'WGST') COMMENT 'Часовой пояс',
    daylight_saving BOOLEAN COMMENT 'Переход на зимнее/летнее время',
    language VARCHAR(100) COMMENT 'Язык пользователя',
    post_counter INT UNSIGNED COMMENT 'Счетчик постов',
    forum_group_id INT UNSIGNED NOT NULL COMMENT 'Ссылка на группу',
    from_where VARCHAR(100) COMMENT 'Откуда пользователь',
    avatar VARCHAR(100) COMMENT 'ссылка на аватар',
    online_flag BOOLEAN COMMENT 'Онлайн ли в настоящее время',
    real_name VARCHAR(255) COMMENT 'Реальное имя пользователя',
    website VARCHAR(255) COMMENT 'Ссылка на веб-сайт пользователя',
    signature VARCHAR(255) COMMENT 'Подпись под постом',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_visit DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE forum_posts (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL COMMENT 'Заголовок поста',
    body TEXT NOT NULL COMMENT 'Сам пост',
    author_id INT UNSIGNED NOT NULL COMMENT 'Автор поста',
    theme_id INT UNSIGNED NOT NULL COMMENT 'В каком разделе форума',
    edit_level TINYINT NOT NULL COMMENT 'Кто может редактировать, ссылка на id группы пользователей',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE forum_themes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT 'Название раздела',
    parent_id INT UNSIGNED COMMENT 'Если тема дочерняя, то кто родитель',
    author_id INT UNSIGNED NOT NULL COMMENT 'Кто создал',
    edit_level TINYINT NOT NULL COMMENT 'Кто может редактировать, ссылка на id группы пользователей',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE forum_comments (
    id SERIAL PRIMARY KEY,
    post_id INT UNSIGNED NOT NULL COMMENT 'К какому посту коммент',
    author_id INT UNSIGNED NOT NULL COMMENT 'Автор коммента',
    body TEXT NOT NULL COMMENT 'Сам коммент',
    edit_level TINYINT NOT NULL COMMENT 'Кто может редактировать, ссылка на id группы пользователей',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    edited_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE forum_groups (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL COMMENT 'Имя группы',
    level TINYINT UNSIGNED NOT NULL COMMENT 'Уровень допуска. 1 - самый высокий',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE forum_groups_users (
    group_id INT UNSIGNED NOT NULL COMMENT 'id группы',
    user_id INT UNSIGNED NOT NULL COMMENT 'id пользователя',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (group_id, user_id) COMMENT 'Составной первичный ключ'
);
