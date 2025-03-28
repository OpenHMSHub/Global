DECLARE @firstDayOfTheCurrentSeason as INT
DECLARE @YearStart as INT
DECLARE @YeareEnd as INT

SELECT @YearStart =  CAST(SUBSTRING(seasons, 1, 4)as INT) FROM shelter.Seasons where id = :seasonId
SELECT @YeareEnd =   CAST(SUBSTRING(seasons, 6, 9)as INT) FROM shelter.Seasons where id = :seasonId
SELECT @firstDayOfTheCurrentSeason = DATENAME(dayofyear , datefromparts(@YearStart, 11,1)) 

SELECT 
	nightHosting.locationId, 
	nightHosting.locationName, 
	nightHosting.reminderCall, 
	nightHosting.primaryCoordinatorEmail,
	nightHosting.primaryCoordinatorPhone,
	nightHosting.primaryCoordinatorPreferredCommunication,
	nightHosting.secondaryCoordinatorEmail,
	nightHosting.secondaryCoordinatorPhone,
	nightHosting.secondaryCoordinatorPreferredCommunication,
	nightHosting.seasonId, 
	nightHosting.DateFromDayOfYear,
	DATEADD(DAY, -:daysPriorToEvent, nightHosting.DateFromDayOfYear) as 'DatePriorEvent'

FROM(
SELECT
	ls.locationId
	,l.locationName
	, ls.reminderCall
	,ISNULL(hcp.email,'') AS 'primaryCoordinatorEmail'
	,ISNULL(hcp.email,'') AS 'primaryCoordinatorEmail1'
	,hcp.phone AS 'primaryCoordinatorPhone'
	,hcp.preferredCommunication AS 'primaryCoordinatorPreferredCommunication'
	,ISNULL(hcs.email,'') AS 'secondaryCoordinatorEmail' 
	,hcs.phone AS 'secondaryCoordinatorPhone'
	,hcs.preferredCommunication AS 'secondaryCoordinatorPreferredCommunication'
	,ls.seasonId
	,s.DateFromDayOfYear
FROM 
	shelter.LocationSeasonal ls
LEFT JOIN
	shelter.Location l ON ls.locationId = l.id
LEFT JOIN
	(
	select *,  
	DateAdd(DAY,s.dayOfYear, case when s.dayOfYear<@firstDayOfTheCurrentSeason then DateFromParts(@YeareEnd-1,12,31) Else DateFromParts(@YearStart-1,12,31) end) as DateFromDayOfYear
	from shelter.Schedule s where timeCancelled is null
	) as s ON ls.locationId = s.locationId and ls.seasonId = s.seasonId
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
	AND ls.reminderCall = 1
	
)nightHosting
WHERE nightHosting.DateFromDayOfYear is not NULL
ORDER BY
	nightHosting.locationName
