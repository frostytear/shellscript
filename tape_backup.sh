#!/bin/bash

TODAY=`date +%d-%m-%Y`
LOG=/root/backup/log/$TODAY-arquivo.log

# iniciando o backup para a fita dat
echo "++++++++++++++++++++++++++"  >> $LOG
echo "    Iniciando o Backup    "  >> $LOG

date >> $LOG
tar -cvf /dev/st0 /RSYNC >> $LOG
date >> $LOG

echo "+++++++++++++++++++++++++"  >> $LOG
echo "     Final do Backup     "  >> $LOG
# término do backup para a fita dat

# envia email
mail -s "Backup Fita DAT"  "btougeiro@inmetro.rs.gov.br" < $LOG