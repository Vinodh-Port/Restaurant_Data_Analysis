

Select Top 10 * From Menu;

Select Top 10 * From Customers;

Select Top 10 * From Billing;

-- Tables count chudataniki

Select Count(*) As MenuCount From Menu;

Select Count(*) As BillingCount From Billing;

Select Count(Distinct CustomerID) As CustomersCount From Customers;

-- Total_ItemPrice correct unnavi and correct lenivi chuddam

Select
	B.OrderID,
	B.FoodItemID,
	B.FoodItemName,
	B.Total_ItemsPrice
From Billing B
Join Menu M On B.FoodItemID = M.FoodItemID
Where B.Total_ItemsPrice = (B.Quantity) * (M.ItemPrice);

-- Negative values emina unnayemo chudataniki

Select
	OrderID,
	Quantity,
	Total_ItemsPrice
From Billing
Where Total_ItemsPrice <= 0 Or Quantity <= 0;

-- Checking for Orphan records - ante if Billing table lo CustomerID undi but Customers table lo ah ID ledu anuko alanti records ni orphan records antaru so ala undakudadu

Select
	*
From Billing B
Left Join Customers C On B.CustomerID = C.CustomerID
Where C.CustomerID Is Null;

-- Total Order, Total Bill amount and Avg Bill Amount chudali ante

	-- Total
			Select
				COUNT(OrderID) As TotalOrders,
				Sum(Total_ItemsPrice) As TotalBillAmount,
				AVG(Total_ItemsPrice) As AvrgBillAmount
			From Billing;

	-- Food Item ni base cheskuni
			
			Select
				FoodItemName,
				COUNT(OrderID) As TotalOrders,
				Sum(Total_ItemsPrice) As TotalBillAmount,
				AVG(Total_ItemsPrice) As AvrgBillAmount
			From Billing
			Group By FoodItemName
			Order By TotalOrders;

-- Month on Month orders and sale amount data chudali anukunte

Select
	DateName(YEAR, Cast(OrderDate As Date)) As Year,
	Left(DateName(MONTH, Cast(OrderDate As Date)), 3) As Month, -- If manam left use cheyyakunda only mnth lo 3 letters eh dsplay cheyyali anukunte then "Format(Cast(OrderDate As Date), 'MMM')" Ala rayachu
	Count(OrderID) As TotalOrders,
	Sum(Total_ItemsPrice) As SaleAmount
From Billing
Group By DateName(YEAR, Cast(OrderDate As Date)), DateName(MONTH, Cast(OrderDate As Date)), Month(Cast(OrderDate As Date)) -- Group By lo "Rollup" ani use chesthe output lo total and grand total osthayi
Order By Month(Cast(OrderDate As Date));

-- New customers and repeated customers ni chudataniki

-- Only repeated customers anthy no Sale value
			Select
				CustomerID,
				CustomerName,
				Count(CustomerID) As RepetitiveCount
			From Customers
			Group By CustomerID, CustomerName
			Having Count(CustomerID) > 1
			Order By RepetitiveCount DESC;

-- Ikkada repeated customers tho paatu Sale kuda calculate chestunnam and ikkada manam CTE use chesam enduku ante if oke dantlo manam sum kuda chesthe adi multiple times sum chestundi

			with UserCount As(
			Select
				CustomerID,
				CustomerName,
				Count(CustomerID) As RepetitiveCount
			From Customers
			Group By CustomerID, CustomerName)
			Select
				U.CustomerID,
				U.CustomerName,
				U.RepetitiveCount,
				Sum(B.Total_ItemsPrice) As SaleAmount
			From UserCount U
			Join Billing B On U.CustomerID = B.CustomerID
			Group By U.CustomerID, U.CustomerName, U.RepetitiveCount
			Order By RepetitiveCount DESC;

