INSERT INTO organization.Provider (
	street,
	providerName, 
	email, 
	state,
	providerTypeId,
	timeCreated)
VALUES (
	:line1, 
	:congregation, 
	:email,
	:state,
	:typeId,
	getDate());