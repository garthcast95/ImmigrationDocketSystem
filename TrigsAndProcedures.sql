--BRENNAN GARTH CASTILLO
--This database design is applicable to a global scale
--Immigration is applicable to almost any country across the globe
--This database can be used to monitor documents as to establish citizenship or residency
--Every country has their own immigration process but relatively require the sameamount of documents
--It can be further modified to legal services such as civil and criminal cases
drop table M_APPLICANTS;
drop trigger PROJTRIG3;
create table M_APPLICANTS(
ID NUMBER,
FirstName VARCHAR2(15),
LastName VARCHAR2(15),
Email VARCHAR2(20),
Salary NUMBER
);
CREATE SEQUENCE M_APPLICANTSEQ
START WITH 1
INCREMENT BY 1
NOMAXVALUE;
CREATE TRIGGER PROJTRIG3
BEFORE INSERT ON M_APPLICANTS
FOR EACH ROW
BEGIN SELECT M_APPLICANTSEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
END;
declare
firstname VARCHAR2(20);
lastname VARCHAR2(30);
email VARCHAR2(30);
salary NUMBER;
begin
FOR i IN 1..500 LOOP
firstname := dbms_random.string('u', trunc(dbms_random.value(1, 11)));
lastname := dbms_random.string('u', trunc(dbms_random.value(1, 11)));
email := dbms_random.string('x', trunc(dbms_random.value(1, 10))) || '@' ||
dbms_random.string('u', trunc(dbms_random.value(1, 5))) || '.' ||
dbms_random.string('u', trunc(dbms_random.value(1, 5)));
salary := trunc(dbms_random.value(0, 100001));
insert into M_APPLICANTS values(null, firstname, lastname, email, salary);
END LOOP;
end;
--Retrieve Record Sets
--Use Cursor
DECLARE
L_LASTNAME M_APPLICANTS.LASTNAME%ROWTYPE;
BEGIN
SELECT LASTNAME
INTO L_LASTNAME
FROM M_APPLICANTS
WHERE ID =4;
DBMS_OUTPUT.put_line(L_LASTNAME);
END;
--Cursor 2
--Error
declare
cursor app_cursor is
select * from M_APPLICANTS;
allowance :=0.10;
app_val app_cursor%ROWTYPE;
app_val2 app_val.salary%TYPE;
begin
open app_cursor;
fetch app_cursor into app_val;
app_val2 := app_val.salary;
salary := allowance*salary;
insert into AREAS values (app_val2, app_val);
close app_cursor;
end;
--Exception Handling
--Double Exception in one
--Determines if the wage is in range
--If it is, it passes it to the next exception
DECLARE
EXHIGHOFFER EXCEPTION;
WAGE NUMBER := 20000;
MAX_WAGE NUMBER := 10000;
erroneous_salary NUMBER;
BEGIN
BEGIN
IF WAGE > MAX_WAGE THEN
RAISE EXHIGHOFFER;
END IF;
EXCEPTION
WHEN EXHIGHOFFER THEN
DBMS_OUTPUT.PUT_LINE('Salary ' || erroneous_salary ||
' is out of range.');
DBMS_OUTPUT.PUT_LINE
('Maximum salary is ' || MAX_WAGE || '.');
RAISE;
END;
EXCEPTION
WHEN EXHIGHOFFER THEN
erroneous_salary := WAGE;
WAGE := MAX_WAGE;
DBMS_OUTPUT.PUT_LINE('Revising salary from ' || erroneous_salary ||
' to ' || WAGE || '.');
END;
--Trigger 1
--Creating a new table
create Table M_Contracts as select * from M_Wage;
alter table M_Contracts add OFFER INT;
alter table M_Contracts add OFFERDATE Date;
select * from M_Contracts;
--When an offer is made to a person but the Salary is below the Wage determined,
--it will be inserted to a table. This compiles a number of Salaries that are not
following determinations of the supposed wage.
Create or replace trigger PROJTRIG1
before update on M_WAGE
for each row
when (new.SALARY < old.SALARY)
begin
Insert into M_Contracts(WAGEID, FACIID, EXPIRATION, WDEGREE, SALARY, OFFER,
OFFERDATE)
values
(:old.WAGEID,:old.FACIID, :old.EXPIRATION, :old.WDEGREE, :old.SALARY, :new.SALARY,
Sysdate);
end;
update M_WAGE set SALARY = '58000' where FACIID = '15';
select * from M_CONTRACTS;
--Trigger 2
--Creating a new table
create Table M_DELDOCS as select * from M_DOCS;
alter table M_DELDOCS add DELDATE Date;
select * from M_DELDOCS;
--When a Document is deleted from the System
--It is added to M_DELDOCS to keep a record
Create or replace trigger PROJTRIG2
before delete on M_DOCS
for each row
begin
Insert into M_DELDOCS(DOCSID, BENEID, DOCTYPE, DOCDATE, DOCEXPIRATION, DELDATE)
values (:old.DOCSID,:old.BENEID,:old.DOCTYPE,:old.DOCDATE, :old.DOCEXPIRATION,
Sysdate);
end;
delete from M_DOCS where DOCTYPE ='DIPLOMA';
select * from M_DELDOCS;
--Function 1
--Calculates a 10% difference pay to the Salary for the beneficiary
create or replace FUNCTION FNSALARY
(WDEGREE IN DATE)
return NUMBER
is
PROJECTED NUMBER:=0;
rate NUMBER(3,2);
BEGIN
rate:=0.10;
SELECT (SALARY*rate)
into PROJECTED
from M_WAGE;
return PROJECTED;
end;
select * from M_WAGE;
--Function 2
--Expiration of Documents date difference
create or replace function FNDUEDATES(DocType IN VARCHAR2)
return NUMBER
is
EXPIRYREMAIN NUMBER(5,2);
begin
Select SUM(DOCDATE - DOCEXPIRATION)
Into EXPIRYREMAIN
From M_DOCS
Where DocType = DocType;
return (EXPIRYREMAIN);
end;
--Package 1 with a function
create or replace package PKGSALARYDET
as
WDEGREE VARCHAR2;
FUNCTION FNSALARY
(WDEGREE IN DATE)
return NUMBER
is
PROJECTED NUMBER:=0;
rate NUMBER(3,2);
BEGIN
rate:=0.10;
SELECT (SALARY*rate)
into PROJECTED
from M_WAGE;
return PROJECTED;
end FNSALARY;
procedure PNEWFACI(pFACIID IN INT, pFACINAME IN VARCHAR2, pFACIADDRESS IN
VARCHAR2, pFACICITY IN VARCHAR2, pFACISTATE IN VARCHAR2, pFACIZIPCODE IN
VARCHAR2) authid current_user
as
begin
insert into M_FACILITY values (pFACIID, pFACINAME, pFACIADDRESS, pFACICITY,
pFACISTATE, pFACIZIPCODE);
end PNEWFACI;
end PKGSALARYDET;
--Procedure 1
--Inserts a row to the data through this procedure
--A new facility is added to the list
DROP PROCEDURE PNEWFACI;
create or replace procedure PNEWFACI(pFACIID IN INT, pFACINAME IN VARCHAR2,
pFACIADDRESS IN VARCHAR2, pFACICITY IN VARCHAR2, pFACISTATE IN VARCHAR2,
pFACIZIPCODE IN VARCHAR2) authid current_user
as
begin
insert into M_FACILITY values (pFACIID, pFACINAME, pFACIADDRESS, pFACICITY,
pFACISTATE, pFACIZIPCODE);
end;
execute PNEWFACI('31', 'KOSH ENTER', 'HUBERT LANE', 'SALT LAKE CITY', 'UT',
'80090');
--Procedure 2
--A notification that tells the user the document has been added.
DROP PROCEDURE PMDOCUMENTS;
create or replace procedure PMDOCUMENTS (pDocsID in INT, pBeneID in INT, pDocType
in VARCHAR2, pDocDate in DATE, pDocExpiration in DATE) authid current_user
as
begin
insert into M_DOCS values (pDocsID, pBeneID, pDocType, pDocDate,
pDocExpiration);
dbms_output.put_line('Your document'||pDocType||' has been added ');
end;
execute PMDOCUMENTS('190', '12', 'DIPLOMA', Sysdate, Null);
--Create an Object
--Creating Location of Services
--Where the filing of the location is done
drop table M_FILING;
drop type M_OFFICEADDTY;
drop type M_ADMINTY;
create type M_OFFICEADTY as object
(Street VARCHAR2(50),
City VARCHAR2(25),
COUNTRY VARCHAR2(30),
Zip NUMBER);
create type M_ADMINTY as object
(Name VARCHAR2(25),
Address M_OFFICEADTY);
create table M_FILING
(LocID NUMBER,
Officer M_ADMINTY);
describe M_FILING;
insert into M_FILING values
(1, M_ADMINTY('John', M_OFFICEADTY('Leaf Road', 'Israel', 'Palestine',8089)));
select * from M_FILING;
