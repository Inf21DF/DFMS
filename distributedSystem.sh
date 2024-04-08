#!/bin/bash

#in crontab -e nachfolgendes einfügen: */1 * * * * bash /home/pi/DFMS/distributedSystem.sh upload >> /home/pi/DFMS/logging.txt &

#programm kann mit upload oder download aufgerufen werden

#erstelle slaves.txt mit in jeder zeile einer ip zum anfragen
#erstelle config.txt mit username (erste zeile) und passwort (zweite zeile), rootdirectory (dritte zeiel) und  remote directory (vierte zeile)

#startzeit speichern
SECONDS=0
start=$(date +%s.%N)
echo "Startzeit: $(date +"%r")"
echo "PID: $$"

pid_file="/tmp/pid_file.txt"

# Überprüfen, ob die PID-Datei bereits existiert
if [ -f "$pid_file" ]; then
    echo "$(date +"%r") $$ PID-Datei existiert bereits. Beende das Skript."
    exit 1
fi

# Schreibe die eigene PID in die Datei
echo $$ > "$pid_file"
echo "$(date +"%r") $$ PID erfolgreich in die Datei geschrieben."

# Dateiname für die IP-Adressen
ip_file="/home/pi/DFMS/slaves.txt"
config_file="/home/pi/DFMS/config.txt"


# Überprüfen, ob mindestens ein Parameter übergeben wurde
if [ $# -eq 0 ]; then
    echo "$(date +"%r") $$ Keine Parameter übergeben. Bitte Parameter angeben."
    rm $pid_file
    exit 1
fi

# Erster übergebener Parameter ist $1, zweiter ist $2 usw.
command="$1"
echo "Kommando: $command"


# Überprüfen, ob die Datei existiert
if [[ -f $ip_file ]]; then
  echo "IP-Adressdatei existiert"
else
  echo "$(date +"%r") $$ Die angegebene IP-Adress Datei existiert nicht. huhu"
  rm $pid_file
  exit 1
fi

if [[ -f $config_file ]]; then
  echo "Config Datei existiert"
else
  echo "$(date +"%r") $$ Die angegebene Konfig Datei existiert nicht."
  rm $pid_file
  exit 1
fi


# Lesen des Benutzernamens (erste Zeile)
username=$(sed -n '1p' $config_file)

# Lesen des Passworts (zweite Zeile)
password=$(sed -n '2p' $config_file)

#lese root verzeichnis (dritte zeile)
rootDirectory=$(sed -n '3p' $config_file)

#lese verzeichnis remote ein (vierte Zeile)
remoteDirectory=$(sed -n '4p' $config_file)

#lese den boolean ein,ob es eine Stern- oder Reihenverteilung ist.
rowSyncronisation=$(sed -n '5p' $config_file)

# Ausgabe der gespeicherten Informationen nur debugging
#echo "$(date +"%r"); $$ Benutzername: $username"
#echo "$(date +"%r"); $$ Passwort: $password"
echo "$(date +"%r"); $$ root directory: $rootDirectory"
echo "$(date +"%r"); $$ remote directory: $remoteDirectory"
echo "$(date +"%r"); $$ Reihensynchronisation: $rowSyncronisation"


if [ "$command" == "show" ]; then
    echo "$(date +"%r"); $$ Dateien in /Files/"
    ls /Files/
fi


# Zeilenweise den Inhalt der Datei ausgeben
while IFS= read -r ip; do
  # track process
  #echo "$(date +"%r") track process: .$(pwd)/DFMS/track_process.sh $$ &"  
  #bash $(pwd)/DFMS/track_process.sh $$ &

  #nur für debugging
  #echo "$ip"

  #ist die ip erreichbar?
  if ping -c 1 $ip &> /dev/null; then
    echo "$(date +"%r"); $$ $ip ist erreichbar."

    # Kommando anzeigen
    # echo "Komando: $command"

    #daten synchronisieren mit rsync 
    if [ "$command" == "upload" ]; then
      # uploaden der dateien
      
      ##HIER IST EIN FEHLER!!! 
      ##rootDirectory="~/Files/"
      ##sendingCommand="$rootDirectory $username@$ip:/home/admin/VTDS/Files/"
      ##echo "Bashcommand: $sendingCommand"
      echo "$(date +"%r") directory: $(pwd)$rootDirectory"
      sshpass -p $password rsync -r $(pwd)$rootDirectory $username@$ip:$(pwd)$remoteDirectory
      #sshpass -p $password rsync -r ~/VTDS/Files/ $username@$ip:~/VTDS/Files/
      echo "$(date +"%r") Raspberry Pi upload fertig"
      
      #########################################################      
      #sshpass -p $password rsync -r $HOME$rootDirectory $username@$ip:$HOME$remoteDirectory
      #sshpass -p $password rsync -r ~/VTDS/Files/ $username@$ip:~/VTDS/Files/
      #########################################################

      echo "$(date +"%r"); $$ Raspberry Pi upload fertig"
      #laufzeit berechnen
      echo "Ausfueherungseit: $SECONDS s"

      if [ "$rowSyncronisation" == "true" ]; then
          #wenn raspi gefunden und synchronisiert (und Reihensynchronisation), abbrechen
          # Lösche die PID-Datei am Ende des Skripts
          trap "rm -f $pid_file" EXIT
          exit 1
      else
          #brauchen wir hier noch ein continue um in die nächste schleifen iteration zu kommen?
      fi    
    elif [ "$command" == "download" ]; then
      #downloaden der dateien
      #########################################################
      #sshpass -p $password rsync -r $username@$ip:$HOME$remoteDirectory $HOME$rootDirectory
      #########################################################
      sshpass -p $password rsync -r $username@$ip:$(pwd)$remoteDirectory $(pwd)$rootDirectory
      echo "$(date +"%r") Raspberry Pi download fertig"
      
      # Endzeit speichern
      #end=$(date +%s.%N)
      echo "$(date +"%r"); $$ Raspberry Pi download fertig"
      # Berechnung der Laufzeit
      #runtime=$(echo "$end - $start" | bc)
      echo "$$ Ausfuehrungseit: $SECONDS s"
      
    else
      echo "Ungültiges Kommando. Verwenden Sie 'download' oder 'upload'."
      # Endzeit speichern
      #end=$(date +%s.%N)

      # Berechnung der Laufzeit
      #runtime=$(echo "$end - $start" | bc)
      echo "$$ Ausfuehrungseit: $SECONDS s"
      # Lösche die PID-Datei am Ende des Skripts
      trap "rm -f $pid_file" EXIT
      exit 1
    fi
    #break entfernen, da er mehrere ip adressen in einem schwung synchronisieren soll
    break
  else
    echo "$(date +"%r"); $$ $ip nicht erreichbar"
  fi

done < "$ip_file"


# Berechnung der Laufzeit
echo "$$ Ausfuehrungseit $SECONDS s"

# Lösche die PID-Datei am Ende des Skripts
trap "rm -f $pid_file" EXIT

exit 1
