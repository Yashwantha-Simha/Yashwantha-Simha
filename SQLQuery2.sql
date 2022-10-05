/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [PortfolioDB].[dbo].[sba_public_data]

  /****** summary of all approved ppp loans  ******/
SELECT
		year(DateApproved) year_approved,
		COUNT(LoanNumber) Number_of_loans,
		SUM (InitialApprovalAmount) Approved_amount,
		AVG (InitialApprovalAmount) Avg_loan_size
  FROM [PortfolioDB].[dbo].[sba_public_data]
    where year(DateApproved) = 2020
  group by year(DateApproved)
union 
  SELECT
		year(DateApproved) year_approved,
		COUNT(LoanNumber) Number_of_loans,
		SUM (InitialApprovalAmount) Approved_amount,
		AVG (InitialApprovalAmount) Avg_loan_size
  FROM [PortfolioDB].[dbo].[sba_public_data]
  where year(DateApproved) = 2021
  group by year(DateApproved);

    /****** summary of all approved ppp loans  ******/
SELECT
		year(DateApproved) year_approved,
		COUNT (distinct OriginatingLender) Number_of_lenders,
		COUNT(LoanNumber) Number_of_loans,
		SUM (InitialApprovalAmount) Approved_amount,
		AVG (InitialApprovalAmount) Avg_loan_size
  FROM [PortfolioDB].[dbo].[sba_public_data]
  group by year(DateApproved);

      /****** TOP Lenders  ******/
	  /*2021*/

SELECT TOP 15
		OriginatingLender,
		COUNT(LoanNumber) Number_of_loans,
		SUM (InitialApprovalAmount) Approved_amount,
		AVG (InitialApprovalAmount) Avg_loan_size
  FROM [PortfolioDB].[dbo].[sba_public_data]
  WHERE year(DateApproved) = 2021
  group by OriginatingLender
  ORDER BY 3 DESC;

  	  /*2020*/
SELECT TOP 15
		OriginatingLender,
		COUNT(LoanNumber) Number_of_loans,
		SUM (InitialApprovalAmount) Approved_amount,
		AVG (InitialApprovalAmount) Avg_loan_size
  FROM [PortfolioDB].[dbo].[sba_public_data]
  WHERE year(DateApproved) = 2020
  group by OriginatingLender
  ORDER BY 3 DESC;

        /****** TOP Borrowing Industry  ******/
		  	  /*2020*/

  SELECT 
		s.Sector,
		COUNT(LoanNumber) Number_of_loans,
		SUM (InitialApprovalAmount) Approved_amount,
		AVG (InitialApprovalAmount) Avg_loan_size
  FROM [PortfolioDB].[dbo].[sba_public_data] p
  inner join [dbo].[sba_naics_sectorcodes] s
  on left(p.NAICSCode,2) = s.lookupcodes
  WHERE year(DateApproved) = 2020
  group by s.Sector
  order  by 3 desc;

    	  /*2021*/

 SELECT 
		s.Sector,
		COUNT(LoanNumber) Number_of_loans,
		SUM (InitialApprovalAmount) Approved_amount,
		AVG (InitialApprovalAmount) Avg_loan_size
  FROM [PortfolioDB].[dbo].[sba_public_data] p
  inner join [dbo].[sba_naics_sectorcodes] s
  on left(p.NAICSCode,2) = s.lookupcodes
  WHERE year(DateApproved) = 2021
  group by s.Sector
  order  by 3 desc;

        /****** percentage of loan each industry has borrowed  ******/
;with cte as (
   SELECT 
		s.Sector,
		COUNT(LoanNumber) Number_of_loans,
		SUM (InitialApprovalAmount) Approved_amount,
		AVG (InitialApprovalAmount) Avg_loan_size
  FROM [PortfolioDB].[dbo].[sba_public_data] p
  inner join [dbo].[sba_naics_sectorcodes] s
  on left(p.NAICSCode,2) = s.lookupcodes
  WHERE year(DateApproved) = 2021
  group by s.Sector
)
select Sector, Number_of_loans, Approved_amount, Avg_loan_size, Approved_amount/SUM(Approved_amount) OVER() * 100 percent_of_totalloanamount
From cte
order by Approved_amount desc;

        /****** percentage of loan forgiven in 2020 ******/

