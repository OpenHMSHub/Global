SELECT TOP 1 loc.id
FROM organization.Congregation as con
LEFT JOIN shelter.Location as loc ON con.id = loc.congregationId
WHERE con.username = :username
ORDER BY loc.id