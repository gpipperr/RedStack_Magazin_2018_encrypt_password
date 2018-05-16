# !/bin/sh
#==============================================================================
# Author: Gunther PippÃ¨rr ( http://www.pipperr.de )
# Desc:   Example for a script to call sql*plus in the Linux bash shell
# Date:   March 2018
# Site:   https://www.pipperr.de/dokuwiki/doku.php?id=prog:apex_export_source_code_and_git
#==============================================================================

############ Helper functions ############
# Normal I put this all to a library file
# but to make this example more readable 
# all is in one file


#normal
printLine() {
	if [ ! -n "$1" ]; then
		printf "\033[35m%s\033[0m\n" "----------------------------------------------------------------------------"
	else
		printf "%s" "-- "		
		while [ "$1" != "" ]; do
			printf "%s " $1 
			shift
		done		
		printf  "%s\n" ""
	fi	
}
#red
printError() {
	if [ ! -n "$1" ]; then
		printf "\033[31m%s\033[0m\n" "----------------------------------------------------------------------------"
	else
		printf "\033[31m%s\033[0m" "!! "		
		while [ "$1" != "" ]; do
			printf "\033[31m%s \033[0m" $1 
			shift
		done
		printf  "%s\n" ""
	fi	
}
#green
printLineSuccess() {
	if [ ! -n "$1" ]; then
		printf "\033[32m%s\033[0m\n" "----------------------------------------------------------------------------"
	else
		printf "\033[32m%s\033[0m" "!! "		
		while [ "$1" != "" ]; do
			printf "\033[32m%s \033[0m" $1 
			shift
		done
		printf  "%s\n" ""
	fi	
}

# Trim a string
trimString() {
	TRIMSTRING=${1}
	TRIMSTRING="${TRIMSTRING#"${TRIMSTRING%%[![:space:]]*}"}"   
	TRIMSTRING="${TRIMSTRING%"${TRIMSTRING##*[![:space:]]}"}"   
	echo ${TRIMSTRING}
}


###########################################################################
# Password file handling
encryptPWDFile () {
	if [ -f "/usr/bin/openssl" ]; then
		openssl des3 -salt -in  ${PWDFILE} -out ${PWDFILE}.des3 -pass pass:"${SYSTEMIDENTIFIER}" > /dev/null
		#debug printf "%s encrypt file :: \n%s to \n%s.des3 \n" "--" "${PWDFILE}" "${PWDFILE}" 
		rm ${PWDFILE} 
	else
		printError "Openssl not exits - password file will be not encrypted"
 fi
}
	
dencryptPWDFile() {
 if [ -f "/usr/bin/openssl" ]; then
	openssl des3 -d -salt -in ${PWDFILE}.des3 -out ${PWDFILE} -pass pass:"${SYSTEMIDENTIFIER}" > /dev/null
  #debug printf "%s decrypt file :: \n%s.des3 to \n%s \n" "--" "${PWDFILE}" "${PWDFILE}" 
 else
  printError "Openssl not exits - password file will be not dencrypted"
 fi  
}

# get the unique system identifer
# Linux 
#SYSTEMIDENTIFIER=`ls -l /dev/disk/by-uuid/ | awk '{ print $9 }'  | tail -1`
# Example for bash at MS Windows
SYSTEMIDENTIFIER=`ifconfig eth1 | grep Hardware`
export SYSTEMIDENTIFIER


##########################################################################