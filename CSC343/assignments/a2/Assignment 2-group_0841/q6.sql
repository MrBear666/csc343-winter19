SET SEARCH_PATH TO parlgov;
drop table if exists q6 cascade;

CREATE TABLE q6(
        countryName VARCHAR(50),
        r0_2 INT,
        r2_4 INT,
        r4_6 INT,
        r6_8 INT,
        r8_10 INT
);

-- the answer to the query
INSERT INTO q6 (
    SELECT country.name AS countryName,
        count(CASE 
            WHEN 0<=party_position.left_right AND party_position.left_right<2 
            THEN 1 
            ELSE NULL 
            END) AS r0_2,
        count(CASE 
            WHEN 2<=party_position.left_right AND party_position.left_right<4 
            THEN 1 
            ELSE NULL 
            END) AS r2_4,
        count(CASE 
            WHEN 4<=party_position.left_right AND party_position.left_right<6 
            THEN 1 
            ELSE NULL 
            END) AS r4_6,
        count(CASE 
            WHEN 6<=party_position.left_right AND party_position.left_right<8 
            THEN 1 
            ELSE NULL 
            END) AS r6_8,
        count(CASE 
            WHEN 8<=party_position.left_right AND party_position.left_right<=10 
            THEN 1 
            ELSE NULL 
            END) AS r8_10
    FROM party_position JOIN party
            ON party_position.party_id = party.id
        RIGHT JOIN country
            ON party.country_id = country.id
    GROUP BY country.id, country.name
);
