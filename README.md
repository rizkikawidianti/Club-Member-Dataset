# Club-Member-Dataset
**Project Overview:**

This project focuses on cleaning and transforming a raw club membership dataset using SQL. The raw data contains member information such as personal details, contact information, address, job title, and membership dates. However, the raw data includes various data quality issues such as duplicate records, inconsistent formatting, corrupted text values, and unstructured address fields. The final dataset is designed to support accurate analysis of member demographics, geographic distribution, and membership trends.

**Business Context:**

The dataset represents membership records for a club or organization that tracks member demographics, location, and engagement over time. This data is typically used by operations and management teams to understand member distribution across different regions, monitor membership growth and trends over time, also support decision-making for marketing, expansion, and member engagement strategies. To ensure reliable analysis and decision-making, the dataset must be cleaned, standardized, and structured before use.

**Cleaning Objectives:**

- Ensure each member record is unique and accurate
- Standardize text fields for consistency
- Transform address data into structured components (city, state, region)
- Improve data usability for geographic and demographic analysis
- Detect and flag suspicious or invalid records


**Dataset Overview:**

- Grain: 1 row = 1 member data
- 2007 rows and 8 columns
- date range: 1912 - 2022

**Data Issues Identified:**

During initial exploration, several data quality issues were identified:

1. Duplicate records identified based on full_name with conflicting attribute values
2. Missing and inconsistent values in columns full_name, martial_status (??? delimiter, typos, blanks)
3. No categorization in address column
4. Invalid date formats
5. Invalid data types
6. Outliers in age and membership_date


**Cleaning Steps Performed:**

1. Resolved Duplicates
    - Investigated duplicate full_name
    - Removed inconsistent duplicates after validation
2. Handled Missing Values
    - Removed ??? delimiter
    - Standardized inconsistent categorical values (e.g., corrected misspelled state names such as 'Kalifornia' → 'California')
    - Replaced blanks with NULL
3. No categorization in address column
    - Break down the full_address column into street, city, state, and region
4. Validated Data Types
    - Converted date columns into a proper date format
5. Checked Outliers
    - Identified extreme values and assessed business validity

**Key Decisions & Assumptions:**

- Duplicate values are removed after validation
- Blank values were treated as NULL to standardize missing data handling
- Typos in state column were fixed after validation
- full_address column is broken down into street, city, state, and region for better analysis
- Mapping US states into regions for higher-level geographic analysis
- Outliers are flagged in anomalies column (added for this purpose)


**Before VS After:**

- Before Cleaning
<img width="1315" height="789" alt="before" src="https://github.com/user-attachments/assets/3a694052-0066-47c9-9f41-4d8b8a42452d" />


- After Cleaning
<img width="1536" height="784" alt="after" src="https://github.com/user-attachments/assets/4e9c3fad-6cc0-4fea-960b-f91b03f44d18" />



Data Validation

- Verified no remaining invalid date formats
- Checked for consistency in categorical values
- Checked for all outliers to be flagged
- Confirmed no unexpected data loss during cleaning

**Final Output:**

Dataset Overview:

- 2004 rows and 12 columns
- date range: 2012 - 2022

The cleaned dataset enables:

- Accurate demographic analysis of members
- Reliable geographic segmentation using region mapping
- Better tracking of membership trends over time
- Identification of suspicious or invalid records through anomaly flags

**Key Takeaways:**

- Data cleaning requires both technical execution and judgment
- Validation is required so not all duplicates can be removed blindly
- Structuring unstructured data (e.g., full_address) significantly improves analytical usability
- Data validation is critical to ensure reliability of downstream analysis















