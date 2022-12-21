DROP DATABASE IF EXISTS airbnb;
CREATE DATABASE airbnb;
USE airbnb;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id SERIAL PRIMARY KEY,
	firstname VARCHAR(100),
	lastname VARCHAR(100),
	birthday DATE,
	hometown VARCHAR(100),
	gender CHAR(1),
	email VARCHAR(100) UNIQUE,
	phone BIGINT UNIQUE,
	emergency_contact_name VARCHAR(100),
	emergency_contact_phone BIGINT,
	password_hash VARCHAR(100),
	created_at DATETIME DEFAULT NOW(),
	photo_id BIGINT UNSIGNED NOT NULL
	-- FOREIGN KEY (photo_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS host_profile;
CREATE TABLE host_profile(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	superhost BIT DEFAULT 0 COMMENT 'Дается хосту, если у его апартов высокий рейтинг',
	rental_id BIGINT UNSIGNED COMMENT 'Договор аренды',
	description TEXT,
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
	);

DROP TABLE IF EXISTS organizer_profile;
CREATE TABLE organizer_profile(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	description TEXT COMMENT 'Профиль организатора экскурсий и пр',
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS countries;
CREATE TABLE countries(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100)
);

DROP TABLE IF EXISTS cities;
CREATE TABLE cities(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	country_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (country_id) REFERENCES countries(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

DROP TABLE IF EXISTS districts;
CREATE TABLE districts(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	city_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (city_id) REFERENCES cities(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

DROP TABLE IF EXISTS apartments;
CREATE TABLE apartments(
	id SERIAL PRIMARY KEY,
	photo_id BIGINT UNSIGNED,
	city BIGINT UNSIGNED NOT NULL,
	district BIGINT UNSIGNED NOT NULL,
	address TEXT,
	type_of_apartment ENUM('entire place', 'private room', 'hotel room', 'shared room'),
	rooms BIGINT UNSIGNED NOT NULL,
	description TEXT,
	price BIGINT UNSIGNED NOT NULL,
	host_id BIGINT UNSIGNED NOT NULL,
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW(),
	FOREIGN KEY (city) REFERENCES cities(id) ON UPDATE CASCADE ON DELETE RESTRICT,
	FOREIGN KEY (district) REFERENCES districts(id) ON UPDATE CASCADE ON DELETE RESTRICT
	-- FOREIGN KEY (host_id) REFERENCES host_profile(id) ON UPDATE CASCADE ON DELETE RESTRICT
);

DROP TABLE IF EXISTS reviews;
CREATE TABLE reviews(
	id SERIAL PRIMARY KEY,
	from_user BIGINT UNSIGNED NOT NULL,
	to_aparts BIGINT UNSIGNED NOT NULL,
	review_text TEXT,
	rating TINYINT,
	FOREIGN KEY (from_user) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (to_aparts) REFERENCES apartments(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types(
	id SERIAL PRIMARY KEY,
	media_type VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS media;
CREATE TABLE media(
	id SERIAL PRIMARY KEY,
	mediatype_id BIGINT UNSIGNED NOT NULL,
	user_id BIGINT UNSIGNED NOT NULL,
	body TEXT,
	filename VARCHAR(100),
	created_at DATETIME DEFAULT NOW(),
	updated_at DATETIME DEFAULT NOW(),
	FOREIGN KEY (mediatype_id) REFERENCES media_types(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS wishlist;
CREATE TABLE wishlist(
	id SERIAL PRIMARY KEY,
	user_id BIGINT UNSIGNED NOT NULL,
	apartments_id BIGINT UNSIGNED NOT NULL,
	name VARCHAR(100),
	description TEXT COMMENT 'Пользователь может создавать несколько списков избранных',
	FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (apartments_id) REFERENCES apartments(id) ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS messages;
CREATE TABLE messages(
	id SERIAL PRIMARY KEY,
	from_user_id BIGINT UNSIGNED NOT NULL,
	to_user_id BIGINT UNSIGNED NOT NULL,
	message_text TEXT,
	created_at DATETIME DEFAULT NOW(),
	FOREIGN KEY (from_user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (to_user_id) REFERENCES users(id)ON UPDATE CASCADE ON DELETE CASCADE
);

DROP TABLE IF EXISTS experiences;
CREATE TABLE experiences(
	id SERIAL PRIMARY KEY,
	organizer_id BIGINT UNSIGNED NOT NULL,
	city_id BIGINT UNSIGNED NOT NULL,
	date_of_exp DATE,
	name VARCHAR(100),
	description TEXT,
	exp_type ENUM('art & culture', 'entertainment', 'food & drink', 'sports', 'tours', 'sightseeing', 'wellness', 'nature & outdoors'),
	price BIGINT NOT NULL,
	-- FOREIGN KEY (organizer_id) REFERENCES organizer_profile(id) ON UPDATE CASCADE ON DELETE CASCADE,
	INDEX experience_name_idx(name)
);

DROP TABLE IF EXISTS articles;
CREATE TABLE articles(
	id SERIAL PRIMARY KEY,
	name VARCHAR(100),
	body TEXT,
	photo_id BIGINT UNSIGNED NOT NULL,
	author_id BIGINT UNSIGNED NOT NULL,
	FOREIGN KEY (photo_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE,
	FOREIGN KEY (author_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE,
	INDEX atricle_idx(name)
);

ALTER TABLE host_profile ADD CONSTRAINT fk_rental_id
	FOREIGN KEY (rental_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE users ADD CONSTRAINT fk_photo_id
	FOREIGN KEY (photo_id) REFERENCES media(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE experiences ADD CONSTRAINT fk_organizer_id
	FOREIGN KEY (organizer_id) REFERENCES organizer_profile(id) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE experiences ADD CONSTRAINT fk_city_id
	FOREIGN KEY (city_id) REFERENCES cities(id) ON UPDATE CASCADE ON DELETE CASCADE;





