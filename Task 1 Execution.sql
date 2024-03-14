SPOOL 'T1 TC5 Spool - Exceptions.txt'

SET ECHO ON

SET LINESIZE 1000

SET SERVEROUTPUT ON

-- With Original Data
-- Single Publication
-- execute print_publication('Yannis_Kotidis')

-- Multiple Publication
-- execute print_publication('M._Tamer_Ozsu')

-- Author Order
-- execute print_publication('Gang_Chen')
-- execute print_publication('Hoang_Tam_Vo')
-- execute print_publication('Sai_Wu')
-- execute print_publication('Ben_Chin_Ooi')

-- With additional Data
-- Order by Year
-- execute print_publication('Ajit_A._Diwan')

-- Exception Test - Null Input
-- execute print_publication('')

-- Exception Test - Non-existing Author
-- execute print_publication('Paul')

-- Exception Test - No Publication Record
-- execute print_publication('John')

SET ECHO OFF

SPOOL OFF