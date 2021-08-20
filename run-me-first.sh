
#!/bin/sh

#----make sure this is run as root
user=`id -u`
if [ $user -ne 0 ]; then
    echo "This script requires root permissions. Please run this script with sudo."
    exit
fi


#----update raspberry
echo ""
echo "TJBot requires an up-to-date installation of your Raspberry Pi's operating"
echo "system software. If you have never done this before, it can take up to an"
echo "hour or longer."
read -p "Proceed with apt-get dist-upgrade? [Y/n] " choice </dev/tty
case "$choice" in
    "n" | "N")
        echo "Warning: you may encounter problems running TJBot recipes without performing"
        echo "an apt-get dist-upgrade. If you experience these problems, please re-run"
        echo "the bootstrap script and perform this step."
        ;;
    *)
        echo "Updating apt repositories [apt-get update]"
        apt-get update
        echo "Upgrading OS distribution [apt-get dist-upgrade]"
        apt-get -y dist-upgrade
        ;;
esac

#----install additional packages
echo ""
if [ $RASPIAN_VERSION_ID -eq 8 ]; then
    echo "Installing additional software packages for Jessie (alsa, libasound2-dev, git, pigpio)"
    apt-get install -y alsa-base alsa-utils libasound2-dev git pigpio
#elif [ $RASPIAN_VERSION -eq 9 ]; then
#    echo "Installing additional software packages for Stretch (libasound2-dev)"
#    apt-get install -y libasound2-dev
fi

#----remove outdated apt packages
echo ""
echo "Removing unused software packages [apt-get autoremove]"
apt-get -y autoremove

#----enable camera on raspbery pi
echo ""
echo "If your Raspberry Pi has a camera installed, TJBot can use it to see."
read -p "Enable camera? [y/N] " choice </dev/tty
case "$choice" in
    "y" | "Y")
        if grep "start_x=1" /boot/config.txt
        then
            echo "Camera is already enabled."
        else
            echo "Enabling camera."
            if grep "start_x=0" /boot/config.txt
            then
                sed -i "s/start_x=0/start_x=1/g" /boot/config.txt
            else
                echo "start_x=1" | tee -a /boot/config.txt >/dev/null 2>&1
            fi
            if grep "gpu_mem=128" /boot/config.txt
            then
                :
            else
                echo "gpu_mem=128" | tee -a /boot/config.txt >/dev/null 2>&1
            fi
        fi
        ;;
    *) ;;
esac

sudo apt-get install espeak
sudo rm -rf tjbotcz_lite
#----nodejs install
echo ""
RECOMMENDED_NODE_LEVEL="15"
MIN_NODE_LEVEL="15"
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
npm install
npm i express
npm i asyncawait
npm install i2c-bus
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
