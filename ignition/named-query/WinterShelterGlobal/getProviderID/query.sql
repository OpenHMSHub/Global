SELECT
	 p.id as 'providerId'
	 ,c.id as 'congregationId' 
	 ,s.id as 'shelterLocationId'
	 ,p.providerName  
FROM 
 	organization.Provider p
 	INNER JOIN  organization.Congregation c ON c.providerId  = p.id
 	INNER JOIN shelter.location s ON s.congregationId = c.id
WHERE
	s.id =   :locationId 