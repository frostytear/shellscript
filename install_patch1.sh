#!/bin/bash

function fncmsg() {
	imagem=$1
	texto=$2
	size=${3:-400}
	yad --image="${imagem}" --title="${TITLE}" --text="${texto}" --button="_Sair:1" --width=${size} --window-icon="${LOGO}" 2>/dev/null
}

function download()	{
	imagem=$1
  	texto=$2
  	size=${3:-400}
  	yad --image="${imagem}" --title="${TITLE}" --text="${texto}" --button="_Sair:1" --button="_Tentar Novamente:0" --width=${size} --window-icon="${LOGO}" 2>/dev/null
}

while true; do

	exec 3> >(yad --pulsate --undecorated --progress --auto-close --no-buttons --title="${TITLE}" --window-icon="${LOGO}" --width=500 >/dev/null 2>&1)
	echo "#\tBaixando patch de atualização, aguarde...\t" >&3
	echo "Baixando patch de atualização, aguarde..." > $LOG

	wget --timeout=10 -O /home/sgimovel/patch1.tar.gz http://www.inmetro.rs.gov.br/lapmpe/patch1.tar.gz 2>> $LOG 1>> $LOG
	FALHA=$?

	wget --timeout=10 -O /home/sgimovel/patch1.md5sum http://www.inmetro.rs.gov.br/lapmpe/patch1.md5sum  2>> $LOG 1>> $LOG
	FALHA=$?
	exec 3>&-

	cd /home/sgimovel

	md5sum -c patch1.md5sum
	MD5SUM=$?

	if [ $FALHA -ne 0 ] ; then
		echo "Falha no download. Atualização cancelada! Verifique sua conexão e tente novamente!" 2>> $LOG 1>> $LOG
		mensagem="\t\tFalha no download. Atualização cancelada!\t\t \n\t\tVerifique sua conexão e tente novamente!\t\t"
		download "gtk-dialog-error" "${mensagem}" 450
		if [ $? -eq 1 ]; then
			exit 1 && break
		else
			continue
		fi
	elif [ $MD5SUM -ne 0 ] ; then
                echo "ERRO! MD5SUM não confere, tente novamente!" 2>> $LOG 1>> $LOG
                mensagem="\t\tERRO! MD5SUM não confere, tente novamente!\t\t"
                download "gtk-dialog-error" "${mensagem}" 450
                if [ $? -eq 1 ]; then
                        exit 1 && break
                else
                        continue
                fi
	else
		break
	fi
done

exec 3> >(yad --pulsate --undecorated --progress --auto-close --no-buttons --title="${TITLE}" --window-icon="${LOGO}" --width=500 >/dev/null 2>&1)
echo "#\tInstalando o patch de atualização, aguarde...\t" >&3
echo "Descompactando o patch de atualização, aguarde..." 2>> $LOG 1>> $LOG
tar xvfz /home/sgimovel/patch1.tar.gz -C /home 2>> $LOG 1>> $LOG
cd /home/patch1
echo "Instalando o patch de atualização, aguarde..." 2>> $LOG 1>> $LOG
chmod 755 *.sh
if grep -q RS /etc/HOSTNAME ; then
	touch /root/login_oper
	su - oper -c /home/patch1/hw_fnc_estado_usuario.sh 2>> $LOG 1>> $LOG
