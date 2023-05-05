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
    printf "Clear content for todo(t)/completed(c)/others will clear both?\n"
    read -p "t/c》" operation
    if [[ $operation == 'c' ]]; then
        truncate -s0 $completed
    elif [[ $operation == 't' ]]; then
        truncate -s0 $file
    else
        truncate -s0 $file $completed
    fi
}

function addTask(){
    taskID=$(date +%Y-%m-%d🔸%H:%M:%S)
    task="$1"
    echo "${task}|${taskID}" >> $file
}

function splitTask(){
    param=$(echo "$1" | sed "s/[, ]/ /g")
    echo "$param"
}

function doneTask(){
    rows=$(splitTask "$1")
    for row in $(echo "$rows")
    do
        doneID=$(date +%Y-%m-%d🟢%H:%M:%S)
        dTask=$(sed -n "${row}p" $file)
        echo "$(echo "$dTask" | cut -d"|" -f1)|${doneID}" >> $completed
        sed -i "s/${dTask}//" $file
    done
    sed -i "/^$/d" $file
    if [[ ! -s $file ]]; then
        printf "█▀█ █▀▀ █░░ ▄▀█ ▀▄▀   █▄░█ █▀▄   █░█ ▄▀█ █░█ █▀▀   █▀ █▀█ █▀▄▀█ █▀▀   █▀▀ █▀█ █▀▀ █▀▀ █▀▀ █▀▀\n"
        printf "█▀▄ ██▄ █▄▄ █▀█ █░█   █░▀█ █▄▀   █▀█ █▀█ ▀▄▀ ██▄   ▄█ █▄█ █░▀░█ ██▄   █▄▄ █▄█ █▀░ █▀░ ██▄ ██▄\n"
        printf "\n"
        printf "█▀▄ █▀█ █▄░█ █▀▀   █░█░█ █ ▀█▀ █░█   ▄▀█ █░░ █░░   ▀█▀ ▄▀█ █▀ █▄▀ █▀\n"
        printf "█▄▀ █▄█ █░▀█ ██▄   ▀▄▀▄▀ █ ░█░ █▀█   █▀█ █▄▄ █▄▄   ░█░ █▀█ ▄█ █░█ ▄█\n"
    fi
}

function removeTask(){
    rows=$(splitTask "$1")
    for row in $(echo "$rows")
    do
        dTask=$(sed -n "${row}p" $file)
        sed -i "s/${dTask}//" $file
    done
    sed -i "/^$/d" $file
}

function multipleTaskAdd(){
    printf "Enter task(s) to be added:\n"
    counter=0
    while read task; do
        [ -z "$task" ] && break
        counter+=1
        taskID=$(date +%Y-%m-%d🔸%H:%M:%S)
        echo "${task}|${taskID}" >> $file
    done
    printf "➕${counter} task(s) added...\n"
}

function multipleTaskUpdate(){
    read -p "Enter task(s) to be updated: " rows
    ids=$(splitTask "$rows")
    counter=0
    failed=0
    for id in $(echo "$ids")
    do
        line=$(sed -n "${id}p" $file)
        uTask=$(echo "$line" | cut -d'|' -f1)
        printf "${uTask} ➜ \n"
        read -r rTask
        sed -i "s/${uTask}/${rTask}/" $file
        if [[ "$?" -ne 0 ]]; then
            printf "❗ Not updated Properly...\n"
            failed+=1
        else
            counter+=1
        fi
    done
    printf "✔${counter} task(s) updated, ❌${failed} task(s) failed to be updated...\n"
}

function multipleTaskRedo(){
    read -p "Enter task(s) to be re-done: " rows
    ids=$(splitTask "$rows")
    counter=0
    for id in $(echo "$ids")
    do
        line=$(sed -n "${id}p" $completed)
        rTask=$(echo "$line" | cut -d"|" -f1)
        redoID=$(date +%Y-%m-%d🔸%H:%M:%S)
        echo "${rTask}|${redoID}" >> $file
        sed -i "s/${line}//" $completed
        counter+=1
    done
    sed -i "/^$/d" $file
    printf "🔁${counter} task(s) need to be done again...\n"
}

function multipleTask(){
    printf "Mutiple task(s) to add(a)/update(u)/redo(r):\n"
    read -p "a/u/r》" operation
    if [[ $operation == 'a' || $operation == 'A' ]]; then
        multipleTaskAdd
    elif [[ $operation == 'u' || $operation == 'U' ]]; then
        multipleTaskUpdate
    elif [[ $operation == 'r' || $operation == 'R' ]]; then
        multipleTaskRedo
    else
        printf "Enter either 'a/A' or 'u/U' or r/R for the operation...\n"
    fi
}

function help(){
    printf "help...\n"
}

function priorityTask(){
    #"Tasks Priority" can be: 
        # 'H' -> High (red)
        # 'M' -> Medium (orange)
        # 'L' -> Low (yellow)
    printf "Enter Task(s) priority level\n"
    printf "type h ➜ High; m ➜ Medium; l ➜ Low\n"    
    while true; do
        read -p "h/m/l》" operation
        read -p "Enter taskID(s): " tasks
        rows=$(splitTask "$tasks")
        if [[ $operation == 'h' || $operation == 'H' ]]; then
            for row in $(echo "$rows")
            do
                pTask=$(sed -n "${row}p" $file)
                sed -i "s/${pTask}/🔴 ${pTask}/" $file
            done    
        elif [[ $operation == 'm' || $operation == 'M' ]]; then
            for row in $(echo "$rows")
            do
                pTask=$(sed -n "${row}p" $file)
                sed -i "s/${pTask}/🟠 ${pTask}/" $file
            done            
        elif [[ $operation == 'l' || $operation == 'L' ]]; then
            for row in $(echo "$rows")
            do
                pTask=$(sed -n "${row}p" $file)
                sed -i "s/${pTask}/🟡 ${pTask}/" $file
            done            
        else
            printf "enter either 'h/H' or 'm/M' or 'l/L for the assignment...\n'"
        fi
        read -p "Done!! Wanna continue (y/n) ➜ " opinion
        if [[ $opinion == 'n' ]]; then
            printf "____________________________________\n\n"
            break
        fi
        printf "____________________________________\n\n"
    done    
}

#Main
setup

args=$(getopt -a -n todo -o a:smd:r:ehp --long add:,show,multiple,done:,remove:,empty,help,priority -- "$@")

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
        -h|--help)
            help;
            shift;;
        -p|--priority)
            priorityTask;
            shift;;
        --)
            shift;
            break;;
        ?)
            help;
            shift;
            exit 2;;
    esac
done


