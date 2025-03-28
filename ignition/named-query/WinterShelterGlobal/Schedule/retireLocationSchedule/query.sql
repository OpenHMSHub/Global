---Determine the current, past and next season
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @thisSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN @thisYear ELSE (@thisYear - 1) END

---Determine the current, past and next season ID's
DECLARE @thisSeasonId int
SELECT @thisSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @thisSeasonStartYear + '%'
DECLARE @currentDayOfYear int = DATEPART(dayofyear, GetDate())

UPDATE shelter.Schedule
SET
	timeRetired = getDate()
WHERE
	timeRetired is null
	AND (
		--Season start year retires everything greater than 152 and less than the current day
		dayOfYear < (CASE WHEN @thisYear = @thisSeasonStartYear and dayOfYear > 152 THEN @currentDayOfYear ELSE -1 END)
	OR
		--Season end year retires everthing greater than 152
		dayOfYear > (CASE WHEN @thisYear > @thisSeasonStartYear THEN 152 ELSE -1 END)
	OR
		--Season end year retires everthing less than the current day
		dayOfYear < (CASE WHEN @thisYear >  @thisSeasonStartYear THEN @currentDayOfYear ELSE -1 END)
	OR
		--old season catch-all
		seasonId < @thisSeasonID
		)