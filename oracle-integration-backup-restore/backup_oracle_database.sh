#!/bin/bash

UNAME=$(uname -n)
DATA=$(date +%F_%H%M)
BACKUP="backup_db-${UNAME}-${DATA}.tar.gz"
ORACLE_HOME="/u01/app/oracle/product/11.2.0/xe/"

function shutdown_db(){
sqlplus / as sysdba <<EOF
shutdown immediate;
exit;
EOF
}

function startup_db(){
sqlplus / as sysdba <<EOF
startup;
exit;
EOF
}

function faz_backup(){
  echo "Gerando arquivo de backup, aguarde..."
  tar cfz /tmp/${BACKUP} dbs
  if [ $? -eq 0 ]; then
    echo "Arquivo de backup gerado com sucesso" 
  else
    echo "Erro ao gerar arquivo de backup, consulte o administrador do sistema" 
    exit 1
  fi
}

function identifica_pendrive(){
  for dev in $(find /dev/sd*); do device=$dev; done
  if [ "$device" = "/dev/sda3" ]; then
    echo "Erro ao mepar particao do pendrive"
    exit
  fi
}

function monta_pendrive(){
  sudo /usr/bin/umount $device
  if [ -d ~/backup ]; then
    sudo mount -o rw,uid=$(id -u),gid=$(id -g),fmask=0022,dmask=0022,iocharset=iso8859-1,shortname=mixed,errors=remount-ro "${device}" ~/backup 2>/dev/null
    if [ $? -eq 1 ]; then
      echo "Erro ao montar pendrive" 
      exit 1
    fi
  else
    mkdir ~/backup
    if [ $? -eq 1 ]; then
      echo "Erro ao criar diretorio ~/backup" 
      exit 1
    fi
    sudo mount -o rw,uid=$(id -u),gid=$(id -g),fmask=0022,dmask=0022,iocharset=iso8859-1,shortname=mixed,errors=remount-ro "${device}" ~/backup 2>/dev/null
    if [ $? -eq 1 ]; then
      echo "Erro ao montar pendrive" 
      exit 1
    fi
  fi
}

function desmonta_pendrive(){
  echo "Removendo pendrive"
  sudo /usr/bin/umount ~/backup 2>/dev/null
  if [ $? -eq 1 ]; then
    echo "Erro ao remover pendrive" 
  else
    echo "Pendrive removido com sucesso" 
  fi
}

function copia_backup_pendrive(){
  espaco_livre=$(df ${device} | awk 'NR==2 {print $4}')
  tamanho_arquivo=$(du /tmp/${BACKUP} | awk '{print $1}')
  porcentagem=$(df ${device} | awk 'NR==2 {print $5}')

  if [ ${tamanho_arquivo} -gt ${espaco_livre} ]; then
    echo "Espaco insuficiente no pendrive <b>${porcentagem}</b>" 
    echo "Area disponivel no pendrive: `df -h /dev/sdb1 | awk 'NR==2 {print $4}'`"
    echo "Tamanho do arquivo: `du -sh ${device} | awk 'NR==2 {print $5}'`" 
    exit 1
  else
    echo "Area disponivel do pendrive: `df -h /dev/sdb1 | awk 'NR==2 {print $4}'`"
    echo "Tamanho do arquivo: `du -sh ${device} | awk 'NR==2 {print $5}'`"
    echo "Copiando backup para o pendrive" 
    cp -rv /tmp/${BACKUP} ~/backup/ 
    if [ $? -eq 1 ]; then
      echo "Erro ao copiar arquivo para o pendrive" 
      exit 1
    else
      echo "Arquivo copiado com sucesso" 
    fi
  fi
}

function move_backup_disco_local(){
  echo "Movendo backup para disco local" 
  if [ -d ~/old_backup ]; then
    mv -v /tmp/${BACKUP} ~/old_backup/
    if [ $? -eq 1 ]; then
      echo "Erro ao mover arquivo para o disco local" 
      exit 1
    else
      echo "Arquivo movido com sucesso" 
    fi
  else
    mkdir ~/old_backup
    if [ $? -eq 1 ]; then
      echo "Erro ao criar diretorio ~/old_backup" 
      exit 1
    fi
    mv /tmp/${BACKUP} ~/old_backup/
    if [ $? -eq 1 ]; then
      echo "Erro ao mover arquivo para o disco local" 
      exit 1
    else
      echo "Arquivo movido com sucesso" 
    fi
  fi
}

if [ $(id -u) -ne 1000 ]; then
  echo "Voce precisar ser o usuario - ORACLE - para continuar" 
  exit 1
fi

echo "INICIO: $(date)"

cd ${ORACLE_HOME}

shutdown_db

if [ $? -eq 1 ]; then
  echo "Erro ao desligar o banco de dados - ORACLE" 
  exit 1
else
  echo "Shutdown concluido"
fi

faz_backup

startup_db

if [ $? -eq 1 ]; then
  echo "Erro ao ligar o banco de dados - ORACLE" 
  exit 1
else
  echo "Startup concluido"
fi

identifica_pendrive

monta_pendrive

copia_backup_pendrive

desmonta_pendrive

move_backup_disco_local

echo "FIM: $(date)"