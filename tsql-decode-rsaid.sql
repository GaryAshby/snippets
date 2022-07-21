/*
  	A South African ID number is a 13-digit number which is defined by the following format: YYMMDDSSSSCAZ.
		- The first 6 digits (YYMMDD) are based on your date of birth. 20 February 1992 is displayed as 920220.
		- The next 4 digits (SSSS) are used to define your gender.  Females are assigned numbers in the range 0000-4999 and males from 5000-9999.
		- The next digit (C) shows if you're an SA citizen status with 0 denoting that you were born a SA citizen and 1 denoting that you're a permanent resident.
		- The last digit (Z) is a checksum digit – used to check that the number sequence is accurate using a set formula called the Luhn algorithm.
		- The graphic below details the different sections of an ID number, based on the fictitious sequence 9202204720082
    
  Format:
	{YYMMDD}{G}{SSS}{C}{A}{Z}
	YYMMDD : Date of birth.
	G  : Gender. 0-4 Female; 5-9 Male.
	SSS  : Sequence No. for DOB/G combination.
	C  : Citizenship. 0 SA; 1 Other.
	A  : Usually 8, or 9 [can be other values]
	Z  : Control digit calculated in the following section:
	ORIGINAL: (missing) http://geekswithblogs.net/willemf/archive/2005/10/30/58561.aspx

	Extra references: 
		https://www.westerncape.gov.za/general-publication/decoding-your-south-african-id-number-0
		https://en.wikipedia.org/wiki/Luhn_algorithm
*/
DECLARE @RSAID varchar(13) = '9202204720082' -- Invalid ID from https://www.westerncape.gov.za/general-publication/decoding-your-south-african-id-number-0

BEGIN TRY 
	--DECLARE @RSAID char(13)
	DECLARE @RSAID1 char(1)
	DECLARE @RSAID2 char(1)
	DECLARE @RSAID3 char(1)
	DECLARE @RSAID4 char(1)
	DECLARE @RSAID5 char(1)
	DECLARE @RSAID6 char(1)
	DECLARE @RSAID7 char(1)
	DECLARE @RSAID8 char(1)
	DECLARE @RSAID9 char(1)
	DECLARE @RSAID10 char(1)
	DECLARE @RSAID11 char(1)
	DECLARE @RSAID12 char(1)
	DECLARE @RSAID13 char(1)

	DECLARE @dob char(6)
	DECLARE @gender char(1)
	DECLARE @citizenship char(1)

	DECLARE @checkValid bit
	DECLARE @checkDob date
	DECLARE @checkAge tinyint
	DECLARE @checkGender char(1)
	DECLARE @checkCitizenship bit

	DECLARE @Digits int
	DECLARE @Evenx2 varchar(10)
	DECLARE @Odd varchar(10)

	--Validation
	SET @Digits = 0
	SET @RSAID1 = substring(cast(@RSAID as varchar),1,1)
	SET @RSAID2 = substring(cast(@RSAID as varchar),3,1)
	SET @RSAID3 = substring(cast(@RSAID as varchar),2,1)
	SET @RSAID4 = substring(cast(@RSAID as varchar),4,1)
	SET @RSAID5 = substring(cast(@RSAID as varchar),5,1)
	SET @RSAID6 = substring(cast(@RSAID as varchar),6,1)
	SET @RSAID7 = substring(cast(@RSAID as varchar),7,1)
	SET @RSAID8 = substring(cast(@RSAID as varchar),8,1)
	SET @RSAID9 = substring(cast(@RSAID as varchar),9,1)
	SET @RSAID10 = substring(cast(@RSAID as varchar),10,1)
	SET @RSAID11 = substring(cast(@RSAID as varchar),11,1)
	SET @RSAID12 = substring(cast(@RSAID as varchar),12,1)
	SET @RSAID13 = substring(cast(@RSAID as varchar),13,1)

	SET @dob = substring(cast(@RSAID as varchar),1,6)
	SET @gender = substring(cast(@RSAID as varchar),7,1)
	SET @citizenship = substring(cast(@RSAID as varchar),11,1)

	SET @Odd = (cast(substring(@RSAID,1,1) as int)
				+cast(substring(@RSAID,3,1) as int)
				+cast(substring(@RSAID,5,1) as int)
				+cast(substring(@RSAID,7,1) as int)
				+cast(substring(@RSAID,9,1) as int)
				+cast(substring(@RSAID,11,1) as int))

	SET @Evenx2 =		cast((	cast(cast(substring(@RSAID,2,1) as int)	 * 2 as varchar)
							+	cast(cast(substring(@RSAID,4,1) as int)	 * 2 as varchar)
							+	cast(cast(substring(@RSAID,6,1) as int)	 * 2 as varchar)
							+	cast(cast(substring(@RSAID,8,1) as int)	 * 2 as varchar)
							+	cast(cast(substring(@RSAID,10,1) as int) * 2 as varchar)
							+	cast(cast(substring(@RSAID,12,1) as int) * 2 as varchar)
						) as varchar)

	WHILE LEN(@Evenx2) <> 0
	BEGIN
		SET @Digits = @Digits + cast(substring(@Evenx2,1,1) as int)
		SET @Evenx2 = SUBSTRING(@Evenx2,2,len(@Evenx2))			
	END

	-- Is Valid
	SELECT @checkValid =
	CASE
		WHEN 10-((@Digits+@Odd) % 10) = @RSAID13 THEN 1 ELSE 0 END
	
	-- Date of Birth
	SELECT @checkDob = CONVERT(DATE, @dob, 126)

	-- Gender
	SELECT @checkGender =
	CASE   
		WHEN @gender LIKE '[0-4]' THEN 'F'
		WHEN @gender LIKE '[5-9]' THEN 'M'
	END

	-- Is South African Citizen - "Go Bokke!"
	SELECT @checkCitizenship =
	CASE   
		WHEN @citizenship = 0 THEN 1
		WHEN @citizenship = 1 THEN 0
	END

	SELECT @checkAge = DATEDIFF(hour,@dob,GETDATE())/8766

	SELECT @checkValid AS valid, @checkAge AS age, @checkDob AS date_of_birth, @checkGender AS gender, @checkCitizenship AS citizen
	
END TRY

BEGIN CATCH

	SELECT @checkAge = DATEDIFF(hour,'1970-01-01',GETDATE())/8766

	SELECT 0 AS valid, @checkAge AS age, CAST('1970-01-01' AS DATE) AS date_of_birth, 'U' AS gender, 0 AS citizen
	
END CATCH
