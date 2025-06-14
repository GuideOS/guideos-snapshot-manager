#!/bin/bash

# Sicherstellen, dass die Verzeichnisse existieren
mkdir -p debian/guideos-snapshot-manager/usr/share/applications
#mkdir -p debian/guideos-ticket-tool/etc/xdg/autostart

# Erstellen der ersten .desktop-Datei
cat > debian/guideos-snapshot-manager/usr/share/applications/guideos-snapshot-manager.desktop <<EOL
[Desktop Entry]
Version=1.0
Name=GuideOS Snapshot Tool
Comment=Btrfs Snapshot Management Tool for GuideOS
Name[de]=GuideOS Snapshot Tool
Comment[de]=Btrfs-Snapshot-Verwaltungstool für GuideOS
Exec=guideos-snapshot-manager
Icon=guideos-snapshot-manager
Terminal=false
Type=Application
Categories=GuideOS;
StartupNotify=true
EOL