SELECT shelter.Tasks.id, shelter.Tasks.dueDate, shelter.Tasks.locationId,shelter.Tasks.notes,
	shelter.Tasks.staffId,shelter.Tasks.statusId, shelter.Tasks.taskTypeId, shelter.Tasks.timeCreated,
	shelter.Tasks.completedDate as completed, shelter.Tasks.title, COALESCE(shelter.Tasks.contact,'') as contact, 
  	shelter.Location.locationName,
  	shelter.taskType.type,
  	shelter.Status.Status,
  	shelter.Priority.priority as taskPriority,
  	shelter.Tasks.priority as priorityId,
  	CONCAT(humans.Human.firstName, ' ', humans.Human.lastName) as staffName
  	FROM shelter.Tasks
  	INNER JOIN shelter.Location ON shelter.Location.id =  shelter.Tasks.locationId
  	INNER JOIN shelter.taskType ON shelter.Tasks.taskTypeId = shelter.taskType.id
  	INNER JOIN shelter.Status ON shelter.Tasks.statusId = shelter.Status.id
  	INNER JOIN shelter.Priority ON shelter.Tasks.priority = shelter.Priority.id
  	INNER JOIN humans.Human ON shelter.Tasks.staffId = humans.Human.id
  	WHERE shelter.Tasks.timeRetired is NULL AND shelter.Tasks.dueDate >= :startDateFilter
  	AND (:staffId IS NULL OR :staffId = -1 OR (shelter.Tasks.staffId = :staffId))
  	AND (:statusId IS NULL OR :statusId = -1 OR (shelter.Tasks.statusId = :statusId))
  	AND (:congregationId IS NULL OR :congregationId = -1 OR (shelter.Tasks.locationId = :congregationId))
  	AND (:priorityId IS NULL OR :priorityId = -1 OR (shelter.Tasks.priority = :priorityId))
  	AND (
  		(:activeInactive IS NULL OR :activeInactive = '' OR :activeInactive = 'Active & Inactive') OR
  		(:activeInactive = 'Active' AND shelter.Tasks.completedDate IS NULL) OR
  		(:activeInactive = 'Inactive' AND shelter.Tasks.completedDate IS NOT NULL) 
  		)
  	AND( :dateRangeStart IS NULL OR :dateRangeStart = '' OR (shelter.Tasks.dueDate >= :dateRangeStart))
  	AND( :dateRangeEnd IS NULL OR :dateRangeEnd = '' OR (shelter.Tasks.dueDate <= :dateRangeEnd))
  	AND (:searchText IS NULL OR 
  	     :searchText = '' OR 
  	     shelter.Location.locationName LIKE :searchText OR 
  	     humans.Human.firstName LIKE :searchText OR 
  	     humans.Human.lastName LIKE :searchText OR
  	     shelter.taskType.type LIKE :searchText OR
  	     shelter.Status.Status LIKE :searchText OR
  	     shelter.Tasks.title LIKE :searchText OR
  	     shelter.Tasks.contact LIKE :searchText OR
  	     shelter.Priority.priority LIKE :searchText
  	     )