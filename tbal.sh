#!/bin/bash

n=0

while true; do
  python /usr/local/bin/balanca.py -v
  let n++
  [ ${n} -eq 10000 ] && killall yad && break
  [ $((${n}%10)) -eq 0 ] && echo -n "${n} - " && date
done | tee /home/sgimovel/tbal.log | yad --text-info \
					 --title='Teste de pesagem' \
					 --width=500 \
					 --height=500 \
					 --tail \
					 --wrap \
					 --no-buttons \
					 --window-icon=logo \
					 --undecorated \
					 --fontname="Monospace bold 12" \
					 --back="#bfe9ec" \
					 --fore="#1B3A7C" \
					 --margins=5 2> /dev/null
