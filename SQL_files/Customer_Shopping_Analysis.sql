CREATE DATABASE CustomerAnalysis;

USE CustomerAnalysis;

DROP TABLE IF EXISTS  Customer_Shopping_Analysis;

CREATE TABLE Customer_Shopping_Analysis(
			Customer_ID INT,
            Age	INT,
            Gender VARCHAR(10),
            Item_Purchased VARCHAR(50),
            Category VARCHAR(50),
            Purchase_Amount_USD INT,
            Location VARCHAR(50),
            Size VARCHAR(5),
            Color VARCHAR(50),
            Season VARCHAR(50),
            Review_Rating FLOAT,
            Subscription_Status VARCHAR(10),
            Shipping_Type VARCHAR(50),
            Discount_Applied VARCHAR(10),
            Promo_Code_Used	VARCHAR(10),
            Previous_Purchases INT,
            Payment_Method VARCHAR(50),
            Frequency_of_Purchases VARCHAR(50)
);

SELECT * FROM Customer_Shopping_Analysis; -- checking the data

--------------------------------------------------------------------------------------------------
/* **Customer Demographics and Segmentation** */
--------------------------------------------------------------------------------------------------
-- Task: 1. **Identify the top 5 locations with the highest number of customers.**
SELECT
	Location,
    COUNT(Customer_ID) AS Customer_Count
FROM customer_shopping_analysis
GROUP BY Location
ORDER BY Customer_Count DESC
LIMIT 5;
-----------------------------------------------------------------------------------------------------
-- Task: 2. **Find the age group (e.g., 20-30, 31-40) that generates the highest revenue.**
SELECT
	CASE
		WHEN AGE BETWEEN 20 AND 30 THEN '20-30'
        WHEN AGE BETWEEN 30 AND 40 THEN '30-40'
        WHEN AGE BETWEEN 40 AND 50 THEN '40-50'
        WHEN AGE BETWEEN 50 AND 60 THEN '50-60'
        WHEN AGE BETWEEN 60 AND 70 THEN '60-70'
        ELSE '70+'
	END AS Age_Group,
	SUM(Purchase_Amount_USD) AS Highest_Revenue_USD
FROM customer_shopping_analysis
GROUP BY Age_Group
ORDER BY Highest_Revenue_USD DESC
LIMIT 1;
----------------------------------------------------------------------------------------------------
-- Task: 3. **Count the number of customers by gender in each state.**

SELECT
	COUNT(Customer_ID) AS Number_of_Customers,
    Gender,
    Location AS State
FROM customer_shopping_analysis
GROUP BY  Gender,Location
ORDER BY State, Number_of_Customers DESC;
-----------------------------------------------------------------------------------------------------
-- Task: 4. **Determine the percentage of customers with subscriptions versus non-subscriptions.**
-- Method - 1:
WITH Customer_with_subscription AS(
		SELECT
		 	COUNT(Subscription_Status) AS Subscription_count
		FROM customer_shopping_analysis
        WHERE Subscription_Status = 'Yes'),
