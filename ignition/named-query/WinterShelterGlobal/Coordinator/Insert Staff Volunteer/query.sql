Insert into staff.Volunteer (
humanId,
timeCreated,
timeUpdated,
timeRetired,
notes,
username
)
Values (
:humanId,
GetDate(),
NULL,
NULL,
NULL,
NULL
)