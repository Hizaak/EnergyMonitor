#!/bin/bash

pid="$1"
chemin="$2"
nom="$3"

#Storage device model for experiments: Samsung MZVLW512HMJP-00000
#link for datasheet https://gzhls.at/blob/ldb/9/4/b/1/a687f4c084d46decabf67b95b29d4648d1ac.pdf
#pidstat -d gives I/O stats...among other stuff


count=0

# Get the start time
start=$(date +%s)

#cleaning...
rm -f pidstat.log

#I do this because pidstat need the monitor way to get real info
pidstat -d -h -p $pid 1 > pidstat.log
input_file="pidstat.log"

total_kb_rd=0
total_kb_wr=0
count=0
line_number=0



while read -r line; do

    line_number=$((line_number + 1))
   # Skip the first three lines
    if [[ $line_number -le 3 ]]; then
        continue
    fi


    if [[ ! "$line" =~ ^# ]]; then
        # Replace commas with points
        line=$(echo "$line" | tr ',' '.')

        kb_rd=$(echo "$line" | awk '{print $4}')
        kb_wr=$(echo "$line" | awk '{print $5}')
        echo kb_wr $kb_wr
        total_kb_rd=$(awk "BEGIN {print $total_kb_rd + $kb_rd}")
        total_kb_wr=$(awk "BEGIN {print $total_kb_wr + $kb_wr}")
        count=$((count + 1))
    fi
done < "$input_file"

# Get the end time
end=$(date +%s)
total_time=$((end - start))

average_read_rate=$(echo "scale=2; $total_kb_rd / $count" | bc)
average_write_rate=$(echo "scale=2; $total_kb_wr / $count" | bc)

echo "Average kB_rd/s: $average_read_rate"
echo "Average kB_wr/s: $average_write_rate"


write_power=6.1 #W -> from the datasheet
read_power=5.1 #W -> from the datasheet

write_max_rate=1600000 #MBs (look at the datasheet) to KBs
read_max_rate=2800000 #MBs (look at the datasheet) to KBs


write_PID_power=$(echo "scale=10; $write_power*($average_write_rate/$write_max_rate)" | bc)
read_PID_power=$(echo "scale=10; $read_power*($average_read_rate/$read_max_rate)" | bc)

echo $read_PID_power
echo $write_PID_power

total_PID_power=$(echo "scale=10; $write_PID_power+$read_PID_power" | bc)
total_PID_energy=$(echo "scale=10; $total_PID_power*$total_time" | bc)


echo ****SD ePerf for PID $pid*****
echo time_S: $total_time
echo avgPower_W: $total_PID_power
echo energy_J: $total_PID_energy


echo ****SD ePerf for PID $pid***** >> "$chemin/SD-$nom.txt"
echo time_S: $total_time >> "$chemin/SD-$nom.txt"
echo avgPower_W: $total_PID_power >> "$chemin/SD-$nom.txt"
echo energy_J: $total_PID_energy >> "$chemin/SD-$nom.txt"
