DECLARE @firstDayOfTheCurrentSeason as INT
DECLARE @YearStart as INT
DECLARE @YeareEnd as INT

SELECT @YearStart =  CAST(SUBSTRING(seasons, 1, 4)as INT) FROM shelter.Seasons where id = :seasonId
SELECT @YeareEnd =   CAST(SUBSTRING(seasons, 6, 9)as INT) FROM shelter.Seasons where id = :seasonId
SELECT @firstDayOfTheCurrentSeason = DATENAME(dayofyear , datefromparts(@YearStart, 11,1)) 

SELECT 
	nightHosting.locationId, 
	nightHosting.locationName, 
	nightHosting.primaryCoordinatorEmail,
	nightHosting.secondaryCoordinatorEmail,
	nightHosting.seasonId, 
	nightHosting.FirstNightHosting,
	DATEADD(DAY, -:daysPriorToEvent, nightHosting.FirstNightHosting) as 'DatePriorEvent'

FROM(
SELECT
	ls.locationId
	,l.locationName
	,ISNULL(hcp.email,'') AS 'primaryCoordinatorEmail'
	,ISNULL(hcs.email,'') AS 'secondaryCoordinatorEmail' 
	,ls.seasonId
	,(
	select top 1  
	DateAdd(DAY,s.dayOfYear, case when s.dayOfYear<@firstDayOfTheCurrentSeason then DateFromParts(@YeareEnd-1,12,31) Else DateFromParts(@YearStart-1,12,31) end) as DateFromDayOfYear
	from shelter.Schedule s where locationId = ls.locationId and seasonId=ls.seasonId and timeCancelled is null
	order by DateAdd(DAY,s.dayOfYear, case when s.dayOfYear<@firstDayOfTheCurrentSeason then DateFromParts(@YeareEnd-1,12,31) Else DateFromParts(@YearStart-1,12,31) end)
	) as 'FirstNightHosting'
FROM 
	shelter.LocationSeasonal ls
LEFT JOIN
	shelter.Location l ON ls.locationId = l.id
LEFT JOIN
	(SELECT * FROM shelter.Coordinator WHERE isPrimary = 1) pcoord  ON ls.locationId = pcoord.locationId
LEFT JOIN 
	humans.human hcp ON pcoord.humanId = hcp.id
LEFT JOIN
	(SELECT * FROM shelter.Coordinator WHERE isPrimary = 0) scoord  ON ls.locationId = scoord.locationId 
LEFT JOIN 
	humans.human hcs ON scoord.humanId = hcs.id
WHERE
	ls.seasonId = :seasonId
)nightHosting
ORDER BY
	nightHosting.locationName
