-- =========================================
-- JOINS Examples
-- =========================================
--INNER JOIN: Get open claims and the assigned adjuster user
SELECT 
  C.ClaimNumber, 
  C.Status, 
  CONCAT(U.FirstName, ' ', U.LastName) AS AdjusterName
FROM Claims C
INNER JOIN Users U ON C.AdjusterUserID=U.UserID
WHERE C.Status = 'O' -- 'O' = Open
ORDER BY C.ClaimNumber

**Use case:** Identify all open, assigned claims

-- Expected Output:
-- ClaimNumber | Status | AdjusterName
-- ABC12345    | O      | Jane Doe
  

--LEFT JOIN: Get all opened or reopened claims include unassigned claims
SELECT 
    C.ClaimNumber, 
    C.Status,
    CASE 
        WHEN C.AdjusterUserID IS NULL THEN 'Unassigned'
        ELSE CONCAT(U.FirstName, ' ', U.LastName)
    END AS AdjusterName
FROM Claims C
LEFT JOIN Users U ON C.AdjusterUserID = U.UserID
WHERE C.Status IN ('O','R') -- 'O' = Open, 'R' = Reopen
ORDER BY AdjusterName, C.ClaimNumber;

**Use case:** Show all claims that are opened or reopened include claims without assigned adjusters

-- Expected Output:
-- ClaimNumber | Status | AdjusterName
-- ABC12345    | O      | Jane Doe
-- DEF98765    | R      | Unassigned
  

--RIGHT JOIN: Get all active adjuster users and the count of claims they closed this year. The adjusters with the most claims closed will appear first. 
SELECT 
  CONCAT(U.FirstName, ' ', U.LastName) AS AdjusterName, 
  COUNT(C.ClaimID) AS ClaimCount
FROM Claims C
RIGHT JOIN Users U ON C.AdjusterUserID = U.UserID
WHERE C.Status = 'C' -- 'C' = Closed
  AND C.LastCloseDate > DATEFROMPARTS(YEAR(GETDATE()), 1, 1)
  AND U.IsActive = 1 -- 1 = Active users
GROUP BY CONCAT(U.FirstName, ' ', U.LastName)
ORDER BY ClaimCount DESC;

**Use case:** Analyze the adjusters workloads
  

-- Expected Output:
-- AdjusterName | Claim Count
-- Jane Doe     | 24 
-- Sally Lu     | 16 

--FULL OUTER JOIN: Show all open and reopened claims and active adjuster users
SELECT 
    C.ClaimNumber, 
    C.Status, 
    CONCAT(U.FirstName, ' ', U.LastName) AS AdjusterName
FROM Claims C
FULL OUTER JOIN Users U ON C.AdjusterUserID = U.UserID
WHERE C.Status IN ('O','R') -- 'O' = Open, 'R' = Reopen
ORDER BY AdjusterName, ClaimNumber;

**Use case:** Identify claims without adjusters AND adjusters without claims


-- Expected Output:
-- ClaimNumber | Status | AdjusterName
-- ABC12345    | O      | 
-- DEF98765    | R      | Wendy Wu
