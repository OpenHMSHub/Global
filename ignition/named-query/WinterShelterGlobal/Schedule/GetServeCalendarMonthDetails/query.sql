DECLARE @YearStart as INT, @YeareEnd as INT
SELECT @YearStart =  CAST(SUBSTRING(seasons, 1, 4)as INT) FROM shelter.Seasons where id = :seasonId
SELECT @YeareEnd =   CAST(SUBSTRING(seasons, 6, 9)as INT) FROM shelter.Seasons where id = :seasonId

;WITH GenerateNumbers AS (
SELECT  :rangeStartDayOfYear  AS Number
UNION ALL
SELECT Number +1 FROM GenerateNumbers
WHERE Number +1<=  :rangeEndDayOfYear 
)
SELECT g.Number, COALESCE(y.noOfCongregations, 0) as noOfCongregations, COALESCE(x.totalBeds, 0) as totalBeds FROM GenerateNumbers g LEFT JOIN
(
select dayOfYear , count(locationId) as noOfCongregations , sum(totalBeds) as totalBeds
from shelter.Schedule 
where seasonId = :seasonId AND dayOfYear >=  :rangeStartDayOfYear AND dayOfYear <= :rangeEndDayOfYear AND timeCancelled is NULL
group by dayOfYear
) x ON g.Number = x.dayOfYear
LEFT JOIN
(
select dayOfYear , count(locationId) as noOfCongregations , sum(totalBeds) as totalBeds
from shelter.Schedule 
where seasonId = :seasonId AND dayOfYear >=  :rangeStartDayOfYear AND dayOfYear <= :rangeEndDayOfYear AND (timeCancelled is NULL OR timeCancelled >= datefromparts(@YearStart, 11,1))--timeCancelled is NULL
group by dayOfYear
) y ON g.Number = y.dayOfYear
ORDER BY g.Number
option (MAXRECURSION 0)
 
