---Determine the current, past and next season
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @thisSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN @thisYear ELSE (@thisYear - 1) END
DECLARE @lastSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN (@thisYear - 1) ELSE (@thisYear - 2) END
DECLARE @nextSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN (@thisYear + 1) ELSE (@thisYear) END
---Determine the current, past and next season ID's
DECLARE @thisSeasonId int
SELECT @thisSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @thisSeasonStartYear + '%'

DECLARE @lastSeasonId int
SELECT @lastSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @lastSeasonStartYear + '%'

DECLARE @nextSeasonId int
SELECT @nextSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @nextSeasonStartYear + '%'

SELECT 	
	 hm.id 
	 ,hm.HostMoreOption 


FROM shelter.HostMoreLocation hml
LEFT JOIN  shelter.HostMore hm on hml.hostMoreId = hm.id
	
WHERE
	hml.locationId  = :locationId 
AND 
	hml.seasonId = :seasonId
