#!/bin/bash

# bash routines for development

#create a combined diff of changed CVS files in the current dir
cvsdiff() {
    local filename=$1
    if [ -z "${filename}" ]
    then
        showError "usage : cvsdiff <id> [files]"
        showError '        files will be created in $DIFFS if available'
        exit 1
    fi
    shift 

    local filepath=$(getDiffFilePath ${filename})
    cvs diff $* 2>/dev/null 1>${filepath}
    showInfo "Diff file created at ${filepath}"
    openfile ${filepath}
}

gitdiff() {
    local filename=$1
    if [ -z "${filename}" ]
    then
        showError "usage : gitdiff <id> [files]"
        showError '        files will be created in $DIFFS if available'
        exit 1
    fi
    shift 

    local filepath=$(getDiffFilePath ${filename})
    git diff origin $* 2>/dev/null 1>${filepath}
    showInfo "Diff file created at ${filepath}"
    openfile ${filepath}   
}

createDiffFile() {
    local filename=$1
    if [ ! -d "${DIFFS}" ]; then
        DIFFS=.
    fi
    
    # if diff file exists, create new file by appending date
    local DATE=`date +%d%h%y_%H%M`
    if [ -e "${DIFFS}/${filename}.txt" ]
    then
        filename=${filename}-${DATE}.txt
    fi
    
    echo "${DIFFS}/${filename}"
}

#create a backup of changed CVS files from the current dir
cvsbackup() {
    local filename=$1
    local files=`cvs up 2>/dev/null $*| sed -e "/^R/d" -e "s/^[M?A] //"`
    createBackupFile ${filename} "cvsbackup" ${files}
}

createBackupFile() {
    local filename=$1
    local commandName=$2
    shift
    shift
    local files=$@

    if [ -z "${filename}" ]
    then
        showError "usage : ${commandName} <id> [files]"
        showError '        files will be created in $BACKUPS if available'
        exit 1
    fi
    shift 
    if [ -z "${BACKUPS}" ]; then
        BACKUPS=.
    fi

    local DATE=`date +%d.%h.%Y_%H-%M`

    filename=${filename}-${DATE}.jar
    filepath=${BACKUPS}/$filename
    jar cfM ${filepath} ${files}

    showInfo "Backup file created at ${filepath}"   
}

#opens a given file
openfile() {
    local file=$1
    if [ -n "${EDITOR}" ];then
        $EDITOR ${file}
    fi
}

showInfo() {
    echo -e '\033[1;34m'"\033[1m$1\033[0m"
}

showError() {
    echo -e '\033[1;31m'"\033[1mERROR: $1\033[0m"
}