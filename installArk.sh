#=========== Update System ==================
sudo apt-get update
sudo apt-get -t experimental install libc6-dev
sudo apt-get install lib32gcc1
sudo apt-get install steamcmd

#============ System CTL file Limit =========
cp /etc/sysctl.conf ~/sysctl.conf
echo "fs.file-max=100000" >> ~/sysctl.conf
sudo cp ~/sysctl.conf /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

#============ File Limits ===============
cp /etc/security/limits.conf ~/limits.conf
echo "*		soft nofile 1000000" >> ~/limits.conf
echo "*		hard nofile 1000000" >> ~/limits.conf
sudo cp ~/limits.conf /etc/security/limits.conf

#====== Apply PAM Limits ===============
cp /etc/pam.d/common-session ~/common-session
sudo echo "session required pam_limits.so" >> /etc/pam.d/common-session

#========== Update streamcmd =============
steamcmd +quit

#========== Create folder ==============
sudo mkdir -p /ark
sudo chown -R xelous /ark --verbose

#========== Add Ark User ===============
sudo useradd -m ark

#========= Link Steamcmd and download the game =========
cd ~
ln -s /usr/games/steamcmd steamcmd
steamcmd +login anonymous +force_install_dir /ark +app_update 376030 +quit
nano /ark/ShooterGame/Saved/Config/DefaultGameUserSettings.ini

#======
sudo chown -R ark /ark --verbose
sudo chgrp -R ark /ark --verbose

#======= Create the service script ===========
echo "[Unit]" > ark.service
echo "Description=ARK Survival Evolved" >> ark.service
echo "[Service]" >> ark.service
echo "Type=simple" >> ark.service
echo "Restart=on-failure" >> ark.service
echo "RestartSec=5" >> ark.service
echo "StartLimitInterval=60s" >> ark.service
echo "StartLimitBurst=3" >> ark.service
echo "User=ark" >> ark.service
echo "Group=ark" >> ark.service
echo "ExecStartPre=/usr/games/steamcmd +login anonymous +force_install_dir /ark +app_update 376030 +quit" >> ark.service
echo "ExecStart=/ark/ShooterGame/Binaries/Linux/ShooterGameServer TheIsland?listen?SessionName=XelServer -server -log" >> ark.service
echo "ExecStop=killall -TERM srcds_linux" >> ark.service
echo "[Install]" >> ark.service
echo "WantedBy=multi-user.target" >> ark.service

#========== Copy the ark service file into the services area ===============
sudo cp ark.service /lib/systemd/system/ark.service

#========= Reload the services daemon ===============
sudo systemctl daemon-reload
sudo systemctl enable ark.service
sudo systemctl start ark
