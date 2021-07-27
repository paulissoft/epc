/* perl generate_ddl.pl (version 1099) --nodynamic-sql --force-view --noremove-output-directory --skip-install-sql */

/*
-- JDBC url            : jdbc:oracle:thin:ORACLE_TOOLS@//localhost:1521/orcl
-- source schema       : 
-- source database link: 
-- target schema       : ORACLE_TOOLS
-- target database link: 
-- object type         : 
-- object names include: 1
-- object names        : EPC,
EPC_CLNT,
EPC_CLNT_OBJECT,
EPC_SRVR,
STD_OBJECT
STD_OBJECT_MGR,
STD_OBJECTS
-- skip repeatables    : 0
-- interface           : pkg_ddl_util v4
-- owner               : ORACLE_TOOLS
*/
-- pkg_ddl_util v4
call dbms_application_info.set_module('uninstall.sql', null);
/* SQL statement 1 (ALTER;ORACLE_TOOLS;CONSTRAINT;STD_OBJECTS_CHK4;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 1');
ALTER TABLE "ORACLE_TOOLS"."STD_OBJECTS" DROP CONSTRAINT STD_OBJECTS_CHK4;

/* SQL statement 2 (ALTER;ORACLE_TOOLS;CONSTRAINT;STD_OBJECTS_CHK3;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 2');
ALTER TABLE "ORACLE_TOOLS"."STD_OBJECTS" DROP CONSTRAINT STD_OBJECTS_CHK3;

/* SQL statement 3 (ALTER;ORACLE_TOOLS;CONSTRAINT;STD_OBJECTS_CHK2;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 3');
ALTER TABLE "ORACLE_TOOLS"."STD_OBJECTS" DROP CONSTRAINT STD_OBJECTS_CHK2;

/* SQL statement 4 (ALTER;ORACLE_TOOLS;CONSTRAINT;STD_OBJECTS_CHK1;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 4');
ALTER TABLE "ORACLE_TOOLS"."STD_OBJECTS" DROP CONSTRAINT STD_OBJECTS_CHK1;

/* SQL statement 5 (ALTER;ORACLE_TOOLS;CONSTRAINT;STD_OBJECTS_PK;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 5');
ALTER TABLE "ORACLE_TOOLS"."STD_OBJECTS" DROP PRIMARY KEY KEEP INDEX;

/* SQL statement 6 (DROP;ORACLE_TOOLS;INDEX;STD_OBJECTS_PK;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;2) */
call dbms_application_info.set_action('SQL statement 6');
DROP INDEX ORACLE_TOOLS.STD_OBJECTS_PK;

/* SQL statement 7 (DROP;ORACLE_TOOLS;PACKAGE_BODY;EPC;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 7');
DROP PACKAGE BODY ORACLE_TOOLS.EPC;

/* SQL statement 8 (DROP;ORACLE_TOOLS;PACKAGE_BODY;EPC_CLNT;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 8');
DROP PACKAGE BODY ORACLE_TOOLS.EPC_CLNT;

/* SQL statement 9 (DROP;ORACLE_TOOLS;PACKAGE_BODY;EPC_SRVR;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 9');
DROP PACKAGE BODY ORACLE_TOOLS.EPC_SRVR;

/* SQL statement 10 (DROP;ORACLE_TOOLS;TYPE_BODY;EPC_CLNT_OBJECT;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 10');
DROP TYPE BODY ORACLE_TOOLS.EPC_CLNT_OBJECT;

/* SQL statement 11 (DROP;ORACLE_TOOLS;PACKAGE_SPEC;EPC_CLNT;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 11');
DROP PACKAGE ORACLE_TOOLS.EPC_CLNT;

/* SQL statement 12 (DROP;ORACLE_TOOLS;PACKAGE_SPEC;EPC_SRVR;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 12');
DROP PACKAGE ORACLE_TOOLS.EPC_SRVR;

/* SQL statement 13 (DROP;ORACLE_TOOLS;PACKAGE_SPEC;EPC;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 13');
DROP PACKAGE ORACLE_TOOLS.EPC;

/* SQL statement 14 (DROP;ORACLE_TOOLS;TABLE;STD_OBJECTS;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 14');
DROP TABLE ORACLE_TOOLS.STD_OBJECTS PURGE;

/* SQL statement 15 (DROP;ORACLE_TOOLS;TYPE_SPEC;EPC_CLNT_OBJECT;;;;;;;;2) */
call dbms_application_info.set_action('SQL statement 15');
DROP TYPE ORACLE_TOOLS.EPC_CLNT_OBJECT;

