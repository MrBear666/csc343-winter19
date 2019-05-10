SET SEARCH_PATH TO parlgov;
DROP TABLE IF EXISTS q2 CASCADE;


CREATE TABLE q2(
        countryName VARCHAR(50),
        partyName VARCHAR(100),
        partyFamily VARCHAR(100),
        stateMarket REAL
);


DROP VIEW IF EXISTS past_twenty_years, all_combinations,
    not_committed_parties, committed_parties CASCADE;



CREATE VIEW past_twenty_years AS (
    SELECT *
    FROM cabinet
    WHERE 1999 <= extract(YEARs FROM start_date) AND
        extract(YEAR FROM start_date) <= 2019
);


CREATE VIEW all_combinations AS (
    SELECT party.id AS party_id, past_twenty_years.id AS cabinet_id
    FROM party, past_twenty_years
    WHERE party.country_id = past_twenty_years.country_id
);


CREATE VIEW not_committed_parties AS (
    (SELECT party_id, cabinet_id
    FROM all_combinations)
    EXCEPT
    (SELECT party_id, cabinet_id
    FROM cabinet_party)
);


CREATE VIEW committed_parties AS (
    (SELECT id AS party_id
    FROM party)
    EXCEPT
    (SELECT party_id
    FROM not_committed_parties)
);


-- Final Answer
INSERT INTO q2 (
    SELECT C.name AS countryName,
        P.name AS PartyName,
        PF.family AS partyFamily,
        PP.state_market AS stateMarket
    FROM committed_parties AS CP INNER JOIN party AS P
        ON CP.party_id = P.id
        INNER JOIN country AS C
        ON P.country_id = C.id
        LEFT JOIN party_family AS PF
        ON CP.party_id = PF.party_id
        LEFT JOIN party_position AS PP
        ON CP.party_id = PP.party_id
);
