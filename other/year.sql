SELECT concat(age,' ',ageName) as age from(select DISTINCT age,
		case
	WHEN age % 100 >=5 && age % 100 <=20 THEN
	'лет'
	WHEN age % 10=1 THEN
	'год'
	WHEN age % 10 >=2
		AND age % 10 <=4 THEN
	'года'
	ELSE 'лет'
	END AS ageName
FROM students) as q
ORDER BY  age; 