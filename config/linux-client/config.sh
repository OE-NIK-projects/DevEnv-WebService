#!/usr/bin/env bash

if [ $(id -u) -eq 0 ]; then
	echo 'This script should not be run as root!'
	exit 1
fi

set -e

CERT_FILE=/usr/local/share/ca-certificates/boilerplate-ca.crt
REPO_PATH=~/projects/Frontend-Repo

sudo bash <<EOF
set -e

tee /etc/apt/sources.list.d/official-package-repositories.list <<EOF2
deb https://quantum-mirror.hu/mirrors/linuxmint/packages xia main upstream import backport
deb https://quantum-mirror.hu/mirrors/pub/ubuntu noble main restricted universe multiverse
deb https://quantum-mirror.hu/mirrors/pub/ubuntu noble-updates main restricted universe multiverse
deb https://quantum-mirror.hu/mirrors/pub/ubuntu noble-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu/ noble-security main restricted universe multiverse
EOF2

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /usr/share/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list

apt update
apt upgrade -y
apt install -y code git inkscape jq libnss3-tools micro ranger

wget -O $CERT_FILE https://raw.githubusercontent.com/OE-NIK-projects/DevEnv-WebService/refs/heads/main/config/certs/rca.crt
update-ca-certificates
EOF

rm -rf $REPO_PATH

echo 'https://benji.coleman:Password1%21@git.boilerplate.lan' > ~/.git-credentials
git config --global user.name benji.coleman
git config --global user.email benji.coleman@boilerplate.lan
git config --global credential.helper store

git clone https://git.boilerplate.lan/Frontend/Frontend-Repo.git $REPO_PATH

if [ ! -f "$REPO_PATH/.gitattributes" ]; then
	pushd $REPO_PATH
	echo '* text=auto eol=lf' > .gitattributes
	git add .gitattributes
	git commit -m 'Added .gitattributes file'
	git push
	popd
fi

firefox &
PID=$!
sleep 1
kill -TERM $PID
certutil -A -d ~/.mozilla/firefox/*.default-release/ -i $CERT_FILE -n 'Boilerplate Certificate Authority' -t 'C,T,TC'

curl -fsSL https://bun.sh/install | bash

code --install-extension oven.bun-vscode

CONFIG=~/.config/cinnamon/spices/grouped-window-list\@cinnamon.org/*.json
TEMP=/tmp/config.json
jq '.["pinned-apps"].value = ["firefox.desktop", "code.desktop", "org.gnome.Terminal.desktop", "nemo.desktop"]' $CONFIG > $TEMP
mv $TEMP $CONFIG

reboot
