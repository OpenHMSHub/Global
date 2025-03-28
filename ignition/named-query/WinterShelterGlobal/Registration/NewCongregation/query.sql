DECLARE @providerTypeId int = (SELECT id FROM organization.ProviderType WHERE providerTypeName like 'Congregation')
INSERT INTO organization.Provider (
	street, 
	street2, 
	city, 
	contactName, 
	providerName, 
	email, 
	phone, 
	state,
	zipCode,
	providerTypeId)
VALUES (
	:line1, 
	:line2, 
	:city, 
	:leader, 
	:congregation, 
	:email, 
	:phone, 
	:state, 
	:zip,
	@providerTypeId
	);