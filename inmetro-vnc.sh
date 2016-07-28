#!/bin/bash
#
# Criação: Bruno Tougeiro - Analista Linux - INMETRO-RS
# Contato: 0xx51 3375-1221 e-mail: btougeiro@inmetro.rs.gov.br
#
# Suporte VNC INMETRO-RS
# atualização: 06/04/2016
#

SCHNELL=200.132.18.189
ONIR=200.132.19.197
TOUGEIRO=200.132.19.175
MARTINI=200.132.18.42

function analyst {
  yad --window-icon=logo \
  --image=gtk-network \
  --width=300 \
  --title="Suporte Remoto INMETRO-RS" \
  --text-align=center \
  --text="<b> Deseja iniciar a conexão? </b>" \
  --center \
  --button="_Sim:0" \
  --button="_Não:1"
  x=$?

  if [ ${x} -eq 0 ]; then
    x11vnc -timeout 3 -noipv6 -coe $WHO 2> /tmp/vnc.log
    sleep 5

    if grep "OK" /tmp/vnc.log; then
      yad --title="Suporte Remoto INMETRO-RS" \
      --text=" Conexão estabelecida com sucesso! " \
      --button='_Encerrar:20' \
      --width=320 \
      --window-icon=logo
    fi

    y=$?
    if [ ${y} -eq 20 ]; then
      killall x11vnc
      yad --title="Suporte Remoto INMETRO-RS" \
      --text=" Conexão encerrada! " \
      --button='_Sair:0' \
      --width=320 \
      --window-icon=logo
    fi

    if grep "reverse_connect_timeout" /tmp/vnc.log; then
      yad --title="Suporte Remoto INMETRO-RS" \
      --text=" Erro ao estabelecer conexão! \n Solicite ao analista que libere sua conexão! " \
      --button='_Sair:1' \
      --width=320 \
      --window-icon=logo
    fi

    if grep "exiting under -connect_or_exit" /tmp/vnc.log; then
      yad --title="Suporte Remoto INMETRO-RS" \
      --text=" Não foi possível estabelecer conexão \n Seu notebook parece estar offline!\n Verifique sua conexão e tente novamente " \
      --button='_Sair:0' \
      --width=320 \
      --window-icon=logo >/dev/null
    fi
  else
        exit 1
    fi
}

# inicio da aplicação

pidof x11vnc && killall x11vnc

yad --window-icon=logo \
--image=gtk-network \
--title="Suporte Remoto INMETRO-RS" \
--text=" Antes de chamar um analista, verifique se o notebook está online! \n Entre em contato com o analista e verifique se ele pode lhe atender! \n Caso contrário, peça ajuda ao setor de TI do seu Estado! " \
--button="_Sair:1" \
--button="_Continuar:0" >/dev/null

[ $? -eq 1 ] && exit 1

while true; do
  OPTION=$(yad --window-icon=logo \
  --image=gtk-network \
  --list \
  --title="Suporte Remoto INMETRO-RS" \
  --text-align=center \
  --text="<b> Selecione o analista para suporte: </b>" \
  --width=285 \
  --height=187 \
  --center \
  --borders=5 \
  --no-headers \
  --button="_Sair:10" \
  --print-column=1 \
  --hide-column=1 \
  --separator='' \
  --column='op1':NUM --column='op2':TEXT \
  1 'Alex Sandro Schnell' \
  2 'Anderson Onir' \
  3 'Bruno Tougeiro' \
  4 'Tatiana Martini' 2>/dev/null)

  RETURN=$?
  [ $RETURN -eq 10 ] && exit 0

  case $OPTION in
      1) WHO=$SCHNELL && analyst ;;
      2) WHO=$ONIR && analyst ;;
      3) WHO=$TOUGEIRO && analyst ;;
      4) WHO=$MARTINI && analyst ;;
  esac
done
