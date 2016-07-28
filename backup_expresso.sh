#!/bin/sh
#
# Script backup do Expresso Mail
#
# Arquivo: backup_expresso.sh
#
# Backup de:
# * Banco de Dados
# * Base do LDAP
# * Cyrus
# * Emails
#
# Última modificacao: 31/08/2015
#
# Alterações: Bruno Tougeiro
# Contato: btougeiro@inmetro.rs.gov.br
#
# IMPORTANTE: REALIZE UM BACKUP ANTES DE RODAR O SCRIPT DE RESTORE!

DIR_BACKUP="/backup/"
USUARIO_BANCO="postgres"
ARQ_LOG="/backup/backup.log"
DATA_ATUAL=`date +%d%m%Y`

[ "$(id -u)" != "0" ] && echo "Você precisa ser 'root' para executar esse script!" && exit 1

echo
echo "########################################################"
echo "########## Sistema de backup do Expresso Mail ##########"
echo "########################################################"
echo
echo "Bem-vindo ao sistema de backup do Expresso Mail" 
echo

while true; do
	echo 'Deseja continuar [yes|no]:'
	printf '> ' && read RESPOSTA
	
	if [ "${RESPOSTA}" == "yes" ]; then
		if [ ! -d ${DIR_BACKUP} ]; then
			echo 'Criando pasta de backup em ${DIR_BACKUP}'
			mkdir -p ${DIR_BACKUP}
			chown -R cyrus.mail ${DIR_BACKUP}
		fi
		
		cd ${DIR_BACKUP}
		
		echo "### Histórico da cópia de segurança do EXPRESSO LIVRE – DATA e HORA INICIAL: ${DATA_ATUAL} ###" | tee ${ARQ_LOG}
		
		echo
		echo "Backup do banco de dados..." | tee -a ${ARQ_LOG}
		pg_dump -o -U ${USUARIO_BANCO} expressov3 > bkp_db.dump
		
		echo
		echo "Backup da base de dados LDAP..." | tee -a ${ARQ_LOG}
		slapcat > bkp_ldap.ldif 2> /dev/null
		
		echo
		echo "Parando o cyrus..." | tee -a ${ARQ_LOG}
		/etc/init.d/cyrus-imapd stop

		echo
		echo "Realizando backup do cyrus..." | tee -a ${ARQ_LOG}
		if [ -d /var/spool/cyrus ]; then
			echo "Backup da estrutura de dados do cyrus..." | tee -a ${ARQ_LOG}
			su - cyrus -c "/usr/sbin/ctl_mboxlist -d > bkp_file_cyrus.dump"
			cp -r /var/spool/cyrus/bkp_file_cyrus.dump ${DIR_BACKUP}
			rm -rf /var/spool/cyrus/bkp_file_cyrus.dump
			echo "Compactando mensagens..." | tee -a ${ARQ_LOG}
			tar -cvfz bkp_mail.tgz /var/spool/cyrus >> ${ARQ_LOG} 2> /dev/null
		fi		
		
		if [ -d /var/lib/cyrus ]; then
			echo "Compactando bibliotecas do sistema cyrus..." | tee -a ${ARQ_LOG}
			tar -zcvf bkp_cyrus_lib.tgz /var/lib/cyrus >> ${ARQ_LOG} 2> /dev/null
		fi
		
		echo
		echo "Iniciando cyrus..." | tee -a ${ARQ_LOG}
		/etc/init.d/cyrus-imapd start
		
		echo
		echo "### Backup concluido ${DATA_ATUAL} ###" | tee -a ${ARQ_LOG}
		break
	else
		if [ "${RESPOSTA}" != "yes" ] && [ "${RESPOSTA}" != "no" ]; then
			echo "Resposta inválida, tente novamente!"
		else
			echo "Obrigado! Talvez faremos o backup em uma outra hora!" && exit 1
			break
		fi
	fi
done