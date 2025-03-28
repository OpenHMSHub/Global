DELETE FROM shelter.Coordinator 
WHERE  
	isPrimary = 0
	AND
	locationId = :locationId 