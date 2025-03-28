---Participants/DrugScreen/ProviderListSelect---
SELECT
	p.id,p.providerName
FROM
	organization.Provider p
	INNER JOIN organization.ProviderType t ON p.providerTypeId = t.id
WHERE
	t.id = (SELECT id FROM organization.ProviderType WHERE providerTypeName like 'Congregation')
ORDER BY p.providerName