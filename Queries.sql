-- ============================================================
--        FASHION SHOW DATABASE — SQL QUERIES
-- ============================================================

15 queries on the Fashion Show Management Database.
Each query includes the question, SQL code, and output.


-- ============================================================
--                     STANDARD QUERIES
-- ============================================================


-- QUERY 1: Upcoming Shows with Venue and Organizer
-- --------------------------------------------------------
-- Show all upcoming fashion shows along with the venue
-- name and organizer name.

SELECT f.ShowID, f.Theme, v.Name AS venue, o.FullName AS organizer
FROM FASHION_SHOW f
JOIN VENUE v ON f.VenueID = v.VenueID
JOIN ORGANIZER o ON f.OrganizerID = o.OrganizerID
WHERE f.Date >= CURRENT_DATE;

Output:
ShowID | Theme           | Venue                | Organizer
-------|-----------------|----------------------|--------------
101    | Summer Vibes    | The Grand Ballroom   | Amit Desai
102    | Winter Luxe     | Expo Convention Hall | Riya Mehta
103    | Urban Street    | Skyline Arena        | Kunal Verma
104    | Royal Heritage  | Heritage Palace      | Sneha Chauhan
105    | Beach Style     | Coastal View Hall    | Kunal Verma
106    | Modern Fusion   | Metro Convention     | Riya Mehta
107    | Dubai Glamour   | The Ritz Hall        | Amit Desai


-- QUERY 2: Designers in Show 101
-- --------------------------------------------------------
-- List all designers participating in Show 101 and
-- their confirmation status.

SELECT d.Name, p.Confirmation_Status
FROM PARTICIPATES p
JOIN DESIGNER d ON p.DesignerID = d.DesignerID
WHERE p.ShowID = 101;

Output:
Designer     | Confirmation_Status
-------------|--------------------
Rahul Jain   | Confirmed
Anita Kapoor | Confirmed


-- QUERY 3: Full Runway Order of Show 101
-- --------------------------------------------------------
-- Get the complete walk order for Show 101 — who walked,
-- which garment, in which segment.

SELECT w.WalkNumber, m.FullName AS model, g.Name AS garment,
       s.SegmentName
FROM WALKS_IN w
JOIN MODEL m ON w.ModelID = m.ModelID
JOIN GARMENT g ON w.GarmentID = g.GarmentID
JOIN SEGMENT s ON w.SegmentID = s.SegmentID
WHERE s.ShowID = 101
ORDER BY w.WalkNumber;

Output:
Walk | Model       | Garment              | Segment
-----|-------------|----------------------|-------------
1    | Aisha Khan  | Crimson Evening Gown | Opening Walk
2    | Rohit Singh | Ocean Blue Lehenga   | Main Show
3    | Neha Verma  | Noir Biker Jacket    | Main Show
4    | Aisha Khan  | Ivory Cocktail Dress | Grand Finale


-- QUERY 4: Models Walking for Multiple Designers in Show 101
-- --------------------------------------------------------
-- Find models who wore garments from more than one
-- designer in the same show.

SELECT m.FullName, COUNT(DISTINCT g.DesignerID) AS designer_count
FROM WALKS_IN w
JOIN MODEL m ON w.ModelID = m.ModelID
JOIN GARMENT g ON w.GarmentID = g.GarmentID
JOIN SEGMENT s ON w.SegmentID = s.SegmentID
WHERE s.ShowID = 101
GROUP BY m.ModelID, m.FullName
HAVING COUNT(DISTINCT g.DesignerID) > 1;

Output:
(No results — in Show 101, Aisha Khan walked in G1 and G4,
both belonging to Designer 1 (Rahul Jain). No model wore
garments from more than one designer in this show.)


-- QUERY 5: Total Sponsorship Amount per Show
-- --------------------------------------------------------
-- How much sponsorship money did each show receive in total?

SELECT ShowID, SUM(ContributionAmount) AS total_sponsorship
FROM SPONSORSHIP
GROUP BY ShowID;

Output:
ShowID | total_sponsorship
-------|------------------
101    | 120000
102    | 63000
103    | 41000
104    | 58000
105    | 32000
106    | 51000


-- QUERY 6: Top 3 Designers by Number of Garments
-- --------------------------------------------------------
-- Which designers have created the most garments?

