---Determine the current, past and next season
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @thisSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN @thisYear ELSE (@thisYear - 1) END

---Determine the current, past and next season ID's
DECLARE @thisSeasonId int
SELECT @thisSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @thisSeasonStartYear + '%'


SELECT 
	* 
FROM 
	shelter.Schedule 
WHERE 
	locationId = :locationId
	and seasonId = @thisSeasonId
	and dayOfYear = :dayOfYear
	and timeCancelled IS NOT NULL