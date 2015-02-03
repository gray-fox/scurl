#!/bin/bash
split_dl()
{
clear
check_url=$( curl -sI $URL | grep -i Accept-ranges )
if [[ $check_url = *"none"* ]]
then
    while [ "$ans" != "y" ] && [ "$ans" != "n" ]
    do
        clear
        echo "Server doesn't seem to support byte ranging"
        echo "Continue anyway(y/n):"
        read ans
    done
    if [ $ans = "n" ]
    then
        exit
    fi
elif [[ $check_url != *"bytes"* ]]
then
    clear
    echo "'bytes' not found in 'Accept-ranges' header."
    echo "If error occurs try downloading from different server"
    sleep 4
fi
byte_sz=$( curl -sI $URL | grep -i Content-Length | awk '{print $2}' )
mod_byte_sz=$(tr -d '\r' <<< "$byte_sz")
if [[ $mod_byte_sz -eq 0 ]]
then
    clear
    echo "Couldn't fetch size of the file"
    echo "Give exact file size(MB):"
    read alter_sz
    mod_byte_sz=$(( $alter_sz * 1048576))
fi
mb_sz=$(( $mod_byte_sz / 1048576 ))
clear
echo "Size of the file is: $mb_sz MB"
echo "Give size(MB) of the first part you want to split:"
read part_sz
count=$(( $mb_sz / $part_sz - 1 ))
psz=$(( $part_sz * 1048576 ))
i=1
j=0
while [ $count -gt 0 ]
do
    curl --range $j-$(( $psz * $i )) -o file.part$i $URL
    count=$(( $count - 1 ))
    i=$(( $i + 1 ))
    j=$(( $j + $psz + 1 ))
done
curl --range $j- -o file.part$i $URL
}
 
part_dl()
{
clear
clear
check_url=$( curl -sI $URL | grep -i Accept-ranges )
if [[ $check_url = *"none"* ]]
then
    while [ "$ans" != "y" ] && [ "$ans" != "n" ]
    do
        clear
        echo "Server doesn't seem to support byte ranging"
        echo "Continue anyway(y/n):"
        read ans
    done
    if [ $ans = "n" ]
    then
        exit
    fi
elif [ [$check_url != *"bytes"* ]]
then
    clear
    echo "'bytes' not found in 'Accept-ranges' header."
    echo "If error occurs try downloading from different server"
    sleep 4
fi
byte_sz=$( curl -sI $URL | grep -i Content-Length | awk '{print $2}' )
mod_byte_sz=$(tr -d '\r' <<< "$byte_sz")
if [[ $mod_byte_sz -eq 0 ]]
then
    clear
    echo "Couldn't fetch size of the file"
    echo "Give exact file size(MB):"
    read alter_sz
    mod_byte_sz=$(( $alter_sz * 1048576))
fi
mb_sz=$(( $mod_byte_sz / 1048576 ))
clear
echo "Size of the file is: $mb_sz MB"
echo "Give size(MB) of the first part you want to split:"
read part_sz
count=$(( $mb_sz / $part_sz ))
clear
echo "File is splitted in $count parts"
echo "Select which part to download: "
read part
count=$(( $mb_sz / $part_sz - 1 ))
psz=$(( $part_sz * 1048576 ))
i=1
j=0
while [ $count -gt 0 ]
do
    if [ $i = $part ]
    then
        curl --range $j-$(( $psz*$i )) -o file.part$i $URL
    fi
    count=$(( $count - 1 ))
    i=$(( $i + 1 ))
    j=$(( $j + $psz + 1 ))
done
if [ $i = $part ]
then
    curl --range $j- -o file.part$i $URL
fi
}
help_menu()
{
echo "Usage1: scurl.sh <url> [optional -p]"
echo "Usage2: scurl.sh <-m> <output_file.name>"
echo "-m Merge downloaded parts"
echo "-p Choose one part to download"
}
 
merge()
{
echo "Merging $f_name"
cat file.part* > $f_name
rm -f file.part*
}
clear
 
if [ $# -eq 0 ]
then
    help_menu
fi
 
 
if [ $# -eq 1 ]
then
    URL=$1
    split_dl  
fi
if [ $# -gt 1 ]
then
    if [ $1 = "-m" ]
    then
        f_name=$2
        merge
    elif [ $2 = "-p" ]
    then
        URL=$1
        part_dl
    else
        help_menu
    fi
fi
 
