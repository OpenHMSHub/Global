--WinterShelter/Registration/insertLocationRegistration--
---Determine the current season
DECLARE @thisMonth int = Month(GetDate())
DECLARE @thisYear varchar(4) = Year(GetDate())
DECLARE @thisSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 5 THEN @thisYear ELSE (@thisYear - 1) END
DECLARE @lastSeasonStartYear varchar(4) = CASE WHEN @thisMonth > 6 THEN (@thisYear - 1) ELSE (@thisYear - 2) END
---Determine the current, past and next season ID's
DECLARE @thisSeasonId int
SELECT @thisSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @thisSeasonStartYear + '%'

DECLARE @lastSeasonId int
SELECT @lastSeasonId = s.id FROM shelter.Seasons s WHERE s.Seasons like @lastSeasonStartYear + '%'

---Get the gender ID from the last active season
DECLARE @genderId int
SELECT @genderId = lsp.genderId FROM  shelter.LocationSeasonal lsp where lsp.seasonId = :lastActiveSeasonId and lsp.locationId = :locationId   
---Get the number of beds from the last active season
DECLARE @beds int
SELECT @beds = lsp.beds FROM  shelter.LocationSeasonal lsp where lsp.seasonId = :lastActiveSeasonId and lsp.locationId = :locationId 

IF @beds < 8
BEGIN
	SET @beds = 8
END
ELSE
BEGIN
	IF  @beds >= 8 and @beds <= 12
	BEGIN
		SET @beds = 12
	END
	
END
INSERT INTO shelter.LocationSeasonal 
	 (
	 locationId 
	 ,seasonId
	 ,genderId
	 ,beds 
	 ,bedsProjected 
	 ,bedsActual  
	 ,timeCreated
	 ,[pickupTime] 
	 )
VALUES
	 (
	 :locationId 
	 , :newSeasonId 
	 ,@genderId
	 ,@beds
	 ,0
	 ,0
	 ,GetDate()
	 ,'NO TIME'
	)