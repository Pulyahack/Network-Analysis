#!/bin/bash



echo "                                           "
echo "                                           "
echo "                                           "
echo "                                           " 
echo "          ⚜️  WELCOME $USER  ⚜️ ️           "
echo "                                           "
echo "                    🕵️‍♂                     "
echo "                                           "
echo "                                           "
echo "                                           "                           
echo " ❗Run this program as sudo bash zeek.sh   "
echo "                                           "
echo "                                           "


# Reads input IOC file
function IOC2() {
echo "Enter a IOC file name or path"
echo "                      "
read IOC
clear

}

# menu 
function mainmenu() {
while true
do
echo "                    "
echo "- - - - - - - - - - "
echo "      MENU          "
echo "- - - - - - - - - - "
echo "                    "
echo " Choose an option    "
echo "                    "
echo " [1] Install Zeek HIDS"
echo " [2] Run Zeek live mode and monitor the network"
echo " [3] Add a domain to an IOC file"
echo " [4] Remove a domain from an IOC file"
echo " [5] View visited melicious sites "
echo " [6] Check melicious files on Virus Total"
echo " [7] Exit           "
echo "                    "
read menu

if [ $menu -eq 1 ]
then
	zeekinstall
	
elif [ $menu -eq 2 ]
then
	clear
	bkg
	mon 
elif [ $menu -eq 3 ]
then
	addip
	
elif [ $menu -eq 4 ]
then
	removeip
elif [ $menu -eq 5 ]
then
	clear
	touch log.txt
	visitedlog=$(cat log.txt)
if [ -z "$visitedlog" ]
		then
			clear
			echo " No melicious sites have been visited"
		else
				echo " Compromised sites that have been visited ↓"
				echo "                                         "
               	cat log.txt | awk '{print $2" " $3" " $4" " $5" " $6" " $10}'
				echo "                        "
				echo ' Press "q" back to menu'
		while true
		do
					read -n 1 -s -t 1 key
  
				if [[ $key == q ]]; then
					clear
					mainmenu
				fi
		done		 
fi
	elif [ $menu -eq 6 ]
	then
		vt
		
	elif [ $menu -eq 7 ]
	then
		exit
fi
done
}

# checks whether zeek is already operating and monitoring
function zeekstatus() {

if [ $(ps aux | grep -i eth0 | wc -l) -gt 1  ]
	then
		echo "Zeek is already running "
		sleep 2
		clear
		echo "The system is monitoring . . . " 
		sleep 2
		mon        			
		
	elif [ $(ps aux | grep -i eth0 | wc -l) -eq 1 ]
	then
		echo "Zeek is not running what would you do?"
		echo "[1] Install Zeek"
		echo "[2] Menu"
		read var
		fi
		if [ $var == 1 ]
		then
			zeekinstall
		else
			clear	
			mainmenu
		
	fi
}

# full installation of zeek
function zeekinstall () {
sudo wget https://gist.githubusercontent.com/ShyftXero/f2cb738313b29206e6b8eafb53e8b7a6/raw/9d22286b2ac7b206728d2704e4fe66265c901231/install_zeek.sh
sudo chmod 777 install_zeek.sh
sudo ./install_zeek.sh
sudo touch  /etc/apt/sources.list.d/security::zeek.list 
echo "deb http://download.opensuse.org/repositories/security:/zeek/Debian_10/ /" > /etc/apt/sources.list.d/security::zeek.list 
echo "deb http://download.opensuse.org/repositories/security:/zeek/Debian_Testing/ /" > /etc/apt/sources.list.d/security::zeek.list 
sudo apt-get update 
sudo apt-get install zeek -y
clear
echo " Zeek installed successfully"
mainmenu
}

# add domains to IOC file
function addip () {

echo " Type The domain name you would like to add to the IOC file"
read domadd
for i in $(echo $domadd);do echo $i >> $IOC;done
sed '/^$/d' $IOC
while true
do
	echo " Would you like to add another domain? Y/N"
r	ead answer
	if [ $answer == Y ] || [ $answer == y ]
	then 
		echo " Type The domain name you would like to add to the IOC file"
		read doadd
	for i in $(echo $doadd);do echo $i >> $IOC;done
	sed '/^$/d' $IOC
	else
			mainmenu
	fi
done
}

# remove domains to IOC file
function removeip() {

echo " Type The domain you would like to remove from the IOC file"
read domremove
sed -i "/^$domremove\b/d" $IOC
sed '/^$/d' $IOC
while true
do
echo " Would you like to remove another domain? Y/N"
read answer
	if [ $answer == Y ] || [ $answer == y ]
	then 
		echo " Type The domain you would like to remove from the IOC file"
		read doremove
		sed -i "/^$doremove\b/d" $IOC
		sed '/^$/d' $IOC
	else
		mainmenu
	fi
done
}

# running zeek in background
function bkg() {
	
	 zeek -i eth0 -C & >/dev/null 2>&1  
                   
	for i in $(seq 1 20)
	do
	echo $i > /dev/null
	done

}
	



# monitoring the visited sites and echo the compromised ones
function mon() {
	userip=$(hostname -I)
	time=$(date -u | awk '{print $1" " $2" "$3" " $4" " $7}')

		cat /dev/null > dns.log
	    cat /dev/null > log.txt

	while true
	do
		for mel in $(cat $IOC)
		do
			visit=$(cat dns.log | grep -i -o $mel | uniq) 
			if [ ! -z "$visit" ]
			then
				echo "Alert! $time $userip has accessed $visit" >> log.txt
				echo "Alert! $time $userip has accessed $visit" 
	    
		
			fi
		done
		  sleep 3
	done                  
} 

	
# checking files on virus total api
function VT() {
		
sudo apt install jq
clear
echo " Enter file name or path"
read file_name
echo "Enter virus total API ( must be signed up for API)"
read ap
hash=$(sha256sum $file_name | awk '{print $1}')
curl https://www.virustotal.com/vtapi/v2/file/report -F resource=$hash -F apikey=$ap > virustotal.txt
jq -R -s -c 'split("\n")' < virustotal.txt  > result.txt
cat result.txt	
}	

# functions executions	
	IOC2
	zeekstatus
	

		
	
	
	
	
	
	
	
	
	
	
	
	


