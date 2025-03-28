def emailText_to_htmlFormat(emailText):
	import re
	# replace apostrope sign with single quote
	emailText = emailText.replace("’","'")
	# replace long dash with single dash
	emailText = emailText.replace("–","-")
	# convert link to html format (if <> found)
	pattern = "<[A-Za-z0-9-–@,.!?:\s']*>"
	matches = re.findall(pattern, emailText)
	if len(matches)>0:
		for oneMatch in matches:
			oneMatchWithoutSymbol = oneMatch[1:-1]
			## check if match is email then add mailto: before email in href
			if ('@' in oneMatchWithoutSymbol) and ('.' in oneMatchWithoutSymbol):
				oneMatchFormated = '<a href ="mailto:' +oneMatchWithoutSymbol + '">' + oneMatchWithoutSymbol + '</a>'
			else:
				oneMatchFormated = '<a href ="' +oneMatchWithoutSymbol + '">' + oneMatchWithoutSymbol + '</a>'
			emailText = emailText.replace(oneMatch,oneMatchFormated)
	# add bold text as required (if # found)
	pattern = "#[A-Za-z0-9-–@,.!?:\s']*#"
	matches = re.findall(pattern, emailText)
	if len(matches)>0:
		for oneMatch in matches:
			oneMatchWithoutSymbol = oneMatch[1:-1]
			oneMatchFormated = '<b>' +oneMatchWithoutSymbol + '</b>'
			emailText = emailText.replace(oneMatch,oneMatchFormated)
	# convert newline in python to break(<br> tag) in html
	emailText = emailText.replace('\n','<br>')
	emailText = emailText.replace('<br>-','<br>&emsp;-')
	## convert text to html format
	emailTextFormated = "<HTML><BODY>"
	emailTextFormated = emailTextFormated + emailText
	emailTextFormated = emailTextFormated + "</BODY></HTML>"
	return emailTextFormated
	
	
def send_email(toAddress,emailText,emailSubject,loggerName):
	to_addr = toAddress
	message = emailText
	logger = system.util.getLogger(loggerName)
	try:
		system.net.sendEmail(fromAddr="discovery-notifications@roomintheinn.org", subject=emailSubject, 
							body= message, to= to_addr, smtpProfile="discoverynotifications")
		logger.info('Email sent successfully.\nSubject: '+ str(emailSubject) + '\nTo: ' + to_addr)
	except:
		logger.info('Could not send email because none of the recipients had valid email addresses.')

def format_sms_text(smsText):
	import re
	# replace apostrope sign with single quote
	smsText = smsText.replace("’","'")
	# replace long dash with single dash
	smsText = smsText.replace("–","-")
	# convert link to html format (if <> found)
	pattern = "<[A-Za-z0-9-–@,.!?:\s']*>"
	matches = re.findall(pattern, smsText)
	if len(matches)>0:
		for oneMatch in matches:
			oneMatchWithoutSymbol = oneMatch[1:-1]
			## check if match is email then add mailto: before email in href
#			if ('@' in oneMatchWithoutSymbol) and ('.' in oneMatchWithoutSymbol):
#				oneMatchFormated = '<a href ="mailto:' +oneMatchWithoutSymbol + '">' + oneMatchWithoutSymbol + '</a>'
#			else:
#				oneMatchFormated = '<a href ="' +oneMatchWithoutSymbol + '">' + oneMatchWithoutSymbol + '</a>'
			smsText = smsText.replace(oneMatch,oneMatchWithoutSymbol)
	# add bold text as required (if # found)
	pattern = "#[A-Za-z0-9-–@,.!?:\s']*#"
	matches = re.findall(pattern, smsText)
	if len(matches)>0:
		for oneMatch in matches:
			oneMatchWithoutSymbol = oneMatch[1:-1]
#			oneMatchFormated = '<b>' +oneMatchWithoutSymbol + '</b>'
			smsText = smsText.replace(oneMatch,oneMatchWithoutSymbol)
	# convert newline in python to break(<br> tag) in html
#	emailText = emailText.replace('\n','<br>')
#	emailText = emailText.replace('<br>-','<br>&emsp;-')
#	## convert text to html format
#	emailTextFormated = "<HTML><BODY>"
#	emailTextFormated = emailTextFormated + emailText
#	emailTextFormated = emailTextFormated + "</BODY></HTML>"
	return smsText