-- Repeat aina customers entha new customers entha and valla sale amount entha chudali anukunte
-- Indaka manam already CTE use chesi repeated users tho paatu Sale kanukkunam kadha so ah query ni kuda ippudu inko CTE ga teskuni then ah renditilo nundi manaki kavalsina output tevali
-- Manaki kavalsinadi oka new column adi ma tables lo ledu so appudu manam CASE END ni use chestham appudu ah kotta column lo kavalsina context anedi present chestundi

				-- Ee query lo enni repetitives unnayi and vaati values chudataniki

						with UserCount As(
						Select
							CustomerID,
							CustomerName,
							Count(CustomerID) As RepetitiveCount
						From Customers
						Group By CustomerID, CustomerName),
						CustomerTracking AS(
						Select
							U.CustomerID,
							U.CustomerName,
							U.RepetitiveCount,
							Sum(B.Total_ItemsPrice) As SaleAmount
						From UserCount U
						Join Billing B On U.CustomerID = B.CustomerID
						Group By U.CustomerID, U.CustomerName, U.RepetitiveCount)

						SELECT 
							RepetitiveCount,
							CASE 
								WHEN RepetitiveCount > 1 THEN 'Repeat Customer' 
								ELSE 'New Customer' 
							END AS CustomerType, 
    						COUNT(CustomerID) As TotalCustomersInSegment,
							SUM(SaleAmount) As TotalSegmentSale
						FROM CustomerTracking
						GROUP BY RepetitiveCount
						Order By RepetitiveCount;

			-- Ee query only Repeat and New Customers ni chudataniki ante inka repetitives enni unna kuda anni andulone group aipothai

				with UserCount As(
						Select
							CustomerID,
							CustomerName,
							Count(CustomerID) As RepetitiveCount
						From Customers
						Group By CustomerID, CustomerName),
						CustomerTracking AS(
						Select
							U.CustomerID,
							U.CustomerName,
							U.RepetitiveCount,
							Sum(B.Total_ItemsPrice) As SaleAmount
						From UserCount U
						Join Billing B On U.CustomerID = B.CustomerID
						Group By U.CustomerID, U.CustomerName, U.RepetitiveCount)

						SELECT 
							CASE 
								WHEN RepetitiveCount > 1 THEN 'Repeat Customer' 
								ELSE 'New Customer' 
							END AS CustomerType, 
    						COUNT(CustomerID) As TotalCustomersInSegment,
							SUM(SaleAmount) As TotalSegmentSale
						FROM CustomerTracking
						GROUP BY 
							CASE 
								WHEN RepetitiveCount > 1 THEN 'Repeat Customer' 
								ELSE 'New Customer' 
							END;
	
-- Ye month lo new customers valana and repeated customers valana yenni orders ostunnayi and yentha sale jarugutondi ani telusukuntaniki

with UserCount As(
	Select
		CustomerID,
		CustomerName,
		Count(CustomerID) As RepetitiveCount
		From Customers
		Group By CustomerID, CustomerName),
OrderCount As(
	Select
		Format(Cast(B.OrderDate As Date), 'MMM') As OrderDate,
		Month(Cast(B.OrderDate As Date)) As MonthNum,
		Count(B.OrderID) As Orders,
		Count(Distinct B.CustomerID) As CustomersCount,
		Sum(B.Total_ItemsPrice) As ItemPrice,
		U.RepetitiveCount
	From Billing B
	Join UserCount U On U.CustomerID = B.CustomerID
	Group By Format(Cast(B.OrderDate As Date), 'MMM'), Month(Cast(B.OrderDate As Date)), U.RepetitiveCount)
SELECT
	OrderDate,
	Sum(Orders) As orders,
	Sum(CustomersCount) As CustomersCount,
	Sum(ItemPrice) As TotalAmount,
	CASE 
		WHEN RepetitiveCount > 1 THEN 'Repeat Customers' 
		ELSE 'New Customers' 
	END AS CustomerType
From OrderCount	
Group By 
	OrderDate,
	MonthNum,
	CASE 
		WHEN RepetitiveCount > 1 THEN 'Repeat Customers' 
		ELSE 'New Customers' 
	END
Order by MonthNum;

-- Runnng total ante Jan total then feb lo Jan + Feb total ala unde danni running total antaaru

With TotalValue As
	(Select
		FORMAT(Cast(OrderDate As Date), 'MMM') As OrderDate,
		MONTH(Cast(OrderDate As Date)) As MonthNum,
		Sum(Total_ItemsPrice) AS Sale
	From Billing
	Group By FORMAT(Cast(OrderDate As Date), 'MMM'), MONTH(Cast(OrderDate As Date)))
Select
	OrderDate,
	Sale,
	Sum(Sale) Over(Order By MonthNum) As TotalSale
From TotalValue;

-- Month wise top 2 undevi chudataniki

With Ranking As(
	Select
		OrderID,
		CustomerID,
		Total_ItemsPrice,
		FoodItemName,
		Format(Cast(OrderDate AS Date), 'MMM') As OrderDate,
		Month(Cast(OrderDate As Date)) As MonthNum,
		DENSE_RANK() Over(Partition By Format(Cast(OrderDate AS Date), 'MMM') Order By Total_ItemsPrice DESC) As RankNum
	From Billing)
Select
	OrderDate,
	OrderID,
	CustomerID,
	FoodItemName,
	Total_ItemsPrice AS Sale,
	RankNum
From Ranking
Where RankNum <=2
Order By 
	MonthNum,
	RankNum

