spool trace_trigger
rem requires following grants to be made explicitly by sys
rollback;
GRANT ALTER SESSION TO sysadm;

CREATE OR REPLACE TRIGGER sysadm.set_id
BEFORE UPDATE OF runstatus ON sysadm.psprcsrqst
FOR EACH ROW
WHEN (new.runstatus = 7 AND old.runstatus != 7)
begin
   sys.dbms_application_info.set_module(:new.prcsname,'AE ('||:new.process_instance||') Started');
EXCEPTION WHEN OTHERS THEN NULL;
end;
/

CREATE OR REPLACE TRIGGER sysadm.unset_trace
BEFORE UPDATE OF runstatus ON sysadm.psprcsrqst
FOR EACH ROW 
WHEN (new.runstatus != 7 AND old.runstatus = 7
AND   new.prcstype IN ('Application Engine'))
BEGIN
   sys.dbms_application_info.set_module(:new.prcsname,'AE ('||:new.process_instance||') Terminated');
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

