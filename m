From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 May 2010 10:08:37 -0000
Subject: LVM2/test check.sh t-lvconvert-mirror.sh t-lvc ...
Message-ID: <20100512100837.3410.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-05-12 10:08:36

Modified files:
	test           : check.sh t-lvconvert-mirror.sh 
	                 t-lvcreate-mirror.sh t-vgcreate-usage.sh 
	                 test-utils.sh 
Added files:
	test           : t-lvconvert-mirror-basic.sh 
Removed files:
	test           : t-mirror-lvconvert.sh 

Log message:
	A fairly extensive refactor of the mirror testing code. The exhaustive
	lvconvert testing is now in its own test, t-lvconvert-mirror-basic ... it
	doesn't do anything fancy but it does run lvconvert through a lot of
	combinations.
	
	I have also merged the remaining t-mirror-lvconvert tests into
	t-lvconvert-mirror and abolished the former. The latter will be split again
	later into more thematic divisions. (The previous split was rather arbitrary,
	may I even say random...)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror-basic.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/check.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-mirror.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-mirror.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-vgcreate-usage.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-mirror-lvconvert.sh.diff?cvsroot=lvm2&r1=1.27&r2=NONE

/cvs/lvm2/LVM2/test/t-lvconvert-mirror-basic.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-mirror-basic.sh
+++ -	2010-05-12 10:08:36.393046000 +0000
@@ -0,0 +1,139 @@
+. ./test-utils.sh
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
+# FIXME: For test_[up|down]convert, I'd still like to be able
+# to specifiy devices - especially if I can do partial PV
+# specification for down-converts.  It may even be wise to
+# do one round through these tests without specifying the PVs
+# to use and one round where we do.
+
+# test_lvconvert
+#   start_mirror_count:  The '-m' argument to create with
+#   start_log_type: core|disk|mirrored
+#   final_mirror_count: The '-m' argument to convert to
+#   final_log_type: core|disk|mirrored
+#   active: Whether the LV should be active when the convert happens
+#
+# Exmaple: Convert 3-way disk-log mirror to
+#          2-way disk-log mirror while not active
+# -> test_lvconvert 2 disk 3 disk 0
+
+test_lvconvert()
+{
+	local start_count=$1
+	local start_count_p1=$(($start_count + 1))
+	local start_log_type=$2
+	local finish_count=$3
+	local finish_count_p1=$(($finish_count + 1))
+	local finish_log_type=$4
+	local dev_array=($dev1 $dev2 $dev3 $dev4 $dev5)
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
+	test "$5" = "active" && active=false
+	#test $finish_count -gt $start_count && up=true
+
+	# Do we have enough devices for the mirror images?
+	if [ $start_count_p1 -gt ${#dev_array[@]} ]; then
+		echo "Action requires too many devices"
+		return 1
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
+	prepare_vg 5
+
+	if [ $start_count -gt 0 ]; then
+		# Are there extra devices for the log or do we overlap
+		if [ $(($start_count_p1 + $start_log_count)) -gt ${#dev_array[@]} ]; then
+			alloc="--alloc anywhere"
+		fi
+
+		lvcreate -l2 -m $start_count --mirrorlog $start_log_type \
+			-n $lv1 $vg $alloc
+		check mirror_legs $vg $lv1 $start_count_p1
+		# FIXME: check mirror log
+	else
+		lvcreate -l2 -n $lv1 $vg
+	fi
+
+	lvs -a -o name,copy_percent,devices $vg
+	if ! $active; then
+		lvchange -an $vg/$lv1
+	fi
+
+	# Are there extra devices for the log or do we overlap
+	if [ $(($finish_count_p1 + $finish_log_count)) -gt ${#dev_array[@]} ]; then
+		alloc="--alloc anywhere"
+	fi
+
+	echo y | lvconvert -m $finish_count --mirrorlog $finish_log_type \
+		$vg/$lv1 $alloc
+
+	if ! $active; then
+		lvchange -ay $vg/$lv1
+	fi
+
+	check mirror_no_temporaries $vg $lv1
+	if [ "$finish_count_p1" -eq 1 ]; then
+		check linear $vg $lv1
+	else
+		if test -n "$alloc"; then
+			check mirror_nonredundant $vg $lv1
+		else
+			check mirror $vg $lv1
+		fi
+		check mirror_legs $vg $lv1 $finish_count_p1
+	fi
+}
+
+aux prepare_vg 5
+
+# Test conversion combinations from linear <-> 4-way mirrors
+for i in $(seq 0 4); do
+	for j in $(seq 0 4); do
+		for k in core disk mirrored; do
+			for l in core disk mirrored; do
+				if test "$i" -eq "$j" && test "$k" = "$l"; then continue; fi
+				: ----------------------------------------------------
+				: "Testing mirror conversion -m$i/$k -> -m$j/$l"
+				: ----------------------------------------------------
+				test_lvconvert $i $k $j $l 0
+				test_lvconvert $i $k $j $l 1
+			done
+		done
+	done
+done
+
--- LVM2/test/check.sh	2010/05/12 05:55:08	1.4
+++ LVM2/test/check.sh	2010/05/12 10:08:35	1.5
@@ -1,5 +1,18 @@
 #!/bin/bash
 
+# check.sh: assert various things about volumes
+
+# USAGE
+#  check linear VG LV
+#  check lv_on VG LV PV
+
+#  check mirror VG LV [LOGDEV|core]
+#  check mirror_nonredundant VG LV
+#  check mirror_legs VG LV N
+#  check mirror_images_on VG LV DEV [DEV...]
+
+# ...
+
 set -e -o pipefail
 
 lvl() {
@@ -15,7 +28,7 @@
   vg=$1
   lv=$vg/$2
 
-  lvs -a $vg
+  lvs -a $vg -o+devices
   for i in `lvdevices $lv`; do
 	  echo "# $i:"
 	  lvdevices $vg/$i | sort | uniq
@@ -31,23 +44,26 @@
 }
 
 mirror_images_on() {
-	lv=$1
+	vg=$1
+	lv=$2
+
+	shift 2
 
 	for i in `lvdevices $lv`; do
+		lv_on $vg $lv $1
 		shift
-		lv_on $lv $1
 	done
 }
 
 lv_on()
 {
-	lv="$1"
-	lvdevices $lv | grep -F "$2" || {
-		echo "LV $lv expected on $2 but is not:" >&2
+	lv="$1/$2"
+	lvdevices $lv | grep -F "$3" || {
+		echo "LV $lv expected on $3 but is not:" >&2
 		lvdevices $lv >&2
 		exit 1
 	}
-	test `lvdevices $lv | grep -vF "$2" | wc -l` -eq 0 || {
+	test `lvdevices $lv | grep -vF "$3" | wc -l` -eq 0 || {
 		echo "LV $lv contains unexpected devices:" >&2
 		lvdevices $lv >&2
 		exit 1
@@ -56,7 +72,14 @@
 
 mirror_log_on()
 {
-	lv_on "${1}_mlog" "$2"
+	vg="$1"
+	lv="$2"
+	where="$3"
+	if test "$where" = "core"; then
+		lvl -omirror_log "$vg/$lv" | not grep mlog
+	else
+		lv_on $vg "${lv}_mlog" "$where"
+	fi
 }
 
 lv_is_contiguous()
@@ -92,14 +115,18 @@
 }
 
 mirror() {
+	mirror_nonredundant "$@"
+	mirror_images_redundant "$1" "$2"
+}
+
+mirror_nonredundant() {
 	lv="$1/$2"
-	lvl -oattr "$lv" | grep "m" || {
+	lvs -oattr "$lv" | grep -q "^ *m.....$" || {
 		echo "$lv expected a mirror, but is not:"
-		lvl -a $lv
+		lvs -a $lv
 		exit 1
 	}
-	mirror_images_redundant "$1" "$2"
-	if test -n "$3"; then mirror_log_on "$lv" "$3"; fi
+	if test -n "$3"; then mirror_log_on "$1" "$2" "$3"; fi
 }
 
 mirror_legs() {
@@ -110,6 +137,17 @@
 	test "$expect" = "$real"
 }
 
+mirror_no_temporaries()
+{
+	vg=$1
+	lv=$2
+	lvl -oname $vg | grep $lv | not grep "tmp" || {
+		echo "$lv has temporary mirror images unexpectedly:"
+		lvl $vg | grep $lv
+		exit 1
+	}
+}
+
 linear() {
 	lv="$1/$2"
 	lvl -ostripes "$lv" | grep -q "1" || {
--- LVM2/test/t-lvconvert-mirror.sh	2010/05/12 06:09:22	1.5
+++ LVM2/test/t-lvconvert-mirror.sh	2010/05/12 10:08:35	1.6
@@ -10,15 +10,15 @@
 # Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 
 . ./test-utils.sh
-aux prepare_vg 5
 
 # convert from linear to 2-way mirror
+aux prepare_vg 5
 lvcreate -l2 -n $lv1 $vg $dev1
 lvconvert -i1 -m+1 $vg/$lv1 $dev2 $dev3:0-1
 check mirror $vg $lv1 $dev3
-lvremove -ff $vg
 
 # convert from 2-way mirror to linear
+aux prepare_vg 5
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
 lvconvert -m-1 $vg/$lv1
 check linear $vg $lv1
@@ -26,16 +26,18 @@
 # and now try removing a specific leg (bz453643)
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
 lvconvert -m0 $vg/$lv1 $dev2
-check lv_on $vg/$lv1 $dev1
+check lv_on $vg $lv1 $dev1
 lvremove -ff $vg
 
 # convert from disklog to corelog, active
+aux prepare_vg 5
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
 lvconvert -f --mirrorlog core $vg/$lv1
-check mirror $vg $lv1 ""
+check mirror $vg $lv1 core
 lvremove -ff $vg
 
 # convert from corelog to disklog, active
+aux prepare_vg 5
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
 lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1
 check mirror $vg $lv1 $dev3
@@ -43,13 +45,15 @@
 
 # bz192865: lvconvert log of an inactive mirror lv
 # convert from disklog to corelog, inactive
+aux prepare_vg 5
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
 lvchange -an $vg/$lv1
 echo y | lvconvert -f --mirrorlog core $vg/$lv1
-check mirror $vg $lv1 ""
+check mirror $vg $lv1 core
 lvremove -ff $vg
 
 # convert from corelog to disklog, inactive
+aux prepare_vg 5
 lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
 lvchange -an $vg/$lv1
 lvconvert --mirrorlog disk $vg/$lv1 $dev3:0-1
@@ -57,6 +61,7 @@
 lvremove -ff $vg
 
 # convert linear to 2-way mirror with 1 PV
+aux prepare_vg 5
 lvcreate -l2 -n $lv1 $vg $dev1
 not lvconvert -m+1 --mirrorlog core $vg/$lv1 $dev1
 lvremove -ff $vg
@@ -70,13 +75,166 @@
 #  This is somewhat timing dependent - sync /could/ finish before
 #  we get a chance to have this command fail
 should not lvconvert -m-1 $vg/$lv1 $dev1
-while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do
-	sleep 1
-done
-lvconvert -m2 $vg/$lv1 $dev1 $dev2 $dev4 $dev3:0
+
+lvconvert $vg/$lv1 # wait
+lvconvert -m2 $vg/$lv1 $dev1 $dev2 $dev4 $dev3:0 # If the above "should" failed...
 
 lvconvert -m-1 $vg/$lv1 $dev1
 check mirror_images_on $lv1 $dev2 $dev4
 lvconvert -m-1 $vg/$lv1 $dev2
 check linear $vg $lv1
-check lv_on $vg/$lv1 $dev4
+check lv_on $vg $lv1 $dev4
+
+# No parallel lvconverts on a single LV please
+
+aux prepare_vg 5
+lvcreate -l5 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+check mirror $vg $lv1
+check mirror_legs $vg $lv1 2
+lvconvert -m+1 -b $vg/$lv1 $dev4
+
+# Next convert should fail b/c we can't have 2 at once
+should not lvconvert -m+1 $vg/$lv1 $dev5
+lvconvert $vg/$lv1 # wait
+lvconvert -m2 $vg/$lv1 # In case the above "should" actually failed
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
+
+# add 1 mirror to core log mirror, but
+#  implicitly keep log as 'core'
+aux prepare_vg 5
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+lvconvert -m +1 -i1 $vg/$lv1
+
+check mirror $vg $lv1 core
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
+
+# remove 1 mirror from corelog'ed mirror; should retain 'core' log type
+aux prepare_vg 5
+lvcreate -l2 -m2 --corelog -n $lv1 $vg
+lvconvert -m -1 -i1 $vg/$lv1
+
+check mirror $vg $lv1 core
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 2
+
+# add 1 mirror then add 1 more mirror during conversion
+# FIXME this has been explicitly forbidden?
+#aux prepare_vg 5
+#lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+#lvconvert -m+1 -b $vg/$lv1 $dev4
+#lvconvert -m+1 $vg/$lv1 $dev5
+#
+#check mirror $vg $lv1 $dev3
+#check mirror_no_temporaries $vg $lv1
+#check mirror_legs $vg $lv1 4
+
+# Linear to mirror with mirrored log using --alloc anywhere
+aux prepare_vg 5
+lvcreate -l2 -n $lv1 $vg $dev1
+lvconvert -m +1 --mirrorlog mirrored $vg/$lv1 $dev1 $dev2 --alloc anywhere
+should check mirror $vg $lv1
+
+# convert inactive mirror and start polling
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvchange -an $vg/$lv1
+lvconvert -m+1 $vg/$lv1 $dev4
+lvchange -ay $vg/$lv1
+lvconvert $vg/$lv1 # wait
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+
+# ---------------------------------------------------------------------
+# removal during conversion
+
+# "remove newly added mirror"
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvconvert -m+1 -b $vg/$lv1 $dev4
+lvconvert -m-1 $vg/$lv1 $dev4
+lvconvert $vg/$lv1 # wait
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 2
+
+# "remove one of newly added mirrors"
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvconvert -m+2 -b $vg/$lv1 $dev4 $dev5
+lvconvert -m-1 $vg/$lv1 $dev4
+lvconvert $vg/$lv1 # wait
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
+
+# "remove from original mirror (the original is still mirror)"
+aux prepare_vg 5
+lvcreate -l2 -m2 -n $lv1 $vg $dev1 $dev2 $dev5 $dev3:0
+lvconvert -m+1 -b $vg/$lv1 $dev4 
+lvconvert -m-1 $vg/$lv1 $dev2 
+lvconvert $vg/$lv1 
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
+
+# "remove from original mirror (the original becomes linear)"
+aux prepare_vg 5
+lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+lvconvert -m+1 -b $vg/$lv1 $dev4 
+lvconvert -m-1 $vg/$lv1 $dev2 
+lvconvert $vg/$lv1 
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 2
+
+# ---------------------------------------------------------------------
+
+# "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
+aux prepare_vg 5
+lvcreate -l`pvs --noheadings -ope_count $dev1` -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0
+while [ `lvs --noheadings -o copy_percent $vg/$lv1` != "100.00" ]; do sleep 1; done
+lvconvert -m0 $vg/$lv1 $dev1
+check linear $vg $lv1
+
+# "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute after being down and the up converted"
+aux prepare_vg 5
+lvcreate -l2 -m1 -n$lv1 --nosync $vg 
+lvconvert -m0 $vg/$lv1
+lvconvert -m1 $vg/$lv1
+lvs --noheadings -o attr $vg/$lv1 | grep '^ *m'
+
+# lvconvert from linear (on multiple PVs) to mirror
+aux prepare_vg 5
+lvcreate -l 8 -n $lv1 $vg $dev1:0-3 $dev2:0-3
+lvconvert -m1 $vg/$lv1
+
+should check mirror $vg $lv1
+check mirror_legs $vg $lv1 2
+
+# BZ 463272: disk log mirror convert option is lost if downconvert option is also given
+aux prepare_vg 5
+lvcreate -l1 -m2 --corelog -n $lv1 $vg $dev1 $dev2 $dev3
+lvconvert -m1 --mirrorlog disk $vg/$lv1 $dev1
+check mirror $vg $lv1 $dev1
+
+# ---
+# add mirror and disk log
+
+# "add 1 mirror and disk log" 
+aux prepare_vg 5
+lvcreate -l2 -m1 --mirrorlog core -n $lv1 $vg $dev1 $dev2
+
+# FIXME on next line, specifying $dev3:0 $dev4 (i.e log device first) fails (!)
+lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0
+
+check mirror $vg $lv1 $dev3
+check mirror_no_temporaries $vg $lv1
+check mirror_legs $vg $lv1 3
--- LVM2/test/t-lvcreate-mirror.sh	2010/04/12 19:16:24	1.1
+++ LVM2/test/t-lvcreate-mirror.sh	2010/05/12 10:08:36	1.2
@@ -20,13 +20,13 @@
 # 2-way mirror with disklog, 3 PVs
 lvcreate -l2 -m1 -n $lv1 $vg $dev1 $dev2 $dev3:0-1
 check mirror_images_redundant $vg $lv1
-check mirror_log_on $vg/$lv1 $dev3
+check mirror_log_on $vg $lv1 $dev3
 lvremove -ff $vg
 
 # 3-way mirror with disklog, 4 PVs
 lvcreate -l2 -m2 --mirrorlog disk -n $lv1 $vg $dev1 $dev2 $dev4 $dev3:0-1
 check mirror_images_redundant $vg $lv1
-check mirror_log_on $vg/$lv1 $dev3
+check mirror_log_on $vg $lv1 $dev3
 lvremove -ff $vg
 
 # lvcreate --nosync is in 100% sync after creation (bz429342)
--- LVM2/test/t-vgcreate-usage.sh	2009/12/28 18:33:04	1.14
+++ LVM2/test/t-vgcreate-usage.sh	2010/05/12 10:08:36	1.15
@@ -17,6 +17,8 @@
 pvcreate $dev1 $dev2
 pvcreate --metadatacopies 0 $dev3
 
+vg=${PREFIX}vg
+
 #COMM 'vgcreate accepts 8.00m physicalextentsize for VG'
 vgcreate -c n $vg --physicalextentsize 8.00m $dev1 $dev2
 check_vg_field_ $vg vg_extent_size 8.00m
--- LVM2/test/test-utils.sh	2010/05/06 18:54:52	1.39
+++ LVM2/test/test-utils.sh	2010/05/12 10:08:36	1.40
@@ -94,7 +94,7 @@
 
 	trap_teardown
 	TESTDIR=$($abs_srcdir/mkdtemp ${LVM_TEST_DIR-$(pwd)} $PREFIX.XXXXXXXXXX) \
-		|| { echo "failed to create temporary directory in $test_dir_"; exit 1; }
+		|| { echo "failed to create temporary directory in ${LVM_TEST_DIR-$(pwd)}"; exit 1; }
 
 	export LVM_SYSTEM_DIR=$TESTDIR/etc
 	export DM_DEV_DIR=$TESTDIR/dev
@@ -131,6 +131,7 @@
 		test -n "$LOOPFILE" && rm -f $LOOPFILE
 	fi
 	unset devs # devs is set in prepare_devs()
+	unset LOOP
 }
 
 teardown() {
@@ -178,7 +179,7 @@
 	trap_teardown
 
 	for i in 0 1 2 3 4 5 6 7; do
-		mknod $DM_DEV_DIR/loop$i b 7 $i
+		test -e $DM_DEV_DIR/loop$i || mknod $DM_DEV_DIR/loop$i b 7 $i
 	done
 
 	LOOPFILE="$PWD/test.img"
@@ -291,16 +292,6 @@
 		local name="${PREFIX}$pvname$i"
 		dmsetup table $name
 	done
-
-    # set up some default names
-	vg=${PREFIX}vg
-	vg1=${PREFIX}vg1
-	vg2=${PREFIX}vg2
-	lv=LV
-	lv1=LV1
-	lv2=LV2
-	lv3=LV3
-	lv4=LV4
 }
 
 disable_dev() {
@@ -346,10 +337,13 @@
 
 prepare_pvs() {
 	prepare_devs "$@"
-	pvcreate $devs
+	pvcreate -ff $devs
 }
 
 prepare_vg() {
+	vgremove -ff $vg || true
+	teardown_devs
+
 	prepare_pvs "$@"
 	vgcreate -c n $vg $devs
 	pvs -v
@@ -400,6 +394,16 @@
 	prepare_testroot
 	prepare_lvmconf
 	prepare_clvmd
+
+	# set up some default names
+	vg=${PREFIX}vg
+	vg1=${PREFIX}vg1
+	vg2=${PREFIX}vg2
+	lv=LV
+	lv1=LV1
+	lv2=LV2
+	lv3=LV3
+	lv4=LV4
 }
 
 LANG=C


