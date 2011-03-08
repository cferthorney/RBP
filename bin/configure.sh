#!/bin/bash
#    This file is part of Basic Rsync Backup Program (BRBP).
#
#    BRBP is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    BRBP is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with BRBP.  If not, see <http://www.gnu.org/licenses/>.
#
#    Author: David Thorne <dthorne@contemporaryfusion.co.uk>
#    Copyright (c) 2011   
#    Global configuration script

#Filter arguments
while [ $# -gt 0 ]
do
    case "$1" in
        -h) HOST="$2"; shift;;
        -d) DIR="$2"; shift;;
        -o) OPTIONS="$2"; shift;;
        -v) VERBOSE=1; shift;;
        -h) echo >&2 \
            "Basic Rsync Backup Program - Configuration\nUsage: $0 -c /path/to/configfile -C gzip|bzip"
            exit 1;;
        *)  break;;     # terminate while loop
    esac
    shift
done