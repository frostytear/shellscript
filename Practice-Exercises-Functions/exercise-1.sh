#!/bin/bash

function file_count(){
        local QUANTIDADE=$(ls | wc -l)
        if [ "$QUANTIDADE" -eq "1" ]
        then
                echo "Seu presente diretório possui 1 arquivo."
        elif [ "$QUANTIDADE" -gt "1" ]
        then
                echo "Seu presente diretório possui $QUANTIDADE arquivos."
        else
                echo "Seu presente diretório não possui arquivos."
        fi
}

file_count
