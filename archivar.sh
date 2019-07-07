#!/bin/sh

#1- Parametros: archivo de foto.
#2- Obtener md5, datetime y extension.
#3- Validar que no exista en ~/Fotos/año/mes
#4- Mover a ~/Fotos/año/mes/md5-hash.extension

#TODO: crea log por dia

FOTOS_DIR="/Users/tito/Fotos"
RED='\033[0;31m'
NOCOLOR='\033[0m'

main() {

    [ -f "$1" ] || die 'Wrong file:' "$1"
    FILE_EXTENSION=`file_extension "$1"`
    MD5=`file_md5 "$1"`
    DATETIME_LINE=`exiftool "$1" | grep 'Create Date'`
    [ ! -z "$DATETIME_LINE" ] || die 'Cannot get EXIF file modification date/time for ' "$1"
    YEAR=`echo $DATETIME_LINE | awk 'BEGIN {FS=":" } ; { print $2 }' | tr -d ' '`
    MONTH=`echo $DATETIME_LINE | awk 'BEGIN {FS=":" } ; { print $3 }'`
    DAY=`echo $DATETIME_LINE | awk 'BEGIN {FS=":" } ; { print $4 }' | awk 'BEGIN {FS=" " } ; { print $1 }'`
    DEST_FILE="$FOTOS_DIR/$YEAR/$MONTH/$YEAR-$MONTH-$DAY-$MD5.$FILE_EXTENSION"
    [ ! -f "$DEST_FILE" ] || die 'Cannot move' "$1" '. File' $DEST_FILE 'already exists.'
    DEST_DIR=`dirname $DEST_FILE`
    [ -d "$DEST_DIR" ] ||  ( mkdir -p "$DEST_DIR" && log 'Directory' "$DEST_DIR" "has been created." )
    CMD="mv \"$1\" \"$DEST_FILE\""
    log $CMD
    eval ${CMD}

}

file_md5() {
    echo `md5 "$1" | awk 'BEGIN {FS="= " } ; { print $2 }'`
}

file_extension() {
    FILENAME=$(basename "$1")
    echo "${FILENAME##*.}"
}

log() {
    echo INFO: `date`: "$*" | tee -a ~/.logs/archivar
}

###
 # Perl style "die" function.
 # Prints an error msg in stderr and exit with status "1".
 #
 #
die() {
    echo ${RED}FATAL: `date`: "$*"$NOCOLOR
    exit 1
}

main $*
