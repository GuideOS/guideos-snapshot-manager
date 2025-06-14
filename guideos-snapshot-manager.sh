#!/bin/bash

# =============================================================================================================
# Titel       : GuideOS Snapshot-Manager
# Autor       : evilware666
# Datum       : 2025-06-11
# Beschreibung: Der GuideOS Snapshot-Manager erstellt und verwaltet Snapshots deines Systems.
# Sprache     : Bash
# =============================================================================================================

# =============================================================================================================
# Verhindert, dass das Programm doppelt ausgeführt wird und gibt einen Hinweis aus.
# =============================================================================================================
LOCKFILE="/tmp/guideos_snapshot_manager.lock"
if [ -e "$LOCKFILE" ]; then
  zenity --error --title="Schon gestartet" --text="Der GuideOS Snapshot-Manager wird bereits ausgeführt."
  exit 1
else
  touch "$LOCKFILE"
  trap "rm -f $LOCKFILE" EXIT
fi

# =============================================================================================================
# Live-System-Erkennung
# =============================================================================================================
if grep -E ' / (overlay|squashfs|aufs|tmpfs)' /proc/mounts &>/dev/null; then
  zenity --error --title="Live-System erkannt" \
    --text="Der GuideOS Snapshot-Manager wurde in einer Live-Umgebung gestartet.\n
                 Bitte starte das Programm auf einem fest installierten System!"
  exit 1
fi

# =============================================================================================================
# Btrfs-Dateisystem-Erkennung
# =============================================================================================================
if ! findmnt -n -T / | grep -q btrfs; then
  zenity --error --title="Nicht unterstütztes Dateisystem" \
    --text="Der GuideOS Snapshot-Manager funktioniert nur auf einem Btrfs-Dateisystem.\n
                 Bitte verwende ein System mit Btrfs-Dateisystem."
  exit 1
fi

# =============================================================================================================
# Überprüft, ob alle Programme zur Ausführung vom GuideOS Snapshot-Manager vorhanden sind.
# =============================================================================================================
fehlende_tools=""
for tool in snapper zenity notify-send paplay; do
  if ! command -v "$tool" &>/dev/null; then
    fehlende_tools+="$tool\n"
  fi
done

if [ -n "$fehlende_tools" ]; then
  zenity --error --title="Fehlende Programme" --text="Folgende Programme fehlen:\n$fehlende_tools\nBitte installiere sie und starte das Tool erneut."
  exit 1
fi

# =============================================================================================================
# Benutzerhilfe anzeigen
# =============================================================================================================
zenity --question --title="Benutzerhilfe anzeigen?" --text="Möchtest du eine kurze Einführung in den Snapshot-Manager erhalten?"
if [ $? -eq 0 ]; then
  zenity --info --title="Benutzerhilfe – GuideOS Snapshot-Manager" \
    --text="\n\n🔄 GuideOS Snapshot-Manager – Dein System sicher im Griff

Der GuideOS Snapshot-Manager hilft dir dabei, dein System zu sichern und bei Bedarf wiederherzustellen.
Ein Snapshot ist wie ein Sicherungspunkt deines gesamten Systems – ähnlich wie ein Systemwiederherstellungspunkt in Windows oder ein Time Machine-Backup auf dem Mac. Wenn später etwas schiefgeht (z. B. durch ein fehlerhaftes Update oder eine falsche Einstellung), kannst du den Zustand deines Systems einfach wieder auf einen früheren Zeitpunkt zurücksetzen.

🛠️ Was du im Hauptmenü machen kannst:

Snapshot erstellen
Du legst einen neuen Sicherungspunkt an. So merkt sich das System seinen aktuellen Zustand.

Snapshot löschen
Alte oder nicht mehr benötigte Sicherungspunkte kannst du hier entfernen, um Speicherplatz zu sparen.

Snapshot-Übersicht anzeigen
Zeigt dir eine Liste aller vorhandenen Snapshots an – inklusive Datum und Namen. So behältst du den Überblick.

💡 Tipp:
Erstelle vor jeder größeren Änderung (z. B. Systemaktualisierung, Software-Installation oder Konfigurationsänderung) einen Snapshot. So kannst du dein System jederzeit in einen funktionierenden Zustand zurückversetzen – ganz ohne Datenverlust."
fi

# =============================================================================================================
# GUI-Passwortabfrage mit Zenity
# =============================================================================================================
PASSWORT=$(zenity --password --title="Authentifizierung erforderlich")
if ! echo "$PASSWORT" | sudo -S -v &>/dev/null; then
  zenity --error --title="Authentifizierung fehlgeschlagen" --text="Falsches Passwort oder keine Berechtigung.\nDas Tool wird beendet."
  exit 
fi

