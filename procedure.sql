USE [TestTaskDB]
GO
/****** Object:  StoredProcedure [dbo].[sp_report_1]    Script Date: 16.11.2022 18:36:54 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sp_report_1]
	@date_from date,
	@date_to date,
	@good_group_name nvarchar(MAX)
AS
BEGIN
	
	/*	---------------------------------------------
		--------------Постановка задачи--------------
		---------------------------------------------
		1. Заказчик утверждает, что продажи с НДС по сети, по группе товаров 'Биологически активные добавки',  в июне 2017 составили: 1 782 949.10 в рублях и 6761.10 в штуках.
			Процедура ETL исполнителя возвращает другие данные.
			Необходимо найти и устранить возможные причины расхождений.
			Пример запуска процедуры: exec sp_report_1 @date_from = '2017-06-01', @date_to = '2017-06-30', @good_group_name = N'Биологически активные добавки'
			 
		2. В результат процедуры необходимо добавить показатели: 
				-Средняя цена закупки руб., без НДС
				-Маржа руб. без НДС
				-Наценка % без НДС
				
		3. Добавить возможность фильтрации по нескольким группам товаров одновременно. 
			Пример входных данных: 'Биологически активные добавки,Косметические средства'
			Пример запуска процедуры после модернизации: exec sp_report_1 @date_from = '2017-06-01', @date_to = '2017-06-30', @good_group_name = 'Биологически активные добавки,Косметические средства'
			
		
		
	*/
		
	declare @date_from_int int
	declare @date_to_int int
	declare @newStr varchar
	set @date_from_int = (select top 1 did from dbo.dim_date where d = @date_from )
	set @date_to_int = (select top 1 did from dbo.dim_date where d = @date_to )
	/*set @newStr = (select  replace(@good_group_name,',','AND group_name=')) */
	

SELECT 
		d.d as [Дата]
        , s.store_name as [Аптека]
        , g.group_name as [Группа товара]
		, g.good_name as [Название товара]
        , SUM(f.quantity) as [Продажи шт.]
        , SUM(f.sale_grs) as [Продажи руб., с НДС]
        , sum(f.cost_grs) as [Закупка руб., с НДС]
        , (sum(f.cost_net)/NULLIF(SUM(f.quantity),0)) as [Средняя цена закупки руб., без НДС]
        , (SUM(f.sale_net)-SUM(f.cost_net)) as [Маржа руб. без НДС]
        , ((SUM(f.sale_net)-SUM(f.cost_net))/(NULLIF(SUM(f.cost_net),0))*100) as [Наценка % без НДС]
		,((SUM(f.sale_grs)-SUM(f.cost_grs))/(NULLIF(SUM(f.cost_grs),0))*100) as [Наценка % c НДС]
FROM [dbo].[fct_cheque] as f
        LEFT JOIN (SELECT DISTINCT cash_register_id FROM dim_cash_register) as cr
        on f.cash_register_id=cr.cash_register_id
        LEFT JOIN [dbo].[dim_date] as d
        ON d.did=f.date_id
        LEFT JOIN (SELECT DISTINCT good_id,good_name,group_id,group_name
        FROM dim_goods) as g
        on f.good_id=g.good_id
        LEFT JOIN dim_stores as s
        on s.store_id=f.store_id
    where did BETWEEN @date_from_int AND  @date_to_int
        and g.group_name= @good_group_name
		 GROUP BY d.d
        , s.store_name 
        , g.group_name
		, g.good_name
		order by [Наценка % c НДС];			
		
END
