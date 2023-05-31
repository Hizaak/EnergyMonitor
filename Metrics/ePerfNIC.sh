#!/bin/bash

#INFO: the intel 6 AX201 has Capabilities: [c8] Power Management version 3 (lspci -v)
#...we can custom it depending on the kernel driver for further optimizations

##### POWER AND TRANSFER RATE VALUES #####

# source to intel confidential (?) sheet specs: https://www.tonymacx86.com/attachments/cnvi-and-9560ngw-documentation-pdf.342854/
# another one but newer: https://fccid.io/B94-9560D2WZ/User-Manual/Users-Manual-3800018.pdf

#Power TpT – 11n HB-40 Rx 11n (at max TpT) 550 mW
#TpT – 11ac HB-80 Tx 11ac (at max TpT) 1029 mW

#11ac 160 MHz 2SS Rx Conductive, best attenuation, TCP/IP 1204 Mbps - 150500 KBps
#11ac 160 MHz 2SS TX Conductive, best attenuation, TCP/IP 1220 Mbps - 152500 KBps

#cleaning...

#sudo nethogs  -P 3207 -v 0 -d 1 #KB/s

pid="$1"
chemin="$2"
nom="$3"



nethogs_pid=0

# Get the start time
start=$(date +%s)

#I do this because nethogs launches even with a void input
if kill -0 $pid; then
    #in Background, because this guy (nethogs) always captures the shell
    nethogs wlp1s0 -t -P $pid -v 0 -d 1 >> "nethogs-$pid.log" &
    nethogs_pid=$!
else
    echo "PANIC!!, process does not exists"
    exit 1
fi

while true
do
    if kill -0 $pid; then
        sleep 1
    else
        kill -9 $nethogs_pid
        break
    fi
done

# Get the end time
end=$(date +%s)
total_time=$((end - start))


grep "$1" "nethogs-$pid.log" | awk '{print $(NF-1), $NF}'
nethogs_results="$(grep "$1" "nethogs-$pid.log" | awk '{print $(NF-1), $NF}')"

# split the results into an array
arr=($nethogs_results)
# initialize variables for upload/download speeds values (even and odd positions)
upload_sum=0
upload_count=0
download_sum=0
download_count=0

# loop through the array and calculate the sum and count for even and odd positions. That's because the output format of nethogs_results -> a single line with upload and doanload values
for ((i=0; i<${#arr[@]}; i+=2)); do
    upload_sum=$(echo "scale=6; $upload_sum + ${arr[$i]}" | bc)
    upload_count=$(($upload_count + 1))
done

for ((i=1; i<${#arr[@]}; i+=2)); do
    download_sum=$(echo "scale=6; $download_sum + ${arr[$i]}" | bc)
    download_count=$(($download_count + 1))
done

#average of upload/download speeds values (even and odd positions)
upload_rate_avg=$(echo "scale=6; $upload_sum / $upload_count" | bc)
download_rate_avg=$(echo "scale=6; $download_sum / $download_count" | bc)

#from the datasheet (look above)
max_download_power=0.55 #W
max_upload_power=1.029 #W

#from the datasheet (look above)
max_download_rate=150500 #KBps
max_upload_rate=152500 #KBps

upload_PID_power=$(echo "scale=10; $max_upload_power*($upload_rate_avg / $max_upload_rate)" | bc)
download_PID_power=$(echo "scale=10; $max_download_power*($download_rate_avg / $max_download_rate)" | bc)

total_PID_power=$(echo "scale=10; $upload_PID_power + $download_PID_power" | bc)
total_PID_energy=$(echo "scale=10; $total_PID_power*$total_time" | bc)


echo ****NIC ePerf for PID $pid***** >> "$chemin/NIC-$nom.txt"
echo time_S: $total_time >> "$chemin/NIC-$nom.txt"
echo avgPower_W: $total_PID_power >> "$chemin/NIC-$nom.txt"
echo energy_J: $total_PID_energy >> "$chemin/NIC-$nom.txt"


rm -f "nethogs-$pid.log"
