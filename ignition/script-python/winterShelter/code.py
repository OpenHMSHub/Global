import traceback
project = "Global"

def cancelScheduleDates(locationId,dayOfYearList):
	if len(dayOfYearList) > 0:
		#convert the list into a Query String
		dayOfYearString = "("
		for date in range(0,len(dayOfYearList)):
			dayOfYearString += str(dayOfYearList[date]) + ","
		#Remove the last comma and add paranthesis
		dayOfYearString = dayOfYearString[:-1] + ")"
		system.perspective.print(dayOfYearString)
		path = 'WinterShelterGlobal/Registration/cancelLocationScheduleDates'
		parameters = {
					"locationId":locationId,
					"dayOfYearString":dayOfYearString
					}
		result = system.db.runNamedQuery(project=project,path=path,parameters=parameters)
		system.perspective.print("Schedule dates are canceled")
	return 
	
def insertScheduleDates(locationId,dayOfYearToAddList,genderId,totalBeds,noteList):
	path = 'WinterShelterGlobal/Registration/insertLocationSchedule'
	for day in range(0,len(dayOfYearToAddList)):
		dayOfYear = dayOfYearToAddList[day]
		notes = noteList[day]
		parameters = {
					"locationId":locationId,
					"dayOfYear":dayOfYear,
					"genderId":genderId,
					"totalBeds":totalBeds,
					"notes":notes
					}
					
		
		IsCancelledSchedule = system.db.runNamedQuery(project=project,path='WinterShelterGlobal/Registration/Check_IsCancelledSchedule',parameters={"locationId":locationId,"dayOfYear":dayOfYear})
		if IsCancelledSchedule.getRowCount() > 0:
			system.db.runNamedQuery(project=project,path='WinterShelterGlobal/Registration/Update_CancelledSchedule',parameters={"locationId":locationId,"dayOfYear":dayOfYear})
		else:
			result = system.db.runNamedQuery(project=project,path=path,parameters=parameters)
	return

def updateScheduleDates(locationId,dayOfYearToUpdateList,genderId,totalBeds,noteList):
	path = 'WinterShelterGlobal/Registration/insertLocationSchedule'
	for day in range(0,len(dayOfYearToUpdateList)):
		seasonId = getSeasonIdFromQuery()
		dayOfYear = dayOfYearToUpdateList[day]
		notes = noteList[day]
		parameters = {
					"locationId":locationId,
					"dayOfYear":dayOfYear,
					"genderId":genderId,
					"totalBeds":totalBeds,
					"notes":notes
					}
		#result = system.db.runNamedQuery(project=project,path=path,parameters=parameters)
		schedule_loc = None
		get_scheduleLoc = system.db.runPrepQuery("SELECT CASE WHEN h.HostLocationType = 'Our Location' THEN 'Congregation' ELSE h.HostLocationType END AS HostLocationType FROM shelter.LocationSeasonal l, shelter.HostLocationType h WHERE l.locationId = "+str(locationId)+" AND l.seasonId = "+str(seasonId)+" AND l.hostLocationTypeId = h.id")
		if get_scheduleLoc.getRowCount()>0:
			schedule_loc = get_scheduleLoc.getValueAt(0,0)
		result = system.db.runPrepUpdate("UPDATE shelter.Schedule SET genderId = ?, totalBeds = ?, notes = ?,timeUpdated = getDate(), HostLocationType = ? WHERE locationId = ? AND seasonId = ? AND dayOfYear = ?",[genderId,totalBeds,notes,schedule_loc,locationId,seasonId,dayOfYear])
		system.perspective.print("Schedule updated")
	return
	
def updateSchedule():
	#General Schedule update tasks completed twice daily
	#Retire old reservations
	path = 'WinterShelterGlobal/Schedule/retireLocationSchedule'
	retire = system.db.runNamedQuery(project=project,path=path)
	#
	#Set the season begin and end dates, and last update time
	lastScheduleUpdate = system.date.now()
	seasonStartDate = calendar.getSeasonStart()
	seasonEndDate = system.date.addDays(seasonStartDate,364)
	tagPaths = ['[default]HMS/Winter Shelter/Season Start','[default]HMS/Winter Shelter/Season End','[default]HMS/Winter Shelter/lastScheduleUpdate']
	tagValues = [seasonStartDate,seasonEndDate,lastScheduleUpdate]
	system.tag.writeAsync(tagPaths,tagValues)
	return
	
