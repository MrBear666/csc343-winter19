SET SEARCH_PATH TO parlgov;
DROP TABLE IF EXISTS q3 CASCADE;


CREATE TABLE q3(
countryName VARCHaR(100),
partyName VARCHaR(100),
partyFamily VARCHaR(100),
wonElections INT,
mostRecentlyWonElectionId INT,
mostRecentlyWonElectionYear INT
);



DROP VIEW IF EXISTS winners, won_count, party_count, election_count,
    average_wons, major_winners, most_recent_winners CASCADE;




CREATE VIEW winners AS (
    SELECT election_id, party_id
    FROM election_result AS E1
    WHERE votes = (
        SELECT MAX(votes)
        FROM election_result AS E2
        WHERE E1.election_id = E2.election_id
    )
);


CREATE VIEW won_count AS (
    SELECT W.party_id, COUNT(*) AS num_won, MAX(E.e_date) AS most_recent_e_date
    FROM winners AS W, election AS E
    WHERE W.election_id = E.id
    group BY W.party_id
);


CREATE VIEW party_count AS (
    SELECT COUNT(*) AS num_party, country_id
    FROM party
    group BY country_id
);


CREATE VIEW election_count AS (
    SELECT P.country_id, SUM(WC.num_won) AS num_election
    FROM party AS P, won_count AS WC
    WHERE WC.party_id = P.id
    group BY P.country_id
);


CREATE VIEW average_wons AS (
    SELECT PC.country_id, ((3.0*NC.num_election)/PC.num_party) AS three_average
    FROM party_count AS PC, election_count AS NC
    WHERE PC.country_id = NC.country_id
);


CREATE VIEW major_winners AS (
    SELECT P.country_id, P.id AS party_id, WC.num_won, WC.most_recent_e_date
    FROM won_count AS WC, party AS P, average_wons AS A
    WHERE p.ID = WC.party_id and
        P.country_id = A.country_id and
        WC.num_won > A.three_average
);


CREATE VIEW most_recent_winners AS (
    SELECT MW.country_id, MW.party_id, MW.num_won,
        E.id AS mostRecentlyWonElectionId,
        extract(YEAR FROM E.e_date) AS mostRecentlyWonElectionYear
    FROM major_winners AS MW, election_result AS ER, election AS E
    WHERE MW.party_id = ER.party_id 
		AND ER.election_id = E.id 
		AND E.e_date = MW.most_recent_e_date
);

-- Final Answer
INSERT INTO q3 (
    SELECT C.name AS countryName,
        P.name AS partyName,
        PF.family AS partyFamily,
        MRW.num_won AS wonElections,
        MRW.mostRecentlyWonElectionId,
        MRW.mostRecentlyWonElectionYear
    FROM most_recent_winners AS MRW INNER JOIN country AS C
        ON MRW.country_id = C.id
        INNER JOIN party AS P
        ON MRW.party_id = P.id
        LEFT JOIN party_family AS PF
        ON MRW.party_id = PF.party_id
);
