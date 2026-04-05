-- Задание 2, Задача 1
WITH stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM sfdb.Cars AS c
    JOIN sfdb.Results AS r
        ON r.car = c.name
    GROUP BY c.name, c.class
),
ranked AS (
    SELECT
        car_name,
        car_class,
        average_position,
        race_count,
        RANK() OVER (
            PARTITION BY car_class
            ORDER BY average_position
        ) AS rn
    FROM stats
)
SELECT
    car_name,
    car_class,
    average_position,
    race_count
FROM ranked
WHERE rn = 1
ORDER BY average_position ASC;

-- Задание 2, Задача 2
SELECT
    c.name AS car_name,
    c.class as car_class,
    AVG(r.position) AS average_position,
    COUNT(r.race) AS race_count,
    cls.country as car_country
FROM sfdb.Cars AS c
JOIN sfdb.Results AS r
    ON r.car = c.name
JOIN sfdb.Classes AS cls
    ON cls.class = c.class
GROUP BY
    c.name,
    c.class,
    cls.country
ORDER BY
    average_position ASC,
    c.name ASC
LIMIT 1;

-- Задание 2, Задача 3
WITH car_stats AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM sfdb.Cars AS c
    JOIN sfdb.Results AS r
        ON r.car = c.name
    GROUP BY c.name, c.class
),
class_stats AS (
    SELECT
        c.class AS car_class,
        AVG(r.position) AS class_average_position,
        COUNT(r.race) AS total_races
    FROM sfdb.Cars AS c
    JOIN sfdb.Results AS r
        ON r.car = c.name
    GROUP BY c.class
),
best_classes AS (
    SELECT
        car_class
    FROM (
        SELECT
            car_class,
            RANK() OVER (ORDER BY class_average_position ASC) AS rn
        FROM class_stats
    ) AS ranked
    WHERE rn = 1
)
SELECT
    cs.car_name,
    cs.car_class,
    cs.average_position,
    cs.race_count,
    cl.country AS car_country,
    cls.total_races
FROM car_stats AS cs
JOIN best_classes AS bc
    ON bc.car_class = cs.car_class
JOIN class_stats AS cls
    ON cls.car_class = cs.car_class
JOIN sfdb.Classes AS cl
    ON cl.class = cs.car_class
ORDER BY
    cs.car_class,
    cs.average_position,
    cs.car_name;

-- Задание 2, Задача 4
WITH car_stats AS (
    SELECT
        c.name AS car,
        c.class,
        AVG(r.position) AS avg_position,
        COUNT(r.race) AS race_count
    FROM sfdb.Cars AS c
    JOIN sfdb.Results AS r
        ON r.car = c.name
    GROUP BY
        c.name,
        c.class
),
class_stats AS (
    SELECT
        c.class,
        AVG(r.position) AS class_avg_position,
        COUNT(DISTINCT c.name) AS car_count
    FROM sfdb.Cars AS c
    JOIN sfdb.Results AS r
        ON r.car = c.name
    GROUP BY
        c.class
)
SELECT
    cs.car as car_name,
    cs.class as car_class,
    cs.avg_position as average_position,
    cs.race_count,
    cl.country as car_country
FROM car_stats AS cs
JOIN class_stats AS cls
    ON cls.class = cs.class
JOIN sfdb.Classes AS cl
    ON cl.class = cs.class
WHERE cls.car_count >= 2
  AND cs.avg_position < cls.class_avg_position
ORDER BY
    cs.class ASC,
    cs.avg_position ASC;

-- Задание 2, Задача 5
WITH car_avg AS (
    SELECT 
		c.name,
        c.class,
        AVG(r.position) AS avg_pos,
        COUNT(r.race) AS race_count
    FROM sfdb.Cars c
             JOIN sfdb.Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
class_stats AS (
	SELECT 
		class,
		COUNT(*) AS total_races,
		COUNT(*) AS low_position_count
	FROM car_avg
	GROUP BY class
	HAVING SUM(CASE WHEN avg_pos > 3.0 THEN 1 ELSE 0 END) > 0
)
SELECT 
	ca.name AS car_name,
    ca.class AS car_class,
	ca.avg_pos AS average_position,
	ca.race_count,
	cl.country AS car_country,
	cs.total_races,
	cs.low_position_count
FROM car_avg ca
	JOIN class_stats cs ON ca.class = cs.class
	JOIN sfdb.Classes cl ON ca.class = cl.class
WHERE ca.avg_pos > 3.0
ORDER BY cs.low_position_count DESC;