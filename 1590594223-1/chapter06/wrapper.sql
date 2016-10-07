spool wrapper

CREATE OR REPLACE PACKAGE wrapper AS
   PROCEDURE ps_stats (p_full_table_name VARCHAR2, p_estimate NUMBER);
END wrapper;
/

CREATE OR REPLACE PACKAGE BODY wrapper AS
   PROCEDURE ps_stats(p_full_table_name VARCHAR2, p_estimate NUMBER) IS
      l_sep NUMBER;
      l_ownname VARCHAR2(20);
      l_tabname VARCHAR2(30);
   BEGIN
      l_sep := INSTR(p_full_table_name,'.');
      IF l_sep > 0 THEN
         l_ownname := SUBSTR(p_full_table_name,1,l_sep-1);
         l_tabname := SUBSTR(p_full_table_name,l_sep+1);
      ELSE
         l_ownname := 'SYSADM';
         l_tabname := p_full_table_name;
      END IF;

      IF p_estimate = 0 THEN
         sys.dbms_stats.gather_table_stats
            (ownname=>l_ownname
            ,tabname=>l_tabname
            ,estimate_percent=>DBMS_STATS.AUTO_SAMPLE_SIZE
            ,method_opt=>'FOR ALL COLUMNS SIZE REPEAT'
            ,cascade=>TRUE); 
      ELSE
         sys.dbms_stats.gather_table_stats
            (ownname=>l_ownname
            ,tabname=>l_tabname
            ,estimate_percent=>p_estimate
            ,method_opt=>'FOR ALL COLUMNS SIZE REPEAT'
            ,cascade=>TRUE); 
      END IF;

   END ps_stats;
END wrapper;
/

show errors

begin wrapper.ps_stats('SYSADM.PSLOCK',0); end;
/
begin wrapper.ps_stats('PSLOCK',.5); end;


spool off
