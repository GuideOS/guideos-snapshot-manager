```markdown
# GuideOS Stop-Tool

## Übersicht
Das **GuideOS Stop-Tool** ist ein Zenity-basiertes Bash-Skript, das die komfortable Beendigung von Programmen durch einfaches Anklicken ermöglicht.  
Es informiert den Benutzer über die Funktionsweise und startet anschließend `xkill`, um ein nicht mehr reagierendes Fenster oder Programm direkt zu schließen.

- **Autor:** evilware666  
- **Version:** 1.1  
- **Letzte Änderung:** 19.12.2025  
- **Lizenz:** MIT  

---

## Voraussetzungen
- **Linux-System** mit Bash  
- **Zenity** für grafische Dialoge  
- **x11-utils** (für `xkill`) installiert  

---

## Installation
1. Skript speichern, z. B. unter `/usr/local/bin/stop-tool.sh`.  
2. Datei ausführbar machen:
   ```bash
   chmod +x /usr/local/bin/stop-tool.sh
   ```
3. Sicherstellen, dass `zenity` und `xkill` verfügbar sind:
   ```bash
   sudo apt install zenity x11-utils
   ```

---

## Nutzung
Starte das Skript im Terminal:
```bash
./stop-tool.sh
```

### Ablauf:
1. **Infobox:** Hinweis zur Nutzung des Tools.  
2. **xkill:** Nach Bestätigung startet `xkill`.  
3. **Aktion:** Mit der Maus auf das zu beendende Fenster klicken.  

---

## Hinweise
- Das Tool ist besonders nützlich bei nicht mehr reagierenden Programmen.  
- `xkill` beendet das ausgewählte Fenster sofort.  
- Vorsicht: Auch wichtige Programme können versehentlich beendet werden.  

---

## Lizenz
Dieses Projekt steht unter der **MIT-Lizenz**.  
Freie Nutzung, Modifikation und Weitergabe sind erlaubt, solange der Lizenztext beibehalten wird.
```
