USE airbnb;

-- 6.скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы);
-- Определить, сколько пользователей в каждом городе
SELECT COUNT(*) AS users_cnt, u.hometown AS city 
FROM users u 
GROUP BY u.hometown
ORDER BY users_cnt DESC;

-- Определить количество дней рождений пользователей в каждом месяце
SELECT COUNT(*) AS b_day_cnt, MONTHNAME(u.birthday) AS b_day_month FROM users u
GROUP BY b_day_month;

-- Определить юзеров, которые и хосты и организаторы активностей
SELECT u.id, u.firstname, u.lastname FROM users u
WHERE u.id IN (SELECT hp.user_id FROM host_profile hp)  AND u.id IN (SELECT op.user_id FROM organizer_profile op);

-- Определить юзеров, которые не хосты и родились летом
SELECT u.id, u.firstname, u.lastname, u.birthday FROM users u
WHERE u.id NOT IN (SELECT hp.user_id FROM host_profile hp)  AND MONTH(u.birthday) BETWEEN 6 AND 8; 

-- Выбрать имя, фамилию и текст сообщений, которые отправили организаторы
SELECT u.firstname, u.lastname, m.message_text, m.from_user_id FROM messages m
JOIN organizer_profile op ON op.user_id = m.from_user_id
LEFT JOIN users u ON m.from_user_id = u.id 
ORDER BY m.from_user_id DESC; 

-- Средняя оценка, которую ставят апартаментам женщины и мужчины
SELECT FLOOR(AVG(r.rating)) AS average_rating FROM reviews r
JOIN users u ON (u.id = r.from_user AND u.gender = 'f')
OR (u.id = r.from_user AND u.gender = 'm')
GROUP BY u.gender;

-- Получить среднюю оценку апартаментов, если оценок нет, вывести соответственное сообщение
DROP FUNCTION IF EXISTS airbnb.check_review;

DELIMITER $$
$$
CREATE FUNCTION airbnb.check_review(check_apartment_id BIGINT)
RETURNS TEXT READS SQL DATA
BEGIN
	DECLARE  average_rating TINYINT; 
	DECLARE count_reviews INT;
  	SET average_rating = 0;
  	SET count_reviews = (
    SELECT COUNT(*) FROM reviews WHERE to_aparts = check_apartment_id  
    );
  
  	IF count_reviews > 0 THEN
  	BEGIN
    SET average_rating = (
    SELECT AVG(rating) FROM reviews WHERE to_aparts = check_apartment_id  
    );
   	END;
   	END IF;
  	
	CASE 
		WHEN average_rating = 1 THEN 
			RETURN 'Жилье может быть опасным!';
		WHEN average_rating > 1 AND average_rating < 3 THEN 
			RETURN 'Удовлетворительное жилье';
		WHEN average_rating >= 3 AND average_rating < 4 THEN 
			RETURN 'Хорошее жилье';
		WHEN average_rating > 4 THEN 
			RETURN 'Отличное жилье!';
		WHEN average_rating = 0 THEN
			RETURN '';
	END CASE;
END;$$
DELIMITER ;

-- Определить среднюю цену на квартиру каждогот типа, в каждом городе

DROP PROCEDURE IF EXISTS airbnb.sp_avg_apart_per_city;

DELIMITER $$
$$
CREATE PROCEDURE airbnb.sp_avg_apart_per_city()
BEGIN
	SELECT AVG(a.price) AS average_price, a.type_of_apartment AS apart_type, (SELECT c.name FROM airbnb.cities c 
	WHERE c.id = a.city) AS city_name
	FROM airbnb.apartments a
	GROUP BY city_name, apart_type
	ORDER BY apart_type, average_price ASC;
END$$
DELIMITER ;

-- Триггер, проверяющий пользователя на совершеннолетие при регистрации
DELIMITER //
CREATE TRIGGER check_user_age_before_insert
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
	IF TIMESTAMPDIFF(YEAR, NEW.birthday, NOW()) < 18 THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Зарегистрироваться могут только совершеннолетнии';
	END IF;
END //
DELIMITER ;

INSERT users(birthday)
VALUES
('2021-01-01');

-- Триггер, проверяющий при добавлении нового города, работает ли ресурс с этой страной (есть ли она в списке)
DELIMITER //
CREATE TRIGGER check_country_before_insert
BEFORE INSERT ON cities
FOR EACH ROW 
BEGIN 
	IF NEW.country_id NOT IN (SELECT c.id FROM countries c) THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Данной страны нет в базе данных';
	END IF;
END //
DELIMITER ;

INSERT cities(country_id)
VALUES 
	(6788);


-- Представление: список всех апартаментов, в которых 2 и 3 комнаты
CREATE OR REPLACE VIEW v_rooms_flat
	AS
		SELECT a.id, a.city, a.address, a.type_of_apartment, a.rooms, a.price FROM apartments a
		WHERE a.rooms BETWEEN 2 AND 3;


-- Представление: получить все договора на квартиры из медиа
CREATE OR REPLACE VIEW v_rental
	AS
		SELECT m.id, m.user_id, m.body, m.filename FROM media m
		WHERE m.mediatype_id = (SELECT mt.id FROM media_types mt WHERE mt.media_type = 'documents');
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
