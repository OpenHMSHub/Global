---Determine the current, past and next season
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @thisSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN @thisYear ELSE (@thisYear - 1) END
---Determine the current, past and next season ID's
UPDATE  shelter.LocationSeasonal
SET  bedsProjected = (
					SELECT sum(s.totalBeds)
					FROM shelter.Schedule s 
					WHERE s.locationId =  :locationId AND s.seasonId  = :seasonId
					AND timeCancelled IS NULL
					)
	, bedsActual = (
					SELECT sum(s.reservedBeds )
					FROM shelter.Schedule s 
					WHERE s.locationId =  :locationId AND s.seasonId  = :seasonId
					)
WHERE shelter.LocationSeasonal.locationId =  :locationId AND shelter.LocationSeasonal.seasonId  = :seasonId