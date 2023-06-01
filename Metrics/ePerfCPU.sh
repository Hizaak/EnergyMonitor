#!/bin/bash

#to see a "by thread" use
# ps -L -p "$pid" -o psr,pcpu --no-headers | awk '{a[$1]+=$2} END {for (i in a) print i, a[i]}' | sort -n

#also: #cpu_voltage=$(rdmsr -p 0 0x198 -f 16:7 | awk '{print $1 / 128}')...see the bitfield...I'm not really sure it works for the intel I7 6Gen series


pid="$1"
chemin="$2"
nom="$3"


# Get the start time
start=$(date +%s)


cpu_freq_tdp=$(echo "$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq) / 1000000" | bc -l)
#cpu_tdp=$(bash -c 'echo $(( (0x$(rdmsr -p0 0x648) & 0x7f) * 125 / 1000 ))')
cpu_tdp=45
cpu_voltage_tdp=1.5 #1.5 from datasheet...I don't remember how to obtain it from rdmsr
cpu_capacitance=$(echo "scale=20; (0.7 * $cpu_tdp) / ($cpu_freq_tdp*$cpu_voltage_tdp*$cpu_voltage_tdp)" | bc)

accumulated_PID_power=0.0
counter=0

while true
do

  if [ ! -e "/proc/$1/stat" ]; then #the same trick (and text XD ) as powerJoular for exiting the script when the PID dies
    echo "/proc/$1/stat/"
    break
  fi

  total_PID_power=$(ps -L -p "$pid" -o psr,pcpu --no-headers | awk -v cap="$cpu_capacitance" -v freq_tdp="$cpu_freq_tdp" '{
    a[$1]+=$2
  } END {
    total_PID_power = 0
    for (i in a) {
      cmd = "bash -c '\''echo \"scale=2; $(sudo rdmsr 0x198 -u --bitfield 47:32)/8192\" | bc'\''"
      cmd | getline cpu_voltage
      close(cmd)
      freq_pid = (a[i] * freq_tdp) / 100
      cpu_power = cap * freq_pid * cpu_voltage * cpu_voltage
      total_PID_power += cpu_power
      #printf "Core: %d freq: %.2f cap: %.20f pow %.2f tpow %.2f\n", i, freq_pid, cap, cpu_power, total_PID_power
    }
    printf "%.2f\n", total_PID_power
  }')

  total_PID_power=$(echo "$total_PID_power" | tr ',' '.')
  accumulated_PID_power=$(echo "scale=10; $accumulated_PID_power + $total_PID_power" | bc -l)
  counter=$((counter + 1))

  # Get the end time
  end=$(date +%s) # Here in order to avoid the next second

  sleep 1
done



total_time=$((end - start))
cpu_watts_AVG=$(echo "scale=10; $accumulated_PID_power / $counter" | bc -l)
cpu_energy=$(echo "scale=10; $cpu_watts_AVG * $total_time" | bc -l)

echo ****CPU ePerf for PID $pid***** >> "$chemin/CPU-$nom.txt"
echo time_S: $total_time >> "$chemin/CPU-$nom.txt"
echo avgPower_W: $cpu_watts_AVG >> "$chemin/CPU-$nom.txt"
echo energy_J: $cpu_energy >> "$chemin/CPU-$nom.txt"

