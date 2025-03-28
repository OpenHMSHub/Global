SELECT 
		---location information---
		loc.id,
		loc.locationName,
		loc.city,
		CONCAT_WS(' ',loc.addressLine1,loc.addressLine2) AS 'locationAddress',
		loc.zipCode,
		loc.timeCreated,
		ISNULL(g.genderAccepted,'') as 'genderAccepted',
		---
		---Coordinator Information----
		---
		pcoord.id AS 'cdid',
		pcoord.humanID AS 'coordinatorHumanID',
		CONCAT_WS(' ',hcp.firstName,hcp.lastName) AS 'coordinator',
		--hcp.nickname as 'Coordinator Nickname', 
		--hcp.street AS 'Coordinator Address',
		--hcp.city AS 'Coordinator City',
		--hcp.zipCode AS 'Coordinator Zipcode',
		ISNULL(hcp.phone,'') AS 'coordinatorPhone', 
		ISNULL(hcp.email,'') AS 'coordinatorEmail', 
		--hcp.preferredCommunication AS 'Coordinator Preferred Communication',
		--pcoord.notes AS 'Coordinator Comments',
		---
		----Location Features----
		----
		ls.seasonId, 
		ls.beds as 'capacity',
		--ISNULL(ls.numberOfWeeks,'') as 'numberOfWeeks',  
		ls.nights as 'nightsInt',
		cast(ls.nights & 1 as bit) as 'sunday',
		cast(ls.nights & 2 as bit) as 'monday',
		cast(ls.nights & 4 as bit) as 'tuesday',
		cast(ls.nights & 8 as bit) as 'wednesday',
		cast(ls.nights & 16 as bit) as 'thursday',
		cast(ls.nights & 32 as bit) as 'friday',
		cast(ls.nights & 64 as bit) as 'saturday',

		ls.accessible, 
 		ls.families,  
		ls.extraShortNotice, 
		ls.stairs, 
		ls.smoking, 
		ls.showers,
		ls.clothing,
		ls.laundry,
		ls.sackLunches,
		ls.breakfast,
		ls.dinner,
		ls.haircuts,
		ls.hygieneItems,
		'' as 'options'


FROM shelter.Location loc
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
	AND  
	{locationName} 
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
ORDER BY loc.locationName
