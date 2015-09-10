#!/bin/bash

Counter=0
flag_nmap_curr=0
flag_nmap_prev=0
flag_ping_curr=0
flag_ping_prev=0
address="127.0.0.1"


if [ "$flag_nmap_curr" = "0" ] 
then
	notify-send --expire-time=1 "services are up on the specified target"
else
	notify-send --expire-time=1 "services are down on the specified target"
fi

while [ $Counter -lt 1 ]
do

	sleep 10;
	nmap -Pn -p22,25,80 $address > temp_nmap_log.dat
	date > temp_date.dat
	echo "" >> nmap_log.dat
	cat temp_date.dat >> nmap_log.dat	
	awk 'BEGIN{i=0}{i++;if(i>5 && i<9) print($0)}' < temp_nmap_log.dat >temp_nmap_log_curr.dat
	cat temp_nmap_log_curr.dat >> nmap_log.dat

	read -r a b c< <(awk 'BEGIN{i=0}{i++;a[i]=$2}END{print(a[1],a[2],a[3])}' < temp_nmap_log_curr.dat)
	if [ "$a" = "open" ] & [ "$b" = "open" ] & [ "$c" = "open" ]
	then
		flag_nmap_curr=1;
	else
		flag_nmap_curr=0;
	fi	

	if [ "$flag_nmap_curr" = "$flag_nmap_prev" ] 
	then
		if [ "$flag_nmap_curr" = "0" ]
		then
			sleep 1
			flag_nmap_prev=$flag_nmap_curr;
			continue
		else
			#ping 
			flag_nmap_prev=$flag_nmap_curr;	
			ping -c 3 $address > temp_ping_log_1.dat
			date > temp_date.dat
			echo "" >> ping_log.dat
			cat temp_date.dat >> ping_log.dat
			awk '{if($1 == 64) print($0)}' < temp_ping_log_1.dat > temp_ping_log_cur.dat
			read -r temp1 temp2 < <(awk 'BEGIN{i=0}{i++;if(i <3) a[i]=$1;}END{print(a[1],a[2])}' < temp_ping_log_1.dat)
			if [ "$temp1" = "PING" ]
			then
				if [ "$temp2" = "64" ]
				then
					flag_ping_curr=1;
					cat temp_ping_log_cur.dat >> ping_log.dat
				else
					flag_ping_curr=0;
					echo "ping unreachable" >> temp_ping_log.dat
					cat temp_ping_log.dat >> ping_log.dat
				fi
			else
				flag_ping_curr=0;
				echo "ping unreachable" >> temp_ping_log.dat	
				cat temp_ping_log.dat >> ping_log.dat
			fi
			if [ "$flag_ping_curr" = "$flag_ping_prev" ]
			then
				sleep 1 
				flag_ping_prev=$flag_ping_curr
				continue
			else
				date > temp_date.dat
				echo "" >> ping_report.dat
				echo "" >> report_final.dat
				cat temp_date.dat >> ping_report.dat
				cat temp_date.dat >> report_final.dat
				if [ "$flag_ping_curr" = "1" ]
				then
					flag_ping_prev=$flag_ping_curr
					cat temp_ping_log_cur.dat >> ping_report.dat
					cat temp_ping_log_cur.dat >> report_final.dat
				else
					flag_ping_prev=$flag_ping_curr
					echo "ping unreachable" >> temp_ping_log.dat	
					cat temp_ping_log.dat >> ping_report.dat
					cat temp_ping_log.dat >> report_final.dat
				fi
			fi

		fi
	else
		date > temp_date.dat
		echo "" >> nmap_report.dat
		echo "" >> report_final.dat
		cat temp_date.dat >> nmap_report.dat
		cat temp_date.dat >> report_final.dat
		cat temp_nmap_log_curr.dat >> nmap_report.dat
		cat temp_nmap_log_curr.dat >> report_final.dat
		#notify
		if [ "$flag_nmap_curr" = "0" ]
		then
			notify-send --expire-time=1 "localhost services are down"
			sleep 1	
			flag_nmap_prev=$flag_nmap_curr;
			echo "services down" >> temp_nmap_report.dat	
			cat temp_nmap_report.dat >> nmap_report.dat
			cat temp_nmap_report.dat >> report_final.dat
			continue
		else
			notify-send --expire-time=1 "localhost services are up"
			flag_nmap_prev=$flag_nmap_curr;	
			ping -c 3 $address > temp_ping_log_1.dat
			date > temp_date.dat
			echo "" >> ping_log.dat
			cat temp_date.dat >> ping_log.dat
			awk '{if($1 == 64) print($0)}' < temp_ping_log_1.dat > temp_ping_log_cur.dat
			read -r temp1 temp2 < <(awk 'BEGIN{i=0}{i++;if(i <3) a[i]=$1;}END{print(a[1],a[2])}' < temp_ping_log_1.dat)
			if [ "$temp1" = "PING" ]
			then
				if [ "$temp2" = "64" ]
				then
					flag_ping_curr=1;
					cat temp_ping_log_cur.dat >> ping_log.dat
				else
					flag_ping_curr=0;
					echo "ping unreachable" >> temp_ping_log.dat
					cat temp_ping_log.dat >> ping_log.dat
				fi
			else
				flag_ping_curr=0;
				echo "ping unreachable" >> temp_ping_log.dat	
				cat temp_ping_log.dat >> ping_log.dat
			fi
			if [ "$flag_ping_curr" = "$flag_ping_prev" ]
			then
				sleep 1 
				flag_ping_prev=$flag_ping_curr
				continue
			else
				date > temp_date.dat
				echo "" >> ping_report.dat
				echo "" >> report_final.dat
				cat temp_date.dat >> ping_report.dat
				cat temp_date.dat >> report_final.dat
				if [ "$flag_ping_curr" = "1" ]
				then
					flag_ping_prev=$flag_ping_curr
					cat temp_ping_log_cur.dat >> ping_report.dat
					cat temp_ping_log_cur.dat >> report_final.dat
				else
					flag_ping_prev=$flag_ping_curr
					echo "ping unreachable" >> temp_ping_log.dat	
					cat temp_ping_log.dat >> ping_report.dat
					cat temp_ping_log.dat >> report_final.dat
				fi
			fi
		fi
	fi	
done