SELECT d.Name, COUNT(g.GarmentID) AS total_garments
FROM DESIGNER d
JOIN GARMENT g ON d.DesignerID = g.DesignerID
GROUP BY d.DesignerID, d.Name
ORDER BY total_garments DESC
LIMIT 3;

Output:
Designer     | Garments
-------------|----------
Rahul Jain   | 3
Anita Kapoor | 2
Zara Khan    | 2


-- QUERY 7: Average Garment Production Cost per Designer
-- --------------------------------------------------------
-- What is the average cost of garments made by each designer?

SELECT d.Name, AVG(g.ProductionCost) AS avg_cost
FROM DESIGNER d
JOIN GARMENT g ON d.DesignerID = g.DesignerID
GROUP BY d.Name;

Output:
Designer       | Avg Cost
---------------|----------
Rahul Jain     | 21900.00
Anita Kapoor   | 15750.00
Zara Khan      | 12150.00
Vikas Sharma   | 21500.00
Meera Joshi    |  9800.00
Arjun Malhotra | 24500.00


-- QUERY 8: Garments That Appeared in More Than One Show
-- --------------------------------------------------------
-- Find garments that were shown in multiple fashion shows.

SELECT g.Name, COUNT(DISTINCT s.ShowID) AS show_count
FROM WALKS_IN w
JOIN GARMENT g ON w.GarmentID = g.GarmentID
JOIN SEGMENT s ON w.SegmentID = s.SegmentID
GROUP BY g.GarmentID, g.Name
HAVING COUNT(DISTINCT s.ShowID) > 1;

Output:
Garment              | Shows
---------------------|------
Crimson Evening Gown | 2


-- QUERY 9: Each Sponsor's Total Contribution
-- --------------------------------------------------------
-- Show how much each sponsor has contributed across all shows.

SELECT s.CompanyName, SUM(sp.ContributionAmount) AS total_amount
FROM SPONSOR s
JOIN SPONSORSHIP sp ON s.SponsorID = sp.SponsorID
GROUP BY s.SponsorID, s.CompanyName;

Output:
Sponsor          | Total
-----------------|--------
Luxe Brands Co.  | 162000
GlowUp Cosmetics | 104000
Shine Jewels     | 41000
StyleHub India   | 58000


-- QUERY 10: Shows with Highest Media Coverage
-- --------------------------------------------------------
-- Which shows got the most media attention based on
-- estimated reach?

SELECT ShowID, SUM(EstimatedReach) AS total_reach
FROM COVERED_BY
GROUP BY ShowID
ORDER BY total_reach DESC;

Output:
ShowID | total_reach
-------|------------
101    | 303000
103    | 301000
105    | 162000
102    | 147000
104    | 136000


-- ============================================================
--                     ADVANCED QUERIES
-- ============================================================


-- QUERY 11: Designer Whose Garments Appeared in Most Shows
-- --------------------------------------------------------
-- Find which designer's garments have been featured across
-- the highest number of different shows.

SELECT d.DesignerID, d.Name
FROM DESIGNER d
WHERE d.DesignerID IN (
    SELECT g.DesignerID
    FROM GARMENT g
    JOIN WALKS_IN w ON g.GarmentID = w.GarmentID
    JOIN SEGMENT s ON w.SegmentID = s.SegmentID
    GROUP BY g.DesignerID
    HAVING COUNT(DISTINCT s.ShowID) = (
        SELECT MAX(show_count)
        FROM (
            SELECT COUNT(DISTINCT s2.ShowID) AS show_count
            FROM GARMENT g2
            JOIN WALKS_IN w2 ON g2.GarmentID = w2.GarmentID
            JOIN SEGMENT s2 ON w2.SegmentID = s2.SegmentID
            GROUP BY g2.DesignerID
        ) AS temp
    )
);

Output:
DesignerID | Name
-----------|----------
1          | Rahul Jain


-- QUERY 12: Models Who Walked in ALL Spring Shows
-- --------------------------------------------------------
-- Find models who have walked in every Spring season show.
-- Uses double NOT EXISTS for relational division.

