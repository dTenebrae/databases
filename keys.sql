ALTER TABLE news
    ADD CONSTRAINT news_author_id_fk
        FOREIGN KEY (author_id) REFERENCES wiki_users(id);

ALTER TABLE bugs
    ADD CONSTRAINT bugs_author_id_fk
        FOREIGN KEY (author_id) REFERENCES wiki_users(id);

ALTER TABLE security
    ADD CONSTRAINT security_package_id_fk
        FOREIGN KEY (package_id) REFERENCES packages(id),
    ADD CONSTRAINT security_author_id_fk
        FOREIGN KEY (author_id) REFERENCES wiki_users(id);

ALTER TABLE packages
    ADD CONSTRAINT packages_last_packager_id_fk
        FOREIGN KEY (last_packager_id) REFERENCES wiki_users(id),
    ADD CONSTRAINT packages_signed_by_id_fk
        FOREIGN KEY (signed_by_id) REFERENCES wiki_users(id);

ALTER TABLE aur
    ADD CONSTRAINT aur_submitter_id_fk
        FOREIGN KEY (submitter_id) REFERENCES wiki_users(id),
    ADD CONSTRAINT aur_last_packager_id_fk
        FOREIGN KEY (last_packager_id) REFERENCES wiki_users(id);

ALTER TABLE assignment_bugs
    ADD CONSTRAINT assignment_bugs_user_id_fk
        FOREIGN KEY (user_id) REFERENCES wiki_users(id),
    ADD CONSTRAINT assignment_bugs_bug_id_fk
        FOREIGN KEY (bug_id) REFERENCES bugs(id);

ALTER TABLE assignment_packages
    ADD CONSTRAINT assignment_packages_user_id_fk
        FOREIGN KEY (user_id) REFERENCES wiki_users(id),
    ADD CONSTRAINT assignment_packages_package_id_fk
        FOREIGN KEY (package_id) REFERENCES packages(id);

ALTER TABLE main_dependencies
    ADD CONSTRAINT main_dependencies_package_id_fk
        FOREIGN KEY (package_id) REFERENCES packages(id),
    ADD CONSTRAINT main_dependencies_depend_id_fk
        FOREIGN KEY (depend_id) REFERENCES packages(id);

ALTER TABLE aur_dependencies
    ADD CONSTRAINT aur_dependencies_package_aur_id_fk
        FOREIGN KEY (package_aur_id) REFERENCES aur(id),
    ADD CONSTRAINT aur_dependencies_depend_aur_id_fk
        FOREIGN KEY (depend_aur_id) REFERENCES aur(id);

ALTER TABLE images
    ADD CONSTRAINT images_author_id_fk
        FOREIGN KEY (author_id) REFERENCES wiki_users(id),
    ADD CONSTRAINT images_mirror_id_fk
        FOREIGN KEY (mirror_id) REFERENCES mirrors(id);

ALTER TABLE wiki_users
    ADD CONSTRAINT wiki_users_group_id_fk
        FOREIGN KEY (group_id) REFERENCES wiki_groups(id);

ALTER TABLE wiki_contents
    ADD CONSTRAINT wiki_contents_author_id_fk
        FOREIGN KEY (author_id) REFERENCES wiki_users(id),
    ADD CONSTRAINT wiki_contents_body_id_fk
        FOREIGN KEY (body_id) REFERENCES wiki_bodys(id);

ALTER TABLE wiki_bodys
    ADD CONSTRAINT wiki_bodys_author_id
        FOREIGN KEY (author_id) REFERENCES wiki_users(id);

ALTER TABLE forum_users
    ADD CONSTRAINT forum_users_group_id_fk
        FOREIGN KEY (group_id) REFERENCES forum_groups(id);

ALTER TABLE forum_posts
    ADD CONSTRAINT forum_posts_author_id_fk
        FOREIGN KEY (author_id) REFERENCES forum_users(id),
    ADD CONSTRAINT forum_posts_theme_id_fk
        FOREIGN KEY (theme_id) REFERENCES forum_themes(id);

ALTER TABLE forum_themes
    ADD CONSTRAINT forum_themes_author_id_fk
        FOREIGN KEY (author_id) REFERENCES forum_users(id);

ALTER TABLE forum_comments
    ADD CONSTRAINT forum_comments_post_id_fk
        FOREIGN KEY (post_id) REFERENCES forum_posts(id),
    ADD CONSTRAINT forum_comments_author_id_fk
        FOREIGN KEY (author_id) REFERENCES forum_users(id);
