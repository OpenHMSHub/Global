SELECT
	id
	,CASE WHEN genderAccepted = 'Men Only' THEN 'Male'
	WHEN genderAccepted = 'Women Only' THEN 'Female'
	WHEN genderAccepted = 'Families with Children' THEN 'Families with Children'
	WHEN genderAccepted = 'Men or Women on Different Nights' THEN 'Male or Female'
	WHEN genderAccepted = 'Men & Women Together' THEN 'Male and Female'
	WHEN genderAccepted = 'All' THEN 'All' END AS gender
FROM
	shelter.Gender 
ORDER BY genderAccepted