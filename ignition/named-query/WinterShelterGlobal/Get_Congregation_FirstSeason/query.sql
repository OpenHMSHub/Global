SELECT 
	TOP(1) ID, Seasons 
FROM 
	shelter.Seasons
WHERE
	ID in (SELECT seasonId FROM shelter.LocationSeasonal where locationId = :locationId)
ORDER BY
	Seasons ASC