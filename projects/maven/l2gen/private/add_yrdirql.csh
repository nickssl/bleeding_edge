#! /bin/csh

# Adds a directory for next year to ouptut directories

#/disks/data/maven/data/sci/pfp/ql
#/disks/data/maven/data/sci/lpw/ql
#/disks/data/maven/data/sci/mag/ql
#/disks/data/maven/data/sci/sep/ql
#/disks/data/maven/data/sci/sta/ql
#/disks/data/maven/data/sci/swe/ql
#/disks/data/maven/data/sci/swi/ql

setenv yrstr `date --date="1 year" +%Y`

set ext = "$yrstr"

mkdir /disks/data/maven/data/sci/pfp/ql/$ext
mkdir /disks/data/maven/data/sci/lpw/ql/$ext
mkdir /disks/data/maven/data/sci/mag/ql/$ext
mkdir /disks/data/maven/data/sci/sep/ql/$ext
mkdir /disks/data/maven/data/sci/sta/ql/$ext
mkdir /disks/data/maven/data/sci/swe/ql/$ext
mkdir /disks/data/maven/data/sci/swi/ql/$ext

