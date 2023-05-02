#!/bin/bash

if [[ ! -d $PWD/todo-cli/ ]]; then
    mkdir -p $PWD/todo-cli
fi

declare -i counter
declare -i failed

folder=$PWD/todo-cli
file=$folder/to-do.txt
completed=$folder/completed.txt

function setup(){
    flag1=0
    flag2=0
    if [[ ! -f $file ]]; then
        touch $file
        flag1=1
    fi
    if [[ ! -f $completed ]]; then
        touch $completed
        flag2=1
    fi
    if [[ $flag1 == 1 && $flag2 == 1 ]]; then
        echo "Setup Done... 🍻"
    fi
}

function showTask(){
    printf "▪▪▪ 📌 Tasks To Be Done ▪▪▪\n"
    cat -n $file
    printf "\n"
    printf "▪▪▪ ✅ Completed ▪▪▪\n"
    cat -n $completed
    printf "\n"
}

function emptyTask(){
    truncate -s0 $file $completed
}

function addTask(){
    taskID=$(date +%Y-%m-%d🔹%H:%M:%S)
    task="$1"
    echo "${task}|${taskID}" >> $file
}

function splitTask(){
    param=$(echo "$1" | sed "s/,/ /g")
    echo "$param"
}

function doneTask(){
    rows=$(splitTask "$1")
    for row in "$rows"
    do
        doneID=$(date +%Y-%m-%d🔹%H:%M:%S)
        dTask=$(sed -n "${row}p" $file | cut -d'|' -f1)
        echo "${dTask}|${doneID}" >> $completed
        sed -i "${row}d" $file
    done
}

function removeTask(){
    rows=$(splitTask "$1")
    for row in $(echo $rows)
    do
        sed -i "${row}d" $file
    done
}

function multipleTaskAdd(){
    printf "Enter task(s) to be added:\n"
    counter=0
    while read task; do
        [ -z "$task" ] && break
        counter+=1
        taskID=$(date +%Y-%m-%d🔹%H:%M:%S)
        echo "${task}|${taskID}" >> $file
    done
    printf "➕${counter} task(s) added..."
}

function multipleTaskUpdate(){
    read -p "Enter task(s) to be updated: " rows
    ids=$(splitTask "$rows")
    counter=0
    for id in $(echo $ids)
    do
        line=$(sed -n "${id}p" $file)
        uTask=$("$line" | cut -d'|' -f1)
        printf "${uTask}-\n"
        read -r rTask
        sed "s/${uTask}/${rTask}/" $file
        if [[ "$?" -ne 0 ]]; then
            printf "❗ Not updated Properly...\n"
            failed+=1
        else
            counter+=1
        fi
    done
    printf "✔${counter} task(s) updated, ❌${failed} task(s) failed to be updated..."
}

function multipleTask(){
    printf "Mutiple task(s) to add/update:\n"
    read -p "a/u》" operation
    if [[ $operation == 'a' || $operation == 'A' ]]; then
        multipleTaskAdd
    elif [[ $operation == 'u' || $operation == 'U' ]]; then
        multipleTaskUpdate
    else
        printf "Enter either 'a/A' or 'u/U' for the operation..."
    fi
}

#Main
setup

args=$(getopt -a -n todo -o a:smd:r:e --long add:,show,multiple,done:,remove:,empty -- "$@")

eval set -- "$args"

while :
do
    case $1 in
        -a|--add)
            addTask "$2";
            shift 2;;
        -s|--show)
            showTask;
            shift;;
        -d|--done)
            doneTask "$2";
            shift 2;;
        -m|--multi)
            multipleTask;
            shift;;
        -r|--remove)
            removeTask "$2";
            shift 2;;
        -e|--empty)
            emptyTask;
            shift;;
        --)
            shift;
            break;;
        ?)
            usage;
            shift;
            exit 2;;
    esac
done


