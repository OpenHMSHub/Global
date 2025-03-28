---Determine the current, past and next season
DECLARE @YearStart as INT

SELECT @YearStart =  CAST(SUBSTRING(seasons, 1, 4)as INT) FROM shelter.Seasons where id = :seasonId


SELECT 	
	 s.id 
	 ,s.locationId 
	 ,s.seasonId 
	 ,s.dayOfYear 


FROM shelter.Schedule s
	
WHERE
	s.seasonId =  :seasonId
	AND
	s.locationId  = :locationId 
	AND
	s.timeCancelled IS NOT NULL AND s.timeCancelled >= datefromparts(@YearStart, 11,1)
