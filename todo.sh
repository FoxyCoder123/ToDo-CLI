#!/bin/bash

# Checking the setup for todo -- creating a file in the same directory

# Operations of todo
# - create (create task)
# - read (list the pending tasks)
# - update (update the existing task)
# - delete (delete user specified or completed task)

# use flag while using todo command
# Always check the setup is done or not

# In file, a new rowID should be created upon adding a new task into the file.
# use fonts, emoji(s) to make it more user-friendly
# user can delete a task in a file by either providing a rowID or by using task name.

# every action should be recursive to make more interactive.

fileName=todo-list.txt
path=`pwd`

function todoSetup() {
    path=$1
    if [ ! -f $path/$fileName ]
    then
        echo "⚙️  Preparing for the setup..."
        touch $path/$fileName
        sleep 1
        echo "✨ Setup Done!"
    fi
}

function createTask() {
    task=$1
    rowID=`date +"%H%M%S"`
    echo "$rowID|$task" >> $path/$fileName
}

function showTasks() {
    cat $path/$fileName
}

function clearAllTasks() {
    truncate -s 0 $path/$fileName
}

todoSetup $path
createTask "Learn Django."
showTasks
echo
echo "Do u want to clear all the tasks? - y/n"
read option
if [ $option=='y'  ]
then
    clearAllTasks
fi
