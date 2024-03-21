#!/bin/bash

#programm kann mit upload oder download aufgerufen werden

#erstelle slaves.txt mit in jeder zeile einer ip zum anfragen
#erstelle config.txt mit username (erste zeile) und passwort (zweite zeile), rootdirectory (dritte zeiel) und  remote directory (vierte zeile)


# Dateiname für die IP-Adressen
ip_file="slaves.txt"
config_file="config.txt"


# Überprüfen, ob mindestens ein Parameter übergeben wurde
if [ $# -eq 0 ]; then
    echo "Keine Parameter übergeben. Bitte Parameter angeben."
    exit 1
fi

# Erster übergebener Parameter ist $1, zweiter ist $2 usw.
command="$1"
echo "Kommando: $command"


# Überprüfen, ob die Datei existiert
if [[ ! -f $ip_file ]]; then
  echo "Die angegebene IP-Adress Datei existiert nicht."
  exit 1
fi

if [[ ! -f $config_file ]]; then
  echo "Die angegebene Konfig Datei existiert nicht."
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

# Ausgabe der gespeicherten Informationen nur debugging
#echo "Benutzername: $username"
#echo "Passwort: $password"
echo "root directory: $rootDirectory"
echo "remote directory: $remoteDirectory"

# Zeilenweise den Inhalt der Datei ausgeben
while IFS= read -r ip; do

  #nur für debugging
  #echo "$ip"

  #ist die ip erreichbar?
  if ping -c 1 $ip &> /dev/null; then
    echo "$ip ist erreichbar."

    # Kommando anzeigen
    # echo "Komando: $command"

    #daten synchronisieren mit rsync 
    if [ "$command" == "upload" ]; then
      # uploaden der dateien

      #HIER IST EIN FEHLER!!!
      #rootDirectory="~/Files/"
      #sendingCommand="$rootDirectory $username@$ip:/home/admin/VTDS/Files/"
      #echo "Bashcommand: $sendingCommand"
      sshpass -p $password rsync -r $HOME$rootDirectory $username@$ip:$HOME$remoteDirectory
      #sshpass -p $password rsync -r ~/VTDS/Files/ $username@$ip:~/VTDS/Files/
      echo "Raspberry Pi upload fertig"
      #wenn raspi gefunden und synchronisiert, abbrechen
      exit 1
    elif [ "$command" == "download" ]; then
      #downloaden der dateien
      sshpass -p $password rsync -r $username@$ip:$HOME$remoteDirectory $HOME$rootDirectory
      echo "Raspberry Pi download fertig"
    else
      echo "Ungültiges Kommando. Verwenden Sie 'download' oder 'upload'."
      exit 1
    fi
    break
  else
    echo "$ip nicht erreichbar"
  fi

done < "$ip_file"
