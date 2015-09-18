#!/bin/sh


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

#parse_city(){}

load_statistic(){
#    sleep 60

    city_count=city_count
    echo "City Users" > $city_count
    while read city ; do
	echo -n "$city " >> $city_count
    	curl -H 'Accept: application/vnd.github.v3.text-match+json'   "https://api.github.com/search/users?q=location:$city" \
	 | grep "total_count" | sed "s|  \"total_count\": ||g" | sed "s|,||" >> $city_count
	sleep 7
    done < city
}

#load_cities
load_statistic