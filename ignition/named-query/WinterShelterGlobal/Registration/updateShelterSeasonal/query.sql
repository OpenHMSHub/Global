UPDATE
	shelter.LocationSeasonal 
SET 
	 beds = :beds 
	 , genderId = :genderId 
	 , families = :families 
	 , extraShortNotice = :extraShortNotice 
	 , showers = :showers 
	 , clothing = :clothing 
	 , laundry = :laundry 
	 , sackLunches = :sackLunches 
	 , breakfast = :breakfast 
	 , dinner = :dinner 
	 , haircuts = :haircuts 
	 , hygieneItems = :hygieneItems 
	 , otherService = :otherService 
	 , otherServiceList = :otherServiceList 
	 , accessible = :accessible 
	 , stairs = :stairs 
	 , smoking = :smoking 
	 , partners = :partners 
	 , serviceNotes = :serviceNotes 
	 , notes = :notes 
	 , scheduleComments = :scheduleComments 
	 , reminderCall = :reminderCall 
	 , otherHostMore = :otherHostMore
	 , nights = :nights 
	 , hostLocationTypeId =  :hostLocationTypeId 
	 ,transportId = :transportId
	 ,frequencyId = :frequencyId
	 ,dateSelectionPattern = :dateSelectionPattern
	 ,dateSelectionDays = :dateSelectionDays
	 ,pickupTime =  :pickupTime 
WHERE id = :locationSeasonId;
