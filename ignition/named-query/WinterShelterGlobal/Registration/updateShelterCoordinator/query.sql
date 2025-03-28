UPDATE	shelter.Coordinator 
SET humanId  = :humanId,
	locationId  = :locationId,
	isPrimary = :isPrimary,
	notes = :notes,
 	timeCreated = GetDate()
WHERE id = :coordinatorId ;