SELECT m.ModelID, m.FullName
FROM MODEL m
WHERE NOT EXISTS (
    SELECT f.ShowID
    FROM FASHION_SHOW f
    WHERE f.Season = 'Spring'
    AND NOT EXISTS (
        SELECT *
        FROM WALKS_IN w
        JOIN SEGMENT s ON w.SegmentID = s.SegmentID
        WHERE w.ModelID = m.ModelID
        AND s.ShowID = f.ShowID
    )
);

Output:
(No results — Spring shows are 101, 103, and 105.
Models 1-3 walked only in Show 101, models 4-6 only
in Show 103, and Show 105 has no walks recorded.
No single model covered all three Spring shows.)


-- QUERY 13: Sponsors Who Gave More Than Average
-- --------------------------------------------------------
-- Find sponsors whose total contribution is above the
-- average sponsorship amount across all sponsors.

SELECT s.SponsorID, s.CompanyName, SUM(sp.ContributionAmount) AS total
FROM SPONSOR s
JOIN SPONSORSHIP sp ON s.SponsorID = sp.SponsorID
GROUP BY s.SponsorID, s.CompanyName
HAVING SUM(sp.ContributionAmount) > (
    SELECT AVG(total_amount)
    FROM (
        SELECT SUM(ContributionAmount) AS total_amount
        FROM SPONSORSHIP
        GROUP BY SponsorID
    ) AS temp
);

Output:
(Average total per sponsor = (162000+104000+41000+58000)/4 = 91250)

SponsorID | CompanyName     | Total
----------|-----------------|--------
1         | Luxe Brands Co. | 162000
2         | GlowUp Cosmetics| 104000


-- QUERY 14: Model with Most Walks in Show 101
-- --------------------------------------------------------
-- Which model walked the most number of times in Show 101?

SELECT m.ModelID, m.FullName
FROM MODEL m
JOIN WALKS_IN w ON m.ModelID = w.ModelID
JOIN SEGMENT s ON w.SegmentID = s.SegmentID
WHERE s.ShowID = 101
GROUP BY m.ModelID, m.FullName
HAVING COUNT(*) = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM WALKS_IN w2
        JOIN SEGMENT s2 ON w2.SegmentID = s2.SegmentID
        WHERE s2.ShowID = 101
        GROUP BY w2.ModelID
    ) AS temp
);

Output:
ModelID | FullName
--------|----------
1       | Aisha Khan


-- QUERY 15: Shows Where Sponsorship Exceeded Garment Costs
-- --------------------------------------------------------
-- Find shows where the total sponsorship received was more
-- than the total production cost of all garments shown.

SELECT f.ShowID, f.Theme
FROM FASHION_SHOW f
WHERE (
    SELECT SUM(sp.ContributionAmount)
    FROM SPONSORSHIP sp
    WHERE sp.ShowID = f.ShowID
) > (
    SELECT SUM(g.ProductionCost)
    FROM WALKS_IN w
    JOIN GARMENT g ON w.GarmentID = g.GarmentID
    JOIN SEGMENT s ON w.SegmentID = s.SegmentID
    WHERE s.ShowID = f.ShowID
);

Output:
(Show 101: Sponsorship=120000, Garment costs=63000 → qualifies
 Show 102: Sponsorship=63000,  Garment costs=75300 → does not qualify
 Show 103: Sponsorship=41000,  Garment costs=58500 → does not qualify)

ShowID | Theme
-------|-------------
101    | Summer Vibes


-- ============================================================
--                      QUERY SUMMARY
-- ============================================================

No. | Query                                      | Type
----|--------------------------------------------|---------
1   | Upcoming shows with venue and organizer    | Standard
2   | Designers in Show 101                      | Standard
3   | Full runway order of Show 101              | Standard
4   | Models walking for multiple designers      | Standard
5   | Total sponsorship per show                 | Standard
6   | Top 3 designers by garment count           | Standard
7   | Average garment cost per designer          | Standard
8   | Garments shown in multiple shows           | Standard
9   | Total contribution per sponsor             | Standard
10  | Shows by media coverage reach              | Standard
11  | Designer with garments in most shows       | Advanced
12  | Models in all Spring shows                 | Advanced
13  | Sponsors above average contribution        | Advanced
14  | Model with most walks in Show 101          | Advanced
15  | Shows where sponsorship > garment cost     | Advanced


-- ============================================================
--                        END OF FILE
-- ============================================================

