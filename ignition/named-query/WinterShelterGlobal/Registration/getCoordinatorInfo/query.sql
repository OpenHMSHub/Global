SELECT 	
		---
		---Coordinator Information---
		hcp.id AS 'HumanId',
		hcp.firstName AS 'FirstName',
		hcp.lastName AS 'LastName',
		ISNULL(hcp.street,'') AS 'Address',
		ISNULL(hcp.city,'') AS 'City',
		ISNULL(hcp.state,'') AS 'State',
		ISNULL(hcp.zipCode,'') AS 'ZipCode',
		ISNULL(hcp.phone,'') AS 'Phone', 
		ISNULL(hcp.altPhone,'') AS 'AltPhone', 
		ISNULL(hcp.email,'') AS 'Email', 
		hcp.preferredCommunication AS 'PreferredCommunication'


FROM humans.human hcp

WHERE
	hcp.id = :humanId 