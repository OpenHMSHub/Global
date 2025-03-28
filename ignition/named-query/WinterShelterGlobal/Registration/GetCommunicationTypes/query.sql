SELECT
	id as 'id',
	communicationTypeName   as 'communication_type'
FROM
	humans.CommunicationType 
	where communicationTypeName not in ('Data Not Collected')