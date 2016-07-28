#!/bin/bash

TITLE="Restore do banco de dados - ORACLE"
LOGO="logo"
LOG=~/restore.log

yad --title="${TITLE}" --text="Confirma restore do backup ?" --width=300 --window-icon="${LOGO}" >/dev/null 2>&1

[ $? -eq 1 ] && exit 1

while [ $(sudo /sbin/fdisk -l | grep -c "sdb1") -eq 0 ] ; do
  yad --image=drive-removable-media-usb-pendrive \
      --title="${TITLE}" \
      --text="Favor conectar o pendrive no Laptop" \
      --width=300 \
      --window-icon="${LOGO}" >/dev/null 2>&1

  [ $? -eq 1 ] && exit 1

done

device=$(sudo /sbin/fdisk -l | awk '/sdb1/ {print $1}')

if [ -z "${device}" ] ; then
   yad --title="${TITLE}" --text='Erro ao detectar a partição do pendrive' --button="_Sair" --width=300 --window-icon="${LOGO}" >/dev/null 2>&1
   exit 1
fi

if [ -d ~/backup ]; then
sudo mount -o rw,uid=$(id -u),gid=$(id -g),fmask=0022,dmask=0022,iocharset=iso8859-1,shortname=mixed,errors=remount-ro "${device}" ~/backup 2>/dev/null
else
mkdir ~/backup
sudo mount -o rw,uid=$(id -u),gid=$(id -g),fmask=0022,dmask=0022,iocharset=iso8859-1,shortname=mixed,errors=remount-ro "${device}" ~/backup 2>/dev/null
fi

if [ ${?} -ne 0 ] ; then
   yad --title="${TITLE}" --text='Erro no mapeamento do pendrive' --button="_Sair" --width=300 --window-icon="${LOGO}" >/dev/null 2>&1
   exit 1
fi

dump=`yad --title="${TITLE}" --file-selection --filename='/u01/app/oracle/backup/' --height=500 --width=800 --file-filter="*.tgz" --window-icon="${LOGO}"`

if [ $? -eq 1 ]; then
yad --title="${TITLE}" --text='Você cancelou o procedimento de restore!' --button="_Sair:1" --window-icon=logo --width=350
exit 1
fi

ctime=`find ${dump} | awk -F"/" '{ print $6 }'`
fsize=`ls -lrths  ${dump} | awk -F" " '{ print $1 }'`

yad --title="${TITLE}" --text="<u><b>Atenção</b></u>. Os dados atuais do SGIMovel serão sobrepostos.\nO restore será do backup de: \n<u><b>'$ctime $fsize'</b></u>.\nConfirmar restore ?" --width=350 --window-icon="${LOGO}" >/dev/null 2>&1

if [ $? -eq 1 ]; then
yad --title="${TITLE}" --text='Você cancelou o procedimento de restore!' --button="_Sair:1" --window-icon=logo --width=350
exit 1
fi

sqlplus / as sysdba <<EOF | yad --title="${TITLE}" --progress --pulsate --undecorated --no-buttons --auto-close --progress-text="Aguarde. Parando os processos do banco de dados Oracle-XE" --width=500 --window-icon="${LOGO}" >/dev/null 2>&1
shutdown immediate;
exit;
EOF

echo "$(date) - Procedimento de shutdown executado" >> ${LOG}

if fuser ${ORACLE_HOME}/dbs >/dev/null 2>&1 ; then 
yad --image="gtk-dialog-warning" --title="${TITLE}" --text="Existem processos ativos do Oracle. \nProcedimento cancelado" --button="_Sair" --width=305 --window-icon=logo 2>/dev/null
echo "$(date) - Existem processos ativos do Oracle" >> ${LOG}
exit 1
fi

DATA=`date "+%Y-%m-%d_%H%M"`

mkdir -p ~/restore/BACKUP-PRE-RESTORE-${DATA}

find /u01/app/oracle/product/11.2.0/xe/dbs/* /u01/app/oracle/archives/* -print -exec cp -a {} ~/restore/BACKUP-PRE-RESTORE-${DATA} | yad --title="${TITLE}" --progress --pulsate --undecorated --no-buttons --auto-close --progress-text="Aguarde. Salvando dados atuais do Oracle-XE" --width=500 --window-icon="${LOGO}" >/dev/null 2>&1

cd ${ORACLE_HOME}

rm -f /u01/app/oracle/archives/*.arc

echo "$(date) - Dados atuais salvos em /home/backup-dbf/BACKUP-PRE-RESTORE-${DATA}" >> ${LOG}

tar xvfzp ${dump} | yad --title="${TITLE}" --progress --pulsate --undecorated --no-buttons --auto-close --progress-text="Aguarde. Descompactando o backup do banco de dados Oracle-XE" --width=500 --window-icon="${LOGO}" >/dev/null 2>&1

echo "$(date) - Restore do arquivo '${dump}' de '${ctime}'" >> ${LOG}

sqlplus -s / as sysdba <<EOF | yad --title="${TITLE}" --progress --pulsate --undecorated --no-buttons --auto-close --progress-text="Aguarde. Iniciando os processos do banco de dados Oracle-XE" --width=500 --window-icon="${LOGO}" >/dev/null 2>&1
startup;
exit;
EOF

echo "$(date) - Procedimento de startup executado" >> ${LOG}

sudo /usr/bin/umount ~/backup 2>/dev/null

yad --image="dialog-information" --title="${TITLE}" --text="Procedimento de restore concluído. \nSeu pendrive foi removido com segurança!" --button="_Sair" --width=420 --window-icon="${LOGO}" 2>/dev/null
