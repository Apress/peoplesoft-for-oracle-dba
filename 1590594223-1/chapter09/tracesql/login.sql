set echo off
ttitle off
btitle off
column SQLPROMPT new_value SQLPROMPT 
set trimspool on trimout on arrays 1 maxdata 9999 echo off head off timi off feedback off message off pause off autotrace off verify off time off termout off lines 110
alter session set nls_date_format = 'HH24:MI:SS DD/MM/YYYY';
select ''''||user||'.'||s.osuser||'.'||s.machine||'>''' SQLPROMPT from sys.v_$session s where s.sid = 1;
select ''''||user||'.'||d.name||'.'||s.osuser||'.'||s.machine||'>''' SQLPROMPT from sys.v_$database d,sys.v_$session s where s.sid = 1;
select ''''||user||'.'||m.sid||'.'||d.name||'.'||s.osuser||'.'||s.machine||'>''' SQLPROMPT from sys.v_$database d,sys.v_$session s,(select sid from v$mystat where rownum=1) m where s.sid = 1;
select ''''||user||'.'||m.sid||':'||p.spid||'.'||d.name||'.'||s.osuser||'.'||s.machine||'>''' SQLPROMPT 
from sys.v_$database d,sys.v_$session s,sys.v_$session ms,sys.v_$process p,(select sid from v$mystat where rownum=1) m 
where ms.paddr = p.addr and s.sid = 1 and ms.sid = m.sid;
spool off
set sqlprompt &&SQLPROMPT
del
set head on timi off feedback on verify on message on time off pages 50 termout on
spool temp




