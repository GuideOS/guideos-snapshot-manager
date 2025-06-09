#!/bin/bash

# GUI-Passwortabfrage mit Zenity
PASSWORT=$(zenity --password --title="Authentifizierung erforderlich")
if ! echo "$PASSWORT" | sudo -S -v &>/dev/null; then
  zenity --error --title="Authentifizierung fehlgeschlagen" --text="Falsches Passwort oder keine Berechtigung.\nDas Tool wird beendet."
  exit 1
fi

# ==============================================================  
#  🛠️  GuideOS Snapshot-Manager  
# ==============================================================

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

  SNAP_IDS=$(zenity --list --checklist --multiple --title="Guideos Snapshot-Manager - Snapshots löschen" \
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
    zenity --text-info --title="Snapshot Übersicht" --width=700 --height=400 --filename=<(echo "$SNAPSHOTS")
  fi
}

function hauptmenue() {
  while true; do
    AUSWAHL=$(zenity --list --title="Guideos Snapshot-Manager" \
      --column="Aktion" --width=400 --height=300 \
      "Snapshot erstellen" "Snapshot löschen" "Snapshot Übersicht anzeigen" "Beenden")

    case "$AUSWAHL" in
      "Snapshot erstellen") snapshot_erstellen ;;
      "Snapshot löschen") snapshot_loeschen ;;
      "Snapshot Übersicht anzeigen") snapshot_uebersicht ;;
      "Beenden"|"") 
        sudo -k   # Sudo-Credentials entwerten, damit beim Beenden keine weitere Abfrage kommt
        exit 0   # Skript sofort beenden
        ;;
    esac
  done
}

hauptmenue
