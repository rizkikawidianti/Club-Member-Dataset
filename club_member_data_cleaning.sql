-- 1. Checking duplicate values
-- checking duplicate in raw table first, before moving it to the staging table
with duplicate_check as(
	select *,
		row_number() over(partition by full_name, age,martial_status,email,phone,full_address, job_title,membership_date) as row_num
	from club_member
)
select * from duplicate_check where row_num > 1

-- create staging table to safely clean and transform data without modifying the original raw dataset
CREATE TABLE club_member_staging (
  `full_name` text,
  `age` int DEFAULT NULL,
  `martial_status` text,
  `email` text,
  `phone` text,
  `full_address` text,
  `job_title` text,
  `membership_date` text,
   `row_num` int DEFAULT null
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- insert value from raw table and added row_num for flagging the duplicate values
insert into club_member_staging 
	select *,
		row_number() over(partition by full_name, age,martial_status,email,phone,full_address, job_title,membership_date) as row_num
		from club_member

-- removing duplicates
delete from club_member_staging
where row_num > 1

-- Check remaining duplicates
select * from club_member_staging
where row_num > 1


-- 2. Standardize missing and inconsistent values, to ensure consistent handling of missing data
-- Extract clean name from corrupted string format (??? delimiter found in raw data)
alter table club_member_staging 
add column new_name varchar(255)

update club_member_staging 
set new_name = trim(SUBSTRING_INDEX(full_name,'???', -1))

-- create a function for formatting text values into Proper format
DELIMITER $$
CREATE FUNCTION PROPER(inputStr VARCHAR(255)) 
RETURNS VARCHAR(255) DETERMINISTIC NO SQL READS SQL DATA
BEGIN
    DECLARE result VARCHAR(255) DEFAULT '';
    DECLARE word VARCHAR(255);
    SET inputStr = LOWER(TRIM(inputStr));
    WHILE LENGTH(inputStr) > 0 DO
        SET word = SUBSTRING_INDEX(inputStr, ' ', 1);
        SET result = CONCAT(result, ' ', CONCAT(UPPER(LEFT(word, 1)), SUBSTRING(word, 2)));
        SET inputStr = SUBSTRING(inputStr, LENGTH(word) + 2);
    END WHILE;
    RETURN TRIM(result);
END$$
DELIMITER ;

update club_member_staging
set new_name = PROPER(new_name)

alter table club_member_staging 
add column marital_status varchar(255)

update club_member_staging
set marital_status = case
	when martial_status = '' then null
	when martial_status like '%divored%' then 'Divorced'
	else proper(martial_status)
end

-- break down the full_address column into street, city, state, and region for better analysis and cleaning the values
select full_address, SUBSTRING_INDEX(SUBSTRING_INDEX(full_address, ',', 2), ',', -1) as city,
	SUBSTRING_INDEX(full_address, ',', -1) as state
from club_member_staging

alter table club_member_staging 
add column street varchar (255),
add column city varchar (255),
add column state varchar (255),
add column region varchar (255)

update club_member_staging
set street = trim(SUBSTRING_INDEX(full_address, ',', 1)),
city = trim(SUBSTRING_INDEX(SUBSTRING_INDEX(full_address, ',', 2), ',', -1)),
state = trim(SUBSTRING_INDEX(full_address, ',', -1))

-- fixing the odd values
update club_member_staging
set state = 'South Dakota'
where state like '%South Dakotaaa%'

update club_member_staging
set state = 'Texas'
where state like '%Tej+F823as%' or state like '%Tejas%'

update club_member_staging
set state = 'North Carolina'
where state like '%NorthCarolina%'
 
update club_member_staging
set state = 'Tennessee'
where state like '%Tennesseeee%'

update club_member_staging
set state = 'California'
where state like '%Kalifornia%'

update club_member_staging
set state = 'New York'
where state like '%NewYork%'

update club_member_staging
set state = 'Kansas'
where state like '%Kansus%'

update club_member_staging
set state = 'District of Columbia'
where state like '%Districts of Columbia%'

-- Map US states into regions for higher-level geographic analysis
update club_member_staging
set region = CASE 
    -- NORTHEAST
    WHEN state IN ('Connecticut', 'Maine', 'Massachusetts', 'New Hampshire', 'Rhode Island', 'Vermont', 'New Jersey', 'New York', 'Pennsylvania') 
        THEN 'Northeast'   
    -- MIDWEST
    WHEN state IN ('Illinois', 'Indiana', 'Michigan', 'Ohio', 'Wisconsin', 'Iowa', 'Kansas', 'Minnesota', 'Missouri', 'Nebraska', 'North Dakota', 'South Dakota') 
        THEN 'Midwest'  
    -- SOUTH
    WHEN state IN ('Delaware', 'Florida', 'Georgia', 'Maryland', 'North Carolina', 'South Carolina', 'Virginia', 'District of Columbia', 'West Virginia', 'Alabama', 'Kentucky', 'Mississippi', 'Tennessee', 'Arkansas', 'Louisiana', 'Oklahoma', 'Texas') 
        THEN 'South'    
    -- WEST
    WHEN state IN ('Arizona', 'Colorado', 'Idaho', 'Montana', 'Nevada', 'New Mexico', 'Utah', 'Wyoming', 'Alaska', 'California', 'Hawaii', 'Oregon', 'Washington') 
        THEN 'West'  
    ELSE 'Other/International'
END

-- 3. Fix invalid date formats, to enable accurate time-based analysis
update club_member_staging 
set membership_date = STR_TO_DATE(membership_date, '%m/%d/%Y')


-- 4. Convert data types, to allow numerical calculations and validation
alter table club_member_staging 
modify column membership_date date null



-- 5. Delete the raw column and renaming the cleaned column
alter table club_member_staging
drop column full_name ,
drop column martial_status,
drop column full_address,
drop column row_num

-- row_num is the column for flagging the duplicate value, removing it after deleting the duplicates

alter table club_member_staging
rename column new_name to full_name


-- 6. Flag anomaly values
select *, case
	when age > 200 then 1
	when membership_date < '1920-01-01' then 1
	else 0
end as anomalies
from club_member_staging

alter table club_member_staging 
add column anomalies int

update club_member_staging 
set anomalies = case
	when age > 200 then 1
	when membership_date < '1920-01-01' then 1
	else 0
end


-- 7. Validation, to ensure data quality after cleaning
select count(*) from club_member_staging where marital_status is null;
select count(*) from club_member_staging where job_title is null;
select * from club_member_staging where anomalies = 1;









