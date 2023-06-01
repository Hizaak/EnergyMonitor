#!/bin/bash

# Run perf stat and capture the output in a file (not possible to assign to a variable for the moment..and we have a deadline :')

pid="$1"
chemin="$2"
nom="$3"

#perf exits when the PID is dead
#OK, I am doing this because I need to change the character encoding of the perf output file. I plan to upgrade it later.
#TODO -> use only vars
perf stat -e mem-stores,mem-loads -p $1 -o "tmpRam2-$pid.txt" >/dev/null 2>&1
iconv -f UTF-8 -t US-ASCII//IGNORE -c "tmpRam2-$pid.txt" > "tmpRam-$pid.txt"


# Extract the counter values using awk and save them to variables
mem_stores=$(awk '/mem-stores/ {print $1}' "tmpRam-$pid.txt")
mem_loads=$(awk '/mem-loads/ {print $1}' "tmpRam-$pid.txt")
total_time=$(awk '/seconds time elapsed/ {print $1}' "tmpRam-$pid.txt" | sed 's/\,/./g')

echo $total_time

#The Background energy consumption
ram_bk=$(echo "$total_time * 1.56" | bc) #to dismiss?? -> Is this power really related to the process?
ram_act=$(echo "scale=10; ($mem_loads * 6.6) + ($mem_stores * 8.7)" | bc) #nanoJoules
ram_act=$(echo "scale=10; ($ram_act / 1000000000)" | bc) #->Joules
ram_energy=$(echo "scale=10; $ram_bk + $ram_act" | bc)
ram_watts_AVG=$(echo "scale=10; $ram_energy / $total_time" | bc)

echo ****RAM ePerf for PID $pid***** >> "$chemin/RAM-$nom.txt"
echo time_S: $total_time >> "$chemin/RAM-$nom.txt"
echo avgPower_W: $ram_watts_AVG >> "$chemin/RAM-$nom.txt"
echo energy_J: $ram_energy >> "$chemin/RAM-$nom.txt"


#rm -f "tmpRam-$pid.txt" && rm -f "tmpRam2-$pid.txt"
