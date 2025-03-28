UPDATE shelter.tasks
SET
	congregationId =  :congregationId,
	typeId	= :typeId ,
	title =  :title ,
	dueDate =  :dueDate ,
	staffId =  :staffId ,
	priority = :priority ,
	statusId =  :statusId ,
	notes =  :notes 
WHERE id =   :row_id  ;