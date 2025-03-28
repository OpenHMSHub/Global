INSERT INTO shelter.Coordinator (
	locationId, 
	isPrimary,
	humanId, 
	timeCreated)
VALUES (
	:locationId,
	:isPrimary,
	:humanId,
	GetDate());