def send_sms_twilio(toNumber, smsText):
	loggerName = "ws_send_sms_twilio"
	logger = system.util.getLogger(loggerName)
	try:
		account = system.twilio.getAccounts()[0]
	 
		# Fetch the first number associated with the account.
		fromNumber = system.twilio.getPhoneNumbers(account)[0]
	 	# Send the message.
		system.twilio.sendSms(account, fromNumber, toNumber, smsText)	
		logger.info('SentTwilio text to ' + str(toNumber))
	except Exception as e:
		logger.info('Error sending Twilio text to ' + str(toNumber) + " : " + str(e))
	
def get_email_from_congregation(congregation):
	email = ''
	users = system.user.getUsers('congregation')
	username = '(New User)'
	congregationName = congregation
	for user in users:
		name = user.get('firstname')
		if name == congregationName:
			contactInfo = user.getContactInfo()
			for item in contactInfo:
				if item.getContactType() == 'email':
					email = item.getValue()
					break
	return email
			
													
def what_to_expect_email():
	loggerName = "what_to_expect_email"
	# get current season id
	getCurrentSeason = system.db.runNamedQuery("WinterShelterGlobal/getCurrentSeason")
	seasonId = getCurrentSeason.getValueAt(0,'id')
	
	# number of days prior to actual event for sending email
	getDaysPriorToEvent = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'WhatToExpectEmail_Time'")
	daysPriorToEvent =  getDaysPriorToEvent.getValueAt(0,'settingValue')
	
	# check is email enable
	getIsEnableEvent = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'WhatToExpectEmail_Enable'")
	isEnableEvent =  getIsEnableEvent.getValueAt(0,'settingValue')
	
	# get email text
	getEmailText = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'WhatToExpectEmail_Text'")
	emailText =  getEmailText.getValueAt(0,'settingValue')
	
	if isEnableEvent == 'true':
		# get first day of night and prior date of all congregations
		parameters = {"seasonId":seasonId,"daysPriorToEvent":daysPriorToEvent}
		getCongregationFirstNight = system.db.runNamedQuery("WinterShelterGlobal/Settings/GetCongregationFirstNightHosting",parameters=parameters)
		todayDate = system.date.now()
		
		if getCongregationFirstNight.getRowCount()>0:
			for i in range(0,getCongregationFirstNight.getRowCount()):
				datePriorEvent = getCongregationFirstNight.getValueAt(i,'DatePriorEvent')
				if datePriorEvent != None and datePriorEvent != '':
					# if prior event(1st schedule night) date equals to today's date then send email
					if system.date.format(todayDate,'dd-MM-yyyy') == system.date.format(datePriorEvent,'dd-MM-yyyy'):
						primaryCoordinatorEmail = getCongregationFirstNight.getValueAt(i,'primaryCoordinatorEmail')
						secondaryCoordinatorEmail = getCongregationFirstNight.getValueAt(i,'secondaryCoordinatorEmail')
						congregation = getCongregationFirstNight.getValueAt(i,'locationName')
						congregationEmail = get_email_from_congregation(congregation)
						toAddress = [congregationEmail,primaryCoordinatorEmail,secondaryCoordinatorEmail]
						emailSubject = "What To Expect : " + str(congregation)
						emailText =  getEmailText.getValueAt(0,'settingValue')
						# replace parameter with original value
						emailText = emailText.replace('@congregationName',congregation)
						emailTextFormated = emailText_to_htmlFormat(emailText)
						send_email(toAddress,emailTextFormated,emailSubject,loggerName)
	
	
