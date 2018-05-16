# !/bin/sh
#==============================================================================
# Author: Gunther Pippèrr ( http://www.pipperr.de )
# Desc:   Example for password Handling inside a Linux shell script
# Date:   March 2018
# Site:   https://www.pipperr.de/dokuwiki/doku.php?id=prog:apex_export_source_code_and_git
#==============================================================================


# Home of the scripts
SCRIPTPATH=$(cd ${0%/*} && echo $PWD/${0##*/})
SCRIPTS=`dirname "$SCRIPTPATH{}"`
export SCRIPTS

echo "Info -- start the Script in the path ${SCRIPTS}" 

# password.conf.des3
PWDFILE=${SCRIPTS}/.password.conf
export PWDFILE
 
 
# etwas Eindeutiges aus der Umgebung der Maschine auslesen
# Linux 
#SYSTEMIDENTIFIER=`ls -l /dev/disk/by-uuid/ | awk '{ print $9 }'  | tail -1`

# Test
# Example for bash at MS Windows
SYSTEMIDENTIFIER=`ifconfig eth1 | grep Hardware`
export SYSTEMIDENTIFIER

 
#
# Password verschlüsseln
encryptPWDFile () {
    /usr/bin/openssl des3 -salt -in  ${PWDFILE} -out ${PWDFILE}.des3 -pass pass:"${SYSTEMIDENTIFIER}" > /dev/null
    # Remove orignal file
    rm ${PWDFILE} 
}

# Password wieder auslesen
dencryptPWDFile() {
    /usr/bin/openssl des3 -d -salt -in ${PWDFILE}.des3 -out ${PWDFILE} -pass pass:"${SYSTEMIDENTIFIER}" > /dev/null
}
 
 
# Password in den Speicher laden
# Falls verschlüsselte Datei vorliegt 
if [ -f "${PWDFILE}.des3" ]; then
    dencryptPWDFile
    # in die Umgebung einlesen
    . ${PWDFILE}
    # Klarschrift Datei wieder entfernen
    rm ${PWDFILE}
else
     # Falls unverschlüsselt vorliegt, Datei verschlüsslen
	if [ -f "${PWDFILE}" ]; then
        . ${PWDFILE}
        encryptPWDFile		
    else
		echo "Info -- No preconfiguration file =>${PWDFILE}<= found"
		echo "export DB_PWD=" > ${PWDFILE}
		echo "Info -- I create this file , please edit now the file ${PWDFILE} and set password and start again the script"
		exit 1
    fi
fi

# Password auf eine interne Variable kopieren und überschreiben
# Siehe Kasten zu den environ Problem
INTERNAL_PWD=${DB_PWD}
export DB_PWD=“DU_SOLLSTE_DAS_NICHT_LESEN“

echo "Info --  read encrypted password  =>> ${INTERNAL_PWD} <<=="
