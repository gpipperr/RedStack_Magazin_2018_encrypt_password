#==============================================================================
# Author: Gunther Pippèrr ( http://www.pipperr.de )
# Desc:   Example for password Handling with the MS Credential object
# Date:   March 2018
# Site:   https://www.pipperr.de/dokuwiki/doku.php?id=prog:apex_export_source_code_and_git
#==============================================================================
<#
	.NOTES
		Created: 03.2018 : Gunther Pippèrr (c) http://www.pipperr.de

		Security:
		(see http://www.pipperr.de/dokuwiki/doku.php?id=windows:powershell_script_aufrufen )
		To switch it off (as administrator)
		get-Executionpolicy -list
		set-ExecutionPolicy -scope CurrentUser RemoteSigned
  
	.SYNOPSIS
		Example Script to handle passwords
		
	.DESCRIPTION
		Example Script to handle passwords
		
	.COMPONENT
		GPI OraPowerShell Library
	
	.EXAMPLE

#>

#==============================================================================



# Environment

$Invocation = (Get-Variable MyInvocation -Scope 0).Value
$scriptpath=Split-Path $Invocation.MyCommand.Path

echo   "Info -- start the Script in the path $scriptpath" 


# PWD
$db_user     = "system"

$oracle_credential = "$scriptpath\ORACLE_CREDENTIAL.xml"

#
# To store the password we use  the PSCredential object
# if the serialized object of the password not exists
# prompt the user to enter the password
#

if (!(test-path -path $oracle_credential)) {
	$user_credential=GET-CREDENTIAL -credential "$db_user"  
	export-clixml -InputObject $user_credential -Path $oracle_credential
}
else {
   $user_credential=Import-Clixml -Path $oracle_credential
}

#get the clear type password

$db_password=$user_credential.GetNetworkCredential().Password 


echo "Info --  read encrypted password  =>> $db_password <<=="


################### END ############################