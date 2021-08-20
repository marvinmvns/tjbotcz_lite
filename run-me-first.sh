
#!/bin/sh

#----make sure this is run as root
user=`id -u`
if [ $user -ne 0 ]; then
    echo "This script requires root permissions. Please run this script with sudo."
    exit
fi

#----ascii art!
echo " _   _ _           _     _                 _       _                   "
echo "| | (_) |         | |   | |               | |     | |                  "
echo "| |_ _| |__   ___ | |_  | |__   ___   ___ | |_ ___| |_ _ __ __ _ _ __  "
echo "| __| | '_ \ / _ \| __| | '_ \ / _ \ / _ \| __/ __| __| '__/ _\` | '_ \ "
echo "| |_| | |_) | (_) | |_  | |_) | (_) | (_) | |_\__ \ |_| | | (_| | |_) |"
echo " \__| |_.__/ \___/ \__| |_.__/ \___/ \___/ \__|___/\__|_|  \__,_| .__/ "
echo "   _/ |                                                         | |    "
echo "  |__/                                                          |_|    "


sudo apt-get install espeak
sudo rm -rf tjbotcz_lite
#----nodejs install
echo ""
RECOMMENDED_NODE_LEVEL="16"
MIN_NODE_LEVEL="16"
NEED_NODE_INSTALL=false

if which node > /dev/null; then
    NODE_VERSION=$(node --version 2>&1)
    NODE_LEVEL=$(node --version 2>&1 | cut -d '.' -f 1 | cut -d 'v' -f 2)
    if [ $NODE_LEVEL -lt $MIN_NODE_LEVEL ]; then
        echo "Node.js v$NODE_VERSION.x is currently installed. We recommend installing"
        echo "v$MIN_NODE_LEVEL.x or later."
        NEED_NODE_INSTALL=true
    fi
else
    echo "Node.js is not installed."
    NEED_NODE_INSTALL=true
fi

if $NEED_NODE_INSTALL; then
    read -p "Would you like to install Node.js v$RECOMMENDED_NODE_LEVEL.x? [Y/n] " choice </dev/tty
    case "$choice" in
        "" | "y" | "Y")
            curl -sL https://deb.nodesource.com/setup_${RECOMMENDED_NODE_LEVEL}.x | sudo bash -
            apt-get install -y nodejs
            ;;
        *)
            echo "Warning: TJBot may not operate without installing a current version of Node.js."
            ;;
    esac
fi


git clone https://github.com/marvinmvns/tjbotcz_lite.git
cd tjbotcz_lite
sudo chmod +rwx /home/pi/Desktop/tjbotcz_lite/
sudo chown -R $USER /home/pi/
sudo npm install
npm i asyncawait
npm install i2c-bus
npm install
if grep -Fq "ipButton.js" ~/.bashrc
then
    echo "the ipButton is already setup in bashrc"
else
    echo "ipButton autostart added"
    echo "# automatically run ipButton program" >> ~/.bashrc
    echo "sudo node ~/Desktop/tjbotcz_lite/ipButton.js" >> ~/.bashrc
fi
hostname -I | cut -d' ' -f1
sudo node easy.js