# =============================================================================================================
# Wichtiger Hinweis
# =============================================================================================================
zenity --warning --title="Wichtiger Hinweis" --text="Lösche regelmäßig alte Snapshots, damit deine Festplatte nicht zu voll wird. 

                ⚠️Es werden MAXIMAL 50 SNAPSHOTS empfohlen.⚠️"

# =============================================================================================================
# Warnung bei zu vielen Snapshots
# =============================================================================================================
function pruefe_snapshot_anzahl() {
  SNAPSHOT_COUNT=$(snapper -c "$SNAPPER_CONFIG" list | tail -n +3 | wc -l)
  if [ "$SNAPSHOT_COUNT" -ge 50 ]; then
    zenity --warning --title="Zu viele Snapshots!" \
      --text="              Es wurden $SNAPSHOT_COUNT Snapshots erstellt!\n\n
 Die empfohlene Höchstzahl von 50 Snapshots ist somit erreicht.\n
 Bitte lösche alte Snapshots, um Speicherplatz freizugeben.\n
⚠️Ein volles Laufwerk kann zu Instabilität und Datenverlust führen⚠️"
  fi
}

# =============================================================================================================
# 🛠️  GuideOS Snapshot-Manager
# =============================================================================================================

SNAPPER_CONFIG="root"

function sende_benachrichtigung() {
  TITLE="$1"
  TEXT="$2"
  notify-send "$TITLE" "$TEXT"
}

function spiele_benachrichtigungston() {
  paplay /usr/share/sounds/freedesktop/stereo/complete.oga &
}

function grub_aktualisieren() {
  if [ -x /usr/sbin/update-grub ]; then
    echo "$PASSWORT" | sudo -S /usr/sbin/update-grub
  fi
}

function snapshot_erstellen() {
  NAME_EINGABE=$(zenity --entry --title="Snapshot erstellen" --text="Name des Snapshots:")
  [ -z "$NAME_EINGABE" ] && return

  NAME="${NAME_EINGABE// /_}"

  echo "$PASSWORT" | sudo -S snapper -c "$SNAPPER_CONFIG" create --description "$NAME"
  sende_benachrichtigung "Snapshot erstellt" "Snapshot \"$NAME\" wurde erstellt."
  spiele_benachrichtigungston
  grub_aktualisieren
  pruefe_snapshot_anzahl
}

function snapshot_loeschen() {
  SNAP_LIST=$(snapper -c "$SNAPPER_CONFIG" list | tail -n +3)

  if [ -z "$SNAP_LIST" ]; then
    zenity --info --text="Keine Snapshots zum Löschen vorhanden."
    return
  fi

  OPTIONS=()
  while IFS= read -r line; do
    ID=$(echo "$line" | awk '{print $1}')
    DESC=$(echo "$line" | cut -d'|' -f3- | sed 's/^ *//;s/ *$//')
    [ -z "$DESC" ] && DESC="(keine Beschreibung)"
    OPTIONS+=("FALSE" "$ID" "$DESC")
  done <<< "$SNAP_LIST"

  SNAP_IDS=$(zenity --list --checklist --multiple --title="GuideOS Snapshot-Manager – Snapshots löschen" \
    --text="Wähle Snapshots zum Löschen aus:" \
    --width=800 --height=400 \
    --column="Markieren" --column="ID" --column="Beschreibung" \
    "${OPTIONS[@]}" --separator=" ")

  if [ -z "$SNAP_IDS" ]; then
    zenity --info --text="Keine Snapshots ausgewählt."
    return
  fi

  for id in $SNAP_IDS; do
    echo "$PASSWORT" | sudo -S snapper -c "$SNAPPER_CONFIG" delete "$id"
  done

  sende_benachrichtigung "Snapshot gelöscht" "Die ausgewählten Snapshots wurden gelöscht."
  spiele_benachrichtigungston
  grub_aktualisieren
}

function snapshot_uebersicht() {
  SNAPSHOTS=$(snapper -c "$SNAPPER_CONFIG" list | tail -n +3)
  if [ -z "$SNAPSHOTS" ]; then
    zenity --info --text="Keine Snapshots vorhanden."
  else
    zenity --text-info --title="Snapshot-Übersicht" --width=700 --height=400 --filename=<(echo "$SNAPSHOTS")
  fi
}

function hauptmenue() {
  pruefe_snapshot_anzahl
  while true; do
    AUSWAHL=$(zenity --list --title="GuideOS Snapshot-Manager" \
      --column="Aktion" --width=400 --height=300 \
      "Snapshot erstellen" "Snapshot löschen" "Snapshot-Übersicht anzeigen" "Beenden")

    case "$AUSWAHL" in
      "Snapshot erstellen") snapshot_erstellen ;;
      "Snapshot löschen") snapshot_loeschen ;;
      "Snapshot-Übersicht anzeigen") snapshot_uebersicht ;;
      "Beenden"|"") 
        sudo -k   # Sudo-Credentials entwerten
        exit 0
        ;;
    esac
  done
}

hauptmenue
