#!/bin/bash

if [ $# eq 0 ] 
then

echo 'В кавычках надо передать комментарий к коммиту'
exit

else 

git status
git add .
git commit -m "${1}"
git push 

fi
