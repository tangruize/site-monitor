#!/bin/bash

cd `dirname $0`

if [ "$#" -gt 0 ]; then
    ARG="$@"
else
    ARG=$(ls -I `basename "$0"` -I README.md)
fi

TOTAL=`echo $ARG | tr ' ' '\n' | wc -l`
COUNT=0

for i in $ARG; do
    MSG="update"
    if [[ "$i" = http* ]]; then
        i=`echo $i | sed -e 's,^http[s]\?://,,' -e 's,/$,,' -e 's,/,@,g'`
        if mkdir "$i" 2>/dev/null; then
            MSG="create"
        fi
    fi
    if [ -d "$i" ]; then
        j="${i//@//}"
        COUNT=$((COUNT+1))
        cd "$i" && echo "$COUNT/$TOTAL http://$j"
        wget -N "$j" -o wget.log --user-agent="Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.3"
        if ! grep -q 304 wget.log; then
            if [ -x rules.sh ]; then
                ./rules.sh
            fi
            git add .
            INFO=`git commit -m "$MSG http://$j"`
            if [ "$?" -eq 0 ]; then
                echo "$INFO"
                notify-send -u critical -a 'Site Monitor' "$j" "<a href='http://$j'>Click!</a>"
            fi
        fi
        cd - &> /dev/null
    fi
done
