# !/bin/sh
#==============================================================================
# Author: Gunther Pippèrr ( http://www.pipperr.de )
# Desc:   Example for a script to set the password
# Date:   March 2018
# Site:   https://www.pipperr.de/dokuwiki/doku.php?id=prog:apex_export_source_code_and_git
#==============================================================================



############ Init Helper functions ############
. pwd_lib.sh

# Home of the scripts
SCRIPTPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
SCRIPTS=`dirname "$SCRIPTPATH{}"`
export SCRIPTS

echo "Info -- start the Script in the path ${SCRIPTS}" 

# password.conf.des3
PWDFILE=${SCRIPTS}/.password.conf
export PWDFILE

# Remove the old password file
rm ${PWDFILE}.des3

# ask the user for the password
echo "Please enter a Password for the variable  DB_PWD:"
read PWD

#create clear password file 
echo "export DB_PWD=${PWD}" > ${PWDFILE}

# decrypt the file
encryptPWDFile

echo "Info - create of new password finished -  call simpleExample.sh to test and see the password"

################ end #############