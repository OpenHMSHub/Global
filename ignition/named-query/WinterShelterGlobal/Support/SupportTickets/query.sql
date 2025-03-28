SELECT shelter.Support.id, shelter.Support.dueDate, shelter.Support.locationId,shelter.Support.congregationNotes, shelter.Support.RITINotes,
	shelter.Support.staffId,shelter.Support.statusId, shelter.Support.ticketTypeId, shelter.Support.timeCreated,
	shelter.Support.completedDate as completed, shelter.Support.title, COALESCE(shelter.Support.Contact,'') as contact, 
  	shelter.Location.locationName,
  	shelter.ticketType.type,
  	shelter.SupportStatus.Status,
  	shelter.Priority.priority as ticketPriority,
  	shelter.Support.priority as priorityId,
  	CONCAT(humans.Human.firstName, ' ', humans.Human.lastName) as staffName
  	FROM shelter.Support
  	INNER JOIN shelter.Location ON shelter.Location.id =  shelter.Support.locationId
  	INNER JOIN shelter.ticketType ON shelter.Support.ticketTypeId = shelter.ticketType.id
  	LEFT JOIN shelter.SupportStatus ON shelter.Support.statusId = shelter.SupportStatus.id
  	LEFT JOIN shelter.Priority ON shelter.Support.priority = shelter.Priority.id
  	LEFT JOIN humans.Human ON shelter.Support.staffId = humans.Human.id
  	WHERE shelter.Support.timeRetired is NULL AND shelter.Support.timeCreated >= :startDateFilter
  	AND (:staffId IS NULL OR :staffId = -1 OR (shelter.Support.staffId = :staffId))
  	AND (:ticketTypeId IS NULL OR :ticketTypeId = -1 OR (shelter.Support.ticketTypeId = :ticketTypeId))
  	AND (:statusId IS NULL OR :statusId = -1 OR (shelter.Support.statusId = :statusId))
  	AND (:congregationId IS NULL OR :congregationId = -1 OR (shelter.Support.locationId = :congregationId))
  	AND (:priorityId IS NULL OR :priorityId = -1 OR (shelter.Support.priority = :priorityId))
  	AND (
  		(:activeInactive IS NULL OR :activeInactive = '' OR :activeInactive = 'Active & Inactive') OR
  		(:activeInactive = 'Active' AND shelter.Support.completedDate IS NULL) OR
  		(:activeInactive = 'Inactive' AND shelter.Support.completedDate IS NOT NULL) 
  		)
  	AND( :dateRangeStart IS NULL OR :dateRangeStart = '' OR (shelter.Support.timeCreated >= :dateRangeStart))
  	AND( :dateRangeEnd IS NULL OR :dateRangeEnd = '' OR (shelter.Support.timeCreated <= :dateRangeEnd))
  	AND (:searchText IS NULL OR 
  	     :searchText = '' OR 
  	     shelter.Location.locationName LIKE :searchText OR 
  	     humans.Human.firstName LIKE :searchText OR 
  	     humans.Human.lastName LIKE :searchText OR
  	     shelter.ticketType.type LIKE :searchText OR
  	     shelter.SupportStatus.Status LIKE :searchText OR
  	     shelter.Support.title LIKE :searchText OR
  	     shelter.Support.contact LIKE :searchText OR
  	     shelter.Priority.priority LIKE :searchText
  	     )