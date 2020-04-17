unit="MB"
RSS="^Rss:"
PSS="^Pss:"
PRIVATE="^Private"
SHARED="^Shared"

##查询某个用户总共占用的内存
function user_mem_info() {
  user=$1
  rss=`ps -u ${user} o pid=| awk '{gsub(" ","",$0);print $0}'| xargs -I {} cat /proc/{}/smaps | grep ${RSS} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  pss=`ps -u ${user} o pid=| awk '{gsub(" ","",$0);print $0}'| xargs -I {} cat /proc/{}/smaps | grep ${PSS} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  shared=`ps -u ${user} o pid=| awk '{gsub(" ","",$0);print $0}'| xargs -I {} cat /proc/{}/smaps | grep ${SHARED} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  private=`ps -u ${user} o pid=| awk '{gsub(" ","",$0);print $0}'| xargs -I {} cat /proc/{}/smaps | grep ${PRIVATE} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  real=$((${pss}+${private}))
  echo "real used mem: ${real}${unit}, detail:pss:${pss}${unit} rss:${rss}${unit} shared:${shared}${unit} private:${private}${unit}"
}

##查询某个父进程及其子进程占用的内存
function ppid_mem_info() {
  ppid=$1
  rss=`(ps --ppid ${ppid} && echo ${ppid}) | awk '{if(NR>1) print $1}' | xargs -I {} cat /proc/{}/smaps | grep ${RSS} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  pss=`(ps --ppid ${ppid} && echo ${ppid}) | awk '{if(NR>1) print $1}' | xargs -I {} cat /proc/{}/smaps | grep ${PSS} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  shared=`(ps --ppid ${ppid} && echo ${ppid}) | awk '{if(NR>1) print $1}' | xargs -I {} cat /proc/{}/smaps | grep ${SHARED} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  private=`(ps --ppid ${ppid} && echo ${ppid}) | awk '{if(NR>1) print $1}' | xargs -I {} cat /proc/{}/smaps | grep ${PRIVATE} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  real=$((${pss}+${private}))
  echo "real used mem: ${real}${unit}, detail:pss:${pss}${unit} rss:${rss}${unit} shared:${shared}${unit} private:${private}${unit}"
}

##查询某个进程占用的内存
function pid_mem_info() {
  pid=$1
  private_pid_mem_pss ${pid} >> /dev/null
 # pss=$?
  private_pid_mem_rss ${pid} >> /dev/null
 # rss=$?
  private_pid_mem_shared ${pid} >> /dev/null
 # shared=$?
  private_pid_mem_private ${pid} >> /dev/null
 # private=$?

  real=$((${pss}+${private}))
  echo "real used mem: ${real}${unit}, detail:pss:${pss}${unit} rss:${rss}${unit} shared:${shared}${unit} private:${private}${unit}"
}

##查询占用内存最大的系统进程
function high_mem_process() {
  count=$1
  [ -z "${count}" ] && count=10
  ps axo rss,comm,pid | awk '{ proc_list[$2]++; proc_list[$2 "," 1] += $1; } END { for (proc in proc_list) { printf("%d\t%s\n", proc_list[proc "," 1],proc); }}' | sort -n | tail -n ${count} | sort -rn | awk '{$1/=1024;printf "%.0fMB\t",$1}{print $2}'
}

##查询占用磁盘最大的文件目录
function disk_check() {
  dir=$1
  count=$2
  [ -z "${dir}" ] && dir=/
  [ -z "${count}" ] && count=10
  du -m ${dir} | sort -rn | awk '{print $1 "MB  " $2}' | head -${count}
}

##打印脚本使用功能方式
function usage() {
  echo "使用手册"
  echo "  1.查询占用磁盘最大的文件目录: -d|--disk dir count, example: -d /root 5, desc:查询root目录占用磁盘空间排名前5的路径"
  echo "  2.查询占用内存最大的系统进程: -s|--system count, example: -s 5, desc:查询占用系统内存前5的进程"
  echo "  3.查询某个父进程及其子进程占用的内存: -ppm pid, example: -ppm 5678, desc:查询父进程5678及其子进程占用的内存"
  echo "  4.查询某个用户总共占用的内存: -um username, example: -um root, desc:查询root用户总共占用的内存"
  echo "  5.查询某个进程占用的内存: -pm pid, example: -pm 5678, desc:查询进程5678占用的内存"
}

##主函数
function main() {
  case $1 in
    -h|--help)
      usage;
      ;;
    -d|--disk)
      disk_check "$2" "$3"
      ;;
    -s|--system)
      high_mem_process "$2" "$3"
	  ;;
    -ppm)
      ppid_mem_info "$2" "$3"
	  ;;
    -um)
      user_mem_info "$2" "$3"
	  ;;
    -pm)
      pid_mem_info "$2" "$3"
	  ;;
    *)
      usage;
      ;;
  esac
}


function private_pid_mem_shared() {
  pid=$1
  shared=`cat /proc/${pid}/smaps | grep ${SHARED} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  echo "shared:${shared}MB"
  return ${shared}
}

function private_pid_mem_private() {
  pid=$1
  private=`cat /proc/${pid}/smaps | grep ${PRIVATE} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  echo "private:${private}MB"
  return ${private}
}


function private_pid_mem_pss() {
  pid=$1
  pss=`cat /proc/${pid}/smaps | grep ${PSS} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  echo "pss:${pss}MB"
  return ${pss}
}

function private_pid_mem_rss() {
  pid=$1
  rss=`cat /proc/${pid}/smaps | grep ${RSS} | awk '{SUM+=$2} END{print int(SUM/1024)}'`
  echo "rss:${rss}MB"
  return ${rss}
}

main "$@"

