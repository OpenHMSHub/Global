UPDATE shelter.tasks
SET
	timeRetired = (getdate())
WHERE id =   :row_id  ;