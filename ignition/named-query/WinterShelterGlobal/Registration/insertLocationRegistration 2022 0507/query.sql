--WinterShelter/Registration/insertLocationRegistration--
--
--Get the current season
DECLARE @locationId int = :locationId
DECLARE @thisWeek int = DATEPART(week,GetDate())
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @thisSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN @thisYear ELSE (@thisYear - 1) END
DECLARE @seasonId int = (SELECT id from shelter.Seasons where Seasons like @thisSeasonStartYear + '-%')
--Get the capacity
DECLARE @guests int = (SELECT capacity FROM shelter.Location WHERE id = :locationId)
--Get the nights per week
DECLARE @monday int = ISNULL((SELECT cast(nights & 1 as bit) FROM shelter.LocationPreference WHERE locationId = :locationId),0)
DECLARE @tuesday int = ISNULL((SELECT cast(nights & 2 as bit) FROM shelter.LocationPreference WHERE locationId = :locationId),0)
DECLARE @wednesday int = ISNULL((SELECT cast(nights & 4 as bit) FROM shelter.LocationPreference WHERE locationId = :locationId),0)
DECLARE @thursday int = ISNULL((SELECT cast(nights & 8 as bit) FROM shelter.LocationPreference WHERE locationId = :locationId),0)
DECLARE @friday int = ISNULL((SELECT cast(nights & 16 as bit) FROM shelter.LocationPreference WHERE locationId = :locationId),0)
DECLARE @saturday int = ISNULL((SELECT cast(nights & 32 as bit) FROM shelter.LocationPreference WHERE locationId = :locationId),0)
DECLARE @sunday int = ISNULL((SELECT cast(nights & 64 as bit) FROM shelter.LocationPreference WHERE locationId = :locationId),0)
DECLARE @nightsPerWeek int = @monday + @tuesday + @wednesday + @thursday + @friday + @saturday + @sunday
--Get weeks left in the season
DECLARE @seasonWeeks int = (SELECT numberOfWeeks  FROM shelter.LocationPreference WHERE locationId = :locationId)
--Project the number of beds left in the season
DECLARE @bedsProjected int = @nightsPerWeek * @seasonWeeks * @guests

--SELECT @nightsPerWeek,@seasonWeeks,@guests,@bedsProjected
INSERT INTO  shelter.LocationStatus
	 (
	 LocationId 
	 ,SeasonId 
	 ,BedsProjected 
	 ,BedsActual 
	 )
SELECT
	 :locationId 
	 ,@seasonId
	 ,@bedsProjected
	 ,0
WHERE NOT EXISTS 
	(
	SELECT LocationId,SeasonId 
	FROM shelter.LocationStatus
	WHERE LocationId = :locationId
	AND SeasonId = @seasonId
	)