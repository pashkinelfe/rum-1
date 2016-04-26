CREATE EXTENSION rum;

CREATE TABLE test_rum( t text, a tsvector );

CREATE TRIGGER tsvectorupdate
BEFORE UPDATE OR INSERT ON test_rum
FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('a', 'pg_catalog.english', 't');

CREATE INDEX rumidx ON test_rum USING rum (a rum_tsvector_ops);

\copy test_rum(t) from 'data/rum.data';

SET enable_seqscan=off;

SELECT count(*) FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', 'ever|wrote');
SELECT count(*) FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', 'have&wish');
SELECT count(*) FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', 'knew&brain');
SELECT count(*) FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', 'among');
SELECT count(*) FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', 'structure&ancient');
SELECT count(*) FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', '(complimentary|sight)&(sending|heart)');

INSERT INTO test_rum (t) VALUES ('foo bar foo the over foo qq bar');
INSERT INTO test_rum (t) VALUES ('345 qwerty copyright');
INSERT INTO test_rum (t) VALUES ('345 qwerty');
INSERT INTO test_rum (t) VALUES ('A fat cat has just eaten a rat.');

SELECT count(*) FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', 'bar');
SELECT count(*) FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', 'qwerty&345');
SELECT count(*) FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', '345');
SELECT count(*) FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', 'rat');

SELECT a FROM test_rum WHERE a @@ to_tsquery('pg_catalog.english', 'bar') ORDER BY a;

DELETE FROM test_rum;

SELECT count(*) from test_rum;

CREATE TABLE tst (i int4, t tsvector);
INSERT INTO tst SELECT i%10, to_tsvector('simple', substr(md5(i::text), 1, 1)) FROM generate_series(1,100000) i;
CREATE INDEX tstidx ON tst USING rum (t rum_tsvector_ops);

DELETE FROM tst WHERE i = 1;
VACUUM tst;
INSERT INTO tst SELECT i%10, to_tsvector('simple', substr(md5(i::text), 1, 1)) FROM generate_series(10001,11000) i;

DELETE FROM tst WHERE i = 2;
VACUUM tst;
INSERT INTO tst SELECT i%10, to_tsvector('simple', substr(md5(i::text), 1, 1)) FROM generate_series(11001,12000) i;

DELETE FROM tst WHERE i = 3;
VACUUM tst;
INSERT INTO tst SELECT i%10, to_tsvector('simple', substr(md5(i::text), 1, 1)) FROM generate_series(12001,13000) i;

DELETE FROM tst WHERE i = 4;
VACUUM tst;
INSERT INTO tst SELECT i%10, to_tsvector('simple', substr(md5(i::text), 1, 1)) FROM generate_series(13001,14000) i;

DELETE FROM tst WHERE i = 5;
VACUUM tst;
INSERT INTO tst SELECT i%10, to_tsvector('simple', substr(md5(i::text), 1, 1)) FROM generate_series(14001,15000) i;