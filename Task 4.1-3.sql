-- Задание 4, Задача 1
WITH RECURSIVE subordinates AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM sfdb.Employees AS e
    WHERE e.EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM sfdb.Employees AS e
    JOIN subordinates AS s
        ON e.ManagerID = s.EmployeeID
)
SELECT
    s.EmployeeID,
    s.Name,
    s.ManagerID,
    d.DepartmentName,
    r.RoleName,
    GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS ProjectNames,
    GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName SEPARATOR ', ') AS TaskNames
FROM subordinates AS s
JOIN sfdb.Departments AS d
    ON d.DepartmentID = s.DepartmentID
JOIN sfdb.Roles AS r
    ON r.RoleID = s.RoleID
LEFT JOIN sfdb.Projects AS p
    ON p.DepartmentID = s.DepartmentID
LEFT JOIN sfdb.Tasks AS t
    ON t.AssignedTo = s.EmployeeID
GROUP BY
    s.EmployeeID,
    s.Name,
    s.ManagerID,
    d.DepartmentName,
    r.RoleName
ORDER BY s.Name;

-- Задание 4, Задача 2
WITH RECURSIVE subordinates AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM sfdb.Employees AS e
    WHERE e.EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM sfdb.Employees AS e
    JOIN subordinates AS s
        ON e.ManagerID = s.EmployeeID
)
SELECT
    s.EmployeeID,
    s.Name,
    s.ManagerID,
    d.DepartmentName,
    r.RoleName,
    GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS ProjectNames,
    GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName SEPARATOR ', ') AS TaskNames,
    COUNT(DISTINCT t.TaskID) AS TotalTasks,
    COUNT(DISTINCT e2.EmployeeID) AS DirectSubordinates
FROM subordinates AS s
JOIN sfdb.Departments AS d
    ON d.DepartmentID = s.DepartmentID
JOIN sfdb.Roles AS r
    ON r.RoleID = s.RoleID
LEFT JOIN sfdb.Projects AS p
    ON p.DepartmentID = s.DepartmentID
LEFT JOIN sfdb.Tasks AS t
    ON t.AssignedTo = s.EmployeeID
LEFT JOIN sfdb.Employees AS e2
    ON e2.ManagerID = s.EmployeeID
GROUP BY
    s.EmployeeID,
    s.Name,
    s.ManagerID,
    d.DepartmentName,
    r.RoleName
ORDER BY s.Name;

-- Задание 4, Задача 3
WITH RECURSIVE manager_tree AS (
    SELECT
        e.EmployeeID AS manager_id,
        e.EmployeeID AS subordinate_id
    FROM sfdb.Employees AS e
    JOIN sfdb.Roles AS r
        ON r.RoleID = e.RoleID
    WHERE r.RoleName = 'Менеджер'

    UNION ALL

    SELECT
        mt.manager_id,
        e.EmployeeID AS subordinate_id
    FROM manager_tree AS mt
    JOIN sfdb.Employees AS e
        ON e.ManagerID = mt.subordinate_id
),
descendant_counts AS (
    SELECT
        manager_id,
        COUNT(*) - 1 AS total_subordinates
    FROM manager_tree
    GROUP BY manager_id
)
SELECT
    e.EmployeeID,
    e.Name as EmployeeName,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ') AS ProjectNames,
    GROUP_CONCAT(DISTINCT t.TaskName ORDER BY t.TaskName SEPARATOR ', ') AS TaskNames,
    dc.total_subordinates as TotalSubordinates
FROM sfdb.Employees AS e
JOIN sfdb.Roles AS r 
	ON r.RoleID = e.RoleID
JOIN sfdb.Departments AS d
	ON d.DepartmentID = e.DepartmentID
JOIN descendant_counts AS dc
    ON dc.manager_id = e.EmployeeID
LEFT JOIN sfdb.Projects AS p
    ON p.DepartmentID = e.DepartmentID
LEFT JOIN sfdb.Tasks AS t
    ON t.AssignedTo = e.EmployeeID
WHERE r.RoleName = 'Менеджер'
  AND dc.total_subordinates > 0
GROUP BY
    e.EmployeeID,
    e.Name,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    dc.total_subordinates
ORDER BY e.Name;