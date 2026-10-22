CREATE DATABASE IF NOT EXISTS Telecom_Expense_Report;

Use Telecom_Expense_Report;

SELECT * FROM telecom_data;

-- Query 1: Check the dataset
SELECT Count(*) As Total_Records,
       COUNT(DISTINCT `Number`) As Unique_Lines,
       COUNT(DISTINCT `Billing Month`) As Billing_Period
From telecom_data;

-- Query 2: Monthly telecom spend
SELECT date_format(STR_TO_DATE(`Billing Month`, '%m/%d/%y'), '%M %Y') As Billing_Monthly,
				  count(distinct `Number`) As Total_Lines,
                  Round(SUM(`Plan Charges`), 2) As Plan_Charges,
                  Round(SUM(`Overages`), 2) As Total_Ovg,
                  Round(SUM(`Total_Charges`), 2) As Monthly_Telecom_Spend,
                  Round(SUM(`Data_Usage_GB`), 2) As Total_Data_Usage_GB
FROM telecom_data
GROUP BY Billing_Monthly
ORDER BY MIN(STR_TO_DATE(`Billing Month`, '%m/%d/%y'));

-- 3- Month-over-month spending change
With MonthlySpend AS(
Select 
STR_TO_DATE(DATE_FORMAT(
 STR_TO_DATE(`Billing Month`, '%m/%d/%Y'), '%Y-%m-01'), '%Y-%m-%d') As Billing_Monthly,
         SUM(`Total_Charges`) As Total_Charges 
         From telecom_data
         GROUP BY Billing_Monthly),
SpendTrend As(
Select Billing_Monthly, Total_Charges, LAG(Total_Charges) Over(
Order By Billing_Monthly) As Previous_Month_Charges
From MonthlySpend)
SELECT DATE_FORMAT(Billing_Monthly, '%b %Y') AS Billing_Monthly, 
		ROUND(Total_Charges, 2) As Total_Charges,
		ROUND(Previous_Month_Charges, 2)As Previous_Month_Charges,
		ROUND((Total_Charges - Previous_Month_Charges)/
		Nullif(Previous_Month_Charges, 0)* 100, 2) As Change_Percentage
From SpendTrend
ORDER BY STR_TO_DATE(
    CONCAT('01 ', Billing_Monthly),
    '%d %b %Y'
);

-- 4- Find the plans with the highest expenses
Select Plan_Name, Count(distinct number) As Total_Lines,
					Round(Sum('Plan Charges'), 2) As Plan_Charges,
                    Round(Sum(Overages), 2) As Total_Ovg,
                    Round(Sum(Total_Charges), 2) As Total_Charge
From telecom_data
Group By Plan_Name
Order By Total_Charge DESC;

-- 5- Find the top 10 high-cost lines
Select `Number`,`Device_Type`,`Status`,`Plan_Name`,
              Round(`Plan Charges`, 2) As Plan_Charges,
              Round(`Domestic_Overage`, 2) As Total_Dom_Ovg,
              Round(`International_Overage`, 2) As Total_Int_Ovg,
              Round(`Total_Charges`, 2) As Total_Charges
From telecom_data
Order By `Total_Charges` DESC Limit 10;

-- 6- Analyze domestic and international overages
SELECT DATE_FORMAT(STR_TO_DATE(`Billing month`, '%m/%d/%Y'), '%b %y') As Billing_Month,
			Round(Sum(Domestic_Overage), 2) As Total_Dom_Ovg,
            Round(Sum(International_Overage), 2) As Total_Intl_Ovg,
            Round(Sum(Overages), 2) As Total_Ovg
From telecom_data
Group By DATE_FORMAT(STR_TO_DATE(`Billing month`, '%m/%d/%Y'), '%b %y')
Order By MIN(STR_TO_DATE(`Billing Month`, '%m/%d/%Y'));

-- 7- Compare spending by line status
SELECT Status, Count(distinct `Number`) As Total_Lines,
			Round(Sum(Total_Charges), 2) As Total_Charges,
            Round(avg(Total_Charges), 2) As Avg_Charges
From telecom_data
Group By Status
Order By Avg_Charges DESC;

-- 8- Compare pooled and non-pooled lines
SELECT Pooling_Status, Count(distinct `Number`) As Total_Lines,
		              Round(Sum(Data_Usage_GB), 2) As Total_Data_Usage_GB,
					   Round(Sum(Overages), 2) As Total_Ovg,
                     Round(Sum(Total_Charges), 2) As Total_Charges
From telecom_data
Group By Pooling_Status
Order By  Total_Charges DESC;





	
 

