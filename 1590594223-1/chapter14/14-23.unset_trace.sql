rem 14-23.unset_trace.sql

CREATE OR REPLACE TRIGGER sysadm.unset_trace
BEFORE UPDATE OF runstatus ON sysadm.psprcsrqst
FOR EACH ROW 
WHEN (new.runstatus != 7 AND old.runstatus = 7
AND   new.prcstype IN ('Application Engine'))
BEGIN
   sys.dbms_session.set_sql_trace(FALSE);
   EXECUTE IMMEDIATE 'ALTER SESSION SET TRACEFILE_IDENTIFIER = ''''';
-- Only reduce MAX_DUMP_FILE_SIZE after changing the TRACEFILE IDENTIFIER again
-- EXECUTE IMMEDIATE 'ALTER SESSION SET MAX_DUMP_FILE_SIZE = 10000';
EXCEPTION WHEN OTHERS THEN NULL; 
END;
