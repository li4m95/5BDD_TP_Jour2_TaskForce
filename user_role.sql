CREATE USER dataflow_app IDENTIFIED BY "DataflowApp2024!"
  DEFAULT TABLESPACE USERS
  QUOTA UNLIMITED ON USERS;

GRANT CREATE SESSION TO dataflow_app;
GRANT CREATE TABLE TO dataflow_app;
GRANT CREATE SEQUENCE TO dataflow_app;
GRANT CREATE PROCEDURE TO dataflow_app;
GRANT CREATE VIEW TO dataflow_app;
GRANT CREATE TRIGGER TO dataflow_app;


SELECT username, account_status, default_tablespace, created
FROM dba_users
ORDER BY created DESC;

SELECT * FROM dba_sys_privs WHERE grantee = 'DATAFLOW_APP';


SELECT USER FROM DUAL;

DROP USER dataflow_app CASCADE;
