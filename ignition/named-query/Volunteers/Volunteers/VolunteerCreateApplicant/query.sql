Insert into [staff].Volunteer (
	humanId,
	application,
	timeCreated 
)
Values (
	:humanId,
	:application,
	GetDate()
)