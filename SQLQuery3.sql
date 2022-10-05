/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [NAICS_Codes]
      ,[NAICS_Industry_Description]
  FROM [PortfolioDB].[dbo].[sba_industry_standards]
  where [NAICS_Codes] = ''

  /*to extract codes**/
  SELECT [NAICS_Industry_Description],
  iif ([NAICS_Industry_Description] like '%–%', SUBSTRING ([NAICS_Industry_Description],8,2), '')lookupcodes
  FROM [PortfolioDB].[dbo].[sba_industry_standards]
  where [NAICS_Codes] = ''

    /*to remove blank values**/
select * from	
	(
	SELECT [NAICS_Industry_Description],
  iif ([NAICS_Industry_Description] like '%–%', SUBSTRING ([NAICS_Industry_Description],8,2), '')lookupcodes
  FROM [PortfolioDB].[dbo].[sba_industry_standards]
  where [NAICS_Codes] = ''
  ) main
  where lookupcodes != ''

    /*to extract sector**/
	select * from	
	(
	SELECT [NAICS_Industry_Description],
  iif ([NAICS_Industry_Description] like '%–%', SUBSTRING ([NAICS_Industry_Description],8,2), '')lookupcodes,
  iif ([NAICS_Industry_Description] like '%–%', SUBSTRING ([NAICS_Industry_Description],CHARINDEX ('–', [NAICS_Industry_Description])+1,LEN([NAICS_Industry_Description]) ), '')  Sector
  FROM [PortfolioDB].[dbo].[sba_industry_standards]
  where [NAICS_Codes] = ''
  ) main
  where lookupcodes != ''

  /*to trim spaces in sector column**/
  select * from	
	(
	SELECT [NAICS_Industry_Description],
  iif ([NAICS_Industry_Description] like '%–%', SUBSTRING ([NAICS_Industry_Description],8,2), '')lookupcodes,
  iif ([NAICS_Industry_Description] like '%–%', ltrim (SUBSTRING ([NAICS_Industry_Description],CHARINDEX ('–', [NAICS_Industry_Description])+1,LEN([NAICS_Industry_Description]) )), '')  Sector
  FROM [PortfolioDB].[dbo].[sba_industry_standards]
  where [NAICS_Codes] = ''
  ) main
  where lookupcodes != ''

    /*selecting into a table, temp table**/
 select * 
 into sba_naics_sectorcodes
 from
	(
	SELECT [NAICS_Industry_Description],
  iif ([NAICS_Industry_Description] like '%–%', SUBSTRING ([NAICS_Industry_Description],8,2), '')lookupcodes,
  iif ([NAICS_Industry_Description] like '%–%', ltrim (SUBSTRING ([NAICS_Industry_Description],CHARINDEX ('–', [NAICS_Industry_Description])+1,LEN([NAICS_Industry_Description]) )), '')  Sector
  FROM [PortfolioDB].[dbo].[sba_industry_standards]
  where [NAICS_Codes] = ''
  ) main
  where lookupcodes != ''

  select * from [dbo].[sba_naics_sectorcodes]

     
	 /*cleaning and correcting minor errors in data**/

  insert into [dbo].[sba_naics_sectorcodes]
  values
  ('Sector 31 – 33 – Manufacturing', 32, 'Manufacturing'),
  ('Sector 31 – 33 – Manufacturing', 33, 'Manufacturing'),
  ('Sector 44 - 45 – Retail Trade', 45, 'Retail Trade'),
  ('Sector 48 - 49 – Transportation and Warehousing', 49, 'Transportation and Warehousing');


  update [dbo].[sba_naics_sectorcodes]
  set Sector = 'Manufacturing' where lookupcodes = 31;