def beds_capacity_vs_allotment_email():
	loggerName = "beds_capacity_vs_allotment_email"
	# get current season id
	getCurrentSeason = system.db.runNamedQuery("WinterShelterGlobal/getCurrentSeason")
	seasonId = getCurrentSeason.getValueAt(0,'id')

	# check is email enable
	getIsEnableEvent = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'BedsCapacityVsAllotmentEmail_Enable'")
	isEnableEvent =  getIsEnableEvent.getValueAt(0,'settingValue')
	
	# get email text
	getEmailText = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'BedsCapacityVsAllotmentEmail_Text'")
	emailText =  getEmailText.getValueAt(0,'settingValue')
	
	if isEnableEvent == 'true':	
		# get actual and registered beds for congregation who has checkin on today date
		todayDate = system.date.now()	
		todayDateFormated = system.date.format(todayDate,'yyyy-MM-dd')
		parameters = {"seasonId":seasonId,"todayDate":todayDateFormated}
		getBedsRegisteredVsAllotment = system.db.runNamedQuery("WinterShelterGlobal/Settings/BedsCapacity_Vs_Allotment",parameters=parameters)
		
		if getBedsRegisteredVsAllotment.getRowCount()>0:
			for i in range(0,getBedsRegisteredVsAllotment.getRowCount()):
					registeredBeds = getBedsRegisteredVsAllotment.getValueAt(i,'registeredBeds')
					actualBeds = getBedsRegisteredVsAllotment.getValueAt(i,'actualBeds')
					isEmailSent = getBedsRegisteredVsAllotment.getValueAt(i,'BedsCapacityVsAllotmentEmail')
					if actualBeds != None and actualBeds != '' and isEmailSent == None:
						if int(actualBeds) > int(registeredBeds):
							primaryCoordinatorEmail = getBedsRegisteredVsAllotment.getValueAt(i,'primaryCoordinatorEmail')
							secondaryCoordinatorEmail = getBedsRegisteredVsAllotment.getValueAt(i,'secondaryCoordinatorEmail')
							congregation = getBedsRegisteredVsAllotment.getValueAt(i,'locationName')
							locationId = getBedsRegisteredVsAllotment.getValueAt(i,'locationId')
							congregationEmail = get_email_from_congregation(congregation)
							toAddress = [congregationEmail,primaryCoordinatorEmail,secondaryCoordinatorEmail]
							emailSubject = "Beds Capacity Vs Allotment: " + str(congregation)
							emailText =  getEmailText.getValueAt(0,'settingValue')
							emailTextFormated = emailText_to_htmlFormat(emailText)
							send_email(toAddress,emailTextFormated,emailSubject,loggerName)
							system.db.runPrepUpdate("Update shelter.LocationSeasonal set BedsCapacityVsAllotmentEmail = '" + str(system.date.format(todayDate,'yyyy-MM-dd hh:mm:ss')) + "' where locationId = "+str(locationId))


