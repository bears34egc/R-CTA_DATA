library(RODBC)

odbcChannel <- odbcConnect("R_SQL")

CTA <- as.data.frame(sqlQuery(odbcChannel, "SELECT
       [station_id]
      ,[stationname]
      ,[rides]
      ,[Longitude]
      ,[Latitude]
      ,[month]
      ,[yr]
      ,[ddate]
      ,[fulldate]
      ,[mth_rides]
      ,[ann_rides]
FROM [master].[dbo].[CTA_sum2]"))
head(CTA)

CTA_map <- CTA

library(sp)
library(ggmap)
library(RColorBrewer)
coordinates(CTA_map) <- ~ Longitude + Latitude
proj4string(CTA_map) <- CRS("+proj=longlat +datum=WGS84")



## Download stamen tiles using the bounding box of the SpatialPointsDataFrame object
bbPoints <- bbox(CTA_map)
gmap <- get_map(c(bbPoints), maptype='roadmap', source='google', crop=FALSE)

## http://spatialreference.org/ref/sr-org/6864/
## Bounding box of the map to resize and position the image with grid.raster
bbMap <- attr(gmap, 'bb')
latCenter <- with(bbMap, ll.lat + ur.lat)/2
lonCenter <- with(bbMap, ll.lon + ur.lon)/2
height <- with(bbMap, ur.lat - ll.lat)
width <- with(bbMap, ur.lon - ll.lon)

## Use sp.layout of spplot: a list with the name of the function
## ('grid.raster') and its arguments
sp.raster <- list('grid.raster', gmap,
                  x=lonCenter, y=latCenter,
                  width=width, height=height,
                  default.units='native')

## Define classes and sizes of the circle for each class
breaks <- c(10000, 1250000, 2500000, 3750000, 5500000)
CTA_map$ann_rides <- gsub(",", "", CTA_map$ann_rides)
CTA_map$ann_rides <- as.numeric(CTA_map$ann_rides)
classes <- cut(CTA_map$ann_rides, breaks)


## Finally, the spplot function
spplot(CTA_map["ann_rides"],
       cuts = breaks,
       col.regions=brewer.pal(n=5, 'Reds'),
       cex=.41,
       edge.col='black', alpha=0.75,
       scales=list(draw=FALSE), key.space='right',
       sp.layout=sp.raster)

##export for work in D3
write.table(CTA, "C:/Users/ecoker/Documents/nvd3-master/CTA.txt", sep="\t")
