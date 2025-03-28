/*---Participants/Registration/FindMatches---*/

SELECT TOP 25 *, case when t.programName like '%Winter Shelter%' then 0 else 1 end as 'ws_enrollment' FROM(
SELECT 
pd.id, pd.firstName, pd.middleName, pd.lastName, pd.BirthDate , pd.suspension, 
(SELECT 
	STRING_AGG(	[interaction].[Program].programName, ', ') 
FROM 
	[participant].[Enrollments]
INNER JOIN 
	[interaction].[Program] 
ON 
	[participant].[Enrollments].programId=[interaction].[Program].id
WHERE 
	particpantId =pd.id
) as programName
FROM 
participant.Dashboard pd
WHERE 
(pd.firstName LIKE '%'+ISNULL(:firstName,pd.firstName)+'%') AND
(pd.middleName LIKE '%'+ISNULL(:middleName,pd.middleName)+'%') AND
(pd.lastName LIKE '%'+ISNULL(:lastName,pd.lastName)+'%')
) t
order by (case when t.programName like '%Winter Shelter%' then 0 else 1 end), t.firstName