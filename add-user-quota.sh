#!/usr/bin/env	bash

echo "Digite o usuário para estabelecer a nova quota:"
printf "> "
read usuario

wbinfo -u | grep -q ${usuario}

if [ $? -ne 0 ]; then
  echo "Usuário não encontrado"
  exit 1
else
  echo "Digite a quota para o usuário: ${usuario}"
  echo "Exemplo: 10m p/ 10 mbs | 10g para 10 gbs"
  printf "> "
  read quota
  echo "criando quota para o usuário: ${usuario}"
  xfs_quota -x -c "limit bsoft=${quota} bhard=${quota} ${usuario}" /home/users
  if [ $? -ne 0 ]; then
    echo
    echo "Erro ao criar quota para usuário"
    exit 1
  else
    echo
    echo "Quota criada com sucesso"
    echo "Exibindo tabela de quotas atual"
    echo
    xfs_quota -x -c "report -h -u" /home/users
    echo "Obrigado!"
  fi
fi

exit 0
