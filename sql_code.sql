-- 1. Join dim_customers with dim_geography to enrich customer data with geographic information
SELECT 
    c.CustomerID,
    c.CustomerName,
    c.Email,
    c.Gender,
    c.Age,
    g.Country,
    g.City
FROM 
    dbo.customers AS c
LEFT JOIN
    dbo.geography AS g
ON 
    c.GeographyID = g.GeographyID;

-- 2. Categorize products based on their price into Low, Medium, or High
SELECT 
    ProductID,
    ProductName,
    Price,
    CASE 
        WHEN Price < 50 THEN 'Low'
        WHEN Price BETWEEN 50 AND 200 THEN 'Medium'
        ELSE 'High'
    END AS PriceCategory
FROM 
    dbo.products;

-- 3. Clean whitespace issues in the ReviewText column of customer_reviews
SELECT 
    ReviewID,
    CustomerID,
    ProductID,
    ReviewDate,
    Rating,
    REPLACE(ReviewText, '  ', ' ') AS ReviewText
FROM 
    dbo.customer_reviews;

-- 4. Normalize engagement_data table by formatting dates and splitting fields
SELECT 
    EngagementID,
    ContentID,
    CampaignID,
    ProductID,
    UPPER(REPLACE(ContentType, 'Socialmedia', 'Social Media')) AS ContentType,
    LEFT(ViewsClicksCombined, CHARINDEX('-', ViewsClicksCombined) - 1) AS Views,
    RIGHT(ViewsClicksCombined, LEN(ViewsClicksCombined) - CHARINDEX('-', ViewsClicksCombined)) AS Clicks,
    Likes,
    FORMAT(CONVERT(DATE, EngagementDate), 'dd.MM.yyyy') AS EngagementDate
FROM 
    dbo.engagement_data
WHERE 
    ContentType != 'Newsletter';

-- 5. Identify and tag duplicate records using ROW_NUMBER
WITH DuplicateRecords AS (
    SELECT 
        JourneyID,
        CustomerID,
        ProductID,
        VisitDate,
        Stage,
        Action,
        Duration,
        ROW_NUMBER() OVER (
            PARTITION BY CustomerID, ProductID, VisitDate, Stage, Action
            ORDER BY JourneyID
        ) AS row_num
    FROM 
        dbo.customer_journey
)
SELECT *
FROM DuplicateRecords
ORDER BY JourneyID;

-- 6. Final cleaned data with duplicates removed and missing durations replaced by average
SELECT 
    JourneyID,
    CustomerID,
    ProductID,
    VisitDate,
    Stage,
    Action,
    COALESCE(Duration, avg_duration) AS Duration
FROM 
    (
        SELECT 
            JourneyID,
            CustomerID,
            ProductID,
            VisitDate,
            UPPER(Stage) AS Stage,
            Action,
            Duration,
            AVG(Duration) OVER (PARTITION BY VisitDate) AS avg_duration,
            ROW_NUMBER() OVER (
                PARTITION BY CustomerID, ProductID, VisitDate, UPPER(Stage), Action
                ORDER BY JourneyID
            ) AS row_num
        FROM 
            dbo.customer_journey
    ) AS subquery
WHERE 
    row_num = 1;
