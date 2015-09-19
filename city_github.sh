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
echo "City Population "  > $city_people

    for i in {1..10} ; do
	pqreq="${pqdata}=${var}"
        wget -O - "$site"$pqreq | \
        iconv -f windows-1250 -t utf-8 | \
        egrep -Eo "(<font color=\"black\">[^<1]+</font>|<td class=\"row[12]\" align=\"right\">[0-9 ]+</td>)" | \
        paste - - | sed "s|<font color=\"black\">||g" | sed "s|</font>||g" | sed "s|<td class=\"row[12]\" align=\"right\">||g" | \
	sed "s|</td>||g" | sed "s|(.*)||g" >> $city_people
	var=$((var+1))
    done
}

load_users_per_city(){
    echo "City Users" > $city_github_user
    while read city ; do
        echo -n "$city " >> $city_github_user
        curl -H 'Accept: application/vnd.github.v3.text-match+json'   "https://api.github.com/search/users?q=location:$city" \
	| grep "total_count" | sed "s|  \"total_count\": ||g" | sed "s|,||" >> $city_github_user
        sleep 7
    done < city
}

load_users_per_city_and_language(){
    city_github_user_per_language=city_github_user_per_language
    echo "City   Users 'C#'  Java     PHP JavaScript Objective-C Ruby Python C++ C" > $city_github_user_per_language
    while read city ; do
        echo -n "$city " >> $city_github_user_per_language
	for language in '*' "C%23" Java PHP JavaScript Objective-C Ruby Python "C%2B%2B" C ; do
            #echo -en "\t $language \t" >> $city_github_user_per_language
            echo -en ' \t ' >> $city_github_user_per_language
            my_city="%22$(echo $city | sed "s| |%20|g")%22"
    	    curl -H 'Accept: application/vnd.github.v3.text-match+json'   "https://api.github.com/search/users?q=location:${my_city}+language:$language" \
		| grep "total_count" | sed "s|  \"total_count\": ||g" | sed "s|,||" | tr -d "\n" >> $city_github_user_per_language
	    sleep 7
	done
	echo " " >> $city_github_user_per_language
    done < city_manual_correct
}

my_merge(){

    while IFS=' ' read city; do
	grep -m 1 "$city" $city_people | tr -d "\n"
	p=$( grep -m 1 "$city" $city_people | grep -Eo "[0-9 ]+" | tr -d " ")
	echo -en ' \t '
	g=$(grep -m 1 "$city" $city_github_user_per_language | sed "s|"$city"||g")
	echo -en "$g"
	echo -en ' \t '
	gr=$(echo $g | grep -m 1 -Eo "[0-9 ]+")
	perl -E "say (${gr}/(${p}/1000))" | cut -c1-7
    done < city
}

#load_cities
#load_people
load_users_per_city_and_language
#load_users_per_city
#my_merge