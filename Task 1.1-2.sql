-- Задание 1, Задача 1
SELECT
    v.maker,
    m.model
FROM sfdb.Motorcycle AS m
JOIN sfdb.Vehicle AS v
    ON v.model = m.model
WHERE m.horsepower > 150
  AND m.price < 20000
  AND m.type = 'Sport'
ORDER BY m.horsepower DESC;

-- Задание 1, Задача 2
SELECT
    v.maker,
    c.model,
    c.horsepower,
    c.engine_capacity,
    'Car' AS vehicle_type
FROM sfdb.Car AS c
JOIN sfdb.Vehicle AS v
    ON v.model = c.model
WHERE c.horsepower > 150
  AND c.engine_capacity < 3
  AND c.price < 35000

UNION ALL

SELECT
    v.maker,
    m.model,
    m.horsepower,
    m.engine_capacity,
    'Motorcycle' AS vehicle_type
FROM sfdb.Motorcycle AS m
JOIN sfdb.Vehicle AS v
    ON v.model = m.model
WHERE m.horsepower > 150
  AND m.engine_capacity < 1.5
  AND m.price < 20000

UNION ALL

SELECT
    v.maker,
    b.model,
    NULL AS horsepower,
    NULL AS engine_capacity,
    'Bicycle' AS vehicle_type
FROM sfdb.Bicycle AS b
JOIN sfdb.Vehicle AS v
    ON v.model = b.model
WHERE b.gear_count > 18
  AND b.price < 4000

ORDER BY horsepower DESC;