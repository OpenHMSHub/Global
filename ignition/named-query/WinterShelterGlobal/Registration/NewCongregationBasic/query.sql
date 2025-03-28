INSERT INTO organization.Congregation (
	breezeId,
	username, 
	providerId,
	timeCreated)
VALUES (
	:breezeId,
	:username, 
	:providerId,
	getDate());