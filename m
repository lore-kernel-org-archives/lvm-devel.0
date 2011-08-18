From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 18 Aug 2011 19:56:17 -0000
Subject: LVM2/test t-lvcreate-raid.sh t-lvconvert-raid.sh
Message-ID: <20110818195617.9118.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-18 19:56:17

Modified files:
	test           : t-lvcreate-raid.sh 
Added files:
	test           : t-lvconvert-raid.sh 

Log message:
	Move RAID convert tests to new file, t-lvconvert-raid.sh
	
	There is duplicate code in t-lvconvert-raid.sh and t-lvcreate-raid.sh.
	This should be moved into a common file which is then sourced by these two
	files.  I'll wait to move the duplicate code until I can talk to mornfall.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-raid.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvcreate-raid.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

/cvs/lvm2/LVM2/test/t-lvconvert-raid.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-lvconvert-raid.sh
+++ -	2011-08-18 19:56:17.566911000 +0000
@@ -0,0 +1,158 @@
+#!/bin/bash
+
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+# is_raid_in_sync <VG/LV>
+function is_raid_in_sync()
+{
+	local dm_name
+	local a
+	local b
+	local idx
+
+	dm_name=`echo $1 | sed s:-:--: | sed s:/:-:`
+
+	if ! a=(`dmsetup status $dm_name`); then
+		echo "Unable to get sync status of $1"
+		exit 1
+	fi
+	idx=$((${#a[@]} - 1))
+	b=(`echo ${a[$idx]} | sed s:/:' ':`)
+
+	if [ ${b[0]} != ${b[1]} ]; then
+		echo "$dm_name (${a[3]}) is not in-sync"
+		return 1
+	fi
+
+	echo "$dm_name (${a[3]}) is in-sync"
+	return 0
+}
+
+# wait_for_raid_sync <VG/LV>
+function wait_for_raid_sync()
+{
+	local i=0
+
+	while ! is_raid_in_sync $1; do
+		sleep 2
+		i=$(($i + 1))
+		if [ $i -gt 500 ]; then
+			echo "Sync is taking too long - assume stuck"
+			exit 1
+		fi
+	done
+}
+
+function is_raid_available()
+{
+	local a
+
+	modprobe dm-raid
+	a=(`dmsetup targets | grep raid`)
+	if [ -z $a ]; then
+		echo "RAID target not available"
+		return 1
+	fi
+	if [ ${a[1]} != "v1.1.0" ]; then
+		echo "Bad RAID version"
+		return 1
+	fi
+
+	return 0
+}
+
+########################################################
+# MAIN
+########################################################
+is_raid_available || exit 200
+
+aux prepare_vg 5 80
+
+###########################################
+# RAID1 convert tests
+###########################################
+for i in 2 3 4; do
+	for j in 1 2 3 4; do
+		if [ $i -eq 1 ]; then
+			from="linear"
+		else
+			from="$i-way"
+		fi
+		if [ $j -eq 1 ]; then
+			to="linear"
+		else
+			to="$j-way"
+		fi
+		echo "Converting from $from to $to"
+		lvcreate --type raid1 -m $(($i - 1)) -l 2 -n $lv1 $vg
+		wait_for_raid_sync $vg/$lv1
+		lvconvert -m $((j - 1))  $vg/$lv1
+
+		# FIXME: ensure no residual devices
+
+		if [ $j -eq 1 ]; then
+			check linear $vg $lv1
+		fi
+		lvremove -ff $vg
+	done
+done
+
+#
+# FIXME: Add tests that specify particular devices to be removed
+#
+
+###########################################
+# RAID1 split tests
+###########################################
+# 3-way to 2-way/linear
+lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
+wait_for_raid_sync $vg/$lv1
+lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
+check lv_exists $vg $lv1
+check linear $vg $lv2
+# FIXME: ensure no residual devices
+lvremove -ff $vg
+
+# 2-way to linear/linear
+lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+wait_for_raid_sync $vg/$lv1
+lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
+check linear $vg $lv1
+check linear $vg $lv2
+# FIXME: ensure no residual devices
+lvremove -ff $vg
+
+# 3-way to linear/2-way
+lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
+wait_for_raid_sync $vg/$lv1
+
+# FIXME: Can't split off a mirror from a mirror yet
+#lvconvert --splitmirrors 2 -n $lv2 $vg/$lv1
+#check linear $vg $lv1
+#check lv_exists $vg $lv2
+
+# FIXME: ensure no residual devices
+lvremove -ff $vg
+
+###########################################
+# RAID1 split + trackchanges / merge
+###########################################
+# 3-way to 2-way/linear
+lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
+wait_for_raid_sync $vg/$lv1
+lvconvert --splitmirrors 1 --trackchanges $vg/$lv1
+check lv_exists $vg $lv1
+check linear $vg ${lv1}_rimage_2
+lvconvert --merge $vg/${lv1}_rimage_2
+# FIXME: ensure no residual devices
+lvremove -ff $vg
--- LVM2/test/t-lvcreate-raid.sh	2011/08/11 18:24:42	1.1
+++ LVM2/test/t-lvcreate-raid.sh	2011/08/18 19:56:17	1.2
@@ -1,3 +1,5 @@
+#!/bin/bash
+
 # Copyright (C) 2011 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
@@ -106,17 +108,6 @@
 	lvremove -ff $vg
 done
 
-###########################################
-# RAID1 down-convert tests
-###########################################
-
-# 3-way to 2-way
-lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg
-wait_for_raid_sync $vg/$lv1
-lvconvert -m 1 $vg/$lv1
-# FIXME: ensure no residual devices
-
-# 2-way to linear
-lvconvert -m 0 $vg/$lv1
-# FIXME: ensure no residual devices
-lvremove -ff $vg
+#
+# FIXME: Add tests that specify particular PVs to use for creation
+#