-- Null values unte ISNull and Coalesce use chesi avi fill cheyyataniki
	
	-- IsNull anedi only okka column ki matrame work avtundi if CustomerName column lo edina Null or empty unte then Guest ani istundi
	
		Select
			CustomerID,
			IsNull(CustomerName, 'Guest') AS CustomerName
		From
		Customers;

	-- Coalesce lo Multiple columns check chestundi ante for example manadeggara 6 columns unnai anuko and operation anedi row wise jarugutundi so
	-- Row 1: 1st column lo data unte, direct ga danni pick cheskuni migatha 5 columns ni vadilesthundi.
	-- Row 4: 1st nundi 4th columns varaku NULL unna, 5th column lo value unte, daanne teeskuntundi.
	-- Row 75 or more: Enni columns check chesina anni NULLs unte, chivarlo manam quotations '..' lo ye text ledha number default ga isthamo (like 'Guest' or 'Unknown'), daanne output ga display chesthundhi.

		Select
			CustomerID,
			Coalesce(FoodItemID, FoodItemName, Quantity, 'Guest') AS CustomerName
		From
		Billing;

-- Row_Number() ni assign cheyyataniki
	-- Row_Number() lo manam Over(Order By) matrame use chesthe then annitiki varusaga nums istundi     

		SELECT 
			OrderID, 
			FoodItemName, 
			Total_ItemsPrice,
			ROW_NUMBER() OVER (ORDER BY OrderDate ASC) AS SerialNo
		FROM Billing;

	-- Row_Number() lo manam Over(Partition By ... Order By) ikkada Partition ni extra ga use chestunnam ante so ee usecase lo CustomerID ni base cheskuni partition chestunnam
	-- Ante customer1 ki 4 orders unte then ah 4 ki nums istundi then customer2 ki veltundi ala andariki assign avthayi

		SELECT 
			CustomerID, 
			OrderID, 
			FoodItemName, 
			OrderDate,
			ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY OrderDate ASC) AS CustVisitSeq
		FROM Billing
		Order By Month(Cast(OrderDate As Date)) ASC;

-- Item price ni base cheskuni categorise cheyyatam and ah categories count and sum chudatam

With OrderCategory AS(
Select
	OrderID,
	FoodItemName,
	Total_ItemsPrice,
	Case
		When Total_ItemsPrice > 500 Then 'Premium Order'
		When Total_ItemsPrice Between 150 And 500 Then 'Average Order'
		Else 'Budget Order'
	End As PriceCategory
From Billing)
Select
	ISNULL(PriceCategory, 'Total') As PriceCategory,
	Count(OrderID) As TotalOrders,
	Sum(Total_ItemsPrice) As TotalSale
From OrderCategory
Group By Rollup(PriceCategory); -- Rollup use chesthe total ostundi but Row name lo Null ani vastundi so paina Isnull use chesam. and ee rollup ni manam max use cheyyamu but telusukuntaniki use chesa

-- Subqueries use cheyatam yela

	-- Avrg value kante ekkuva > or takkuva < or equal = unde data kavali anukunte Where clause lo subquery ni add chestham
		
		Select
			OrderID,
			FoodItemName,
			Total_ItemsPrice
		From Billing
		Where Total_ItemsPrice > (Select Avg(Total_ItemsPrice) From Billing);

	-- Output columns lone edina data undali comparison ki anukunte select lone subquery use chestham

		SELECT 
			OrderID,
			CustomerID
			Total_ItemsPrice,
			(SELECT AVG(Total_ItemsPrice) FROM Billing) AS OverallAverage
		FROM Billing;

		SELECT 
			OrderID,
			CustomerID
			Total_ItemsPrice,
			(SELECT Max(Total_ItemsPrice) FROM Billing) AS MaxBill
		FROM Billing;

		SELECT 
			OrderID,
			CustomerID
			Total_ItemsPrice,
			(SELECT Min(Total_ItemsPrice) FROM Billing) AS MinBill
		FROM Billing;
		
	-- ila aggregations kuda use cheyyachu

		SELECT 
			OrderID,
			CustomerID
			Total_ItemsPrice,
			((SELECT Max(Total_ItemsPrice) FROM Billing)-(SELECT Min(Total_ItemsPrice) FROM Billing)) AS MaxMinDiff
		FROM Billing;

	-- Paina unnavi anni independent subqueries ante lopala unna query ki byta unna query ki link undadu
	-- But ippudu corelated subqueries chuddam ante rendu queries ki relation untundi
		
		Select
			O.OrderID,
			O.CustomerID,
			O.Total_ItemsPrice,
			(Select
				Avg(I.Total_ItemsPrice)
			From Billing I
			Where I.CustomerID = O.CustomerID
			) As CustomerAvgBill
		From Billing O;
						-- Same subquery output eh vastundi but CTE model lo 

							With BillAvrg AS
								(Select
									CustomerID,
									Avg(Total_ItemsPrice) As CustomerAvrg,
									Count(CustomerID) As CustomerCount
								From Billing
								Group By CustomerID)
								Select
									B.OrderID,
									B.CustomerID,
									B.FoodItemName,
									B.Total_ItemsPrice,
									A.CustomerAvrg,
									A.CustomerCount
								From Billing B
								Join BillAvrg A On A.CustomerID = B.CustomerID;
	
		Select
			O.OrderID,
			O.CustomerID,
			O.FoodItemName,
			(Select Count(I.OrderID) From Billing I
			Where I.CustomerID = O.CustomerID) As CustomerTotalOrdersCount
		From Billing O;

