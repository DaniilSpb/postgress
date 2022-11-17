SELECT itemid,
		 year_,
		 round(sum * 100.0 / sum_year) AS Percentage
FROM 
	(SELECT year_,
		 itemid,
		 sum(price),
		 sum_year
	FROM 
		(SELECT to_char(purchases.date,
		 'YYYY')as year_,purchases.itemid,price,sum_year
		FROM users
		INNER JOIN purchases
			ON Users.userid = Purchases.userid
		INNER JOIN items
			ON Purchases.itemid = Items.itemid
		INNER JOIN 
			(SELECT to_char(purchases.date,
		 'YYYY') year_,sum(price) sum_year
			FROM users
			INNER JOIN purchases
				ON Users.userid = Purchases.userid
			INNER JOIN items
				ON Purchases.itemid = Items.itemid
			GROUP BY  year_ ) AS q2
				ON q2.year_ = to_char(purchases.date,'YYYY')
			WHERE items.itemid IN 
				(SELECT itemid
				FROM 
					(SELECT Sum(price) ,
		 items.itemid
					FROM items
					INNER JOIN purchases
						ON Purchases.itemid = Items.itemid
					GROUP BY  items.itemid
					ORDER BY  sum DESC limit 3)as q)
					ORDER BY  YEAR_) AS q3
					GROUP BY  year_,itemid,sum_year)as q4;

