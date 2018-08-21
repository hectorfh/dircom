#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

# TODO: change "subtract" for "diff"

# find . -type f -not -name “checksums.md5” -exec md5 '{}' \; > checksums.md5

# CONSTANTS

set MD5_FILE_NAME "checksums.md5"
set CHECKSUMS_FILE_NAME ".checksums"

# Help banner.
set banner \
{###############################################################################
#                                                                             #
#           88  88                                                            #
#           88  ""                                                            #
#           88                                                                #
#   ,adPPYb,88  88  8b,dPPYba,   ,adPPYba,   ,adPPYba,   88,dPYba,,adPYba,    #
#  a8"    `Y88  88  88P'   "Y8  a8"     ""  a8"     "8a  88P'   "88"    "8a   #
#  8b       88  88  88          8b          8b       d8  88      88      88   #
#  "8a,   ,d88  88  88          "8a,   ,aa  "8a,   ,a8"  88      88      88   #
#   `"8bbdP"Y8  88  88           `"Ybbd8"'   `"YbbdP"'   88      88      88   #
#                                      ____ ____ ____ _ ____ _____            #
#                                     / ___/   _/  __/ /  __/__ __\           #
#                                     |    |  / |  \/| |  \/| / \             #
#                                     \___ |  \_|    | |  __/ | |             #
#                                     \____\____\_/\_\_\_/    \_/             #
#                                                                             #
#   * checksum                                                                #
#                                                                             #
#         Generate file with checksums for directory.                         #
#                                                                             #
#   * repeated                                                                #
#                                                                             #
#         Detect repeated files inside directory.                             #
#                                                                             #
#   * nrepeated                                                               #
#                                                                             #
#         Count repeated files inside directory.                              #
#                                                                             #
#   * subtract                                                                #
#                                                                             #
#         List files that are in directory A, but not in directory B.         #
#                                                                             #
#   * verify                                                                  #
#                                                                             #
#         Verify all files listed in checksums file are in the directory.     #
#                                                                             #
#                                             Programmed by Tito Hernandez.   #
#                                                                             #
###############################################################################}

# Main procedure.
proc main {} {

    switch [lindex $::argv 0] {
        checksum  createMD5_File
        repeated  detectRepeatedFiles
        nrepeated countRepeatedFiles
        subtract  subtract
        verify    verifyAgainst
        default   help
    }

}

proc help {} {

    puts $::banner

}

proc verifyAgainst {} {

    puts "Verifying..."

    set directory [lindex $::argv 1]
    set actualFileDataList [createFileDataListFromDirectory $directory]

    set expectedFileDataList [createFileDataListFromChecksumFile \
            [file join $directory $::MD5_FILE_NAME]]

    set subtraction [lfilter $expectedFileDataList \
            {[isMD5_InList $actualFileDataList [dict get $_ MD5]]} \
            [dict create actualFileDataList $actualFileDataList]]

    foreach file $subtraction {
        puts $file
    }

}

#
# Uses MacOS find and md5 commands to create a list of checksums of all the
# files in the directory and its subdirectories.
#
proc createFileDataListFromDirectory {directory} {

    if {![file isdirectory $directory]} {
        # TODO: puts to stderr
        puts "Error: $directory is not a directory."
        exit 1
    }

    set currentDir [pwd]
    cd $directory

    set command [list exec find . -type f -not -name \
                      $::MD5_FILE_NAME -exec md5 {{}} {;}]

    set output [eval $command]

    cd $currentDir

    set lines [split $output "\n"]
    lmap lines {mapMD5_LineToMD5_FileData $_}

}

proc createMD5_File {} {

    if {[llength $::argv] < 2} {
        # TODO: puts to stderr
        puts "Too few arguments. Should specify a directory."
        puts "usage: tclsh script.tcl -md5 directory"
        exit 1
    }

    set directory [lindex $::argv 1]

    if {![file isdirectory $directory]} {
        # TODO: puts to stderr
        puts "Error: $directory is not a directory."
        exit 1
    }

    # TODO: puts to stderr
    puts "Generating $::MD5_FILE_NAME at $directory"

    set currentDir [pwd]
    cd $directory

    set command [list exec find . -type f -not -name \
                      $::MD5_FILE_NAME -exec md5 {{}} {;} > $::MD5_FILE_NAME]

    eval $command

    cd $currentDir

}

proc test {} {
    # TODO: test method
}

proc detectRepeatedFiles {} {

    set directory [lindex $::argv 1]
    set filePath [file join $directory $::MD5_FILE_NAME]

    set fileDataList [createFileDataListFromChecksumFile $filePath]

    set existingFiles [list]
    set repeatedFiles [list]

    # Replace by list reduce
    foreach fileData $fileDataList {
        #set MD5 [dict get $fileData MD5]
        #set fileName [dict get $fileData fileName]

        # Find if checksum exists.
        foreach existingFile $existingFiles {
            if {[dict get $existingFile MD5] == [dict get $fileData MD5]} {
                # If exists...
                lappend repeatedFiles $fileData
                break
            }
        }

        lappend existingFiles $fileData
    }

    foreach fileData $repeatedFiles {
        puts [dict get $fileData fileName]
    }

}

proc countRepeatedFiles {} {

    set directory [lindex $::argv 1]
    set filePath [file join $directory $::MD5_FILE_NAME]

    set fileDataList [createFileDataListFromChecksumFile $filePath]

    set existingFiles [list]
    set repeatedFiles [list]

    # Replace by list reduce
    foreach fileData $fileDataList {
        #set MD5 [dict get $fileData MD5]
        #set fileName [dict get $fileData fileName]

        # Find if checksum exists.
        foreach existingFile $existingFiles {
            if {[dict get $existingFile MD5] == [dict get $fileData MD5]} {
                # If exists...
                lappend repeatedFiles $fileData
                break
            }
        }

        lappend existingFiles $fileData
    }

    puts [llength $repeatedFiles]

}

proc createFileDataListFromChecksumFile {filePath} {

    if {![file exists $filePath]} {
        puts "File $filePath doesn't exist."
        exit 1
    }

    set content [readWholeFile $filePath]
    set lines [split $content "\n"]
    lmap lines {mapMD5_LineToMD5_FileData $_}

}

proc subtract {} {

    if {[llength $::argv] < 3} {
        # TODO: puts to stderr
        puts "Too few arguments. Should specify two directories to compare."
        puts "usage: tclsh script.tcl -subtract dir1 dir2"
        exit 1
    }

    set dir1 [lindex $::argv 1]
    set dir2 [lindex $::argv 2]

    set md5FileName1 [file join $dir1 $::MD5_FILE_NAME]
    set md5FileName2 [file join $dir2 $::MD5_FILE_NAME]

    set fileDataList1 [createFileDataListFromChecksumFile $md5FileName1]
    set fileDataList2 [createFileDataListFromChecksumFile $md5FileName2]

    set subtraction [lfilter $fileDataList1 \
            {[isMD5_InList $fileDataList2 [dict get $_ MD5]]} \
            [dict create fileDataList2 $fileDataList2]]

    foreach file $subtraction {
        puts [dict get $file fileName]
    }

}

# Check if MD5 is in list
proc isMD5_InList {MD5_Files MD5} {
    set MD5_Found [lfilter $MD5_Files {[dict get $_ MD5] == $MD5} \
            [dict create MD5 $MD5]]

    expr {[llength $MD5_Found] == 0}
}

proc mapMD5_LineToMD5_FileData {MD5_Line} {

    # Lines generated by md5 commands looks like this:
    # MD5 (./lulu 2010/España/DSC05537.JPG) = 5a6199725053c9d71d8b45e01af7f40c
    # Delete "MD5 ("
    # Get ./lulu 2010/España/DSC05537.JPG) = 5a6199725053c9d71d8b45e01af7f40c
    set MD5_LineAfterFirstStep [string range $MD5_Line 5 end]

    # Split into two chunks. Will have:
    # 1. ./lulu 2010/España/DSC05537.JPG
    # 2. 5a6199725053c9d71d8b45e01af7f40c
    set chunks [wsplit $MD5_LineAfterFirstStep ") = "]

    dict create \
            fileName [lindex $chunks 0] \
            MD5      [lindex $chunks 1]

}

# Returns the whole file content.
# http://wiki.tcl.tk/367
proc readWholeFile {file} {
    set fd [open $file]
    set content [read $fd]
    close $fd
    return $content
}

# List map.
# http://wiki.tcl.tk/9617
proc lmap {listname expr} {
    upvar $listname list
    set res [list]
    foreach _ $list {
        lappend res [eval $expr]
    }
    return $res
}

# Filter list.
# http://wiki.tcl.tk/8384
proc lfilter {list script vars} {
    dict for {var value} $vars {
        set $var $value
    }

    set res {}
    foreach _ $list { if $script { lappend res $_ } }
    return $res
}

# Split by substring.
# Original TCL split proc splits by character.
# http://wiki.tcl.tk/1499
proc wsplit {str sep} {
    set out {} 
    set sepLen [string length $sep]
    if {$sepLen < 2} {
        return [split $str $sep]
    }
    while {[set idx [string first $sep $str]] >= 0} {
        # the left part : the current element
        lappend out [string range $str 0 [expr {$idx-1}]]
        # get the right part and iterate with it
        set str [string range $str [incr idx $sepLen] end]
    }
    # there is no separator anymore, but keep in mind the right part must be
    # appended
    lappend out $str
}

# Calls main procedure.
main

