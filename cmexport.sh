#!/bin/bash

#set loop echo time
loop_time=1

tag_cpu="%Cpu\(s\):"
tag_mem="KiB Mem :"

tag_cpu_id="id"
tag_mem_total="total"
tag_mem_used="used"

while true
do
{
  print=$(date "+%Y-%m-%d %H:%M:%S")
  top -b -n 1 > top_temp
  cat top_temp | while read line
   do
   {
    if [[ $line =~ $tag_cpu ]]
    then
      cpustr=${line#*$tag_cpu}
      #split with ','  get id
      cpu_id=$(echo $cpustr | cut -d "," -f 4)
      #remove 'id'
      cpu=${cpu_id%%$tag_cpu_id*}
      #remove 'space'
      cpu=$(echo $cpu | sed s/[[:space:]]//g)
      cpuused_num=$(awk 'BEGIN{print 100.0-'$cpu'}')    

      print=${print}" CPU:"${cpuused_num}"% "
    elif [[ $line =~ $tag_mem ]]
    then
      memstr=${line#*$tag_mem}
      memtotal=$(echo $memstr | cut -d "," -f 1)
      memused=$(echo $memstr | cut -d "," -f 3)
      #get num
      memtotal=${memtotal%%$tag_mem_total*}
      memtotal=$(echo $memtotal | sed s/[[:space:]]//g)
      memused=${memused%%$tag_mem_used*}
      memused=$(echo $memused | sed s/[[:space:]]//g)
      let memtotal_num=$memtotal
      let memused_num=$memused
      mem_persent=$(awk 'BEGIN{printf("%.1f",'$memused_num'.0*100/'$memtotal_num')}')
      let memtotal_num_mb=$(($memtotal_num / 1024))
      let memused_num_mb=$(($memused_num / 1024))

      print=${print}" MEMORY:"${mem_persent}"% MEMORY USED:"${memused_num_mb}"MB MEMORY TOTAL:"${memtotal_num_mb}"MB "
      echo $print
      echo $print >> report.log
    fi
  }
  done
  sleep $loop_time
}
done

