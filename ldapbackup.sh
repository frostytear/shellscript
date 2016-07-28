#!/bin/bash

[ "$(id -u)" != "0" ] && echo "Você precisa ser 'root' para executar esse script!" && exit 0

echo
echo "Utilitário de backup do banco de dados do LDAP"
echo

echo "Digite a localização do banco de dados (Ex.: dc=inmetro,dc=rs,dc=gov,dc=br):"
printf '> ' && read banco

if [ -z $banco ]; then
	echo "Erro: Digite corretamente a localização do banco de dados."
	echo "Banco de dados não encontrado!"
else
	data=`date --rfc-3339 date`
	ldapsearch -x -b $banco "(ObjectClass=*)" > ~/backupLDAP-$data.ldif
	if [ $? -ne 255 ]; then
		echo "Backup realizado com sucesso. Ele está salvo na pasta /root"
	fi
fi
