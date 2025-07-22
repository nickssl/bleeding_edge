#! /bin/csh

# Adds a directory for next year to ouptut directories

#/disks/data/maven/data/sci/pfp/ql
#/disks/data/maven/data/sci/lpw/ql
#/disks/data/maven/data/sci/mag/ql
#/disks/data/maven/data/sci/sep/ql
#/disks/data/maven/data/sci/sta/ql
#/disks/data/maven/data/sci/swe/ql
#/disks/data/maven/data/sci/swi/ql

setenv yrstr `date +%Y`

set ext = "$yrstr"

rm -rf /disks/data/maven/data/sci/*/ql/2018

mkdir /disks/data/maven/data/sci/pfp/ql/2018
mkdir /disks/data/maven/data/sci/lpw/ql/2018
mkdir /disks/data/maven/data/sci/mag/ql/2018
mkdir /disks/data/maven/data/sci/sep/ql/2018
mkdir /disks/data/maven/data/sci/sta/ql/2018
mkdir /disks/data/maven/data/sci/swe/ql/2018
mkdir /disks/data/maven/data/sci/swi/ql/2018