def getLocationCurrentSchedule(locationId,seasonId):
	#Get the current schedule
	path = 'WinterShelterGlobal/getCurrentSchedule'
	parameters = {
				"locationId":locationId,
				"seasonId":seasonId
				}
	currentSchedule = system.db.runNamedQuery(project=project,path=path,parameters=parameters)
	#system.perspective.print(str(currentSchedule.getRowCount()))
	return currentSchedule
	
def updateBedProjection(locationId,seasonId):
	#Bed projection is sum of beds for all nights in a season
	#Beds actual is usm of all reserveations in a season
	path = 'WinterShelterGlobal/updateBedProjection'
	parameters = {
					"locationId":locationId,
					"seasonId":seasonId
					}
	success = system.db.runNamedQuery(project=project,path=path,parameters=parameters)
	return success
	

def editRegistrationSchedule(locationId,newSchedule,genderId,totalBeds):
	#Input is an edited schedule
	#Query the exisiting schedule and make deletions, insertions,
	#and updates as required 
	system.perspective.print("Editing the registration schedule for location ID " + str(locationId))
	# Get the current season
	seasonId = calendar.getCurrentSeasonId()
	system.perspective.print("Current Season ID is " + str(seasonId))
	currentDayOfSeason = calendar.dayOfSeason(system.date.getDayOfYear(system.date.now()))
	system.perspective.print("Current day of season is " + str(currentDayOfSeason))
	#Get the current schedule
	currentSavedSchedule = getLocationCurrentSchedule(locationId,seasonId)
	#convert to array
	oldSchedule = []
	for item in range(0,currentSavedSchedule.getRowCount()):
		oldDate = currentSavedSchedule.getValueAt(item,'dayOfYear')
		oldSchedule.append(int(oldDate))
	system.perspective.print('Days in old schedule: ' + str(oldSchedule))
	system.perspective.print('Days in new schedule: ' + str(newSchedule))
	#Remove dates that are not on the new schedule
	#Be sure there are no reservations before removing
	dayOfYearToCancelList = []
	for date in range(0,len(oldSchedule)):
		#Convert dayOfYear to dayOfSeason
		dayOfSeason = calendar.dayOfSeason(oldSchedule[date])
		#system.perspective.print(str(oldSchedule[date]))
		#Only remove dates in the future
		if dayOfSeason >= currentDayOfSeason:
			if oldSchedule[date] not in newSchedule:
				dayOfYearToCancelList.append(oldSchedule[date])
	#Remove the last comma and close the paranthesis
	if len(dayOfYearToCancelList) > 0:
		system.perspective.print('Days to remove: ' + str(dayOfYearToCancelList))
		cancelScheduleDates(locationId,dayOfYearToCancelList)
	else: 
		system.perspective.print('No dates to remove.')
	#
	#Insert new dates
	newScheduleDateCount = len(newSchedule)
	system.perspective.print(str(newScheduleDateCount) + " nights found in the new schedule.")
	dayOfYearToAddList = []
	dayOfYearToUpdateList = []
	noteList = []
	for newDate in range(0,newScheduleDateCount):
		dayOfSeason = calendar.dayOfSeason(newSchedule[newDate])
		dayOfYear = newSchedule[newDate]
		#Only add dates in the future
		#system.perspective.print(str(dayOfSeason))
		if dayOfSeason >= currentDayOfSeason:
			system.perspective.print(newSchedule[newDate])
			if int(newSchedule[newDate]) not in oldSchedule:
				dayOfYearToAddList.append(newSchedule[newDate])
				noteList.append('')
			else: #Update
				dayOfYearToUpdateList.append(newSchedule[newDate])
				noteList.append('')
	if len(dayOfYearToAddList) > 0:
		system.perspective.print('Days to add: ' + str(dayOfYearToAddList))
		insertScheduleDates(locationId,dayOfYearToAddList,genderId,totalBeds,noteList)
	else: 
		system.perspective.print('No dates to add.')
	#
	#Update exisiting dates, including dates that were previously cancelled then added back in
	if len(dayOfYearToUpdateList) > 0:
		system.perspective.print('Days to update: ' + str(dayOfYearToUpdateList))
		updateScheduleDates(locationId,dayOfYearToUpdateList,genderId,totalBeds,noteList)
	else: 
		system.perspective.print('No dates to Update.')
	#
	#Update the bed projection
	#
	updateProjection = updateBedProjection(locationId,seasonId)
	#
	#
	return
	
def getSeasonIdFromQuery():
	return 	int(system.db.runNamedQuery("WinterShelterGlobal/getCurrentSeason", {}).getValueAt(0,'id'))
