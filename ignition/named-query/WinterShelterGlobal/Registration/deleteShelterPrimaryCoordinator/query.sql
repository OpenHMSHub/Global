DELETE FROM shelter.Coordinator 
WHERE  
	isPrimary = 1
	AND
	locationId = :locationId 