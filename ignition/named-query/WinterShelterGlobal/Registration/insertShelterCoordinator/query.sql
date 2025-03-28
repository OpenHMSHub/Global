INSERT INTO	shelter.Coordinator 
	(
	humanId
	,locationId
	,isPrimary
	,notes
	,timeCreated
	)
VALUES
	(
	:humanId
	,:locationId
	,:isPrimary
	,:notes
	,GetDate()
	)
