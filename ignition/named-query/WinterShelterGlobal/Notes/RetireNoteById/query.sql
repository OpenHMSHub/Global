UPDATE shelter.LocationNotes
	SET timeRetired = :retiredDate
WHERE id = :noteId