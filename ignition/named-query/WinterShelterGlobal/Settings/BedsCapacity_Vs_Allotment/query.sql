SELECT
	distinct sp.locationId
	,l.locationName
	,BedsCapacityVsAllotmentEmail
	,ISNULL(hcp.email,'') AS 'primaryCoordinatorEmail'
	,ISNULL(hcs.email,'') AS 'secondaryCoordinatorEmail' 
	, (SELECT count(id)*max(totalBeds) as 'registeredBeds' FROM shelter.Schedule where locationId = sp.locationId and seasonId = sp.seasonId and timeCancelled IS NULL) as 'registeredBeds'
	,(SELECT count(id) as 'actualBeds' FROM shelter.ScheduleParticipant where locationId = sp.locationId and seasonId = sp.seasonId and timeRetired is null) as 'actualBeds'
FROM 
	shelter.ScheduleParticipant sp
LEFT JOIN
	shelter.location l ON sp.locationId = l.id
LEFT JOIN
	shelter.LocationSeasonal ls ON sp.locationId = ls.locationId and sp.seasonId = ls.seasonId
LEFT JOIN
	(SELECT * FROM shelter.Coordinator WHERE isPrimary = 1) pcoord  ON l.id = pcoord.locationId
LEFT JOIN 
	humans.human hcp ON pcoord.humanId = hcp.id
LEFT JOIN
	(SELECT * FROM shelter.Coordinator WHERE isPrimary = 0) scoord  ON l.id = scoord.locationId 
LEFT JOIN 
	humans.human hcs ON scoord.humanId = hcs.id
WHERE 
	sp.seasonId = :seasonId 
	and CAST(sp.timeCreated as date) = :todayDate
	and sp.timeRetired is null
	