SELECT 
eventID, allDay, bymonth, bysetpos, category, endDate, freq, interval, repeat, subCategory,
startDate, title, monday, tuesday, wednesday, thursday, friday, saturday, sunday
FROM calendar.CalendarEvents
WHERE 
	deleted = 0