/****** Script for SelectTopNRows command from SSMS  ******/
  ALTER TABLE master.dbo.CTA
  ADD [yr] CHAR(2)]
  UPDATE master.dbo.CTA
  SET [yr]=DATEPART(year,[date])

  UPDATE dbo.CTA_sum
  SET Longitude=COALESCE(Longitude, -87.627891)
  SET Latitude=COALESCE(Latitude, 41.8839569)
 
 / **/
DROP table master.dbo.CTA_sum
CREATE Table [master].[dbo].[CTA_sum] 
	  (station_id float
      ,stationname nvarchar(255)
      ,[date] datetime
      ,[daytype] nvarchar(255)
      ,[rides] float
      ,[Longitude] decimal(9,6)
      ,[Latitude] decimal(9,6)
      ,[month] float
	  ,[yr] float
	  ,[ddate] float
	  ,[fulldate] char(10)
	  ,[mth_rides] float
	  ,[ann_rides] float);

  INSERT into [master].[dbo].[CTA_sum]
  SELECT
	  [station_id]
      ,[stationname]
      ,[date]
      ,[daytype]
      ,[rides]
      ,[Longitude]
      ,[Latitude]
      ,[month]
	  ,[yr]
	  ,[ddate]
	  ,[fulldate]
	  ,SUM([rides]) OVER(PARTITION by [station_id],[yr],[month]) [mth_rides] 
	 ,SUM([rides]) OVER(PARTITION by [station_id],[yr]) [ann_rides]
	  from master.dbo.CTA_



	 / **/
	 CREATE Table [master].[dbo].[CTA_0113] 
	  ([station_id] float
      ,[stationname] nvarchar(255)
	  ,[yr] char(2)
      ,[ann_rides] float
      ,[Longitude] float
      ,[Latitude] float);

	  INSERT into [master].[dbo].[CTA_0113] 
	  select distinct 
	   [station_id]
      ,[stationname] 
	  ,[yr]
      ,[ann_rides] 
      ,[Longitude]
      ,[Latitude]
	  from [master].[dbo].[CTA_sum]

	 / **/
	 CREATE Table [master].[dbo].[CTA_0107] 
	  ([station_id] float
      ,[stationname] nvarchar(255)
	  ,[yr] char(2)
      ,[ann_rides] float
      ,[Longitude] float
      ,[Latitude] float);

	  INSERT into [master].[dbo].[CTA_0107] 
	  select distinct 
	   [station_id]
      ,[stationname] 
	  ,[yr]
      ,[ann_rides] 
      ,[Longitude]
      ,[Latitude]
	  from [master].[dbo].[CTA_sum]
	  where [yr] < 08

	 
	drop Table [master].[dbo].[CTA_chg]*/

	CREATE Table [master].[dbo].[CTA_chg] 
	  ([station_id] float
      ,[stationname] nvarchar(255)
      /*,[ann_rides] float*/
      ,[Longitude] float
      ,[Latitude] float
	  /*,[yr] char(2)*/
	  ,[change0113] float
	  ,[change0813] float
	  ,[change0107] float);

  INSERT into [master].[dbo].[CTA_chg]
  SELECT distinct
	   a.[station_id]
      ,a.[stationname]
      /*,a.[ann_rides]*/
      ,a.[Longitude]
      ,a.[Latitude]
	  /*,a.[yr]*/
	  ,a.[change0113]
	  ,a.[change0813]
	  ,b.[change0107]
	  from 
	  ((SELECT distinct
	  [station_id]
      ,[stationname]
	  ,[ann_rides] 
      ,[Longitude]
      ,[Latitude]
	  ,[yr]
	  ,([ann_rides] - lag([ann_rides],12) OVER (partition by station_id order by [station_id],[yr]))/LAG(ann_rides,12) 
	  OVER (partition by station_id order by [station_id],[yr])*100 AS [change0113]
	  ,([ann_rides] - lag([ann_rides],5) OVER (partition by station_id order by [station_id],[yr]))/LAG(ann_rides,5) 
	  OVER (partition by station_id order by [station_id],[yr])*100 AS [change0813]
	  from [master].[dbo].[CTA_0113]) as a 
	  left join 
	   (SELECT distinct 
	  [station_id]
      ,[stationname]
	  ,[ann_rides] 
      ,[Longitude]
      ,[Latitude]
	  ,[yr]
	  ,([ann_rides] - lag([ann_rides],6) OVER (partition by station_id order by [station_id],[yr]))/LAG(ann_rides,6) 
	  OVER (partition by station_id order by [station_id],[yr])*100 AS [change0107]
	  from [master].[dbo].[CTA_0107]) as b
	 on a.station_id = b.station_id and a.stationname=b.stationname and
	 a.Longitude=b.Longitude and a.Latitude=b.Latitude)

	 
  DELETE from [master].[dbo].[CTA_chg]
   where [change0113] is null
   or [change0107] is null
   or [change0813] is null


	select top 1000
	 [station_id]
      ,[stationname]
      ,[Longitude]
      ,[Latitude]
	  ,[change0113]
	  ,[change0107]
	  ,[change0813]
	  from master.dbo.CTA_chg
	  order by station_id

	  select 
	  distinct stationname,
	  [month],
	  yr,
	  mth_rides,
	  ann_rides,
	  Latitude,
	  Longitude
	  from dbo.CTA_sum where stationname not in (select stationname from master.dbo.CTA_chg)
	  order by stationname, [month]