SELECT 
		COUNT(LoanNumber) Number_of_loans,
		SUM (CurrentApprovalAmount) current_Approved_amount,
		AVG (CurrentApprovalAmount) Avg_capproved_size,
		SUM (ForgivenessAmount) Forgiveness_Amount,
		SUM (ForgivenessAmount)/SUM (CurrentApprovalAmount) *100 percentage_of_loan_forgiven
  FROM [PortfolioDB].[dbo].[sba_public_data]
  WHERE year(DateApproved) = 2020;

         /****** percentage of loan forgiven in 2021 ******/
SELECT 
		COUNT(LoanNumber) Number_of_loans,
		SUM (CurrentApprovalAmount) current_Approved_amount,
		AVG (CurrentApprovalAmount) Avg_capproved_size,
		SUM (ForgivenessAmount) Forgiveness_Amount,
		SUM (ForgivenessAmount)/SUM (CurrentApprovalAmount) *100 percentage_of_loan_forgiven
  FROM [PortfolioDB].[dbo].[sba_public_data]
  WHERE year(DateApproved) = 2021
  order by Avg_capproved_size desc;

          /****** percentage of loan forgiven as per sector ******/
SELECT 
		s.Sector,
		COUNT(LoanNumber) Number_of_loans,
		SUM (CurrentApprovalAmount) current_Approved_amount,
		AVG (CurrentApprovalAmount) Avg_capproved_size,
		SUM (ForgivenessAmount) Forgiveness_Amount,
		SUM (ForgivenessAmount)/SUM (CurrentApprovalAmount) *100 percentage_of_loan_forgiven
  FROM [PortfolioDB].[dbo].[sba_public_data] p
  inner join [dbo].[sba_naics_sectorcodes] s
  on left(p.NAICSCode,2) = s.lookupcodes
   WHERE year(DateApproved) = 2020
     group by s.Sector
	 order by percentage_of_loan_forgiven desc
;

SELECT 
		s.Sector,
		COUNT(LoanNumber) Number_of_loans,
		SUM (CurrentApprovalAmount) current_Approved_amount,
		AVG (CurrentApprovalAmount) Avg_capproved_size,
		SUM (ForgivenessAmount) Forgiveness_Amount,
		SUM (ForgivenessAmount)/SUM (CurrentApprovalAmount) *100 percentage_of_loan_forgiven
  FROM [PortfolioDB].[dbo].[sba_public_data] p
  inner join [dbo].[sba_naics_sectorcodes] s
  on left(p.NAICSCode,2) = s.lookupcodes
   WHERE year(DateApproved) = 2021
     group by s.Sector
	 order by percentage_of_loan_forgiven desc
;

         /****** percentage of loan by each city ******/

;with cte as (
SELECT 
		BorrowerState,
		BorrowerCity,
		COUNT(LoanNumber) Number_of_loans,
		SUM (InitialApprovalAmount) total_loans,
		AVG (InitialApprovalAmount) Avg_loan_size
  FROM [PortfolioDB].[dbo].[sba_public_data]
  WHERE year(DateApproved) = 2020
  group by BorrowerState, BorrowerCity
  )
  select BorrowerState, BorrowerCity, Number_of_loans, total_loans, Avg_loan_size, total_loans/SUM (total_loans) over() * 100 as percentage_of_totalloan
  from cte
  order by percentage_of_totalloan desc;

         /****** Amount of loan by each month ******/


  SELECT YEAR(DateApproved),
		month (DateApproved),
		COUNT(LoanNumber) Number_of_loans,
		SUM (InitialApprovalAmount) total_loans,
		AVG (InitialApprovalAmount) Avg_loan_size
  FROM [PortfolioDB].[dbo].[sba_public_data]
  group by YEAR(DateApproved), month (DateApproved) 
  order by total_loans desc;

  create view ppp_main as
  select d.Sector,
		 year(DateApproved) year_Approved,
		 month(DateApproved) month_Approved,
		 OriginatingLender,
		 BorrowerState,
		 Race,
		 Gender,
		 Ethnicity,
		 COUNT(LoanNumber) Number_of_approved,
		 SUM (CurrentApprovalAmount) current_avg_loansize,
		 SUM (ForgivenessAmount) Forgiveness_Amount,
		 SUM (InitialApprovalAmount) approved_amt,
		 avg (InitialApprovalAmount) avg_loan_size
	from
		[PortfolioDB].[dbo].[sba_public_data] p
		inner join  [dbo].[sba_naics_sectorcodes] d
		on left(p.NAICSCode,2) = d.lookupcodes
	group by
	     d.Sector,
		 year(DateApproved),
		 month(DateApproved),
		 OriginatingLender,
		 BorrowerState,
		 Race,
		 Gender,
		 Ethnicity;








