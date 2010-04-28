From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 28 Apr 2010 17:46:36 -0000
Subject: LVM2/test t-mirror-lvconvert.sh
Message-ID: <20100428174636.19043.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-04-28 17:46:35

Modified files:
	test           : t-mirror-lvconvert.sh 

Log message:
	Test all combinations of mirror conversion, both while the LV
	is active and while it is in-active.
	
	+for i in $(seq 0 4); do
	+       for j in $(seq 0 4); do
	+               for k in core disk mirrored; do
	+                       for l in core disk mirrored; do
	
	The testing code still needs some improvement.  I'd like to add
	the ability to test specifying the PVs to be added/removed during
	a convert.  It will also be important to test partial PV
	specification during down converts (i.e. request to remove more
	mirror images than we have provided PVs for).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/test/t-mirror-lvconvert.sh	2010/04/22 15:39:40	1.26
+++ LVM2/test/t-mirror-lvconvert.sh	2010/04/28 17:46:34	1.27
@@ -142,6 +142,269 @@
     "$@" && exit 1 || :;
 }
 
+# ---------------------------------------------------------------------
+# Main repeating test function
+
+log_name_to_count()
+{
+	if [ $1 == "mirrored" ]; then
+		echo 2
+	elif [ $1 == "disk" ]; then
+		echo 1
+	else
+		echo 0
+	fi
+}
+
+#
+# FIXME: For test_[up|down]convert, I'd still like to be able
+# to specifiy devices - especially if I can do partial PV
+# specification for down-converts.  It may even be wise to
+# do one round through these tests without specifying the PVs
+# to use and one round where we do.
+#
+
+#
+# test_upconvert
+#   start_mirror_count:  The '-m' argument to create with
+#   start_log_type: core|disk|mirrored
+#   final_mirror_count: The '-m' argument to convert to
+#   final_log_type: core|disk|mirrored
+#   active: Whether the LV should be active when the convert happens
+#
+# Exmaple: Convert 2-way disk-log mirror to
+#          3-way disk-log mirror while not active
+# -> test_upconvert 1 disk 2 disk 0
+test_upconvert()
+{
+	local start_count=$1
+	local start_count_p1=$(($start_count + 1))
+	local start_log_type=$2
+	local finish_count=$3
+	local finish_count_p1=$(($finish_count + 1))
+	local finish_log_type=$4
+	local dev_array=($dev1 $dev2 $dev3 $dev4 $dev5)
+	local create_devs=""
+	local convert_devs=""
+	local log_devs=""
+	local start_log_count
+	local finish_log_count
+	local max_log_count
+	local alloc=""
+	local active=true
+	local i
+
+	if [ $start_log_type == "disk" ] &&
+		[ $finish_log_type == "mirrored" ]; then
+		echo "FIXME:  disk -> mirrored log conversion not yet supported by LVM"
+		return 0
+	fi
+
+	if [ $5 -eq 0 ]; then
+		active=false
+	fi
+
+	# Do we have enough devices for the mirror images?
+	if [ $finish_count_p1 -gt ${#dev_array[@]} ]; then
+		echo "Action requires too many devices"
+		return 1
+	fi
+
+	start_log_count=`log_name_to_count $start_log_type`
+	finish_log_count=`log_name_to_count $finish_log_type`
+	if [ $finish_log_count -gt $start_log_count ]; then
+		max_log_count=$finish_log_count
+	else
+		max_log_count=$start_log_count
+	fi
+
+	# First group of devs for create
+#	for i in $(seq 0 $start_count); do
+#		create_devs="$create_devs ${dev_array[$i]}"
+#	done
+
+	# Second group of devs for convert
+#	for i in $(seq $start_count_p1 $finish_count); do
+#		convert_devs="$convert_devs ${dev_array[$i]}"
+#	done
+
+	# Third (or overlapping) group of devs for log
+#	for i in $(seq $((${#dev_array[@]} - $max_log_count)) $((${#dev_array[@]} - 1))); do
+#		if [ $i -gt $finish_count ]; then
+#			log_devs="$log_devs ${dev_array[$i]}:0"
+#		else
+#			log_devs="$log_devs ${dev_array[$i]}"			
+#		fi
+#	done
+
+	prepare_lvs_
+	if [ $start_count -gt 0 ]; then
+		# Are there extra devices for the log or do we overlap
+		if [ $(($start_count_p1 + $start_log_count)) -gt ${#dev_array[@]} ]; then
+			alloc="--alloc anywhere"
+		fi
+
+		lvcreate -l2 -m $start_count --mirrorlog $start_log_type \
+			-n $lv1 $vg $alloc $create_devs $log_devs || return 1
+		check_mirror_count_ $vg/$lv1 $start_count_p1
+		# FIXME: check mirror log
+	else
+		lvcreate -l15 -n $lv1 $vg $create_devs || return 1
+	fi
+
+	lvs -a -o name,copy_percent,devices $vg
+	if ! $active; then
+		lvchange -an $vg/$lv1 || return 1
+	fi
+
+	# Are there extra devices for the log or do we overlap
+	if [ $(($finish_count_p1 + $finish_log_count)) -gt ${#dev_array[@]} ]; then
+		alloc="--alloc anywhere"
+	fi
+	echo y | lvconvert -m $finish_count --mirrorlog $finish_log_type \
+		$vg/$lv1 $alloc $convert_devs $log_devs || return 1
+
+	if ! $active; then
+		lvchange -ay $vg/$lv1 || return 1
+	fi
+
+	wait_conversion_ $vg/$lv1
+	lvs -a -o name,copy_percent,devices $vg
+	check_no_tmplvs_ $vg/$lv1
+	check_mirror_count_ $vg/$lv1 $finish_count_p1
+	mimages_are_redundant_ $vg $lv1
+	check_and_cleanup_lvs_
+}
+
+#
+# test_downconvert
+#   start_mirror_count:  The '-m' argument to create with
+#   start_log_type: core|disk|mirrored
+#   final_mirror_count: The '-m' argument to convert to
+#   final_log_type: core|disk|mirrored
+#   active: Whether the LV should be active when the convert happens
+#
+# Exmaple: Convert 3-way disk-log mirror to
+#          2-way disk-log mirror while not active
+# -> test_downconvert 2 disk 3 disk 0
+test_downconvert()
+{
+	local start_count=$1
+	local start_count_p1=$(($start_count + 1))
+	local start_log_type=$2
+	local finish_count=$3
+	local finish_count_p1=$(($finish_count + 1))
+	local finish_log_type=$4
+	local dev_array=($dev1 $dev2 $dev3 $dev4 $dev5)
+	local create_devs=""
+	local convert_devs=""
+	local log_devs=""
+	local start_log_count
+	local finish_log_count
+	local max_log_count
+	local alloc=""
+	local active=true
+	local i
+
+	if [ $start_log_type == "disk" ] &&
+		[ $finish_log_type == "mirrored" ]; then
+		echo "FIXME:  disk -> mirrored log conversion not yet supported by LVM"
+		return 0
+	fi
+
+	if [ $5 -eq 0 ]; then
+		active=false
+	fi
+
+	# Do we have enough devices for the mirror images?
+	if [ $start_count_p1 -gt ${#dev_array[@]} ]; then
+		echo "Action requires too many devices"
+		return 1
+	fi
+
+	start_log_count=`log_name_to_count $start_log_type`
+	finish_log_count=`log_name_to_count $finish_log_type`
+	if [ $finish_log_count -gt $start_log_count ]; then
+		max_log_count=$finish_log_count
+	else
+		max_log_count=$start_log_count
+	fi
+
+	# First group of devs for create
+#	for i in $(seq 0 $start_count); do
+#		create_devs="$create_devs ${dev_array[$i]}"
+#	done
+
+	# Same devices for convert (because we are down-converting)
+#	for i in $(seq 0 $start_count); do
+#		convert_devs="$convert_devs ${dev_array[$i]}"
+#	done
+
+	# Third (or overlapping) group of devs for log creation
+#	for i in $(seq $((${#dev_array[@]} - $max_log_count)) $((${#dev_array[@]} - 1))); do
+#		if [ $i -gt $start_count ]; then
+#			log_devs="$log_devs ${dev_array[$i]}:0"
+#		else
+#			log_devs="$log_devs ${dev_array[$i]}"			
+#		fi
+#	done
+
+	prepare_lvs_
+	if [ $start_count -gt 0 ]; then
+		# Are there extra devices for the log or do we overlap
+		if [ $(($start_count_p1 + $start_log_count)) -gt ${#dev_array[@]} ]; then
+			alloc="--alloc anywhere"
+		fi
+
+		lvcreate -l2 -m $start_count --mirrorlog $start_log_type \
+			-n $lv1 $vg $alloc $create_devs $log_devs || return 1
+		check_mirror_count_ $vg/$lv1 $start_count_p1
+		# FIXME: check mirror log
+	else
+		lvcreate -l15 -n $lv1 $vg $create_devs || return 1
+	fi
+
+	lvs -a -o name,copy_percent,devices $vg
+	if ! $active; then
+		lvchange -an $vg/$lv1 || return 1
+	fi
+
+	# Are there extra devices for the log or do we overlap
+	if [ $(($finish_count_p1 + $finish_log_count)) -gt ${#dev_array[@]} ]; then
+		alloc="--alloc anywhere"
+	fi
+
+	echo y | lvconvert -m $finish_count --mirrorlog $finish_log_type \
+		$vg/$lv1 $alloc $convert_devs $log_devs || return 1
+
+	if ! $active; then
+		lvchange -ay $vg/$lv1 || return 1
+	fi
+
+	wait_conversion_ $vg/$lv1
+	lvs -a -o name,copy_percent,devices $vg
+	check_no_tmplvs_ $vg/$lv1
+	check_mirror_count_ $vg/$lv1 $finish_count_p1
+	mimages_are_redundant_ $vg $lv1
+	check_and_cleanup_lvs_
+}
+
+# test_convert
+#   start_image_count
+#   start_log_type
+#   finish_image_count
+#   finish_log_type
+test_convert()
+{
+	if [ $1 -lt $3 ]; then
+		test_upconvert $1 $2 $3 $4 0 || return 1
+		test_upconvert $1 $2 $3 $4 1 || return 1
+	else
+		test_downconvert $1 $2 $3 $4 0 || return 1
+		test_downconvert $1 $2 $3 $4 1 || return 1
+	fi
+}
+
 
 prepare_lvs_
 check_and_cleanup_lvs_
@@ -150,7 +413,38 @@
 # mirrored LV tests
 
 # ---
+# Test conversion combinations from linear <-> 4-way mirrors
+for i in $(seq 0 4); do
+	for j in $(seq 0 4); do
+		for k in core disk mirrored; do
+			for l in core disk mirrored; do
+				#############################################
+				echo "Testing mirror conversion -m$i/$k -> -m$j/$l"
+				test_convert $i $k $j $l
+				#############################################
+			done
+		done
+	done
+done
+
+# ---
 # add mirror to mirror
+prepare_lvs_
+lvs -a -o+devices $vg
+lvcreate -l15 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvs -a -o+devices $vg
+check_mirror_count_ $vg/$lv1 2
+check_mirror_log_ $vg/$lv1
+lvconvert -m+1 -i 20 -b $vg/$lv1 $dev4
+# Next convert should fail b/c we can't have 2 at once
+not lvconvert -m+1 -b $vg/$lv1 $dev5
+wait_conversion_ $vg/$lv1
+lvs -a -o+devices $vg
+check_no_tmplvs_ $vg/$lv1
+check_mirror_count_ $vg/$lv1 3
+mimages_are_redundant_ $vg $lv1
+mirrorlog_is_on_ $vg/$lv1 $dev3
+check_and_cleanup_lvs_
 
 # add 1 mirror
 prepare_lvs_
@@ -471,4 +765,3 @@
 mimages_are_redundant_ $vg $lv1 
 mirrorlog_is_on_ $vg/$lv1 $dev3 
 check_and_cleanup_lvs_
-


