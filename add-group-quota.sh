#!/usr/bin/env	bash

echo "Digite o grupo para estabelecer a nova quota:"
printf "> "
read grupo

wbinfo -u | grep -q ${grupo}

if [ $? -ne 0 ]; then
  echo "Grupo não encontrado"
  echo "Verifique o grupo digitado e tente novamente"
  exit 1
else
  echo "Digite a quota para o grupo: ${grupo}"
  echo "Exemplo: 10m p/ 10 mbs | 10g para 10 gbs"
  printf "> "
  read quota
  echo "criando quota para o grupo: ${grupo}"
  xfs_quota -x -c "limit -g bsoft=${quota} bhard=${quota} ${grupo}" /home/shares
  if [ $? -ne 0 ]; then
    echo
    echo "Erro ao criar quota para grupo"
    exit 1
  else
    echo
    echo "Quota criada com sucesso"
    echo "Exibindo tabela de quotas atual"
    echo
    xfs_quota -x -c "report -h -g" /home/shares
    echo "Obrigado!"
  fi
fi

exit 0
