#!/bin/ksh

# The purpose of this utility is to collect detailed kernel data required for determining
# a computer's workload requirements. This tool will run for 72 hours from when it is
# launched. We expect that you are running the tool on a Fedora 7 or later kernel.
# DO NOT use this tool on a non-Fedora kernel or on a Fedora kernel that is older
# than version 7. Examples of Fedora kernels include Redhat and Oracle enterprise
# Linux.

# LICENSE REQUIREMENTS
# ====================
# The repository is open to the community and is considered open source under the
# GNU General Public License Agreement. The programs contained herein are free software;
# you can redistribute it and/or modify them under the terms of the GNU General Public
# License as published by the Free Software Foundation; either version 2 of the License,
# or (at your option) any later version.

# NO WARRANTEE
# ============
# This program is distributed in the hope that it will be useful,         #
# but WITHOUT ANY WARRANTY; without even the implied warranty of          #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
# GNU General Public License for more details. 

# OTHER SYSTEM requirements
# 1. ksh must be installed.
# 2. sysstat must be installed.
# 3. tar must be installed.
# 4. gzip must be installed.

# WHERE TO PLACE THIS UTILITY AND WHAT FILE PERMISSIONS TO SET
# 1. The file should be copied to /usr/local/bin/
# 2. The file ownership should be set to root:root
# 3. The file permissions should be set to 750

# WHEN TO RUN THIS UTILITY
# This utility should be started on a Monday, Tuesday, or Wednesday morning. It must not 
# be started any other day of the week unless your cloud professional has directed
# otherwise.

# HOW TO RUN THIS UTILITY
# You should call this script and background it. You can do this with the nohup utility.
# If you use nohup, you will get no output to stdout or stderror. We prefer that
# you run the tool with a redirect to a text file in /tmp. This way, you'll see if
# anything has gone wrong when running it. When it launches, a directory in /tmp
# called perfdata.[datestamp] will be created. Do not delete this directory as it
# contains your system's performance data.

# EXAMPLE FOR RUNNING THIS UTILITY
# /usr/local/bin/collect_perf_data.ksh /tmp/collect_perf_data.log 2>&1 &

# WHAT TO DO WHEN THIS UTILITY COMPLETES ITS RUN
# When completed, the tool will tar up the performance files and then compress the tar
# file with gzip. The performance data directory previously created is removed. Please
# upload the gzip file to the project folder for further data analysis by a cloud
# professional.


echo ""
echo ""

iterations=43200
interval=6
date=`date +%d%m%y%H%M`
out_dir="/tmp/perfdatta_"$date

echo ""
echo "Checking system requirements......"

# check to see if sysstat rpm is installed
check_for_sysstat=`rpm -qa | grep sysstat | wc -l`
if [ $check_for_sysstat -ne 1 ]; then
	echo "This script requires that the sysstat tools be installed"
	echo "Please install as root with 'yum install sysstat -y'"
	exit 9
fi

# check for other package requirements
if [ ! -f /bin/tar ]; then
	echo "This script requires the tar utility to be installed in order to run"
	echo "Please check your system and try again."
	exit 9
fi
if [ ! -f /bin/gzip ]; then
	echo "This script requires the gzip utility to be installed in order to run"
        echo "Please check your system and try again."
        exit 9
fi

if [ -d "$out_dir" ]; then
	echo "Directory Exists"
else
	mkdir $out_dir
fi

# start collecting stats
echo "Starting the utilities vmstat and iostat for " iterations " iterations of " interval "second aggregate intervals......"
vmstat $interval $iterations > $out_dir/vmstat.$date.txt &
iostat -x $interval $iterations > $out_dir/iostat$date.txt &

# get CPU info
cat /proc/cpuinfo > $out_dir/cpuinfo.$date.txt

# enter a while loop and collect memory and other stats
echo "Entering the while loop for collection of memory and swap stats......"
echo 
counter=0
while [ $counter -lt $iterations ]; do
	sum=$((counter))
	echo "Running data collection iteration " $sum " of " $iterations " iterations."
	echo '------------' >> $out_dir/meminfo.$date.txt
	echo "iteration " $sum >> $out_dir/meminfo.$date.txt
	cat /proc/meminfo | grep MemTotal 	>> $out_dir/meminfo.$date.txt
	cat /proc/meminfo | grep MemFree  	>> $out_dir/meminfo.$date.txt
	cat /proc/meminfo | grep MemAvailable  	>> $out_dir/meminfo.$date.txt
	cat /proc/meminfo | grep SwapTotal	>> $out_dir/meminfo.$date.txt
	cat /proc/meminfo | grep SwapFree	>> $out_dir/meminfo.$date.txt

	counter=$counter+1
	sleep $interval
done

# now tar & compress the files  & housekeeping
tar cvf /tmp/perfdata.$date.tar $out_dir
gzip /tmp/perfdata.$date.tar
rm -Rf $out_dir
if [ -f /tmp/perfdata.$date.tar ]; then
	rm -f /tmp/perfdata.$date.tar
fi

echo "Data collection script comleted. Please upload the file " /tmp/perfdata.$date.tar".gz to the file google share"
echo "you were provided with."