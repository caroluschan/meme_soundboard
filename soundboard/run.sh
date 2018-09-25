#!/bin/bash
function printTable()
{
    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"

    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"

        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1

            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"

                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"

                # Add Line Delimiter

                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi

                # Add Header Or Body

                table="${table}\n"

                local j=1

                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done

                table="${table}#|\n"

                # Add Line Delimiter

                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done

            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines()
{
    local -r content="${1}"

    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString()
{
    local -r string="${1}"
    local -r numberToRepeat="${2}"

    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString()
{
    local -r string="${1}"

    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi

    echo 'false' && return 1
}

function trimString()
{
    local -r string="${1}"

    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

function ctrl_c() {
        if [ ! -z "$pid" ]
        then
                kill -s 0 -PIPE $pid &>/dev/null
	fi
	reset
	exit 0
}

table="Key,Sound Effect
a,Air Horn
s,Sad4me
x,Illuminati
t,Thug Life
d,dudludu dudludu dudludu dadada
k,End Sound Effect
r,Really Nigga"

echo -e "\033[0;31m
  _____   ____   _____   ____  
 /     \_/ __ \ /     \_/ __ \ 
|  Y Y  \  ___/|  Y Y  \  ___/ 
|__|_|  /\___  >__|_|  /\___  >
      \/     \/      \/     \/ 
                               .______.                          .___
  __________  __ __  ____    __| _/\_ |__   _________ _______  __| _/
 /  ___/  _ \|  |  \/    \  / __ |  | __ \ /  _ \__  \\_  __ \/ __ | 
 \___ (  <_> )  |  /   |  \/ /_/ |  | \_\ (  <_> ) __ \|  | \/ /_/ | 
/____  >____/|____/|___|  /\____ |  |___  /\____(____  /__|  \____ | 
     \/                 \/      \/      \/           \/           \/ \033[0m" 
echo ""
echo Press the following key to play the desired sound effect
printTable ',' "$table"
echo Press Ctrl+C to exit

DIR="$(dirname "$(readlink "$0")")"
array=(a s x k t d r)
pid=""
tmp_pid=""
while true;
do
	tmp_pid=""
	trap ctrl_c INT 
	read -s -n1 var
	for i in "${array[@]}"
	do
		if [ "$var" == "$i" ]
		then
			afplay $DIR/$i &
			command="afplay $DIR/$i"
			tmp_pid="$!"
			break	
		fi
	done
	sleep 0.1
	if [ ! -z "$pid" ]
        then
                kill -s 0 -PIPE $pid &>/dev/null
        fi
	pid="$tmp_pid"
done
