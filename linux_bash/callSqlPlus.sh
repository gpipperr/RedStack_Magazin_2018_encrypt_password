# !/bin/sh
#==============================================================================
# Author: Gunther PippÃ¨rr ( http://www.pipperr.de )
# Desc:   Example for a script to call sql*plus in the Linux bash shell
# Date:   March 2018
# Site:   https://www.pipperr.de/dokuwiki/doku.php?id=prog:apex_export_source_code_and_git
#==============================================================================

############ Init Helper functions ############
. pwd_lib.sh



# Helper function to check the password
#
checkDBPassword(){
  	
	TEST_USER=${1}
	TEST_PASSWD=${2}
    TNSALIAS=${3}
    ORACLE_HOME=${4}
	SQLPLUS=${5}
	
	if [ "${TEST_USER}" = 'SYS' ]; then
	 CONNECT="${1}/${2}@${TNSALIAS} as SYSDBA"
	else
	 CONNECT="${1}/${2}@${TNSALIAS}"
	fi
		
	printLine "Test Connect to database ${ORACLE_SID} for the user ${TEST_USER}/*****@${TNSALIAS}"
  
	TEST_CONNECT="SUCESS"
	
	#test connect to the DB
    # Workaround for the $ in the tablename
	testtab=\$instance
	
	
TEST_CONNECT=`${ORACLE_HOME}/${SQLPLUS} -s ${CONNECT} << EOScipt
		set heading  off
		set pagesize 0
		set feedback off	
		select 'Sucess! DB Connection to database '||INSTANCE_NAME||' established for user ${1}' from v$testtab;
		exit		
EOScipt`


# Check for success
  if [ "$?" -ne "0" ]; then 
		printError "Can not connect to the Oracle database with the given user ${1} and your password ${TEST_PASSWD}" 		
		printError "${TEST_CONNECT:0:40}...."
		CAN_CONNECT=false			
	else
	  printLineSuccess ${TEST_CONNECT}
		CAN_CONNECT=true
	fi
  
}

########################## Main #########################

# Home of the scripts
SCRIPTPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
SCRIPTS=`dirname "$SCRIPTPATH{}"`
export SCRIPTS


PWDFILE=${SCRIPTS}/.password.conf
export PWDFILE

## Read encrypted password conf it exits in to memory #########################

if [ -f "${PWDFILE}.des3" ]; then
	dencryptPWDFile
	. ${PWDFILE}
	rm ${PWDFILE}
else
  if [ -f "${PWDFILE}" ]; then
		. ${PWDFILE}
		rm ${PWDFILE}
	else
	 printError
	 printError "no preconfiguration ${PWDFILE} found"
	 printError
	 exit -1
	fi
fi


# Password auf eine interne Variable kopieren und überschreiben
# Siehe Kasten zu den environ Problem
INTERNAL_PWD=${DB_PWD}
export DB_PWD=“DU_SOLLSTE_DAS_NICHT_LESEN“

# test if you can call SQL*Plus

printLineSuccess  
printLine  "Info -- try to connect to the database"

# first set your enviroment
export TNS_ADMIN=/mnt/c/oracle/TNS_ADMIN
export ORACLE_HOME=/mnt/c/oracle/products/12.2.0.1/dbhome_1
export TNSALIAS=gpi
export DB_USER=SYSTEM
export SQLPLUS_CMD=/bin/sqlplus.exe

#  user user pwd tnsalias oracle_home

checkDBPassword  "${DB_USER}" "${INTERNAL_PWD}" "${TNSALIAS}" "${ORACLE_HOME}" "${SQLPLUS_CMD}"

printLineSuccess