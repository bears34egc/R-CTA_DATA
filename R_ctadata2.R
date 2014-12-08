library(RODBC)

odbcChannel <- odbcConnect("R_SQL")
##sqlFetch(odbcChannel, "CTA")

CTA_chg <- as.data.frame(sqlQuery(odbcChannel, "SELECT [station_id]
      ,[stationname]
      ,[Longitude]
      ,[Latitude]
      ,[change0113]
      ,[change0107]
      ,[change0813]
       FROM [master].[dbo].[CTA_chg]"))
CTA <- as.data.frame(sqlQuery(odbcChannel, "SELECT
        [station_id]
        ,[stationname]
        ,[Longitude]
        ,[Latitude]
        ,[date]
        ,[rides]
        ,[Longitude]
        ,[Latitude]
        ,[month]
        ,[yr]
        ,[mth_rides]
        ,[ann_rides]
          FROM [master].[dbo].[CTA_sum]"))

odbcCloseAll()



##CTA$month <- format.Date(CTA$date, "%m")
##CTA$year <- format.Date(CTA$date, "%Y")
cta_uniq <- unique(CTA[,c("station_id", "stationname", "Longitude", "Latitude", "month", "yr", "mth_rides", "ann_rides")])

#dataset for maps with rider changes
CTA_chg_m <- CTA_chg
#normalized rider changes variables

lm <- function(x){x/1000000}
x <- cta_uniq$ann_rides
cta_uniq$ann_rides_n <- lm(x)

library(sp)
library(ggmap)
library(RColorBrewer)
coordinates(CTA_chg_m) <- ~ Longitude + Latitude
proj4string(CTA_chg_m) <- CRS("+proj=longlat +datum=WGS84")
names(CTA_chg_m)[5] <- 'Chg_in_Ridership_2001_13'


## Download stamen tiles using the bounding box of the SpatialPointsDataFrame object
bbPoints <- bbox(CTA_chg_m)
gmap <- get_map(c(bbPoints), maptype='toner', source='stamen', crop=FALSE)

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
breaks <- c(-58, 25, 75, 185, 761)
classes <- cut(CTA_chg_m$change0113, breaks)
meds <- tapply(CTA_chg_m$change0113, classes, FUN=median)
sizes <- (meds/max(meds))^0.57 * 1.8

## Finally, the spplot function
spplot(CTA_chg_m["change0113"],
       cuts = breaks,
       col.regions=brewer.pal(n=5, 'Reds'),
       cex=.41,
       edge.col='black', alpha=0.75,
       scales=list(draw=FALSE), key.space='right',
       sp.layout=sp.raster)

#m + geom_text(size=2, aes(label=stationname))

#restrict to downtown
CTA_dwntn <- subset(CTA_chg,
                    + -87.652193 <= Longitude & Longitude <= -87.612813 &
                      + 41.867368 <= Latitude & Latitude <= 41.953665)

coordinates(CTA_dwntn) <- ~ Longitude + Latitude
proj4string(CTA_dwntn) <- CRS("+proj=longlat +datum=WGS84")
names(CTA_dwntn)[5] <- 'Chg_in_Ridership_2001_13_b'


## Download stamen tiles using the bounding box of the SpatialPointsDataFrame object
bbPoints <- bbox(CTA_dwntn)
gmap <- get_map(c(bbPoints), maptype='toner', source='stamen', crop=FALSE)

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
breaks <- c(-58, 25, 75, 185, 761)
classes <- cut(CTA_chg_m$change0113, breaks)
meds <- tapply(CTA_chg_m$change0113, classes, FUN=median)
sizes <- (meds/max(meds))^0.57 * 1.8

## Finally, the spplot function
spplot(CTA_dwntn["change0113"],
       cuts = breaks,
       col.regions=brewer.pal(n=5, 'Reds'),
       cex=.57,
       edge.col='black', alpha=0.75,
       scales=list(draw=FALSE),
       sp.layout=sp.raster)


library(ggplot2)

qplot(ann_rides_n, data = cta_uniq, geom="histogram", binwidth = .01, xlim=c(.01,5.8),xlab="annual rides in millions", ylab="count for 143 stations btwn 2001-13")
m <- ggplot(cta_uniq, aes(x=ann_rides_n))
m + geom_histogram(aes(y = ..count..))
m + geom_histogram(aes(fill = ..count..)) + xlab("Annual Nbr Rides (Millions)") + ylab("Count across 143 stations btwn 2001_13")



#boxplot shows the distribution of annual ridership btwn 01_13 for each of the 143 stations
b1<- ggplot(cta_uniq, aes(x=stationname, y=ann_rides))
b2 <- b1 + geom_boxplot() + coord_flip() + theme(axis.text.y=element_text(vjust=.5, size=4))

b2 + geom_boxplot(fill="grey90") + theme_bw() + facet_wrap(~ yr) + theme(axis.text.y=element_text(vjust=.5, size =3))



print(l.bw)

#lattice showing change in overal ridership by year
scatter.lattice <- xyplot(yr ~ ann_rides, data=cta_uniq)
bwplot(yr ~ ann_rides, data=cta_uniq)

#avg ridership by station
ave.rider.station <- aggregate(cta_uniq$mth_rides, by = list(cta_uniq$stationname, cta_uniq$yr), 
                           FUN = mean)
ave.rider.station




#animation
library(animation)
library(gmap)
map <- get_map(location = 'Chicago', zoom = 10)

saveHTML({
  for (i in 5:7){
  CTA_chg$Ridership = CTA_chg[, i]

  spplot(CTA_chg["change0113"],
         cuts = breaks,
         col.regions=brewer.pal(n=5, 'Reds'),
         cex=.57,
         edge.col='black', alpha=0.75,
         scales=list(draw=FALSE),
         sp.layout=sp.raster)
  
  cta_map=ggplot(data=CTA_chg, aes(x=Longitude, y=Latitude, group = DRAWSEQ, 
    fill = CrimeRate)) + geom_polygon(color = "black") + ggtitle(paste("Violent Crime Rate in", 
    names(decadespct[i]))) + xlab("") + ylab("") + scale_fill_manual(values = mycols, 
   labels = c("Low", "Medium", "High")) + theme(legend.position = "top")
 
  
myLocation <- "Chicago"
myMap <- get_map(location=myLocation, source="google", maptype="roadmap"

ggmap(myMap) 
