SET SEARCH_PATH TO parlgov;

SELECT *
FROM q4
ORDER BY year desc, countryName desc, voteRange desc, partyName desc;
