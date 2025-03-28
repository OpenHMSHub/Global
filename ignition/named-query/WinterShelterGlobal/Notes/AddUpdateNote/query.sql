DECLARE @noteId INT = :noteId;
DECLARE @locationId INT = :locationId;
DECLARE @note VARCHAR(MAX) = :note;
DECLARE @noteTime DATETIME = :createdTime;

IF (NOT EXISTS(SELECT id FROM shelter.LocationNotes WHERE id = @noteId))
BEGIN 
    INSERT INTO shelter.LocationNotes (locationId, note, timeCreated, timeRetired)
    VALUES (@locationId, @note, @noteTime, NULL)
END 
ELSE 
BEGIN 
    UPDATE shelter.LocationNotes
    SET note = @note, timeCreated = @noteTime
    WHERE id = @noteId
END 