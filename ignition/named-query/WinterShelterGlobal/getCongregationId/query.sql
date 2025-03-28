SELECT
	loc.congregationId 
FROM
	shelter.Location loc
WHERE
	loc.id = :locationId 
