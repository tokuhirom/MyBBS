CREATE TABLE IF NOT EXISTS sessions (
    id           CHAR(72) PRIMARY KEY,
    session_data TEXT
);
CREATE TABLE IF NOT EXISTS entry (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    body VARCHAR(255) NOT NULL,
    ctime INT UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
CREATE TABLE IF NOT EXISTS member (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nickname VARCHAR(24) NOT NULL,
    twitter_access_token VARCHAR(255) DEFAULT NULL,
    twitter_access_token_secret VARCHAR(255) DEFAULT NULL,
    twitter_user_id VARCHAR(255) DEFAULT NULL,
    twitter_screen_name VARCHAR(255) DEFAULT NULL,
    ctime INT UNSIGNED NOT NULL,
    INDEX (twitter_user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
