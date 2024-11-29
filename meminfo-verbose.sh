#!/bin/bash
# (C) Marian Hanzel
# https://access.redhat.com/solutions/406773

export LC_ALL="C"
MEMINFO=$(cat /proc/meminfo)

_calculate () {
DOTHIS=$@
printf "%.3f" $(echo "scale=3; ${DOTHIS}" | bc -l)
}


_get_info () {
echo "${MEMINFO}" | grep -q -w ${1}
if [ $? -eq 0 ];then
NUMBER=$(echo "${MEMINFO}" | grep -w ${1} | awk '{print $2}')
VALUE=$(echo "${MEMINFO}" | grep -w ${1} | awk '{print $3}')
case ${VALUE} in
 kB)
echo $(_calculate $NUMBER/1024/1024)
;;
 MB)
echo $(_count $NUMBER/1024)
;;
 *)
echo ${NUMBER}
;;
esac
fi

}

_high_level_statistics() {
cat << 'EOF'
MemTotal: Total usable memory
MemFree: The amount of physical memory not used by the system
Buffers: Memory in buffer cache, so relatively temporary storage for raw disk blocks. This shouldn't get very large.
Cached: Memory in the pagecache (Diskcache and Shared Memory)
SwapCached: Memory that is present within main memory, but also in the swapfile. (If memory is needed this area does not need  to be swapped out AGAIN because it is already in the swapfile. This saves I/O and increases performance if machine runs short on memory.)
MemAvailable: An estimate of how much memory is available for starting new applications, without swapping. 
EOF
}

_detailed_level_statistics() {
cat << 'EOF'
Active: Memory that has been used more recently and usually not swapped out or reclaimed
Inactive: Memory that has not been used recently and can be swapped out or reclaimed
Active(anon): Anonymous memory that has been used more recently and usually not swapped out
Inactive(anon): Anonymous memory that has not been used recently and can be swapped out
Active(file): Pagecache memory that has been used more recently and usually not reclaimed until needed
Inactive(file): Pagecache memory that can be reclaimed without huge performance impact
Unevictable: Unevictable pages can't be swapped out for a variety of reasons
Mlocked: Pages locked to memory using the mlock() system call. Mlocked pages are also Unevictable.
EOF
}

_memory_statistics() {
cat << 'EOF'
SwapTotal: Total swap space available
SwapFree: The remaining swap space available
Dirty: Memory waiting to be written back to disk
Writeback: Memory which is actively being written back to disk
AnonPages: Non-file backed pages mapped into userspace page tables
Mapped: Files which have been mmaped, such as libraries
Slab: In-kernel data structures cache
PageTables: Amount of memory dedicated to the lowest level of page tables. This can increase to a high value if a lot of processes are attached to the same shared memory segment.
NFS_Unstable: NFS pages sent to the server, but not yet commited to the storage
Bounce: Memory used for block device bounce buffers
CommitLimit: Based on the overcommit ratio (vm.overcommit_ratio), this is the total amount of memory currently available to be allocated on the system. This limit is only adhered to if strict overcommit accounting is enabled (mode 2 in vm.overcommit_memory).
Committed_AS: The amount of memory presently allocated on the system. The committed memory is a sum of all of the memory which has been allocated by processes, even if it has not been "used" by them as of yet.
VmallocTotal: total size of vmalloc memory area
VmallocUsed: amount of vmalloc area which is used
VmallocChunk: largest contiguous block of vmalloc area which is free
HugePages_Total: Number of hugepages being allocated by the kernel (Defined with vm.nr_hugepages)
HugePages_Free: The number of hugepages not being allocated by a process
HugePages_Rsvd: The number of hugepages for which a commitment to allocate from the pool has been made, but no allocation has yet been made.
Hugepagesize: The size of a hugepage (usually 2MB on an Intel based system)
Shmem: Total used shared memory (shared between several processes, thus including RAM disks, SYS-V-IPC and BSD like SHMEM)
SReclaimable: The part of the Slab that might be reclaimed (such as caches)
SUnreclaim: The part of the Slab that can't be reclaimed under memory pressure
KernelStack: The memory the kernel stack uses. This is not reclaimable.
WritebackTmp: Memory used by FUSE for temporary writeback buffers
HardwareCorrupted: The amount of RAM the kernel identified as corrupted / not working
AnonHugePages: Non-file backed huge pages mapped into userspace page tables
HugePages_Surp: The number of hugepages in the pool above the value in vm.nr_hugepages. The maximum number of surplus hugepages is controlled by vm.nr_overcommit_hugepages.
DirectMap4k: The amount of memory being mapped to standard 4k pages
DirectMap2M: The amount of memory being mapped to hugepages (usually 2MB in size)
DirectMap1G. The amount of memory being mapped to hugepages (usually 1GB in size)
EOF
}

