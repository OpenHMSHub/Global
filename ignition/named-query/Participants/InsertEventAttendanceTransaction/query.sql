-- Get Point counts from breeze event id
DECLARE @points int
DECLARE @participantId int
DECLARE @campusStorecategory int
DECLARE @eventName varchar(500)

SELECT @points = cep.points
from calendar.CalendarEvents ce, calendar.CalendarEventsPointCounts cep
where ce.breezeId = :eventBreezeId and ce.name = cep.name

SELECT @eventName = ce.name
from calendar.CalendarEvents ce, calendar.CalendarEventsPointCounts cep
where ce.breezeId = :eventBreezeId and ce.name = cep.name

SELECT @participantId = p.id 
from Participant.participant p , humans.human h
where h.breezeId = :humanBreezeId AND p.humanId = h.id

SELECT @campusStorecategory = Id
FROM  participant.CampusStoreCategory 
WHERE Name = @eventName

IF @campusStorecategory IS NULL 
BEGIN
	INSERT INTO  participant.CampusStoreCategory (Name, CanAdd, CanDeduct) VALUES (@eventName,0,1)
	SELECT @campusStorecategory = SCOPE_IDENTITY()
END
IF @participantId IS NOT NULL
BEGIN
	INSERT INTO participant.CampusStore(Category, ParticipantId, timeCreated, TotalPoints, TransactionPoints)
	VALUES(
    @campusStorecategory,
    @participantId,
    GETDATE(),
    /* Retrieve the point total from last transaction and add the point difference */
    (SELECT COALESCE(
      (SELECT TOP 1 store.TotalPoints
        FROM participant.CampusStore AS store
        WHERE store.ParticipantId = @participantId
        ORDER BY timeCreated DESC),
      0) AS points
    ) + @points,
    
    @points)
END