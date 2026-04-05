-- Задание 3, Задача 1
SELECT
    c.name,
    c.email,
    c.phone,
    COUNT(b.ID_booking) AS total_bookings,
    GROUP_CONCAT(DISTINCT h.name ORDER BY h.name SEPARATOR ', ') AS hotel_list,
    AVG(DATEDIFF(b.check_out_date, b.check_in_date)) AS avg_stay_days
FROM sfdb.Customer AS c
JOIN sfdb.Booking AS b
    ON b.ID_customer = c.ID_customer
JOIN sfdb.Room AS r
    ON r.ID_room = b.ID_room
JOIN sfdb.Hotel AS h
    ON h.ID_hotel = r.ID_hotel
GROUP BY
    c.ID_customer,
    c.name,
    c.email,
    c.phone
HAVING COUNT(b.ID_booking) > 2
   AND COUNT(DISTINCT h.ID_hotel) > 1
ORDER BY total_bookings DESC;

-- Задание 3, Задача 2
WITH client_stats AS (
    SELECT
        c.ID_customer,
        c.name,
        COUNT(b.ID_booking) AS total_bookings,
        COUNT(DISTINCT h.ID_hotel) AS total_hotels,
        SUM(r.price) AS total_spent
    FROM sfdb.Customer AS c
    JOIN sfdb.Booking AS b
        ON b.ID_customer = c.ID_customer
    JOIN sfdb.Room AS r
        ON r.ID_room = b.ID_room
    JOIN sfdb.Hotel AS h
        ON h.ID_hotel = r.ID_hotel
    GROUP BY
        c.ID_customer,
        c.name
)
SELECT
    ID_customer,
    name,
    total_bookings,
    total_spent,
    total_hotels
FROM client_stats
WHERE total_bookings > 2
  AND total_hotels > 1
  AND total_spent > 500
ORDER BY total_spent ASC;

-- Задание 3, Задача 3
WITH hotel_categories AS (
    SELECT
        h.ID_hotel,
        h.name AS hotel_name,
        CASE
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) <= 300 THEN 'Средний'
            ELSE 'Дорогой'
        END AS hotel_type
    FROM sfdb.Hotel AS h
    JOIN sfdb.Room AS r
        ON r.ID_hotel = h.ID_hotel
    GROUP BY
        h.ID_hotel,
        h.name
),
client_hotel_types AS (
    SELECT
        c.ID_customer,
        c.name,
        MAX(CASE WHEN hc.hotel_type = 'Дорогой' THEN 1 ELSE 0 END) AS has_expensive,
        MAX(CASE WHEN hc.hotel_type = 'Средний' THEN 1 ELSE 0 END) AS has_medium,
        MAX(CASE WHEN hc.hotel_type = 'Дешевый' THEN 1 ELSE 0 END) AS has_cheap,
        GROUP_CONCAT(DISTINCT hc.hotel_name ORDER BY hc.hotel_name SEPARATOR ', ') AS visited_hotels
    FROM sfdb.Customer AS c
    JOIN sfdb.Booking AS b
        ON b.ID_customer = c.ID_customer
    JOIN sfdb.Room AS r
        ON r.ID_room = b.ID_room
    JOIN hotel_categories AS hc
        ON hc.ID_hotel = r.ID_hotel
    GROUP BY
        c.ID_customer,
        c.name
)
SELECT
    ID_customer,
    name,
    CASE
        WHEN has_expensive = 1 THEN 'Дорогой'
        WHEN has_medium = 1 THEN 'Средний'
        ELSE 'Дешевый'
    END AS preferred_hotel_type,
    visited_hotels
FROM client_hotel_types
ORDER BY
    CASE
        WHEN has_cheap = 1 AND has_medium = 0 AND has_expensive = 0 THEN 1
        WHEN has_medium = 1 AND has_expensive = 0 THEN 2
        ELSE 3
    END;