#echo "Memory Total    :" $(_get_info MemTotal:)
#echo "Memory used     :" $(_calculate $(_get_info MemTotal:)-$(_get_info MemFree:)-$(_get_info Buffers:)-$(_get_info Cached:)-$(_get_info Slab:))
#echo "Memory Free     :" $(_get_info MemFree:)
#echo "Memory Shared   :" $(_get_info Shmem:)
#echo "Mem buff/cache  :" $(_calculate $(_get_info Buffers:)+$(_get_info Cached:)+$(_get_info Slab:))
#echo "Memory Available:" $(_get_info MemAvailable:)
#echo "Swap Total      :" $(_get_info SwapTotal:)
#echo "Swap used       :" $(_calculate $(_get_info Buffers:)+$(_get_info Cached:)+$(_get_info Slab:))
#echo "Swap free       :" $(_get_info SwapFree:)
#
#
#echo "------------------------"
#echo "Memory that has not been used recently and can be swapped out or reclaimed" $(_get_info Inactive:)
#echo "Unevictable pages can't be swapped out for a variety of reasons" $(_get_info Unevictable:)
#echo "Dirty: Memory waiting to be written back to disk" $(_get_info Dirty:)

_termsize() {
WIDTH=$(stty size| awk '{print $2}')
echo $WIDTH
}

horizontal_line () {
WIDTH=$(stty size| awk '{print $2}')
x=$(printf "%*s" ${WIDTH} "")
echo "${x// /${1}}"
}

_show_info() {
${1} | while read PARAM TEXT
do
C=90
#A=$(/usr/bin/tput cols)
#A=$((A-10))
#printf "%8.2fGB %-80s\n" "$(_get_info ${PARAM})" "$(echo ${TEXT} | sed -e 's/\(.\)/\1           /'60 -e 's/\(.\)/\1           /'120 -e 's/\(.\)/\1           /'180 -e 's/\(.\)/\1           /'240| fold -w 60)"  
#printf "%8.2fGB %-80s\n" "$(_get_info ${PARAM})" "$(echo ${TEXT} | sed -e 's/\(.\)/\1\'"$B"'/'${A} -e 's/\(.\)/\1'"$B"'/'$(($A*2)) -e 's/\(.\)/\1'"$B"'/'$(($A*3)) -e 's/\(.\)/\1'"$B"'/'$(($A*4))| fold -w ${A})"  
B=$(printf "%8.2s   \n" " ")
#    printf "%8.2fGB %s\n" "$(_get_info ${PARAM})" "$(echo ${TEXT} | sed  '-es/\(.\)/\1\'"$B"'/'{90..320..90})"  
    printf "%8.2fGB %s\n" "$(_get_info ${PARAM})" "$(echo ${TEXT} | sed  '-es/\(.\)/\1\'"$B"'/'{90..320..90} | fold -w ${C})"  
done
}

horizontal_line - 
echo "High Level statistics"
horizontal_line - 
_show_info _high_level_statistics
horizontal_line -
echo "Detailed level statistics"
horizontal_line -
_show_info _detailed_level_statistics
horizontal_line -
echo "Memory statistics"
horizontal_line -
_show_info _memory_statistics
