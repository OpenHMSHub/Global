
SELECT
	prov.providerName AS 'congregationName'
FROM
	shelter.Location loc
LEFT JOIN
	organization.Congregation cong ON loc.congregationId = cong.Id
LEFT JOIN 
	organization.Provider prov ON cong.providerId = prov.id
WHERE
	loc.id = :locationId 
