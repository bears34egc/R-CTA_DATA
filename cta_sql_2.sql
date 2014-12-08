  ALTER TABLE master.dbo.CTA_Ridership
  /*ADD [yr] CHAR(2)*/
  /*ADD [ddate] CHAR(2)*/
 /*ADD [month] CHAR(2)*/
 ADD [fulldate] CHAR(10)

INSERT into dbo.CTA_Ridership
SELECT *
,DATEPART(month,[date]) as [month]
,DATEPART(year,[date]) as [yr]
,DATEPART(weekday,[date]) as [ddate]
,CONCAT((DATEPART(month,[date])), (DATEPART(day,[date])), (DATEPART(year,[date]))) as fulldate
from dbo.CTA_Ridership

DROP table master.dbo.CTA_
CREATE Table [master].[dbo].[CTA_] 
	  (station_id float
      ,stationname nvarchar(255)
      ,[date] datetime
      ,[daytype] nvarchar(255)
      ,[rides] float
      ,[Longitude] float
      ,[Latitude] float
      ,[month] float
	  ,[yr] float
	  ,[ddate] float
	  ,[fulldate] char(10));

SELECT * from dbo.CTA_
  INSERT into [master].[dbo].[CTA_] 
  SELECT
	  [station_id]
      ,[stationname]
      ,[date]
      ,[daytype]
      ,[rides]
      ,[Longitude]
      ,[Latitude]
      ,(DATEPART(month,[date])) [month]
	  ,(DATEPART(year,[date])) [yr]
	  ,(DATEPART(weekday,[date])) [ddate]
	  ,CONCAT((DATEPART(month,date)), '_', (DATEPART(day,date)), '_', (DATEPART(year,date))) [fulldate]
from master.dbo.CTA_Ridership
	


	Select max(ann_rides), min(ann_rides), max(mth_rides), min(mth_rides) from master.dbo.CTA_sum
