---Participants/DrugScreen/ProviderListSelect---
SELECT
	p.id,p.providerName
FROM
	organization.Provider p
WHERE
	p.providerTypeId =  :provider_type_id 