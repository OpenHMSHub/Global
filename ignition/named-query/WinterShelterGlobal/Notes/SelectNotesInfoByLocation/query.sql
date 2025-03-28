SELECT
	ln.id,
	ln.timeCreated,
	ln.note
FROM shelter.LocationNotes ln
WHERE ln.locationId = :locationId
AND ln.timeRetired IS NULL
ORDER BY ln.timeCreated