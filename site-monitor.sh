#!/bin/bash

if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR=/run/user/`id -u`
fi

cd `dirname $0`

if [ "$#" -gt 0 ]; then
    ARG="$@"
else
    ARG=$(ls -I `basename "$0"` -I README.md)
fi

TOTAL=`echo $ARG | tr ' ' '\n' | wc -l`
COUNT=0

for i in $ARG; do
    COUNT=$((COUNT+1))
    MSG="update"
    if [[ "$i" = http* ]]; then
        i=`sed -e 's,^http://,,' -e 's,^https://,@,' -e 's,/$,,' -e 's,/,@,g' <<< "$i"`
        if mkdir "$i" 2>/dev/null; then
            MSG="create"
        fi
    fi
    if [ -d "$i" ]; then
        j=`sed -e 's,^\([^@]\),http://\1,' -e 's,^@,https://,' -e 's,@,/,g' <<< "$i"`
        cd "$i"
        echo "$COUNT/$TOTAL $j"
        wget --timeout=60 --tries=3 -N "$j" -o wget.log --user-agent="Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.3"
        if [ $? -eq 0 ] && ! grep -q '304 Not Modified\|p.nju.edu.cn' wget.log; then
            if [ -x rules.sh ]; then
                ./rules.sh
            fi
            git add . 2> /dev/null
            INFO=`git commit -m "$MSG $j"`
            if [ "$?" -eq 0 ]; then
                echo "$INFO"
                notify-send -u critical -a 'Site Monitor' "$j" "<a href='$j'>Click!</a>"
            fi
        else
            git restore .
        fi
        cd - &> /dev/null
    fi
done
