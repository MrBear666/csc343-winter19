SET SEARCH_PATH TO parlgov;
drop table if exists q5 cascade;

-- create table for q5
CREATE TABLE q5(
        countryName varchar(50),
        year INT,
        participationRatio REAL
);

DROP VIEW IF EXISTS Participation_Ratio, nonDecreasing CASCADE;

CREATE VIEW Participation_Ratio AS (
    SELECT country_id, extract(year FROM e_date) AS year,
        1.0*sum(votes_cast)/sum(electorate) AS participationRatio
    FROM election
    WHERE extract(year FROM e_date) <= 2016 AND
        extract(year FROM e_date) >= 2001 AND
        votes_cast is not null AND
        electorate is not null
    GROUP BY country_id, extract(year FROM e_date)
);

CREATE VIEW nonDecreasing AS (
    SELECT *
    FROM Participation_Ratio
    WHERE country_id not IN (
        SELECT distinct Participation_Ratio1.country_id
        FROM Participation_Ratio AS Participation_Ratio1, 
            Participation_Ratio AS Participation_Ratio2
        WHERE Participation_Ratio1.country_id = Participation_Ratio2.country_id AND
            Participation_Ratio1.year > Participation_Ratio2.year AND
            Participation_Ratio1.participationRatio < Participation_Ratio2.participationRatio
    )
);

-- the final answe
INSERT INTO q5 (
    SELECT country.name AS countryName, 
        nonDecreasing.year, 
        nonDecreasing.participationRatio
    FROM nonDecreasing, country
    WHERE nonDecreasing.country_id = country.id
);
