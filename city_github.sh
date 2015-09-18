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

load_people(){
#<td class="row1" align="right">10 381 288</td>

site="http://www.tiptopglobe.com/biggest-cities-world"
pqdata="?p"
var=0
    for i in {1..10} ; do
	pqreq="${pqdata}=${var}"
        wget -O - "$site"$pqreq \ |
        iconv -f windows-1250 -t utf-8 biggest-cities-world \ |
        egrep -Eo "(<font color=\"black\">[^<-]+</font>|<td class=\"row[12]\" align=\"right\">[0-9 ]+</td>)" \ |
        paste - - \ |
	sed "s|<font color=\"black\">||g" | sed "s|</font>||g" | sed "s|<td class=\"row[12]\" align=\"right\">||g" \ |
	sed "s|</td>||g" | sed "s|(.*)||g"

        # grep -Eo '<td class=\"row1\" align=\"right\">[0-9 ]+</td>' | sed "s|<td class=\"row1\" align=\"right\">||g" | sed "s|</td>||g" >> city_people
	var=$((var+1))
    done

 
}

example(){

# egrep -Eo "(<font color=\"black\">[^<]+</font>|<td class=\"row[12]\" align=\"right\">[0-9 ]+</td>)" \ |
# sed "s|<font color=\"black\">||g" | sed "s|</font>||g" | sed "s|<td class=\"row1\" align=\"right\">||g" | sed "s|</td>||g" 

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
load_people
#load_statistic