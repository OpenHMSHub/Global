DECLARE @provider_id AS INT = 32
--DECLARE @program_id AS INT = ?
--DECLARE @referral_status_id AS INT = ?
--DECLARE @activity_start AS DATE = ?
--DECLARE @search_text VARCHAR(max) = ? 
 
SELECT 
	[participant].[id] AS [participant_id]
	,CONCAT_WS(' ',[Human].firstName, [Human].middleName, [Human].lastName) AS [name]
	,[Human].dob AS [dob]
	,DATEDIFF(year, [Human].dob, GETDATE()) AS [age]
	,[Referral].[timeCreated] AS [referral_date]
	,[ReferralType].[ReferralTypeName] AS [referral_type]
	,[ReferralStatus].[ReferralStatusName] AS [referral_status]
	,[Program].[programName] AS [program_name]
FROM [participant].[Referral]
	LEFT JOIN [participant].[Participant] ON [Referral].[ParticipantId] = [Participant].[id]
	LEFT JOIN [humans].[Human] ON [Participant].[humanId] = [Human].[id]
	LEFT JOIN [organization].[Provider] ON [Referral].[providerId] = [Provider].[id]
	LEFT JOIN [participant].[ReferralType] ON [Referral].[Type_id] = [ReferralType].[id]
	LEFT JOIN [participant].[ReferralStatus] ON [Referral].[Status_Id] = [ReferralStatus].[id]
	LEFT JOIN [interaction].[Program] ON [Program].[id] = [Referral].[ProgramId]
	
WHERE 1=1
	AND ([Referral].[ProviderId] = @provider_id OR ISNULL(@provider_id, -1) = -1)
	--AND ([Program].[id] = @program_id OR ISNULL(@program_id, -1) = -1)
	--AND ([ReferralStatus].[id] = @referral_status_id OR ISNULL(@referral_status_id, -1) = -1)
	--AND ([Referral].timeCreated >= @activity_start OR ISNULL(YEAR(@activity_start), -1) = -1)