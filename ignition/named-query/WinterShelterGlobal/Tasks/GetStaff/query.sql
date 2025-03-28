SELECT
	[humans].[Human].id,
	CONCAT_WS(' ',[humans].[Human].firstName, [humans].[Human].middleName, [humans].[Human].lastName) as 'employee_name'
FROM
	[staff].[Employee]
	INNER JOIN [humans].[Human] on [staff].[Employee].humanId = [humans].[Human].id