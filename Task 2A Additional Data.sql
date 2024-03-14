SPOOL 'Task 2A Additional Data Spool.txt'

SET ECHO ON

SET LINESIZE 1000

SET SERVEROUTPUT ON

INSERT INTO publication (
    pubid,
    title
) VALUES (
    '9099138',
    'Roadmap to Zero Carbon Footprint'
);

INSERT INTO publication (
    pubid,
    title
) VALUES (
    '8370198',
    'The Black Hole'
);

INSERT INTO publication (
    pubid,
    title
) VALUES (
    'DLV23-09k',
    'Introduction To Databases'
);

INSERT INTO publication (
    pubid,
    title
) VALUES (
    'PRC991k',
    'Whispers Of Forgotten Empires Unearthing Lost Civilizations'
);

INSERT INTO publication (
    pubid,
    title
) VALUES (
    'CAPD200',
    'The Augmented Gardener Cultivating Beauty In A DigitalAge'
);

SPOOL OFF