-- Window aggregate functions use chesi group or join cheyyalsina avsaram lekunda and CTE or subquery lekunda pakkana columns lo aggregations cheyachu

	Select
		OrderID,
		CustomerID,
		FoodItemName,
		Total_ItemsPrice,
		Sum(Total_ItemsPrice) Over (Partition By FoodItemName) As TotalFoodSale,
		Avg(Total_ItemsPrice) Over(Partition By FoodItemName) As AvrgFoodPrice
	From Billing;

	SELECT 
		OrderID,
		CustomerID,
		Total_ItemsPrice,
		COUNT(OrderID) OVER(PARTITION BY CustomerID) AS CustomerTotalOrders,
		AVG(Total_ItemsPrice) OVER(PARTITION BY CustomerID) AS CustomerAvgBill
	FROM Billing;

-- Views ni create cheddam View ante oka virtual table which means manaki unna main tables anniti nundi inko table create cheskuntam and danni kuda inko table laga use cheskochu
	-- ee view tables anevi oka summary laga use avthayi ante if manam oka report ni prathisaari generate cheyyakunda oksari view ni create cheskunte prathi sari adeuse cheskochu
		-- 1. Total billing report kosam

			Create Or Alter View BillingReport As
				Select
					B.OrderID,
					B.CustomerID,
					Concat(B.CustomerID, ' - ', Coalesce(C.CustomerName, 'Guest')) As CustomerUID,
					Coalesce(C.CustomerName, 'Guest') As CustomerName,
					B.FoodItemID,
					B.FoodItemName,
					Concat(B.OrderID, ' # ', B.FoodItemName) As OrderDetailsKey,
					B.Quantity,
					B.Total_ItemsPrice,
					Sum(B.Total_ItemsPrice) Over(Partition By B.CustomerID) As CustomerTotalSpend,
					Avg(B.Total_ItemsPrice) Over(Partition By B.CustomerID) As CustomerAvrgSpend,
					Max(B.Total_ItemsPrice) Over(Partition By B.CustomerID) As CustomerMaxOrderPrice,
					Min(B.Total_ItemsPrice) Over(Partition By B.CustomerID) As CustomerMinOrderPrice,
					Count(B.OrderID) Over(Partition By B.CustomerID) As CustomerVisits,
					B.OrderDate,
					Year(B.OrderDate) As OrderYear,
					Month(B.OrderDate) As OrderMonth,
					Day(B.OrderDate) As OrderDay,
					Format(Cast(B.OrderDate As Date), 'MMM') As OrderMonthName
				From Billing B
				Left Join Customers C On B.CustomerID = C.CustomerID
				Group by 
					B.OrderID,
					B.CustomerID,
					C.CustomerName,
					B.FoodItemID,
					B.FoodItemName,
					B.Quantity,
					B.Total_ItemsPrice,
					B.OrderDate;

		-- 2. Daily Business summary kosam
			
			Create Or Alter View DailyBusinessSummary As
				Select
					OrderDate,
					Count(Distinct OrderID) As TotalOrders,
					SUM(Quantity) As TotalItemsSold,
					Sum(Total_ItemsPrice) As TotalRevenue,
					Year(OrderDate) As OrderYear,
					Month(OrderDate) As OrderMonth,
					Day(OrderDate) As OrderDay,
					Format(Cast(OrderDate As Date), 'MMM') As OrderMonthName
				From Billing
				Group By OrderDate;
				
		-- 3. Menu performance chudataniki
			
			Create Or Alter View MenuPerformanceReport As
				Select
					M.FoodItemID,
					M.FoodItemName,
					M.ItemPrice,
					Sum(B.Quantity) As QuantityOrdered,
					Sum(B.Total_ItemsPrice) As TotalRevenueGenerated
				From Menu M
				Left Join Billing B On M.FoodItemID = B.FoodItemID
				Group By M.FoodItemID, M.FoodItemName, M.ItemPrice;
	
Select * From BillingReport
Select * From DailyBusinessSummary
Select * From MenuPerformanceReport













































