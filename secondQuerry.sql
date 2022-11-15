SELECT max(sum_temp) answer from (
	SELECT to_char(purchases.date,
		'MM') AS month_,sum(price) sum_temp
	FROM users
	INNER JOIN purchases
		ON Users.userid = Purchases.userid
	INNER JOIN items
		ON Purchases.itemid = Items.itemid
	WHERE age >35
	GROUP BY  month_ ) as q;