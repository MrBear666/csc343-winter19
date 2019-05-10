SET SEARCH_PATH TO parlgov;
drop table if exists q4 cascade;

--create table for q4
create table q4(
year INT,
countryName VARCHAR(50),
voteRange VARCHAR(20),
partyName VARCHAR(100)
);

DROP VIEW IF EXISTS votingPercent, voteRange CASCADE;

-- find voting percentage for each party 
-- from every election, country and year
CREATE VIEW votingPercent AS (
    SELECT election.country_id, 
        election_result.party_id,
        extract(year FROM election.e_date) AS year,
        1.0*election_result.votes/election.votes_valid AS percent
    FROM election, 
        election_result
    WHERE election.id = election_result.election_id AND
        election_result.votes is not null AND
        election.votes_valid is not null AND
        extract(year FROM election.e_date) >= 1996 AND
        extract(year FROM election.e_date) <= 2016
);

-- finding average voting percentage and  average voteRange
-- for each party from every country and every year
CREATE VIEW voteRange AS (
    SELECT country_id, party_id, year,
        CASE
        WHEN 0 <= 1.0*sum(percent)/count(percent) AND 1.0*sum(percent)/count(percent) <= 0.05 THEN '(0-5]'
        WHEN 0.05 < 1.0*sum(percent)/count(percent) AND 1.0*sum(percent)/count(percent) <= 0.1 THEN '(5-10]'
        WHEN 0.1 < 1.0*sum(percent)/count(percent) AND 1.0*sum(percent)/count(percent) <= 0.2 THEN '(10-20]'
        WHEN 0.2 < 1.0*sum(percent)/count(percent) AND 1.0*sum(percent)/count(percent) <= 0.3 THEN '(20-30]'
        WHEN 0.3 < 1.0*sum(percent)/count(percent) AND 1.0*sum(percent)/count(percent) <= 0.4 THEN '(30-40]'
        WHEN 0.4 < 1.0*sum(percent)/count(percent) AND 1.0*sum(percent)/count(percent) <= 1 THEN '(40-100]'
        END AS voteRange
    FROM votingPercent
    GROUP BY country_id, party_id, year
);

-- final answer
INSERT INTO q4 (
    SELECT year, country.name AS countryName, voteRange, party.name_short AS partyName
    FROM voteRange, party, country
    WHERE voteRange.country_id = country.id AND
        voteRange.party_id = party.id
);
