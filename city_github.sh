#!/bin/sh

city_github_user=city_github_user
city_people=city_people

load_cities(){
site="http://www.tiptopglobe.com/biggest-cities-world"
pqdata="?p"
var=0
    for i in {1..10} ; do
	pqreq="${pqdata}=${var}"
        wget -O - "$site"$pqreq | grep -Eo '<font color="black">([A-z]+)</font>' | sed "s|<font color=\"black\">||g" | sed "s|</font>||g" >> city
	var=$((var+1))
    done
}

load_people(){
site="http://www.tiptopglobe.com/biggest-cities-world"
pqdata="?p"
var=0
    for i in {1..10} ; do
	pqreq="${pqdata}=${var}"
        wget -O - "$site"$pqreq | \
        iconv -f windows-1250 -t utf-8 | \
        egrep -Eo "(<font color=\"black\">[^<-]+</font>|<td class=\"row[12]\" align=\"right\">[0-9 ]+</td>)" | \
        paste - - | sed "s|<font color=\"black\">||g" | sed "s|</font>||g" | sed "s|<td class=\"row[12]\" align=\"right\">||g" | \
	sed "s|</td>||g" | sed "s|(.*)||g" >> $city_people
	var=$((var+1))
    done
}

load_statistic(){
#    sleep 60

    echo "City Users" > $city_github_user
    while read city ; do
	echo -n "$city " >> $city_github_user
    	curl -H 'Accept: application/vnd.github.v3.text-match+json'   "https://api.github.com/search/users?q=location:$city" \
	 | grep "total_count" | sed "s|  \"total_count\": ||g" | sed "s|,||" >> $city_github_user
	sleep 7
    done < city
}

my_merge(){

    while IFS=' ' read city; do
#	echo "$city " 
	#cat | tr -d " " |
	grep -m 1 "$city" $city_people | tr -d "\n"
	p=$( grep -m 1 "$city" $city_people | grep -Eo "[0-9 ]+" | tr -d " ")
	#; echo $(($a / 1000))
#	echo -en ' \t '
	echo -en ' !!! '
#	| sed "s|"$city"||g" 
	g=$(grep -m 1 "$city" $city_github_user | sed "s|"$city"||g")
	
	echo -en "$g"
	#$( grep "$city" $city_github_user | grep -Eo "[0-9]+")
	echo -en ' !!! '
#	echo "say (${g}/(${p}/1000))"
	perl -E "say (${g}/(${p}/1000))" | cut -c1-7
	#| tr -d "\n"
    done < city
    #city
}

#load_cities
#load_people
#load_statistic
my_merge