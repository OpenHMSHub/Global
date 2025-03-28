---Determine the current, past and next season
DECLARE @startDayOfSeason int

SELECT @startDayOfSeason=DATENAME(dayofyear , DATEFROMPARTS( :seasonStartYear , 10, 1))

SELECT Sum(totalBeds) as totalBeds, 
CASE WHEN MONTH(DateFromDayOfYear) < 10 THEN 
convert(varchar, DateAdd(MONTH,MONTH(DateFromDayOfYear),DateFromParts(Year(DATEFROMPARTS( :seasonEndYear , 10, 1))-1,12,1)), 1)
ELSE 
convert(varchar, DateAdd(MONTH,MONTH(DateFromDayOfYear),DateFromParts(Year(DATEFROMPARTS( :seasonStartYear , 10, 1))-1,12,1)), 1)
END as DatePerMonth
FROM
(SELECT seasonId,totalBeds,dayOfYear,
CASE 
WHEN dayOfYear < @startDayOfSeason THEN DateAdd(DAY,dayOfYear,DateFromParts(Year(DATEFROMPARTS( :seasonEndYear , 10, 1))-1,12,31)) 
ELSE DateAdd(DAY,dayOfYear,DateFromParts(Year(DATEFROMPARTS( :seasonStartYear , 10, 1))-1,12,31))
END as DateFromDayOfYear 
FROM shelter.Schedule
Where seasonId =  :seasonId AND locationId = :locationId and timeCancelled IS NULL) as x
group by MONTH(DateFromDayOfYear)

