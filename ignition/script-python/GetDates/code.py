#from calendar import monthrange
from datetime import datetime,timedelta

def getFirstDayOfCurrentMonth():
	return system.date.format(system.date.now(), "MM/01/yyyy")

def getFirstDayOfCurrentYear():
	return system.date.format(system.date.now(), "01/01/yyyy")
		
def getFirstDayOfLastMonth():
	return system.date.format(system.date.addMonths(system.date.now(), -1),"MM/01/yyyy")

def getLastDayOfLastMonth():
		value = system.date.addMonths(system.date.now(), -1)
		month = system.date.getMonth(value)
		if month == 0 or month == 2 or month == 4 or month == 6 or month == 7 or month == 9 or month == 11:
			return system.date.format(value, "MM/31/yyyy")
		elif month == 1:
			year = system.date.getYear(value)
			lastDay = monthrange(year, 2)[1]
			return system.date.format(value, "MM/" + str(lastDay) + "/yyyy")
		else:
			return system.date.format(value, "MM/30/yyyy")
			
def getFirstDayOfLastYear():
	return system.date.format(system.date.addYears(system.date.now(), -1), "01/01/yyyy")
	
def getLastDayOfLastYear():
	return system.date.format(system.date.addYears(system.date.now(), -1), "12/31/yyyy")	
		
def getFirstDayOfLastWeek():
	value=system.date.addWeeks(system.date.now(),-1)
	day = system.date.getDayOfWeek(value)
	return system.date.format(system.date.addDays(value,1-day),"MM/dd/yyyy")

def getLastDayOfLastWeek():
	value=system.date.addWeeks(system.date.now(),-1)
	day = system.date.getDayOfWeek(value)
	return system.date.format(system.date.addDays(value,7-day),"MM/dd/yyyy")
	
def getFirstDayOfCurrentWeek():
	day = system.date.getDayOfWeek(system.date.now())
	return system.date.format(system.date.addDays(system.date.now(),1-day),"MM/dd/yyyy")
	


from datetime import *
	
today = system.date.now()
#print today
todayFormat = system.date.format(today,"yyyy-MM-dd HH:mm:ss")

#days = ["Saturday","Sunday"]

def thisWeekDate(days):
	
	#from datetime import *
	#days = ["Saturday","Sunday"]
	#days = ["Saturday","Sunday"]
	#days = ["Thursday","Friday"]
	#days = ["Friday","Saturday"]
	#days = ["Monday","Tuesday","Wednesday"]
	baseDate  = datetime.today() # current day or some other date (e.g. last monday)
	dateOfDayThisWeek = { dt.strftime("%A"):dt for dow in range(7) for dt in [baseDate+timedelta(dow)] }
	x = 0
	returnDays = []
	for day in dateOfDayThisWeek:
	
		#[x+1 if x >= 45 else x+5 for x in l]
		for hosted in days:
		
			if day == hosted:# and x <= 1:
			
				daysweek, ThisWeekDate = day,dateOfDayThisWeek[day].strftime("%Y-%m-%d %H:%M:%S")

				
				parse = system.date.parse(ThisWeekDate, 'yyyy-MM-dd HH:mm:ss')
				
				returnDays.append(parse)
				
				returnDays.sort()
	
	#print returnDays
	for thisWeek in returnDays:

		nextHostingCheck = system.date.isBefore(today,thisWeek)
	
	
		format = system.date.format(thisWeek,'yyyy-MM-dd')
	
	if todayFormat == format:
		
		nextHosting = thisWeek
		
		return nextHosting
		
		nextHostingCheck = system.date.isBefore(today,thisWeek)
		
		if nextHostingCheck:
	#
			#print "Next Hosting Day-------",returnDays[1]
			return returnDays[1]
	
	else:
		pass
		
	nextHostingCheck = system.date.isBefore(today,thisWeek)
	
	
	if nextHostingCheck:
	#
		#print "Next Hosting Day-------",thisWeekDate()[0]
		return returnDays[0]
	
	else:
			
		pass	

							
													
	#return returnDays
	
#	x += 1
	
	
def lastWeekDate(days):	
	y = 0
	returnDays = []
	#days = ["Saturday","Sunday"]
	#days = ["Thursday","Friday"]
	#days = ["Friday","Saturday"]
	#days = ["Monday","Tuesday","Wednesday"]
	today = system.date.now()

	todayFormat = system.date.format(today,"yyyy-MM-dd HH:mm:ss")

	baseDate  = datetime.today() # current day or some other date (e.g. last monday)

	baseDateFormat = baseDate.strftime("%Y-%m-%d %H:%M:%S")

	
	
	if todayFormat == baseDateFormat:
		#print 'yippeeee'
		weekRange = 8
		
	else:
	
		weekRange = 7
	

	dateOfDayLastWeek = { dt.strftime("%A"):dt for dow in range(weekRange) for dt in [baseDate-timedelta(dow)] }
	
	
			
# print dates for each possible day
	for day in dateOfDayLastWeek:
	
		
		for hosted in days:
		
			if day == hosted:# and y <= 1:
			
				daysweek, lastWeekDate = day,dateOfDayLastWeek[day].strftime("%Y-%m-%d %H:%M:%S")
						
				
				parse = system.date.parse(lastWeekDate, 'yyyy-MM-dd HH:mm:ss')
				
				returnDays.append(parse)
				
	
				returnDays.sort()
				
	
	for thisWeek in returnDays:
	
		lastHostingCheck = system.date.isAfter(today,thisWeek)
	
		weekLength = len(returnDays) - len(returnDays) + 1
	
	if lastHostingCheck:
		
		#print "last Hosting Day------",lastWeekDate()[-weekLength]
		return returnDays[-weekLength]
	
	else:
		pass
		
	

#print thisWeekDate()
#print lastWeekDate()
