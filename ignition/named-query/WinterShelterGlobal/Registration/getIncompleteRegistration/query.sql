SELECT 
	distinct ls.locationId 
	,l.locationName 
	,(select ISNULL(email,'') from humans.human  where id = (SELECT TOP(1) humanId FROM shelter.Coordinator WHERE isPrimary = 1 and locationId = ls.locationId)) AS 'primaryCoordinatorEmail'
	,(select ISNULL(email,'') from humans.human where id = (SELECT TOP(1) humanId FROM shelter.Coordinator WHERE isPrimary = 0 and locationId = ls.locationId)) AS 'secondaryCoordinatorEmail' 
FROM 
	shelter.LocationSeasonal ls
	LEFT JOIN 
		shelter.location l ON ls.locationId = l.id	
	LEFT JOIN
		(SELECT locationId, seasonId , sum(totalBeds) as bedsProjected
		FROM shelter.Schedule 
		WHERE timeCancelled is NULL 
		GROUP BY locationId, seasonId ) sch ON ls.seasonId = sch.seasonId AND sch.locationId = ls.locationId
WHERE
	ls.seasonId = :seasonId
	AND (ls.beds = 0 or ls.genderId = NULL or ISNULL(sch.bedsProjected,'') = NULL or ISNULL(sch.bedsProjected,'') < 1)
	AND IncompleteRegistrationEmail IS NULL
ORDER BY
	l.locationName ASC