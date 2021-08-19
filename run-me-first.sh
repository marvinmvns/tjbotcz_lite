
!/bin/bash
sudo apt-get install espeak
sudo rm -rf tjbotcz_lite
curl -sL https://deb.nodesource.com/setup_14.x
apt-get install -y nodejs
git clone https://github.com/marvinmvns/tjbotcz_lite.git
cd tjbotcz_lite
sudo npm install
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