def ws_schedule_reminder_email():
	loggerName = "ws_schedule_reminder_email"
	logger = system.util.getLogger(loggerName)
	
	# get current season id
	getCurrentSeason = system.db.runNamedQuery("WinterShelterGlobal/getCurrentSeason")
	seasonId = getCurrentSeason.getValueAt(0,'id')
	
	# number of days prior to actual event for sending email
	getDaysPriorToEvent = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'ScheduleReminderEmail_Time'")
	daysPriorToEventEmail =  getDaysPriorToEvent.getValueAt(0,'settingValue')
	# check is email enable
	getIsEnableEmail = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'ScheduleReminderEmail_Enable'")
	isEnableEmail =  getIsEnableEmail.getValueAt(0,'settingValue')
	# get email text
	getEmailText = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'ScheduleReminderEmail_Text'")
	emailText =  getEmailText.getValueAt(0,'settingValue')
	
	# number of days prior to actual event for sending text
	getDaysPriorToEventText = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'ScheduleReminderText_Time'")
	daysPriorToEventText =  getDaysPriorToEventText.getValueAt(0,'settingValue')
	# check is email enable
	getIsEnableText = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'ScheduleReminderText_Enable'")
	isEnableText =  getIsEnableText.getValueAt(0,'settingValue')
	# get email text
	getTextMessage = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'ScheduleReminderText_Message'")
	textMessage =  getTextMessage.getValueAt(0,'settingValue')
	
	
	if isEnableEmail == 'true':
		logger.info("ws_schedule_reminder_email - enable email true")
		# get all days of scheduled night and prior date of all congregations
		parameters = {"seasonId":seasonId,"daysPriorToEvent":daysPriorToEventEmail}
		getCongregationFirstNight = system.db.runNamedQuery("WinterShelterGlobal/Settings/GetCongregationAllNightHosting",parameters=parameters)
		todayDate = system.date.now()
		
		if getCongregationFirstNight.getRowCount()>0:
			for i in range(0,getCongregationFirstNight.getRowCount()):
				datePriorEvent = getCongregationFirstNight.getValueAt(i,'DatePriorEvent')
				dateOfHosting = getCongregationFirstNight.getValueAt(i,'DateFromDayOfYear')
				nightHosted = system.date.format(dateOfHosting,'MM/dd')
				if datePriorEvent != None and datePriorEvent != '':
					# if prior event(1st schedule night) date equals to today's date then send email
					if system.date.format(todayDate,'dd-MM-yyyy') == system.date.format(datePriorEvent,'dd-MM-yyyy'):
						primaryCoordinatorEmail = getCongregationFirstNight.getValueAt(i,'primaryCoordinatorEmail')
						primaryCoordinatorPreferredCommunication = getCongregationFirstNight.getValueAt(i,'primaryCoordinatorPreferredCommunication')
						secondaryCoordinatorEmail = getCongregationFirstNight.getValueAt(i,'secondaryCoordinatorEmail')
						secondaryCoordinatorPreferredCommunication = getCongregationFirstNight.getValueAt(i,'secondaryCoordinatorPreferredCommunication')
						congregation = getCongregationFirstNight.getValueAt(i,'locationName')
						toAddress = []
						emailText =  getEmailText.getValueAt(0,'settingValue') # reinitialize so that correct text is sent everytime
						
						if primaryCoordinatorPreferredCommunication == 'Email' and primaryCoordinatorEmail != None and primaryCoordinatorEmail != '':
							toAddress.append(primaryCoordinatorEmail)
						
						if secondaryCoordinatorPreferredCommunication == 'Email' and secondaryCoordinatorEmail != None and secondaryCoordinatorEmail != '':
							toAddress.append(secondaryCoordinatorEmail)
				
						emailSubject = "Winter shelter schedule reminder : " + str(congregation)
						
						# replace parameter with original value
						emailText = emailText.replace('@congregationName',congregation)
						emailText = emailText.replace('@nightHosted',nightHosted)
						emailTextFormated = emailText_to_htmlFormat(emailText)
						
						if len(toAddress)>0:
							send_email(toAddress,emailTextFormated,emailSubject,loggerName)
	if isEnableText == 'true':
		# get all days of scheduled night and prior date of all congregations
		logger.info("ws_schedule_reminder_email - enable text true")
		parameters = {"seasonId":seasonId,"daysPriorToEvent":daysPriorToEventText}
		getCongregationFirstNight = system.db.runNamedQuery("WinterShelterGlobal/Settings/GetCongregationAllNightHosting",parameters=parameters)
		todayDate = system.date.now()
		
		if getCongregationFirstNight.getRowCount()>0:
			
			for i in range(0,getCongregationFirstNight.getRowCount()):
				datePriorEvent = getCongregationFirstNight.getValueAt(i,'DatePriorEvent')
				dateOfHosting = getCongregationFirstNight.getValueAt(i,'DateFromDayOfYear')
				nightHosted = system.date.format(dateOfHosting,'MM/dd')
				if datePriorEvent != None and datePriorEvent != '':
					
					# if prior event(1st schedule night) date equals to today's date then send email
					if system.date.format(todayDate,'dd-MM-yyyy') == system.date.format(datePriorEvent,'dd-MM-yyyy'):
						
						primaryCoordinatorPhone = getCongregationFirstNight.getValueAt(i,'primaryCoordinatorPhone')
						primaryCoordinatorPreferredCommunication = getCongregationFirstNight.getValueAt(i,'primaryCoordinatorPreferredCommunication')
						secondaryCoordinatorPhone = getCongregationFirstNight.getValueAt(i,'secondaryCoordinatorPhone')
						secondaryCoordinatorPreferredCommunication = getCongregationFirstNight.getValueAt(i,'secondaryCoordinatorPreferredCommunication')
						congregation = getCongregationFirstNight.getValueAt(i,'locationName')
						
						textMessage =  getTextMessage.getValueAt(0,'settingValue') ## reinitialize at every instance
						
						if textMessage is not None and textMessage != "":
							textMessage = textMessage.replace('@congregationName',congregation)
							textMessage = textMessage.replace('@nightHosted',nightHosted)
							textMessage = format_sms_text(textMessage)
						
						if ( primaryCoordinatorPreferredCommunication == 'Text' or primaryCoordinatorPreferredCommunication == 'Call' ) and primaryCoordinatorPhone != None and primaryCoordinatorPhone != '':
							## send text message
							if textMessage != None and textMessage != "":
								send_sms_twilio(primaryCoordinatorPhone,textMessage)
							
						
						
						if ( secondaryCoordinatorPreferredCommunication == 'Text' or secondaryCoordinatorPreferredCommunication == 'Call' ) and secondaryCoordinatorPhone != None and secondaryCoordinatorPhone != '':
							## send text message
							if textMessage != None and textMessage != "":
								send_sms_twilio(secondaryCoordinatorPhone,textMessage)
						
						
		
