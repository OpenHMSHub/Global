---Determine the current, past and next season
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @thisSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN @thisYear ELSE (@thisYear - 1) END

SELECT Sum(totalBeds) as totalBeds, 
convert(varchar, DateAdd(MONTH,MONTH(DateFromDayOfYear),DateFromParts(Year(GetDate())-1,12,1)), 1) as DatePerMonth FROM
(SELECT seasonId,totalBeds,dayOfYear,DateAdd(DAY,dayOfYear,DateFromParts(Year(GetDate())-1,12,31)) as DateFromDayOfYear FROM shelter.Schedule
Where seasonId = (SELECT s.id FROM shelter.Seasons s WHERE s.Seasons like @thisSeasonStartYear + '%')
AND locationId = :locationId) as x
group by MONTH(DateFromDayOfYear)
