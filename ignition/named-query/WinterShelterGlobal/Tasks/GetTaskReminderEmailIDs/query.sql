SELECT *, 
	(select CONCAT(firstName, ' ', lastName) from [humans].[Human] where id = t.staffId) as staffName,
	(select email from [humans].[Human] where id = t.staffId) as staffEmail,
	(select CONCAT(firstName, ' ', lastName) from [humans].[Human] where id = t.assignerId) as assignerName,
	(select email from [humans].[Human] where id = t.assignerId) as assignerEmail,
	(select type from shelter.taskType where id = t.taskTypeId) as type,
	(select priority from shelter.Priority where id = t.priority) as taskPriority,
	(select locationName from shelter.location where id = t.locationId) as locationName
FROM (
	SELECT * FROM shelter.Tasks where timeRetired is NULL and cast(CURRENT_TIMESTAMP as date) = cast(DATEADD(day, -1, dueDate) as date)
	) t