def ws_task_reminder_email():
	getWSTaskReminderEmail = system.db.runNamedQuery("WinterShelterGlobal/Tasks/GetTaskReminderEmailIDs")
	if getWSTaskReminderEmail.getRowCount()>0:
		# check is email enable
		getIsEnableEvent = system.db.runPrepQuery("SELECT id, settingName, settingValue FROM shelter.Settings WHERE timeRetired is NULL AND settingName = 'TaskReminderEmail_Enable'")
		isEnableEvent =  getIsEnableEvent.getValueAt(0,'settingValue')
		if isEnableEvent == 'true':
			for i in range(0,getWSTaskReminderEmail.getRowCount()):
				staffEmail = getWSTaskReminderEmail.getValueAt(i,'staffEmail')
				assignerEmail = getWSTaskReminderEmail.getValueAt(i,'assignerEmail')
				emailText = "<HTML><BODY>"
				emailText = emailText + "Subject : " + str(getWSTaskReminderEmail.getValueAt(i,'title')) + "<br>Task Type : " + str(getWSTaskReminderEmail.getValueAt(i,'type'))
				emailText = emailText + "<br>Congregation : " + str(getWSTaskReminderEmail.getValueAt(i,'locationName')) + "<br>Contact : " + str(getWSTaskReminderEmail.getValueAt(i,'contact'))
				emailText = emailText + "<br>Notes : " + str(getWSTaskReminderEmail.getValueAt(i,'notes')) + "<br>Assigner : " + str(getWSTaskReminderEmail.getValueAt(i,'assignerName'))
				emailText = emailText + "<br>Staff : " + str(getWSTaskReminderEmail.getValueAt(i,'staffName')) + "<br>Priority : " + str(getWSTaskReminderEmail.getValueAt(i,'taskPriority'))
				emailText = emailText + "<br>Due Date : " + str(system.date.format(getWSTaskReminderEmail.getValueAt(i,'dueDate'), 'yyyy-MM-dd hh:mm:ss'))
				emailText = emailText + "</BODY></HTML>"
				emailSubject = 'Winter shelter task reminder : ' + str(getWSTaskReminderEmail.getValueAt(i,'title'))
				loggerName = 'WS_Task_Reminder'
				to_addr = [staffEmail,assignerEmail]
				message = emailText
				logger = system.util.getLogger(loggerName)
				try:
					system.net.sendEmail(fromAddr="discovery-notifications@roomintheinn.org", subject=emailSubject, 
										body= message, to= to_addr, smtpProfile="discoverynotifications",html=1)
					logger.info('Email sent successfully.\nSubject: '+ str(emailSubject) + '\nTo: ' + to_addr)
				except:
					logger.info('Could not send email because none of the recipients had valid email addresses.')
					
def incomplete_ws_registration_email():
	loggerName = "incomplete_ws_registration_email"
	# get current season id
	getCurrentSeason = system.db.runNamedQuery("WinterShelterGlobal/getCurrentSeason")
	seasonId = getCurrentSeason.getValueAt(0,'id')
	isEnableEvent = 'true'
	
	if isEnableEvent == 'true':
		# get first day of night and prior date of all congregations
		parameters = {"seasonId":seasonId}
		getIncompleteRegistration = system.db.runNamedQuery("WinterShelterGlobal/Registration/getIncompleteRegistration",parameters=parameters)
		todayDate = system.date.now()
		
		if getIncompleteRegistration.getRowCount()>0:
			for i in range(0,getIncompleteRegistration.getRowCount()):
				primaryCoordinatorEmail = getIncompleteRegistration.getValueAt(i,'primaryCoordinatorEmail')
				secondaryCoordinatorEmail = getIncompleteRegistration.getValueAt(i,'secondaryCoordinatorEmail')
				congregation = getIncompleteRegistration.getValueAt(i,'locationName')
				locationId = getIncompleteRegistration.getValueAt(i,'locationId')
				congregationEmail = get_email_from_congregation(congregation)
				toAddress = "shelter@roomintheinn.org"
				emailText = "Please complete registration for congregation : " + str(congregation)
				emailSubject = "Incomplete Registration : " + str(congregation)
				send_email(toAddress,emailText,emailSubject,loggerName)
				system.db.runPrepUpdate("Update shelter.LocationSeasonal set IncompleteRegistrationEmail = '" + str(system.date.format(todayDate,'yyyy-MM-dd hh:mm:ss')) + "' where locationId = "+str(locationId))
