UPDATE	organization.Provider
SET street = :congregationStreet,
	street2 = :congregationStreet2,
	city = :congregationCity,
	state =  :congregationState,
	zipCode =  :congregationZipCode,
	phone =  :congregationPhone,  
	providerTypeId = (SELECT id FROM organization.ProviderType WHERE providerTypeName like 'Congregation')

WHERE id = :providerId ;
