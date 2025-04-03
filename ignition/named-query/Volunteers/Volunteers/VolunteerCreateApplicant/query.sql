Insert into [staff].Volunteer (
	humanId,
	timeCreated 
)
Values (
	:humanId,
	GetDate()
)