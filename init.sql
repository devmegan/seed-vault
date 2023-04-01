\echo 'Creating database...'

\c vaults;

CREATE TABLE facilities (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL, 
  city VARCHAR(50) NOT NULL,
  country VARCHAR(3) NOT NULL
);

CREATE TABLE seeds (
  id SERIAL PRIMARY KEY,
  latin_name VARCHAR(50) NOT NULL,
  common_name VARCHAR(50) NOT NULL,
  type VARCHAR(50) NOT NULL
);

\echo 'Loading facilities data from fixtures...'

COPY facilities (name, city, country) 
FROM '/tmp/fixtures/facilities.csv' 
WITH (FORMAT csv);

\echo 'Facilities data loaded'
\echo 'Loading seeds data from fixtures...'

COPY seeds (latin_name, common_name, type) 
FROM '/tmp/fixtures/seeds.csv' 
WITH (FORMAT csv);

\echo 'Seeds data loaded'
\echo 'Done.'