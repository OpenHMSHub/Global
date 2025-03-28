INSERT INTO shelter.LocationSeasonal (
	locationId,
	seasonId,
	genderId,
	beds, 
	nights,
	timeCreated)
VALUES (
	:locationId,
	:seasonId,
	NULL,
	0,
	0,
	getDate());