# Wohin nur mit den Passwörtern in Windows und Linux Skripten? - Passwörter in Skripten verschlüsselt hinterlegen.

Autor: Gunther Pippèrr, Freiberufler

Das Problem: In vielen Skripten rund um die tägliche Wartung unserer Systemumgebungen müssen Passwörter hinterlegt werden. Und nicht immer kann mit der Oracle Wallet oder SSL Zertifikaten bzw. Betriebssystem Rechten ganz auf Passwörter verzichtet werden.

Wie aber diese Passwörter so schützen, dass nicht jeder sofort die Passwörter auslesen und verwenden kann? Wie die Skripte in einer Sourcecode Verwaltung so hinterlegen, dass dort sicher keine Passwörter mehr vorkommen? Wie Passwörter auf gehosteten Server Umgebungen hinterlegen und den Sicherheits-Regularien meines Unternehmens genügen?

Gerade in Umgebungen, die in die Jahre gekommen sind, wimmelt es nur so von Passwörtern. Jede Änderung bedingt meist umfangreiche Anpassungen an vielen Stellen. Werden Skripte kopiert und weitergegeben, besteht immer die Gefahr, dass ein Passwort in die falschen Hände gerät. Besonders in gehosteten Umgebungen, auf denen das Betriebssystem vom einen Hoster mit Root Rechten verwaltet wird, sollte sich der Kunde der Gefahr mit den offenen Passwörtern in Skripten sehr bewusst sein.

Diese Passwörter stellen trotz aller Bemühung auch heute noch eines der höchsten Sicherheitsrisiken für die meisten Systeme dar.

Um dieses Risiko zu bekämpfen, sollten die folgenden Vorgaben für alle Umgebungen gültig sein:
* Kein Passwort kommt im Skript vor, nur eine Variable wird verwendet, die mit dem Passwort gefüllt wird.
* Bei einer Passwort-Änderung muss das Skript nicht angepasst werden.
* Die Passwörter sind auf dem System verschlüsselt hinterlegt.
* Die verschlüsselten Passwörter können nur auf der Zielmaschine entschlüsselt gelesen werden.
* Alles was für die Umsetzung des Konzepts benötigt wird, muss auch in veralteten, bzw. gehosteten Umgebungen ohne große Systemrechte möglich sein.

Und nebenbei werden so ohne großen Aufwand meist schon die wichtigsten Sicherheits-Regeln eingehalten, ohne den Betrieb mit zu hohen Aufwänden zu belasten.

Vor welchen Szenarien schützt uns die Umsetzung des Konzepts?

* Skripte können nun problemlos per Mail / Git oder Web verteilt werden, keine Passwörter gehen aus Versehen verloren.
* Die verschlüsselten Passwörter sind keinem vom Nutzen, der keinen Zugriff auf dem Ziel Server hat.
* Der Security Officer nervt uns nicht mehr in der Kantine beim Mittagessen.

Vor welchen Szenarien schützt uns das NICHT?
* Vor den neugierigen Blicken der Kollegen mit Root Zugriff auf das System! Während das Skript läuft, ist im Speicher oder der /proc Umgebung das Passwort meist mit etwas Geschick auffindbar.
* Das Passwort lässt sich auf der Maschine per Skript auslesen, der Schlüssel für das Passwort lässt sich dort aber nie so verstecken, dass keiner den Schlüssel findet, das Skript benötigt diesen ja auch.

Denn wie bei jeder Verschlüsselung ist es eigentlich egal wie komplex oder sicher der Algorithmus ist, meist kann durch ein wenig Nachdenken und Ausprobieren der Schlüssel im System selber gefunden werden. Den Schlüssel zu verstecken gelingt den wenigsten wirklich, denken wir nur an unsere Eltern, da liegt der Schlüssel auch immer hinten am Gartenzaun unter dem Blumentopf.

D.h. unser Ziel ist mit dieser Lösung nicht eine 100% Sicherheit, sondern das Begrenzen von Schaden und das Erfüllen von Sicherheitsvorgaben.

Werden diese einfachen Vorgaben konsequent umgesetzt, bedeutet dies für das Unternehmen meist schon eine dramatische Verbesserung der Sicherheitslage ohne großen Aufwand und viele Schwierigkeiten im Betrieb.


Wie lässt sich das ganze nun aber unter Windows und Linux so bequem wie möglich umsetzen?

Unser Werkzeugkasten:

* Das Microsoft Credential Objects in der Windows PowerShell
* Verschlüsseltes Hinterlegen von Passwörtern auf Linux Systemen mit openssl
* Oracle Featuren wie der Oracle Wallet

Und nun im ersten Schritt die ideale Lösung für das Problem, wir verwenden gar keine Passwörter mehr.  D.h. in der Regel delegieren wir diese Aufgabe einfach an das Betriebssystem der Datenbank und überlassen diesem, bzw. dem Systemadministrator der Umgebung, die ganze Verantwortung, dass alles sicher betrieben wird.

Nachteil: Wer sich am System anmelden kann, kommt nun ganz ohne Passwort aus.

