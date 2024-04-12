##Erklärung:

#Starten:
Um das Script zu starten muss sshpass und rsync installiert werden.

Danach muss mit man sich initial mit gedem Node des Clusters einmalig per ssh verbinden um eine Fingerprint zu genereiren.

In der slaves.txt müssen, müssen die IP-Adressen der Nodes angegeben werden (Zu beginn kommt der masternode). 
Pro Zeile steht genau eine IP-Adressse.

Die config.txt sieht folgendermaßen aus (ACHTUNG: PW  und User sowie die Verzeichnisse müssen auf allen Knoten identisch sein!):
<username>
<password>
<leseverzeichnis eigener knoten>
<leseverzeichnis clusterknoten>


#Starten des Scripts:
Anzeigen der Dateien:
bash distributedSystem.sh show

Hochladen:
bash distributedSystem.sh upload

Herunterladen:
bash distributedSystem.sh download