Customer_with_out_subscription AS (
	SELECT
		COUNT(Subscription_Status) AS No_Subscription_count
    FROM customer_shopping_analysis
    WHERE Subscription_Status = 'No')
 SELECT
	cs.Subscription_count,
    cos.No_Subscription_count,
    ROUND( cs.Subscription_count / (cs.Subscription_count + cos.No_Subscription_count)*100, 2) AS Subscription_percentage,
    ROUND( cos.No_Subscription_count / (cs.Subscription_count + cos.No_Subscription_count)*100, 2) AS No_Subscription_percentage
 FROM Customer_with_subscription cs, Customer_with_out_subscription cos;   
 
 -- Method - 2
 SELECT
	SUM(CASE WHEN Subscription_Status = 'YES' THEN 1 ELSE 0 END) AS Subscription_count,
    SUM(CASE WHEN Subscription_Status = 'NO' THEN 1 ELSE 0 END) AS No_Subscription_percentage,
    ROUND(SUM(CASE WHEN Subscription_Status = 'YES' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS Subscription_percentage,
    ROUND(SUM(CASE WHEN Subscription_Status = 'NO' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS No_Subscription_percentage
 FROM customer_shopping_analysis;
 ------------------------------------------------------------------------------------------------------------------------------------
-- Task: 5. **Segment customers based on their purchase frequency (e.g., Weekly, Monthly, Quarterly).**
SELECT
	Frequency_of_Purchases,
	COUNT(Customer_ID) AS Number_of_customers
FROM customer_shopping_analysis
GROUP BY Frequency_of_Purchases
ORDER BY Number_of_customers DESC;
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* **Sales Performance** */
-------------------------------------------------------------------------------------------------
-- Task: 6. **Calculate the total sales for each product category.**
SELECT
	Category,
    SUM(Purchase_Amount_USD) AS Total_sales_USD,
    COUNT(*) AS Total_Items_Sold
FROM customer_shopping_analysis
GROUP BY Category
ORDER BY Total_sales_USD DESC;
--------------------------------------------------------------------------------------------------
-- Task: 7. **Find the top 10 highest-selling products based on the number of purchases.**
SELECT
	Item_Purchased AS Product_Name,
    COUNT(*) AS Number_Of_Purchases
FROM customer_shopping_analysis
GROUP BY Item_Purchased
ORDER BY Number_Of_Purchases DESC
LIMIT 10;
--------------------------------------------------------------------------------------------------
-- Task: 8. **Determine the average purchase amount by category.**
SELECT
	Category,
    ROUND( AVG(Purchase_Amount_USD),2) AS Average_Purchace_Amount_USD
FROM customer_shopping_analysis
GROUP BY Category
ORDER BY Average_Purchace_Amount_USD DESC;
--------------------------------------------------------------------------------------------------
-- Task: 9. **Identify the products that have never been purchased.**
WITH Products_List AS (
	SELECT
		DISTINCT Item_Purchased AS Product
    FROM customer_shopping_analysis)
SELECT 
	pl.Product,
    csa.Category
FROM Products_List pl
LEFT JOIN customer_shopping_analysis csa
ON csa.Item_Purchased = pl.Product
WHERE csa.Category IS NULL;
----------------------------------------------------------------------------------------------------
-- Task: 10. **Analyze revenue contributions by season (Spring, Summer, Fall, Winter).**
SELECT
	Season,
    SUM(Purchase_Amount_USD) AS Revenue_USD,
    ROUND( SUM(Purchase_Amount_USD) / (SELECT SUM(Purchase_Amount_USD) FROM customer_shopping_analysis) * 100, 2) AS Revenue_Percentage
FROM customer_shopping_analysis
GROUP BY Season
ORDER BY Revenue_USD DESC;
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/* **Customer Behavior** */
------------------------------------------------------------------------------------------------
-- Task: 11. **Find customers who have made more than 50 previous purchases.**
SELECT
	Customer_ID,
    Previous_Purchases
FROM customer_shopping_analysis
WHERE Previous_Purchases >= 50;
--------------------------------------------------------------------------------------------------
-- Task: 12. **Identify customers who use promo codes most frequently.**
SELECT
	Customer_ID,
    COUNT(*) AS Promo_Code_Used_count
FROM customer_shopping_analysis
WHERE Promo_Code_Used = 'Yes'
GROUP BY Customer_ID;
-------------------------------------------------------------------------------------------------
-- Task: 13. **Calculate the average number of previous purchases for subscription-based customers.**
SELECT
	COUNT(Previous_Purchases) AS Total_Count,
    ROUND( AVG(Previous_Purchases),2) AS Avg_of_Previous_purchases
FROM customer_shopping_analysis
WHERE Subscription_Status = 'YES';
------------------------------------------------------------------------------------------------------
-- Task: 14. **Determine the average review rating for each product category.**
SELECT
	Category,
    ROUND( AVG(Review_Rating), 2) AS Avg_Rating
FROM customer_shopping_analysis
GROUP BY Category
ORDER BY Avg_Rating DESC;
------------------------------------------------------------------------------------------------
-- Task: 15. **Identify customers with consistently low review ratings (e.g., average rating < 3).**
SELECT
	Customer_ID,
    Review_Rating,
    ROUND(AVG(Review_Rating),2) AS Avg_Rating
FROM customer_shopping_analysis
GROUP BY Customer_ID,Review_Rating
HAVING Avg_Rating < 3.0;
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
/* **Shipping and Logistics** */
---------------------------------------------------------------------------------------------------
-- Task: 16. **Count the number of purchases by shipping type (e.g., Free Shipping, Express, etc.).**
SELECT
	Shipping_Type,
    COUNT(*) AS Number_Of_Purchases
FROM customer_shopping_analysis
GROUP BY Shipping_Type
ORDER BY Number_Of_Purchases DESC;
--------------------------------------------------------------------------------------------------
-- Task: 17. **Identify the shipping type with the highest average purchase amount.**
SELECT
	Shipping_Type,
	ROUND( AVG(Purchase_Amount_USD), 2) AS Average_Purchase_Amount_USD
FROM customer_shopping_analysis
GROUP BY Shipping_Type
ORDER BY Average_Purchase_Amount_USD DESC
LIMIT 1;
-----------------------------------------------------------------------------------------------
-- Task: 18. **Determine the most popular shipping type in each state.**
WITH Shipping_count AS(
			SELECT
				Location,
				Shipping_Type,
				COUNT(Shipping_Type) AS Shipping_Type_Count
			FROM customer_shopping_analysis
			GROUP BY Location, Shipping_Type
			ORDER BY Location, Shipping_Type_Count DESC)
SELECT
	SC.Location AS State,
    SC.Shipping_Type AS Popular_Shipping_Type,
	SC.Shipping_Type_Count AS Popular_Shipping_Type_Count
FROM Shipping_count SC
JOIN (SELECT
		Location,
        MAX(Shipping_Type_Count) AS Popular_Shipping_Type
        FROM Shipping_count
        GROUP BY Location) AS Getting_Max_Counts
ON SC.Location = Getting_Max_Counts.Location
AND SC.Shipping_Type_Count = Getting_Max_Counts.Popular_Shipping_Type
ORDER BY SC.Location;
--------------------------------------------------------------------------------
-- Task: 19. **Analyze how discounts impact the choice of shipping type.**
SELECT
	Shipping_Type,
    SUM(CASE WHEN Discount_Applied = 'YES' THEN 1 ELSE 0 END) AS Count_of_orders_with_Discount,
	COUNT(*) AS Total_Orders,
    ROUND(SUM(CASE WHEN Discount_Applied = 'YES' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS Discount_impact_percentage_over_Shipping_Type
FROM customer_shopping_analysis
GROUP BY Shipping_Type
ORDER BY Count_of_orders_with_Discount DESC;
-----------------------------------------------------------------------------------
-- Task: 20. **Find locations with the highest demand for next-day air shipping.**
SELECT
	Location,
	COUNT(*) AS Count_next_day_air_shipping
FROM customer_shopping_analysis
WHERE Shipping_Type = 'next day air'
GROUP BY Location
ORDER BY Count_next_day_air_shipping DESC;
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
/* **Discounts and Promotions** */
----------------------------------------------------------------------------------
-- Task: 21. **Count the number of purchases where discounts were applied.**
SELECT
	COUNT(*) AS No_Of_Purchases
FROM customer_shopping_analysis
WHERE Discount_Applied = 'YES';
--------------------------------------------------------------------------------------
-- Task: 22. **Calculate the total revenue lost due to discounts.**
SELECT
	Discount_Applied,
    ROUND( AVG(Purchase_Amount_USD), 2) AS AVG_Purchased_Amount
FROM customer_shopping_analysis
GROUP BY Discount_Applied;
 /* Yes	59.28
    No	60.13 */
-- So, the average purchase amount of discount applied is less than non discounted sales as per over all sales.
-- Let's try to check for item type / product type.
SELECT
	Category,
	Discount_Applied,
    ROUND( AVG(Purchase_Amount_USD), 2) AS AVG_Purchased_Amount
FROM customer_shopping_analysis
GROUP BY Category, Discount_Applied
ORDER BY Category, Discount_Applied DESC;

/* Accessories	Yes	58.49
Accessories	No	60.89
Clothing	Yes	59.75
Clothing	No	60.22
Footwear	Yes	61.80
Footwear	No	59.08
Outerwear	Yes	55.32
Outerwear	No	58.66 */
-- Out of 4 categories 3 categories have less avegrage amount where the discount applied. If there is total items sold per each category it may change.
WITH Category_Revenue AS (
    SELECT
        Category,
        Discount_Applied,
        COUNT(*) AS Items_Sold,
        ROUND(SUM(Purchase_Amount_USD), 2) AS Total_Revenue,
        ROUND(AVG(Purchase_Amount_USD), 2) AS Avg_Purchase_Amount
    FROM customer_shopping_analysis
    GROUP BY Category, Discount_Applied
)
SELECT
    c1.Category,
    ROUND((c2.Avg_Purchase_Amount * c1.Items_Sold) - c1.Total_Revenue, 2) AS Estimated_Revenue_Lost
FROM Category_Revenue c1
JOIN Category_Revenue c2
  ON c1.Category = c2.Category
WHERE c1.Discount_Applied = 'Yes' AND c2.Discount_Applied = 'No';
/* Clothing	341.82
Footwear	-704.28
Outerwear	481.04
Accessories	1303.27 */
-- If we include the items sold per category then Clothing, Outerwear, Accessories are running in loss due to discounts and 
-- Footwear is running in profit.
----------------------------------------------------------------------------------------------------------------------------
-- Task: 23. **Identify the most effective promo codes based on their usage count.**
----------------------------------------------------------------------------------------------------------------------------
-- Task: 24. **Determine if customers who use promo codes spend more on average than those who do not.**
SELECT
    Promo_Code_Used,
    ROUND( AVG(Purchase_Amount_USD), 2) AS Average_Purchase_Amount_USD
FROM customer_shopping_analysis
GROUP BY  Promo_Code_Used
ORDER BY Average_Purchase_Amount_USD;
--------------------------------------------------------------------------------------------------------------
-- Task: 25. **Analyze the correlation between discount usage and purchase frequency.**
WITH Customer_Revenue AS (
    SELECT
        Customer_ID,
        COUNT(*) AS Purchase_Frequency,
        SUM(Purchase_Amount_USD) AS Total_Revenue
    FROM customer_shopping_analysis
    GROUP BY Customer_ID
)
SELECT
    csa.Discount_Applied,
    ROUND(AVG(cr.Purchase_Frequency), 2) AS Avg_Purchase_Frequency,
    ROUND(AVG(cr.Total_Revenue), 2) AS Avg_Total_Revenue
FROM customer_shopping_analysis csa
JOIN Customer_Revenue cr
    ON csa.Customer_ID = cr.Customer_ID
GROUP BY csa.Discount_Applied
ORDER BY Avg_Purchase_Frequency DESC;
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
/* **Payment Insights** */
----------------------------------------------------------------------------------
-- Task 26. **Calculate the total revenue generated by each payment method (e.g., Credit Card, PayPal).**
SELECT
	Payment_Method,
    SUM(Purchase_Amount_USD) AS Total_Revenue_Per_Payment_Method
FROM customer_shopping_analysis
GROUP BY Payment_Method
ORDER BY Total_Revenue_Per_Payment_Method DESC;
----------------------------------------------------------------------------------------
 -- Task: 27. **Identify the most popular payment method for high-value purchases (e.g., > $100).**
SELECT
	Payment_Method,
    COUNT(*) AS Total_Sales,
    DENSE_RANK() OVER (ORDER BY COUNT(*) DESC, Payment_Method ASC) AS Popular_Payment_Method_Ranking
FROM customer_shopping_analysis
WHERE Purchase_Amount_USD >= 75.0
GROUP BY Payment_Method;
---------------------------------------------------------------------------------------------------
-- Task: 28. **Determine the average purchase amount for each payment method.**
SELECT
	Payment_Method,
    AVG(Purchase_Amount_USD) AS Average_Payment_USD
FROM customer_shopping_analysis
GROUP BY Payment_Method
ORDER BY Average_Payment_USD DESC;
---------------------------------------------------------------------------------------------------
-- Task: 29. **Find the percentage of purchases made using cash versus digital payment methods.**
SELECT 
	COUNT(*) AS Total_purchases,
    SUM(CASE WHEN Payment_Method = 'Cash' THEN 1 ELSE 0 END) AS Count_Of_Cash_purchases,
    SUM(CASE WHEN Payment_Method <> 'Cash' THEN 1 ELSE 0 END) AS Count_Of_Digital_purchases,
    ROUND( (SUM(CASE WHEN Payment_Method = 'Cash' THEN 1 ELSE 0 END) / COUNT(*)) * 100,2) AS Cash_Payment_Percentage,
    ROUND( SUM(CASE WHEN Payment_Method <> 'Cash' THEN 1 ELSE 0 END) / COUNT(*)*100, 2) AS Digital_Payment_Percentage
FROM customer_shopping_analysis;
----------------------------------------------------------------------------------------------------
-- Task: 30. **Analyze payment method preferences by age group.**
SELECT
	CASE
		WHEN AGE BETWEEN 20 AND 30 THEN '20-30'
        WHEN AGE BETWEEN 30 AND 40 THEN '30-40'
        WHEN AGE BETWEEN 40 AND 50 THEN '40-50'
        WHEN AGE BETWEEN 50 AND 60 THEN '50-60'
        WHEN AGE BETWEEN 60 AND 70 THEN '60-70'
        ELSE '70+'
	END AS Age_Group,
	Payment_Method,
    COUNT(Payment_Method) AS Count_Of_Payment_Method
FROM customer_shopping_analysis
GROUP BY Age_Group, Payment_Method
ORDER BY Age_Group,Count_Of_Payment_Method DESC, Payment_Method;
----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
/* **Product Trends** */
----------------------------------------------------------------------------------------------
-- Task: 31. **Identify the most popular color for each product category.**
WITH Color_Count_cte AS (
					SELECT 
						Category,
						Color,
                        COUNT(*) AS Color_Count
                    FROM customer_shopping_analysis
                    GROUP BY Color, Category
                    ORDER BY Color, Color_Count DESC)
SELECT 
	cc.Category,
	cc.Color AS Popular_Color,
	cc.Color_Count AS Popular_Color_Count
FROM Color_Count_cte cc
JOIN (SELECT 
		Category,
        MAX(Color_Count) AS Popular_Color_Count
	 FROM Color_Count_cte
     GROUP BY Category) AS Getting_Popular_Color
ON cc.Category = Getting_Popular_Color.Category
AND cc.Color_Count = Getting_Popular_Color.Popular_Color_Count
ORDER BY cc.Color_Count DESC;
--------------------------------------------------------------------------------------------------
-- Task: 32. **Analyze the relationship between product size and review ratings.**
SELECT
	Size,
    ROUND( AVG(Review_Rating), 2) AS Average_Review_Ratings
FROM customer_shopping_analysis
GROUP BY Size
ORDER BY Average_Review_Ratings DESC;
---------------------------------------------------------------------------------------------
-- Task: 33. **Find the categories that are most frequently purchased during specific seasons.**
SELECT
	Season,
	Category AS Most_Frequent_Categories,
    COUNT( Category) AS Count_Category
FROM customer_shopping_analysis
GROUP BY Season, Category
ORDER BY Season, Count_Category DESC;
---------------------------------------------------------------------------------------------------
-- Task: 34. **Calculate the average purchase amount for each product size (S, M, L, XL).**
SELECT
	Size AS Product_Size,
    ROUND( AVG(Purchase_Amount_USD),2) AS Average_Purchase_Amount_USD
FROM customer_shopping_analysis
GROUP BY Size
ORDER BY Average_Purchase_Amount_USD DESC;
----------------------------------------------------------------------------------------------------
-- Task: 35. **Determine the categories with the highest review ratings.**
SELECT
	Category,
    ROUND( AVG(Review_Rating), 2) AS Average_Review_Rating
FROM customer_shopping_analysis
GROUP BY Category
ORDER BY Average_Review_Rating DESC;








