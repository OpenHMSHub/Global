import traceback
project = "HMS"
TODAY = system.date.now()
THISYEAR = system.date.getYear(TODAY)

#Returns day number where season start = 1.
#Input: dayOfYear is day number where Jan 1 = 1
#Input:	year (defaults to current year)
#NOTE:	If dayOfYear date is before years season start, dayOfYear is assumed to be in next year.
#		In other words, use the year the season starts.
def dayOfSeason(dayOfYear, year=THISYEAR):
	dayOfSeason = 0
	date = dayOfYearToDate(dayOfYear, year)
	seasonStart = getSeasonStart(year)
	if system.date.isBefore(date, seasonStart):
		date = dayOfYearToDate(dayOfYear, year+1)
	dayOfSeason = system.date.daysBetween(seasonStart, date)+1
	return dayOfSeason

#
#
#Returns a day of year number
#Input dayOfSeason is day number where June 1 = 1
def dayOfYear(dayOfSeason, year=THISYEAR):
	dayOfYear = 0
	seasonStart = getSeasonStart(year)
	date = system.date.addDays(seasonStart, dayOfSeason-1)
	dayOfYear = system.date.getDayOfYear(date)
	return dayOfYear



#Returns number day of week where Sunday is 1
#Input:	dayOfYear is day number where Jan 1 = 1
#Input:	year (defaults to current year)	
def dayOfWeekInt(dayOfYear, year=THISYEAR):
	dayOfWeekInt = 0
	date = dayOfYearToDate(dayOfYear, year)
	dayOfWeekInt = system.date.getDayOfWeek(date)
	return dayOfWeekInt



#Returns the weekday name: Sunday, Monday, Tuesday...	
#Input: dayOfYear is day number where Jan 1 = 1
#Input: year (defaults to current year)	
def dayOfWeekString(dayOfYear, year = THISYEAR):
	dayOfWeekString = ''
	date = dayOfYearToDate(dayOfYear, year)
	dayOfWeekString = system.date.format(date, 'EEEE')
	return dayOfWeekString

	
		
#Returns the date of a dayOfYear and given season
#Input: dayOfYear is day number where Jan 1 = 1
#Input: year (defaults to current year)
def dayOfYearToDate(dayOfYear, year=THISYEAR):
	yearStart = system.date.getDate(year, 0, 1)
	date = system.date.addDays(yearStart, dayOfYear-1)
	return date



#Returns the season of a given date as a string: 'year-year'
def getSeason(date):
	season = ''
	nearestStart = getSeasonStart(date)
	year = system.date.getYear(date)
	if system.date.isBefore(now, nearestStart):		#Before season start
		yearBefore = year - 1
		season = str(yearBefore) + '-' + str(year)
	else:											#After season start
		yearAfter = year + 1
		season = str(year) + '-' + str(yearAfter)
	return season



#Returns the start of the season in year given. 
#NOTE: Season static set to June 1st. Update if changed.
def getSeasonStart(year=THISYEAR):
	return system.date.getDate(year, 5, 1)		#June 1 of current year	

#Returns the season ID of the current season	
def getCurrentSeasonId():
	#Get the current season ID
	path = 'WinterShelterGlobal/getCurrentSeason'
	parameters = {}
	dataset = system.db.runNamedQuery(project=project,path=path,parameters=parameters)
	currentSeasonId = dataset.getValueAt(0,'id')
	return currentSeasonId

## returns the date from dayOfYear and SeasonID
def getDateForSeasonForDayOfYear(dayOfYear, seasonId):
	returnDate = None
	seasonString = system.db.runScalarPrepQuery("SELECT seasons FROM Shelter.seasons where id = ?", [seasonId], database='HMSOps')
	if seasonString != None and seasonString != "":
		seasonStartYear = int(seasonString.split("-")[0])
		seasonEndYear = int(seasonString.split("-")[1])
		
		startDayOfSeason = system.date.getDayOfYear(getSeasonStart(seasonStartYear))
		
		if dayOfYear < startDayOfSeason:
			returnDate = dayOfYearToDate(dayOfYear,seasonEndYear)
		else:
			returnDate = dayOfYearToDate(dayOfYear,seasonStartYear)
	return returnDate
