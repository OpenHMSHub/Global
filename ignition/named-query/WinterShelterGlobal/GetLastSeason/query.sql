---Determine the past season
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @lastSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 6 THEN (@thisYear - 1) ELSE (@thisYear - 2) END
---Determine the past season ID's
SELECT s.id,s.Seasons FROM shelter.Seasons s WHERE s.Seasons like @lastSeasonStartYear + '%'