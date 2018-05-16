# Source code for a article in the German Red Stack Magazine 2018

## Encrypt and decrypt passwords in the MS Windows Powershell and the Linux/HP UX Bash

* For the MS Windows Powershell see ms_powershell
* For linux see linux_powershell

# Main Idea:

This is not a 100% bullet prof high tech password protection system, this is only the simple idea not to use password in scripts.

This idea helps us with the following topics:
* Fulfill main company regularities ( no clear password in scripts)
* transfer scripts to git or send via e-mail without password inside
* If someone can access the backup he can not grep out password informations
 * The password file can only be read the the target server, if someone copy the file it is useless
* Make a password change easier as on only one point you have to set the pashsword
 
This idea does not protect us against a professional hacker attack!

If the hacker is able to start the script on the target server he can read also the password with a simple print out.
But this is the most general problem of all encryptions, it is very difficultly to protect the key if the key is part of the software.

Therefore we using some unique key from the target server for the salt of the encryption, 
for MS Windows the build in Software key , on Linux something from the operation system.

If the script with the encrypted password is executed on an other server the password can not be read!