Sehr einfach lässt sich das Umsetzen, wenn der OS User in der DBA Gruppe ist und alle Aufgaben mit dem SYS User durchgeführt werden können.

Etwas sicherer ist es, „External authentification“ für die Datenbankzugänge einzusetzen. 

Sehr komfortabel ist die Oracle Wallet als Secure External Passwort Store Lösung, mehr dazu unter https://www.pipperr.de/dokuwiki/doku.php?id=dba:oracle_secure_external_passwort_store .

## Passwörter unter Windows schützen

Unter Windows ist das verschlüsselte Hinterlegen der Passwörter so trivial, dass jeder der es nicht nützt, sich eigentlich fast grob fahrlässig verhält.

Das Erstellen eines Passwort-Containers inkl. des Aufrufes der Pflegeoberfläche sind im Prinzip nur 2 Zeilen Code.


 

Wer lieber das Password über die Console setzt, kann mit dem Registry Eintrag  (HKLM:\SOFTWARE\Microsoft\PowerShell\1\ShellIds\ConsolePrompting) =$True den graphischen Dialog vermeiden.

 

Sourcecode:
```powershell
# Parameter belegen
$db_user     = "system"
$oracle_credential = "ORACLE_CREDENTIAL.xml"

#
# Prüfen ob bereits ein serialisertes Password gefunden werden kann
# wenn nicht den Dialog dazu öffnen und das Password als XML speichern ( verschlüsselt!)
#
 
if (!(test-path -path $oracle_credential)) {
     #  setzen des Passworts über eine Dialog
	$user_credential=GET-CREDENTIAL -credential "$db_user"  
	export-clixml -InputObject $user_credential -Path $oracle_credential
}
else {
   # Objekt wieder einlesen 
   $user_credential=Import-Clixml -Path $oracle_credential
}

#Password als text wieder auslesen 
$db_password=$user_credential.GetNetworkCredential().Password
```


Ein praktisches Beispiel dazu: ⇒ Oracle Apex Source Code automatisch exportieren und einchecken mit Git unter Windows mit der PowerShell => https://www.pipperr.de/dokuwiki/doku.php?id=prog:apex_export_source_code_and_git .

### Wie funktioniert das Ganze im Detail?

Das Passwort wird über den originalen Windows Passwort Dialog einmalig über den Aufruf von „GET-CREDENTIAL" eingeben und in einer serialisierten Form als XML Datei auf der Festplatte hinterlegt.

Im Code erzeugen wir mit „$user_credential=GET-CREDENTIAL -credential "$db_user" in der Variablen user_credential das Credential Objekt mit unserem Passwort. Der Schlüssel ist die eindeutige ID des aktuell installierten Betriebssystems und dies ist für jeden Windows Rechner auf dieser Welt eindeutig.

Um nun unseren Passwort Store auf der Platte abzulegen (wir wollen ja nicht bei jedem Skript Aufruf das Passwort neu eingeben), serialisieren wir das Objekt mit „export-clixml -InputObject $user_credential -Path $oracle_credential”. Es entsteht eine XML Datei mit dem Objekt in einer Art BASE64 Codierung.

Beim nächsten Lauf ist das Passwort bereits hinterlegt, und das Objekt wird wieder in den Speicher geladen mit „$user_credential=Import-Clixml -Path $oracle_credential"”.

Nun kann das Passwort im Script in Klarschrift ausgelesen werden über „$db_password=$user_credential.GetNetworkCredential().Password“


## Passwörter unter Linux sicher verwahren

Unter Linux wird das ganze etwas schwieriger. Gerade in gehosteten Umgebungen muss der Kunde mit dem Vorlieb nehmen, was der Dienstleister unter Sicherheit versteht. Das heißt meistens rein kosten optimiert zu arbeiten und wenig flexibel auf besondere Softwarewünsche wie ein aktuelles Java oder einen gcc einzugehen.

SSH und damit „openssl“ steht hier aber überwiegend zur Verfügung, bzw. es spricht sehr wenig dagegen das kostenfrei installieren zu lassen.

Damit haben wir mit „openssl“ auf Linux ein Werkzeug zur Verfügung das die kompliziertesten Verschlüsselungs-Verfahren sehr sicher beherrscht.

Jetzt müssen wir nur noch einen Schlüssel finden, der möglichst länger ist als das Passwort, um das Entschlüsseln für den Angreifer spannender zu gestalten.

Der Schlüssel muss erfüllen:

* Muss auf jeden Server dieser Welt eindeutig sein.
* Länger als das Passwort sein. 
* Sollte sich nicht auf den ersten Blick erkennen lassen.
* Einfaches erzeugen/auslesen unter Linux.

Solche Schlüssel können sein:

* WWN oder UUID eines Devices, dass sich auf dem Server nicht so schnell ändert.
* Hardware ID wie die MAC Adresse oder die Prozessor ID.
* Eine eigene Routine in c die eine eindeutige ID erzeugt.

