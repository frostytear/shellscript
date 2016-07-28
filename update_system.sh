#!/bin/bash

if [ $(id -u) -ne 0 ]; then
	echo 'Você precisa ser root para executar esse script'
	exit 1
fi

echo 'Bem-vindo ao script de atualização do sistema Ubuntu Linux'

echo 'Aperte <ENTER> para continuar ou <CTRL+C> para sair...'
read

echo 'Verificando atualizações do sistema, aguarde...'
apt-get update -y --force-yes -qq
apt-get upgrade -y --force-yes -qq
apt-get dist-upgrade -y --force-yes -qq

echo 'Instalando wine1.7...'
add-apt-repository ppa:ubuntu-wine/ppa -y
apt-get update -y --force-yes -qq
apt-get install wine1.7 -y --force-yes -qq

echo 'Instalando editor vim...'
apt-get install vim -y --force-yes -qq

echo 'Instalando gparted...'
apt-get install gparted -y --force-yes -qq

echo 'Instalando ubuntu-restricted-extras...'
apt-get install ubuntu-restricted-extras -y --force-yes -qq

echo 'Instalando gerenciador de pacotes aptitude...'
apt-get install aptitude -y --force-yes -qq

echo 'Baixando navegador Google Chrome...'
wget -O google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
echo 'Instalando navegador Google Chome...'
dpkg -i google-chrome-stable_current_amd64.deb
apt-get install -f -y --force-yes -qq

echo 'Instalando reprodutor de audio/video VLC...'
apt-get install vlc -y --force-yes -qq

echo 'Instalando editor de programação Geany...'
apt-get install geany -y --force-yes -qq

echo 'Instalando gerenciador de arquivos zip...'
apt-get install p7zip-full -y --force-yes -qq

echo 'Instalando gerenciador FTP FileZilla...'
apt-get install filezilla -y --force-yes -qq

echo 'Instalando gerenciador de tarefas htop...'
apt-get install htop -y --force-yes -qq

echo 'Instalando Java 1.8...'
add-apt-repository ppa:webupd8team/java -y
apt-get update -y --force-yes -qq
apt-get install oracle-java8-installer -y --force-yes -qq
apt-get install oracle-java8-set-default -y --force-yes -qq

echo 'Instalando STEAM...'
apt-get install steam -y --force-yes -qq

echo 'Instalando player Spotify...'
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2C19886
echo 'deb http://repository.spotify.com stable non-free' >> /etc/apt/sources.list
apt-get update -y --force-yes -qq
apt-get install spotify-client spotify-client-qt -y --force-yes -qq
apt-get install spotify-client-gnome-support -y --force-yes -qq
wget -O libgcrypt11_1.5.3-2ubuntu4.2_amd64.deb https://launchpad.net/ubuntu/+archive/primary/+files/libgcrypt11_1.5.3-2ubuntu4.2_amd64.deb
dpkg -i libgcrypt11_1.5.3-2ubuntu4.2_amd64.deb
apt-get install -f -y --force-yes -qq

echo 'Iniciando gerenciador Skype...'
apt-get install sni-qt:i386 -y --force-yes -qq
echo 'Baixando Skype...'
wget -O skype-ubuntu-precise_4.3.0.37-1_i386.deb http://download.skype.com/linux/skype-ubuntu-precise_4.3.0.37-1_i386.deb
echo 'Instalando Skype...'
dpkg -i skype-ubuntu-precise_4.3.0.37-1_i386.deb
apt-get install -f -y --force-yes -qq

echo 'Instalando DarkTable e Rawtherapee'
apt-get istall darktable -y --force-yes -qq
apt-get install rawtherapee -y --force-yes -qq

echo 'Instalando Ubuntu-Tweak-Tool e vários temas...'
apt-get install gnome-tweak-tool -y --force-yes -qq
add-apt-repository ppa:upubuntu-com/gtk3themes -y
add-apt-repository ppa:upubuntu-com/icons -y
apt-get update -y --force-yes -qq
apt-get install ambiance-dark-blue-gtk3 -y --force-yes -qq
apt-get install animus-gtk3 -y --force-yes -qq
apt-get install autumn-kerala-gtk3 -y --force-yes -qq
apt-get install azure-theme-gtk3 -y --force-yes -qq
apt-get install delorean-dark-gtk3 -y --force-yes -qq
apt-get install dorian-theme-gtk3 -y --force-yes -qq
apt-get install  sable-theme-gtk3 -y --force-yes -qq
apt-get install sable-icons -y --force-yes -qq
apt-get install stylish-dark-gtk3 -y --force-yes -qq
apt-get install vold-theme-gtk3 -y --force-yes -qq
apt-get install adwaita-os-x-gtk3 -y --force-yes -qq

echo 'Instalando YAD, para criação de shell gráfico...'
add-apt-repository ppa:nilarimogard/webupd8 -y
apt-get update -y --force-yes -qq
apt-get install yad -y --force-yes -qq

echo 'Todos os aplicativos foram instalados com sucesso!!!'
sleep 5

echo 'Limpando cache do sistema, aguarde...'
apt-get autoclean -y --force-yes -qq
apt-get autoremove -y --force-yes -qq

echo 'Sistema limpo. Seu computador precisa ser reiniciado para que todas as mudanças tenham efeito...'
echo 'Aperte <ENTER> para reiniciar ou <CTRL+C> para sair e reiniciar quando julgar necessário!!!'
read

echo 'Obrigado por utilizar esse script!!!'

echo 'Reiniciando o sistema, aguarde...'
sleep 3
shutdown -r now
