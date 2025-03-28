SELECT 
	SUM(bedsActual)
FROM
(SELECT 
		---location information---
		loc.id as 'id',
		p.providerName as locationName,
		ls.bedsActual as bedsActual
FROM shelter.Location loc
LEFT JOIN Organization.Congregation c ON loc.congregationId = c.Id
LEFT JOIN organization.provider p ON c.providerId = p.id
LEFT JOIN
	shelter.LocationSeasonal ls ON loc.id = ls.locationId
LEFT JOIN 
	shelter.Gender g ON ls.genderId = g.id
LEFT JOIN 
	shelter.Seasons sea ON ls.seasonId = sea.id
OUTER APPLY
	(SELECT DISTINCT TOP (1) * FROM shelter.Coordinator WHERE isPrimary = 1 and locationId = loc.id ORDER BY timeCreated DESC) AS pcoord --ON loc.id = pcoord.locationId  --ON loc.id = pcoord.locationId -- pcoord.congregationId
LEFT JOIN 
	humans.human hcp ON pcoord.humanId = hcp.id
LEFT JOIN ( SELECT locationId, seasonId , sum(totalBeds) as bedsProjected
	FROM shelter.Schedule 
	WHERE timeCancelled is NULL 
	GROUP BY locationId, seasonId ) sch ON ls.seasonId = sch.seasonId AND ls.locationId = sch.locationId

	
WHERE
	ls.seasonId =  :season 
	AND loc.congregationId IN (select id from organization.Congregation where timeRetired IS NULL) 
	AND sch.bedsProjected IS NOT NULL AND sch.bedsProjected > 0
	AND {locationName} 
	AND  {city} 
	AND  {zipCode} 
	AND  {minGuests} 
	AND  {maxGuests} 
	AND  {accessible}
	AND  {families} 
	AND  {shortNotice} 
	AND  {stairs} 
	AND  {smoking} 
	AND  {reminderCall} 
	AND  {monday} 
	AND  {tuesday} 
	AND  {wednesday} 
	AND  {thursday} 
	AND  {friday} 
	AND  {saturday} 
	AND  {sunday} 
	AND  {gender} 
	AND  {search} 
	AND  {showers} 
	AND  {clothing} 
	AND  {laundry} 
	AND  {sackLunches} 
	AND  {breakfast} 
	AND  {dinner} 
	AND  {haircuts} 
	AND  {hygieneItems} 
	
) a
