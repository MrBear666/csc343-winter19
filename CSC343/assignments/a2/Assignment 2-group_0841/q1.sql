SET SEARCH_PATH TO parlgov;


DROP TABLE IF EXISTS q1 CASCADE;
CREATE TABLE q1(
        countryId INT,
        alliedPartyId1 INT,
        alliedPartyId2 INT
);


DROP VIEW IF EXISTS alliance, election_count, percentage CASCADE;


CREATE VIEW alliance AS (
    SELECT ER1.election_id,
        E.country_id AS countryId,
        ER1.party_id AS alliedPartyId1,
        ER2.party_id AS alliedPartyId2
    FROM election_result AS ER1, election_result AS ER2, election AS E
    WHERE ER1.election_id = ER2.election_id
        AND ER1.election_id = E.id 
		AND (ER1.id = ER2.alliance_id OR ER1.alliance_id = ER2.alliance_id OR ER2.id = ER1.alliance_id) 
		AND ER1.party_id < ER2.party_id
);


CREATE VIEW election_count AS (
    SELECT country_id AS countryId, COUNT(*)
    FROM election
    group by country_id
);


CREATE VIEW percentage AS (
    SELECT 1.0*COUNT(*)/EC.COUNT AS percent,
        A.alliedPartyId1, A.alliedPartyId2, A.countryId
    FROM alliance AS A, election_count AS EC
    WHERE A.countryId = EC.countryId
    group by A.alliedPartyId1, A.alliedPartyId2, A.countryId, EC.COUNT
);


-- Final Answer
INSERT INTO q1 (
    SELECT countryId, alliedPartyId1, alliedPartyId2
    FROM percentage AS P
    WHERE P.PERCENT >= 0.3
);
