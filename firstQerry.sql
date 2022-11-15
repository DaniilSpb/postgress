select  users.userid,price,users.age,purchases.date,to_char(purchases.date,'YYYY/MM') as newData,sum(price) as сумма from users
	INNER JOIN  purchases On Users.userid = Purchases.userid
	INNER JOIN  items On Purchases.itemid = Items.itemid
	where age BETWEEN 18 AND 25
    GROUP by newdata;
