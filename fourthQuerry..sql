SELECT items.itemid, SUM(price)
	FROM items
	INNER JOIN purchases
		ON Purchases.itemid = Items.itemid
    where to_char(purchases.date,'YYYY') in (select DISTINCT max(to_char(purchases.date,'YYYY'))  from purchases)
    GROUP By items.itemid
    order BY  sum DESC limit 1;