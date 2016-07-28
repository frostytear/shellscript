#!/bin/sh
#
# Script restore do Expresso Mail
#
# Arquivo: restore_expresso.sh
#
# Restore de:
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
# IMPORTANTE: ANTES DE REALIZAR UM RESTORE, FAÇA UM BACKUP!

DIR_BACKUP="/backup/"
USUARIO_BANCO="postgres"
ARQ_LOG="/backup/restore.log"
DATA_ATUAL=`date +%d%m%Y`

[ "$(id -u)" != "0" ] && echo "Você precisa ser 'root' para executar esse script!" && exit 1

echo
echo "########################################################"
echo "######### Sistema de restore do Expresso Mail ##########"
echo "########################################################"
echo
echo "Bem-vindo ao sistema de restore do Expresso Mail!"
echo "Antes de começar realize um backup do seu sistema!"
echo "Use o script backup_expresso.sh para realizar um backup!"
echo "Caso contrário, não continue! Isso irá danificar sua base de dados!"
echo

while true; do
	echo 'Deseja continuar [yes|no]:'
	printf '> ' && read RESPOSTA

	if [ "${RESPOSTA}" == "yes" ]; then
		if [ ! -d ${DIR_BACKUP} ]; then
			echo "Diretório '/backup/' não existe, por segurança faça um backup antes de realizar um restore. Obrigado!" && exit 1
			break
		fi
		
		if [ -f ${DIR_BACKUP}bkp_db.dump ] && [ -f ${DIR_BACKUP}bkp_ldap.ldif ] && [ -f ${DIR_BACKUP}bkp_file_cyrus.dump ] && [ -f ${DIR_BACKUP}bkp_cyrus_lib.tgz ]; then
			
			echo "Restaurando a base do Expresso..." | tee ${ARQ_LOG}
			psql -U ${USUARIO_BANCO} -c "DROP DATABASE expressov3;"
			psql -U ${USUARIO_BANCO} -c "CREATE DATABASE expressov3 with ENCODING='utf-8';"
			psql -U postgres expressov3 <${DIR_BACKUP}bkp_db.dump
			
			echo "Parando o serviço LDAP.." | tee -a ${ARQ_LOG}
			/etc/init.d/slapd stop
			echo "Restaurando o LDAP..." | tee -a ${ARQ_LOG}
			rm -rf /var/lib/ldap/*
			slapadd -l ${DIR_BACKUP}bkp_ldap.ldif 2> /dev/null
			chown -R openldap /var/lib/ldap/
			echo "Iniciando o serviço LDAP.." | tee -a ${ARQ_LOG}
			/etc/init.d/slapd start
			
			echo "Parando o serviço cyrus..." | tee -a ${ARQ_LOG}
			/etc/init.d/cyrus-imapd stop
			echo "Restaurando a estrutura das contas de email..." | tee -a ${ARQ_LOG}
			su - cyrus -c "/usr/sbin/ctl_mboxlist -u < ${DIR_BACKUP}bkp_file_cyrus.dump"
			cd /
			echo "Descompactando arquivos de email.." | tee -a ${ARQ_LOG}
			tar -zxvf ${DIR_BACKUP}bkp_mail.tgz
			
			echo "Descompactando arquivos da biblioteca de mensagens..." | tee -a ${ARQ_LOG}
			cd /
			tar -zxvf ${DIR_BACKUP}bkp_cyrus_lib.tgz
			chown -R cyrus.mail /var/lib/cyrus
			
			echo "Reconstruindo a lista de mensagens dos usuarios..." | tee -a ${ARQ_LOG}
			echo "Acompanhe o log no arquivo /var/lib/cyrus/log/reconstruct.log" | tee -a ${ARQ_LOG}
			su - cyrus -c "/usr/sbin/cyrreconstruct -rf user/* > /var/lib/cyrus/log/reconstruct.log"
			echo "Iniciando o cyrus" | tee -a ${ARQ_LOG}
			/etc/init.d/cyrus-imapd start
			echo "Expresso Livre restaurado com sucesso. Obrigado!" | tee -a ${ARQ_LOG} && exit 0
			break
		else
			echo 'ERROR:	Faltando arquivo para restore!'
			echo '	Verifique se na pasta /backup/ contém os seguintes arquivos:'
			echo '	bkp_db.dump, bkp_ldap.ldif, bkp_file_cyrus.dump e bkp_cyrus_lib.tgz'
			echo '	Por medidas de segurança, caso falte algum dos arquivos listados acima, o restore não irá prosseguir!'
			echo '	Obrigado!' && exit 1
			break
		fi
	else
		if [ "${RESPOSTA}" != "yes" ] && [ "${RESPOSTA}" != "no" ]; then
			echo "Resposta inválida, tente novamente!"
		else
			echo "Obrigado! Talvez faremos o restore em uma outra hora!" && exit 1
			break
		fi
	fi
done