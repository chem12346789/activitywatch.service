cp activitywatch.service ~/.config/systemd/user/activitywatch.service
cp activitywatch_kill.sh ~/.local/bin/activitywatch_kill.sh
cp activitywatch_start.sh ~/.local/bin/activitywatch_start.sh
chmod +x ~/.local/bin/activitywatch_kill.sh
chmod +x ~/.local/bin/activitywatch_start.sh
cd tmp

# == Install aw-awatcher ==
# Download (deb package for Debian/Ubuntu)
wget https://github.com/2e3s/awatcher/releases/download/v0.3.3/aw-awatcher_0.3.3-1_amd64.deb
sudo dpkg -i aw-awatcher_amd64.deb
sudo apt-get install -f
# Verify
which aw-awatcher

# == Install focused-window-dbus and aw status extension ==
echo "Install focused-window-dbus and aw status extension"

#  == Install aw-server and aw-sync ==
wget https://github.com/ActivityWatch/activitywatch/releases/download/v0.13.2/activitywatch-v0.13.2-linux-x86_64.zip
if [ -d ~/Nutstore\ Files/Nutstore/ActivityWatchSync ]; then
    ln -s ~/Nutstore\ Files/Nutstore/ActivityWatchSync ~/ActivityWatchSync
else
    echo "Directory ~/Nutstore Files/Nutstore/ActivityWatchSync does not exist. You can create it and sync it with Nutstore to keep your ActivityWatch data backed up."
fi
mkdir -p ~/.local/opt/
unzip activitywatch-v0.13.2-linux-x86_64.zip -d ~/.local/opt/
rm activitywatch-v0.13.2-linux-x86_64.zip

systemctl --user daemon-reload
systemctl --user enable activitywatch.service
systemctl --user start activitywatch.service
ps aux | grep -E "aw-(server|awatcher|sync)" | grep -v grep
echo "Installation complete."
