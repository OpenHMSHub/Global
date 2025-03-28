---Determine the current, past and next season
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @thisSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 7 THEN @thisYear ELSE (@thisYear - 1) END
DECLARE @lastSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 7 THEN (@thisYear - 1) ELSE (@thisYear - 2) END
DECLARE @nextSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 7 THEN (@thisYear + 1) ELSE (@thisYear) END
---Determine the current, past and next season ID's
DECLARE @thisSeasonId int
SELECT @thisSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @thisSeasonStartYear + '%'

DECLARE @lastSeasonId int
SELECT @lastSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @lastSeasonStartYear + '%'


SELECT
    l.congregationid,
    l.locationName AS 'Name',
    --Congregation_Name AS 'Name',
    l.addressLine1 AS 'Address One',
    l.addressLine2 AS 'Address Two',
    l.city,
    l.state,
    l.zipCode AS 'Zipcode',
    l.timeCreated,
    l.timeRetired,
    ls.genderID,
    ls.seasonId,
    --ls.nights,
    ls.numberOfWeeks,
    ls.beds,
    ls.accessible,
    ls.families,
    ls.extraShortNotice,
    ls.stairs,
    ls.smoking,
    ls.reminderCall,
    ls.showers,
    ls.beds,
	ls.bedsProjected as 'projection',
	ls.bedsActual as 'actual',
	ISNULL(ls.numberOfWeeks,'') as 'numberOfWeeks', 
	cast(ls.nights & 1 as bit) as 'monday',
	cast(ls.nights & 2 as bit) as 'tuesday',
	cast(ls.nights & 4 as bit) as 'wednesday',
	cast(ls.nights & 8 as bit) as 'thursday',
	cast(ls.nights & 16 as bit) as 'friday',
	cast(ls.nights & 32 as bit) as 'saturday',
	cast(ls.nights & 64 as bit) as 'sunday',
	g.genderAccepted As 'Gender Accepted',
	lsp.nights AS 'Last Season Total'
    --Phone_Number AS 'Phone',
    --Phone_Number_we_can_use_to_reach_you_during_evening_hours AS 'Evening Phone',
    --Office_Email AS 'Email',
    --Preferred_Method_of_Communication AS 'Preferred Communication',
    --Comments,
    --Comments2,
    --Coordinator_fName + ' ' + Coordinator_lName AS 'Coordinator',
    --cCity,
    --cZip_Code AS 'cZipcode',
    --cComments,
    --cPrimary_Phone_Number AS 'cPhone',
    --cEmail_Address AS 'cEmail',
    --cHome_Address AS 'cAddress',
    --Back_Up_Coordinator_fName + ' ' + Back_Up_Coordinator_lName AS 'Backup Coordinator1',
    --Back_Up_Coordinator_fName2 + ' ' + Back_Up_Coordinator_lName2 AS 'Backup Coordinator2',
    --bcCity,
    --bcZip_Code AS 'bcZipcode',
    --bcEmail_Address AS 'bcEmail',
    --bcHome_Address AS 'bcAddress',
    --bcPrimary_Phone_Number AS 'bcPhone',
    --bcPreferred_Method_Of_Communication 'bcPreferred Communication',
    --Minister_Pastor_Congregation_Leader AS 'Congregation Leader',
    --Night_s_of_the_Week_Hosting AS 'Nights Hosted',
    --Days_To_Host,
    --Number_of_Days,
    --Number_of_Guests,
    --Phone_Number_we_can_use_to_reach_you_during_evening_hours AS 'Evening Phone',
    --Gender_of_Guests AS 'Gender of Guests',
    --Are_guests_required_to_climb_stairs AS 'Stairs',
    --List_other_congregations_organizations_that_work_with_your_congregation_to_host_Room_In_The_Inn AS 'Partner Congregations in Hosting',
    --Can_you_accommodate_a_guest_who_uses_a_wheelchair AS "Wheelchair Access",
    --Is_a_designated_outdoor_smoking_area_provided AS 'Designated Smoking Area?',
    --We_are_open_to_hosting_families_with_children AS 'Can Host Families',
    --We_would_like_to_receive_a_reminder_call_in_the_week_before_our_scheduled_date_s_to_host AS "Reminder Call",
    --Our_congregation_might_be_able_to_do_more_host_more_guests_or_nights_if_we_had AS 'Could do more if',
    --Our_congregation_is_able_to_host_extra_nights_on_short_notice_in_the_event_of_extreme_weather AS 'Extreme Weather',
    --Special_Services_Offered_Check_all_that_apply AS 'Special Services',
    --Comments_about_Dates_Selected AS 'Date Comments',
    --Comments_for_the_Room_In_The_Inn_Staff AS 'Comments for RITI',
    --Submission_Date AS 'Submission Date',
    --_2020_Projected AS '2020 Projected',
    --Delimeter

FROM shelter.Location l
LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE seasonID = @thisSeasonId) ls ON l.congregationID = ls.locationid
--LEFT JOIN (SELECT * FROM shelter.LocationSeasonal WHERE ID IN (Select max(id) FROM shelter.LocationSeasonal 
--		WHERE seasonID <= @lastSeasonID GROUP BY locationId)) lsp ON l.congregationID = lsp.locationid
LEFT JOIN shelter.gender g on ls.genderID = g.id
LEFT JOIN  (SELECT nights,locationid FROM shelter.LocationSeasonal WHERE ID IN (Select max(id) FROM shelter.LocationSeasonal 
		WHERE seasonID <= @lastSeasonID GROUP BY locationId)) lsp ON l.congregationID = lsp.locationid

			
--left join shelter.LocationSeasonal ls on l.congregationID = ls.locationId

WHERE congregationID = :ID --AND Submission_Date IS NOT NULL