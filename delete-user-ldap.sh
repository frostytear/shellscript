#!/bin/bash

echo 'insira o nome do usuario que deseja deletar'
printf '> ' && read usuario

ldapdelete -x -W -D 'cn=admin,dc=inmetro,dc=rs,dc=gov,dc=br' "uid=${usuario},ou=people,dc=inmetro,dc=rs,dc=gov,dc=br" 
ldapdelete -x -W -D 'cn=admin,dc=inmetro,dc=rs,dc=gov,dc=br' "uid=${usuario},ou=groups,dc=inmetro,dc=rs,dc=gov,dc=br"

exit $?