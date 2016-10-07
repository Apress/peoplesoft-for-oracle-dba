spool trace_trigger
rem requires following grants to be made explicitly by sys
rollback;
GRANT ALTER SESSION TO sysadm;

CREATE OR REPLACE TRIGGER sysadm.set_trace
BEFORE UPDATE OF runstatus ON sysadm.psprcsrqst
FOR EACH ROW
WHEN (new.runstatus = 7 AND old.runstatus != 7 
AND   new.prcstype IN('Application Engine','COBOL SQL','Crystal',
        'SQR Process','SQR Report','SQR Report For WF Delivery')
--AND new.prcstype = 'COBOL SQL'
--AND new.prcsname = 'GLPJEDIT' 
--AND new.oprid = 'VP1' 
--AND new.servernamerqst = 'PSUNX' 
--AND new.runcntlid = 'TRACEME'
--AND new.rqstdttm <= TO_DATE(‘31122001’,’DDMMYYYY’)
)
begin
   EXECUTE IMMEDIATE 'ALTER SESSION SET TIMED_STATISTICS = TRUE';
   EXECUTE IMMEDIATE 'ALTER SESSION SET MAX_DUMP_FILE_SIZE = 2048000';
   EXECUTE IMMEDIATE 'ALTER SESSION SET STATISTICS_LEVEL=ALL';
   EXECUTE IMMEDIATE 'ALTER SESSION SET TRACEFILE_IDENTIFIER = '''||
        REPLACE(:new.prcstype,' ','_')||'_'||
        REPLACE(:new.prcsname,' -','__')||'_'||
        :new.prcsinstance||'''';

-- EXECUTE IMMEDIATE 'ALTER SESSION SET OPTIMIZER_INDEX_CACHING=98';
-- EXECUTE IMMEDIATE 'ALTER SESSION SET OPTIMIZER_INDEX_COST_ADJ=50';

-- sys.dbms_session.set_sql_trace(true);
-- levels: 1=basic trace, 4=bind variable, 8=wait statistics
   EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 TRACE NAME CONTEXT FOREVER, LEVEL 8''';

-- sys.DBMS_SUPPORT.START_TRACE(FALSE,    /* Include waits (default FALSE)*/
--                              TRUE      /* Include binds (default FALSE)*/);
   /* partition elimination*/
-- EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10128 trace name context forever, level 2''';
   /*cbo analysis*/
-- EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10053 trace name context forever, level 1''';
   /*hash activity */
-- EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10104 trace name context forever, level 1''';
   /* sort statistics */
-- EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10032 trace name context forever, level 1''';
   /* sort I/O */
-- EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10033 trace name context forever, level 1''';
   /* parallel slave execution */
-- EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10391 trace name context forever, level 8191''';

EXCEPTION WHEN OTHERS THEN NULL;
end;
/

CREATE OR REPLACE TRIGGER sysadm.unset_trace
BEFORE UPDATE OF runstatus ON sysadm.psprcsrqst
FOR EACH ROW 
WHEN (new.runstatus != 7 AND old.runstatus = 7
AND   new.prcstype IN ('Application Engine'))
BEGIN
   sys.dbms_session.set_sql_trace(FALSE);
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

show errors

rem test that the trigger fires by updating something
UPDATE    sysadm.psprcsrqst
SET     runstatus = 7
WHERE   runstatus != 7
AND     prcstype IN('Application Engine','COBOL SQL',
       'SQR Process','SQR Report','SQR Report For WF Delivery')
AND    rownum = 1
;

rollback;
spool off

