#!/bin/bash

function file_count(){

	DIRETORIO=$(ls $1 | wc -l)

	if [ -d $1 ]
	then
		echo "Você está listando o conteúdo do diretório: $1"
		echo "O diretório: ${1}, possui, $DIRETORIO itens."
		exit 0
	elif [ -f $1 ]
	then
		echo "Por favor, chame a script: ${0}, utilizando um diretório como parâmetro."
		exit 0 
	else
		echo "Para executar este script você precisar inserir um diretório como parâmetro."
	fi
}

file_count $1