Meist verwende ich einfach die UUID von /dev/sda1 als Schlüssel oder die Seriennummer des OS unter HP UX. 

Hier ist es der Phantasie des Entwicklers überlassen durch Obfuscation das Ganze noch etwas intransparenter zu gestalten. Die Kollegen vom Support aus fernen Ländern sollten das am Ende aber noch bedienen und warten können.

Wie funktioniert das Ganze im Detail?

Das Passwort wird zu Beginn in einer Datei in Klarschrift hinterlegt und dann verschlüsselt. Das kann im Skript gleich beim nächsten Aufruf oder mit einem kleinen Hilfsskript vorab erfolgen.

„openssl“ dient im folgenden dazu die Konfigurationsdatei mit dem Passwort Store
zu verschlüsseln und stellt den kompliziertesten Teil des Ganzen dar. Über folgenden Aufruf „openssl des3 -salt -in  ${PWDFILE} -out ${PWDFILE}.des3 -pass pass:"${SYSTEMIDENTIFIER}"“ wird die Passwort Datei dabei verschlüsselt.

Sourcecode:

```bash
# password.conf.des3
PWDFILE=.password.conf
export PWDFILE
 
 
# etwas Eindeutiges aus der Umgebung der Maschine auslesen
# Linux 
SYSTEMIDENTIFIER=`ls -l /dev/disk/by-uuid/ | awk '{ print $9 }'  | tail -1`
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
		echo "no preconfiguration file =>password.conf<= found"
		echo "export DB_PWD=" > ${PWDFILE}
		echo "no preconfiguration password.conf found - edit the file =>password.conf<= and set password and start again"
		exit 1
    fi
fi

# Password auf eine interne Variable kopieren und überschreiben
INTERNAL_PWD=${DB_PWD}
export DB_PWD=“DU_SOLLSTE_DAS_NICHT_LESEN“

echo "Info --  read encrypted password  =>> ${INTERNAL_PWD} <<=="

```

Um die Sicherheit noch weiter zu erhöhen und um Spuren in der Umgebung so weit wie möglich zu verschleiern, kann das Passwort in der Datei beim Verschlüsseln zuvor noch mit einem symmetrischen Algorithmus so verschlüsselt werden, dass erst zur Laufzeit im Skript an den jeweiligen Stellen das echte Passwort extrahiert wird. 

Diese sollte dann ohne Umwege in das aufzurufende Programm hinein „gepiped“ werden. Dies ist zwar nicht deutlich sicherer, dient aber dazu auf den ersten Blick den Angreifer etwas mehr zu verwirren.  

## Fazit

Auch mit diesem Konzept lässt sich in unserer Welt keine endgültige Sicherheit herstellen. Es ist aber ein wichtiger Schritt sensitiver und vor allem proaktiv mit dem Passwortproblem umzugehen.

Und das Ganze ohne besonderem Aufwand für den Betrieb mit dem Vorteil die Passwortänderungen zu zentralisieren.


Besonders möchte ich mich bei Martina Pippèrr und Sebastian Geddes bedanken, die geduldig geholfen haben diesen Text zu überabeiteten.


## Über das Auslesen von Umgebung-Variablen in Linux - das environ Problem

Über /proc die Laufzeit Umgebung eines Linux Prozesses auslesen

Mit entsprechenden Rechten (denken sie dabei an ihren Kollegen oder Ihren Dienstleister) kann über das /proc Dateisystem und die „environ“ Datei die gesetzte Umgebung eines Scripts ausgelesen werden. D.h. sensitive Daten wie Passwörter sollten nur so kurz wie möglich in diesem Bereich sichtbar sein!

Über diesen Weg lässt auch sich sehr einfach überprüfen welche Umgebungs-Variablen ein Prozess (wie zum Beispiel ein Oracle Hintergrund) wirklich sieht und verwendet.

Anwendungsbeispiel:  
* Prozess ID ermitteln mit  „ps uafx | grep sqlplus”
* In das Proc File System wechseln „cd /proc/<processid>/“ 
* Über die Datei „environ“ kann nun die Umgebung des des Prozess ausgelesen werden „strings environ | grep NLS_LANG“ 


Um die Sicherheit noch weiter zu erhöhen und um Spuren in der Umgebung so weit wie möglich zu verschleiern, kann das Passwort in der Datei beim Verschlüsseln zuvor noch mit einem symmetrischen Algorithmus so verschlüsselt werden, dass erst zur Laufzeit im Skript an den jeweiligen Stellen das echte Passwort daraus extrahiert daraus wird. Diese sollte dann ohne Umwege in das aufzurufende Programm hinein „gepipt“ wird. Dies ist zwar nicht groß sicherer, dient aber dazu auf den ersten Blick den Angreifer etwas mehr zu verwirren.  



Kontakt:
Gunther Pippèrr
gunther@pipperr.de


Link Liste
1 – https://www.pipperr.de/dokuwiki/doku.php?id=dba:oracle_secure_external_passwort_store
2 – https://www.pipperr.de/dokuwiki/doku.php?id=prog:apex_export_source_code_and_git




