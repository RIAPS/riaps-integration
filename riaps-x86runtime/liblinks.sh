#!/bin/bash
# liblinks - generate symbolic links 
# given libx.so.0.0.0 this would generate links for libx.so.0.0, libx.so.0, libx.so
#

# By adding sudo to the ls command, we get permission to do the linking (or get an empty list)
LIBFILES='sudo ls lib*.so.*'
for FILE in $LIBFILES;
   do
   echo $FILE
    shortlib=$FILE
    basename=$FILE
    while extn=$(echo $shortlib | sed -n '/\.[0-9][0-9]*$/s/.*\(\.[0-9][0-9]*\)$/\1/p')
          [ -n "$extn" ]
    do
        shortlib=$(basename $shortlib $extn)
        sudo ln -fs $basename $shortlib
        basename=$shortlib
    done

   done
