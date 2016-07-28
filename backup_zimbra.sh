#!/bin/bash

DATE=`date +%d-%m-%Y`
LOCAL=/opt/zimbra/backup
DESTINO=/BACKUP/caixas_zimbra

[ ! -d $LOCAL/$DATE ] && mkdir $LOCAL/$DATE

[ ! -d $DESTINO/$DATE ] && mkdir $DESTINO/$DATE

LOG=$LOCAL/$DATE/backup.log

INICIO=`date +%s`
echo "Início do Backup - `date`" > $LOG
for mbox in `zmprov -l gaa`
        do
        echo >> $LOG
        echo "Gerando arquivo de backup da caixa $mbox" >> $LOG
        zmmailbox -z -m $mbox getRestURL "//?fmt=tgz" > $LOCAL/$DATE/$mbox.tgz
        gerar_caixa=$?
        if [ $gerar_caixa -eq 0 ]; then
                echo "Arquivo $mbox.tgz gerado com sucesso" >> $LOG
                echo "Copiando arquivo $mbox.tgz para pasta de backup" >> $LOG
                cp $LOCAL/$DATE/$mbox.tgz $DESTINO/$DATE/$mbox.tgz >> $LOG
                copiar_caixa=$?
                if [ $copiar_caixa -ne 0 ]; then
                        echo "Falha ao copiar arquivo $mbox.tgz" >> $LOG
                        echo "Backup interrompido!" >> $LOG
                        exit 1 && break
                else
                        echo "Backup da caixa $mbox realizado com sucesso" >> $LOG
                        rm -f $LOCAL/$DATE/$mbox.tgz
                fi
        else
                echo "Falha ao gerar arquivo $mbox.tgz" >> $LOG
                echo "Backup interrompido!" >> $LOG
                exit 1 && break
        fi
        echo >> $LOG
done
echo "Término do Backup - `date`" >> $LOG
FIM=`date +%s`

TEMPO=`expr $FIM - $INICIO`
echo "Duração: $TEMPO segundos" >> $LOG
