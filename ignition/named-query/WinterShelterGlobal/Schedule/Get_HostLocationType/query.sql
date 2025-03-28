SELECT 
	CASE WHEN HostLocationType = 'Our Location' THEN 'Congregation' ELSE HostLocationType END as'HostLocationType' 
FROM 
	shelter.HostLocationType 
WHERE 
	HostLocationType != 'Remote'