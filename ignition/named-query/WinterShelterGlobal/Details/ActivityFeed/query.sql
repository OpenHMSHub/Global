----WinterShelter/Activities/ActivityFeed----

Declare @congregationId as int = :congregationId;

with Activities as (


-- Congregation Created         ( MAY CHANGE TO [shelter].[congregation]  
SELECT
	[organization].[congregation].id AS ID
,	'CongregationCreated' as CardType
,	[organization].[congregation].timeCreated as Date
FROM [organization].[congregation]
Where [organization].[congregation].congregationId = @congregationId
union

-- Note Added                               *******  NO TABLE *********
SELECT
	[shelter].[notes].id AS ID
,	'NoteAdded' as CardType
,	[shelter].[notes].timeCreated as Date
FROM [shelter].[notes]
Where [shelter].[notes].congregationId = @congregationId
union

-- Volunteer Added                          *******  MODIFY TABLE *********
SELECT
	[shelter].[sheltervolunteers].id as ID
,	'VolunteerAdded' as CardType
,	[shelter].[sheltervolunteers].timeCreated as Date
FROM [shelter].[sheltervolunteers]
WHERE [shelter].[sheltervolunteers].Id = @congregationId
union

-- Registration                              *******  NO TABLE *********
SELECT
	[shelter].[registration].id AS ID
,	'Registration' as CardType
,	[shelter].[registration].timeCreated as Date
FROM [shelter].[registration]
WHERE [shelter].[registration].Id = @congregationId
union

-- Registration Changed                       *******  NO TABLE *********
SELECT
	[shelter].[registration].id AS ID
,	'RegistrationChanged' as CardType
,	[shelter].[registration].timeModified as Date
FROM [shelter].[registration]
WHERE [shelter].[registration].congregationId = @congregationId
	AND [shelter].[registration].timeModified is not Null

-- Support Ticket Added                        *******  MODIFY TABLE *********
SELECT
	[shelter].[ticket].id AS ID
,	'SupportTicketAdded' as CardType
,	[shelter].[ticket].timeCreated as Date
FROM [shelter].[ticket]
WHERE [shelter].[ticket].congregationId =  @congregationId
union

-- Support Ticket Modified                      *******  MODIFY TABLE *********
SELECT
	[shelter].[ticket].id AS ID
,	'SupportTicketModified' as CardType
,	[shelter].[ticket].timeModified as Date
FROM [shelter].[ticket]
WHERE [shelter].[ticket].congregationId = @congregationId
	AND [shelter].[ticket].timeModified is not Null

-- Task Added                                   *******  NO TABLE *********
SELECT
	[shelter].[task].id AS ID
,	'TaskAdded' as CardType
,	[shelter].[task].timeCreated as Date
FROM [shelter].[task]
WHERE [shelter].[task].congregationId =  @congregationId
union

-- Task Modified                                 *******  NO TABLE *********
SELECT
	[shelter].[task].id AS ID
,	'TaskModified' as CardType
,	[shelter].[task].timeModified as Date
FROM [shelter].[task]
WHERE [shelter].[task].congregationId = @congregationId
	AND [shelter].[task].timeModified is not Null

-- Winter Shelter Night                           *******  NO TABLE *********
SELECT
	[shelter].[event].id AS ID
,	'WinterShelterNight' as CardType
,	[shelter].[event].timeCreated as Date
FROM [shelter].[event]
WHERE [shelter].[event].congregationId =  @congregationId
union


),

Headers AS (
Select distinct
	0 as ID
,	'Header' as CardType
,	DATEADD(Day,-1,DATEADD(month, DATEDIFF(month, -1, Activities.Date), 0)) AS Date
from Activities
),

TotalInfo as (
Select * from Activities
Union
Select * from Headers
)

Select * from TotalInfo
Order by Date desc