fi
touch /root/login_oper
su - oper -c /home/patch1/crosscheck.sh 2>>$LOG 1>>$LOG
chattr -i /home/sgimovel/.kde4/share/config/power*
cp -rv power* /home/sgimovel/.kde4/share/config/ 2>> $LOG 1>> $LOG
chattr +i /home/sgimovel/.kde4/share/config/power*
chattr -i /home/sgimovel/.kde4/share/config/plasma-desktop-appletsrc
cp -rv plasma-desktop-appletsrc /home/sgimovel/.kde4/share/config/ 2>> $LOG 1>> $LOG
chattr +i /home/sgimovel/.kde4/share/config/plasma-desktop-appletsrc
cp -rv plasma-desktoprc /home/sgimovel/.kde4/share/config/ 2>> $LOG 1>> $LOG
cp -rv mimeTypes.rdf /home/sgimovel/.mozilla/firefox/*.default/ 2>> $LOG 1>> $LOG
tar xvfz sgimovel-adobe.tar.gz -C /home/sgimovel 2>> $LOG 1>> $LOG
cp -rv user-dirs.dirs /home/sgimovel/.config/ 2>> $LOG 1>> $LOG
cp -rv oper-bashrc /home/oper/.bashrc 2>> $LOG 1>> $LOG
cp -rv oper-xinitrc /home/oper/.xinitrc 2>> $LOG 1>> $LOG
touch /home/oper/analyze_lapmpe.log
cp -rv chk-network.sh /etc/NetworkManager/dispatcher.d 2>> $LOG 1>> $LOG
cp -rv oracle-dev /etc/init.d 2>> $LOG 1>> $LOG
cp -rv cupsd.conf /etc/cups 2>> $LOG 1>> $LOG
cp -rv sudoers /etc 2>> $LOG 1>> $LOG
tar xvfz firefox.tar.gz 2>> $LOG 1>> $LOG
cp -rvf firefox/* /usr/lib64/firefox/ 2>> $LOG 1>> $LOG
rm -r firefox
rpm -ivh x11vnc-0.9.13-2.1.4.x86_64.rpm --force 2>> $LOG 1>> $LOG
rpm -ivh flash-plugin-11.2.202.521-release.x86_64.rpm --force 2>> $LOG 1>> $LOG
tar xvfz acroread.tar.gz 2>> $LOG 1>> $LOG
rpm -ivh acroread/*.rpm --force 2>> $LOG 1>> $LOG
rm -r acroread
tar xvfz oracle-bin.tar.gz 2>> $LOG 1>> $LOG
cp -rv bin/* /u01/app/oracle/bin/ 2>> $LOG 1>> $LOG
rm -r bin
[ -f /u01/app/oracle/bin/restore.sh ] && rm -rf /u01/app/oracle/bin/restore.sh
tar xvfz root-bin.tar.gz 2>> $LOG 1>> $LOG
cp -rv bin/* /root/bin/ 2>> $LOG 1>> $LOG
rm -r bin
tar xvfz sgimovel-bin.tar.gz 2>> $LOG 1>> $LOG
cp -rv bin/* /home/sgimovel/bin/ 2>> $LOG 1>> $LOG
rm -r bin
[ ! -d /home/webservice ] && mkdir /home/webservice
[ ! -d /home/BACKUP ] && mkdir /home/BACKUP
[ ! -d /home/RMAN/rman ] && mkdir -p /home/RMAN/rman
[ ! -d /home/RMAN/log ] && mkdir -p /home/RMAN/log
chown -R oracle.dba /home/RMAN
date '+%s' > /home/RMAN/log/copia_pendrive.log
touch /home/RMAN/log/backup_rman.log
[ -f /home/sgimovel/Área\ de\ trabalho/Backup.desktop ] && rm /home/sgimovel/Área\ de\ trabalho/Backup.desktop
[ -f /home/sgimovel/Área\ de\ trabalho/Office.desktop ] && rm /home/sgimovel/Área\ de\ trabalho/Office.desktop
[ -f /home/sgimovel/Área\ de\ trabalho/MozillaFirefox.desktop ] && rm /home/sgimovel/Área\ de\ trabalho/MozillaFirefox.desktop
cp -rv Suporte\ VNC.desktop /home/sgimovel/Área\ de\ trabalho 2>> $LOG 1>> $LOG
chown root.root /home/sgimovel/Área\ de\ trabalho
touch /usr/local/bin/balanca.cfg
chmod a+rw /usr/local/bin/balanca.cfg
touch /usr/local/bin/balanca_config.py
chmod a+rw /usr/local/bin/balanca_config.py
cp -rv uifont.ali /oracle/OraHome_1/guicommon/tk/admin/ 2>> $LOG 1>> $LOG
tar xvfz fonts-ttf.tar.gz -C /home/sgimovel/.fonts/ 2>> $LOG 1>> $LOG
touch /root/login_oper
su - oper -c "/home/patch1/webservice_patch.sh" 2>> $LOG 1>> $LOG
touch /root/login_oper
su - oper -c "/home/patch1/atualiza_versao_banco.sh" 2>> $LOG 1>> $LOG
exec 3>&-

if [ $? -eq 1 ]; then
	echo "Ocorreram erros durante a atualização contate o suporte!" 2>> $LOG 1>> $LOG
	mensagem="\tOcorreram erros durante a atualização contate o suporte!\t"
	fncmsg "gtk-dialog-warning" "${mensagem}" 450
	exit 1
else
	echo "Atualização realizada com sucesso!" 2>> $LOG 1>> $LOG
	mensagem="\tAtualização realizada com sucesso!\t"
	fncmsg "gtk-dialog-warning" "${mensagem}" 450
	exit 0
fi
