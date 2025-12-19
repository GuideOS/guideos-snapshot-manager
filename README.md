```markdown
# GuideOS Snapshot-Manager

## Übersicht
Der **GuideOS Snapshot-Manager** ist ein Zenity-basiertes Bash-Skript als GUI-Frontend für **Timeshift**.  
Es ermöglicht die komfortable Verwaltung von Snapshots über eine grafische Oberfläche:

- Snapshots erstellen  
- Snapshots löschen  
- Anzeige von Snapshots mit Datum und Kommentar  
- Einfache Bedienung über Zenity  

- **Autor:** evilware666  
- **Version:** 1.2  
- **Letzte Änderung:** 19.12.2025  
- **Lizenz:** MIT  

---

## Voraussetzungen
- **Linux-System mit Btrfs-Dateisystem**  
- **Timeshift** installiert und einmalig eingerichtet  
- **Zenity** für grafische Dialoge  
- **Sudo-Rechte** für Snapshot-Operationen  
- Optional: `paplay` für akustische Benachrichtigungen  

---

## Einrichtungshinweis
Vor der Nutzung Timeshift einmalig konfigurieren:
1. Alle Snapshot-Intervalle aktivieren  
2. Home-Verzeichnis **nicht** sichern (vermeidet große Snapshots)  

---

## Installation
1. Skript speichern, z. B. unter `/usr/local/bin/snapshot-manager.sh`.  
2. Datei ausführbar machen:
   ```bash
   chmod +x /usr/local/bin/snapshot-manager.sh
   ```
3. Sicherstellen, dass `timeshift` und `zenity` installiert sind:
   ```bash
   sudo apt install timeshift zenity
   ```

---

## Nutzung
Starte das Skript im Terminal:
```bash
./snapshot-manager.sh
```

### Ablauf:
- **Systemprüfung:** Nur auf Btrfs-Systemen, nicht im Live-Modus.  
- **Passwortabfrage:** Authentifizierung über Zenity.  
- **Menü:** Auswahl zwischen Snapshot erstellen, Snapshot löschen oder Beenden.  
- **Snapshot-Erstellung:** Eingabe eines Namens, Erstellung mit Timeshift, GRUB-Aktualisierung.  
- **Snapshot-Löschung:** Auswahl aus Liste, Bestätigung, Löschung mit Timeshift, GRUB-Aktualisierung.  

---

## Hinweise
- Snapshots werden über **Timeshift** verwaltet.  
- Nach jeder Erstellung oder Löschung wird die **GRUB-Konfiguration** automatisch aktualisiert.  
- Akustische Signale werden abgespielt, wenn `paplay` verfügbar ist.  
- Das Tool ist ausschließlich für **Btrfs-Systeme** geeignet.  

---

## Lizenz
Dieses Projekt steht unter der **MIT-Lizenz**.  
Freie Nutzung, Modifikation und Weitergabe sind erlaubt, solange der Lizenztext beibehalten wird.
```
