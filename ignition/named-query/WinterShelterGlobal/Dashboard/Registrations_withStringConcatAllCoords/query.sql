SELECT 

		---location information---
		loc.id as 'id',
		MAX(p.providerName) as locationName,
		MAX(loc.city) as 'city',
		MAX(CONCAT_WS(' ',loc.addressLine1,loc.addressLine2)) AS 'locationAddress',
		MAX(loc.zipCode) as 'zipCode',
		MAX(loc.timeCreated) as 'timeCreated',
		ISNULL(MAX(g.genderAccepted),'') as 'genderAccepted',
		---
		---Coordinator Information----
		---
		STRING_AGG(pcoord.id,', ') AS 'cdid',
		--pcoord.id AS 'cdid',
		STRING_AGG(pcoord.humanID,', ') AS 'coordinatorHumanID',
		STRING_AGG(CONCAT_WS(' ',hcp.firstName,hcp.lastName),', ') AS 'coordinator',
		--hcp.nickname as 'Coordinator Nickname', 
		--hcp.street AS 'Coordinator Address',
		--hcp.city AS 'Coordinator City',
		--hcp.zipCode AS 'Coordinator Zipcode',
		STRING_AGG(ISNULL(hcp.phone,''),', ') AS 'coordinatorPhone', 
		STRING_AGG(ISNULL(hcp.email,''),', ') AS 'coordinatorEmail', 
		--hcp.preferredCommunication AS 'Coordinator Preferred Communication',
		--pcoord.notes AS 'Coordinator Comments',
		---
		----Location Features----
		----
		MAX(ls.seasonId) as 'seasonId', 
		MAX(ls.beds) as 'capacity',
		--ISNULL(ls.numberOfWeeks,'') as 'numberOfWeeks',  
		MAX(ls.nights) as 'nightsInt',
		cast(MAX(ls.nights) & 1 as bit) as 'sunday',
		cast(MAX(ls.nights) & 2 as bit) as 'monday',
		cast(MAX(ls.nights) & 4 as bit) as 'tuesday',
		cast(MAX(ls.nights) & 8 as bit) as 'wednesday',
		cast(MAX(ls.nights) & 16 as bit) as 'thursday',
		cast(MAX(ls.nights) & 32 as bit) as 'friday',
		cast(MAX(ls.nights) & 64 as bit) as 'saturday',

		MAX(CAST(ls.accessible AS tinyint)) as 'accessible', 
 		MAX(CAST(ls.families AS tinyint)) as 'families',  
		MAX(CAST(ls.extraShortNotice AS tinyint)) as 'extraShortNotice', 
		MAX(CAST(ls.stairs AS tinyint)) as 'stairs', 
		MAX(CAST(ls.smoking AS tinyint)) as 'smoking', 
		MAX(CAST(ls.showers AS tinyint)) as 'showers',
		MAX(CAST(ls.clothing AS tinyint)) as 'clothing',
		MAX(CAST(ls.laundry AS tinyint)) as 'laundry',
		MAX(CAST(ls.sackLunches AS tinyint)) as 'sackLunches',
		MAX(CAST(ls.breakfast AS tinyint)) as 'breakfast',
		MAX(CAST(ls.dinner AS tinyint)) as 'dinner',
		MAX(CAST(ls.haircuts AS tinyint)) as 'haircuts',
		MAX(CAST(ls.hygieneItems AS tinyint)) as 'hygieneItems',
		'' as 'options'


FROM shelter.Location loc
LEFT JOIN Organization.Congregation c ON loc.congregationId = c.Id
LEFT JOIN organization.provider p ON c.providerId = p.id
LEFT JOIN
	shelter.LocationSeasonal ls ON loc.id = ls.locationId
LEFT JOIN 
	shelter.Gender g ON ls.genderId = g.id
LEFT JOIN 
	shelter.Seasons sea ON ls.seasonId = sea.id
LEFT JOIN
	(SELECT DISTINCT * FROM shelter.Coordinator WHERE isPrimary = 1) pcoord ON loc.id = pcoord.locationId  --ON loc.id = pcoord.locationId -- pcoord.congregationId
LEFT JOIN 
	humans.human hcp ON pcoord.humanId = hcp.id

	
WHERE
	ls.seasonId =  :season 
	AND loc.congregationId IN (select id from organization.Congregation where timeRetired IS NULL) 
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
	
GROUP BY loc.id, ls.id
ORDER BY MAX(loc.locationName)
