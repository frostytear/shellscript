#!/bin/bash

[ "$(id -u)" != "0" ] && echo "Você precisa ser 'root' para executar esse script!" && exit 0

echo
echo "Utilitário de restore do banco de dados do LDAP"
echo
echo "Uso: ldaprestore [cn=usuario,dc=inmetro,dc=rs,dc=gov,dc=br] [nome do arquivo]"
echo "Exemplo de uso: bash ldaprestore.sh cn=Administrator,dc=inmetro,dc=rs,dc=gov,dc=br backupLDAP-2010-5-12.ldif"
echo

usrlogin="$1"
banco="$2"
if [ -z $banco ]; then
	echo "Erro: Arquivo não encontrado."
elif [ -z $usrlogin ]
	echo "Erro: É necessário que digite o nome de administrador do banco de dados LDAP e o nome do banco de dados"
	echo "Ex.: cn=Administrator,dc=inmetro,dc=rs,dc=gov,dc=br"
else
	ldapadd -x -D $usrlogin -W -f $banco
	if [ $? -ne 255 ]; then
		echo "O banco de dados LDAP foi restaurado com sucesso!"
	fi
fi
