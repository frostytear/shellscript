#!/bin/bash

hoje=$(date +%d-%b-%Y)
log="/agendamentos/log/${hoje}.log"

# montando servidor de bakcup rsync
mount -t nfs 200.132.19.242:/BACKUP /BACKUP
if [ $? -ne 0 ]; then
  echo "erro ao mapear unidade de backup" >> $LOG
  mail -s "Erro mapeamento de Backup - ${hoje} - Fita DAT" "btougeiro@inmetro.rs.gov.br" < $log
  exit 1
fi

# verificando o status da fita
mt -f /dev/st0 status
if [ $? -ne 0]; then
  echo "erro na verificação do status da fita dat" >> $log
  echo "fita parece estar inoperante, verifique e tente novamente" >> $log
  mail -s "Falha Backup - ${hoje} - Fita DAT" "btougeiro@inmetro.rs.gov.br" < $log
  exit 1
fi

# iniciando o backup para a fita dat
echo "++++++++++++++++++++++++++"  >> $log
echo "     Início do Backup     "  >> $log
echo
date >> $log
echo
echo "rebobinando a fita" >> $log
mt -f /dev/st0 rewind
if [ $? -ne 0 ]; then
  echo "erro ao rebobinar a fita de backup" >> $log
else
  echo "fita rebobinada com sucesso" >> $log
fi
echo
echo "iniciando procedimento de cópia" >> $log
tar -cvpf /dev/st0 /BACKUP/caixas_zimbra >> $log
if [ $? -ne 0 ]; then
  echo "erro ao copiar arquivo" >> $log
else
  echo "toda a estutura foi copiada com sucesso" >> $log
fi
echo "ejetando a fita"
mt -f /dev/st0 offline
if [ $? -ne 0 ]; then
  echo "erro ao ejetar a fita de backup" >> $log
else
  echo "fita ejetada com sucesso" >> $log
fi
date >> $log
echo
echo "+++++++++++++++++++++++++"  >> $log
echo "     Final do Backup     "  >> $log
# término do backup para a fita dat

umount /BACKUP
if [ $? -ne 0 ]; then
  echo "erro ao desmontar unidade de backup" >> $LOG
  mail -s "Erro mapeamento de Backup - ${hoje} - Fita DAT" "btougeiro@inmetro.rs.gov.br" < $log
fi

# envia email
mail -s "Backup - ${hoje} - Fita DAT" "btougeiro@inmetro.rs.gov.br" < $log