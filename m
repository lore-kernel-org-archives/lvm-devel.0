From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 24 Jan 2012 14:33:39 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/raid_manip.c tes ...
Message-ID: <20120124143339.12629.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-01-24 14:33:39

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : raid_manip.c 
	test/shell     : lvconvert-raid.sh 

Log message:
	Use suspend|resume_origin_only when up-converting RAID LVs, as mirrors do.
	
	Failure to do so results in "Performing unsafe table load while X device(s) are
	known to be suspended" errors.  While fixing the problem in this way works and
	is consistent with the way the mirror segment type does it, it would be nice
	to find a solution that uses the generic suspend/resume calls.
	
	Also included in this check-in are additions to the test suite that perform
	conversions on RAID LVs under a snapshot.  These tests are disabled for the
	time being due to a kernel bug that is yet to be tracked down.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2235&r2=1.2236
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvconvert-raid.sh.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2012/01/23 20:56:42	1.2235
+++ LVM2/WHATS_NEW	2012/01/24 14:33:38	1.2236
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Use suspend|resume_origin_only when up-converting RAID, as mirrors do.
   Fix the way RAID meta LVs are added to the dependency tree.
   Change exclusive LV activation logic to try local node before remote nodes.
   Add CLVMD_FLAG_REMOTE to skip processing on local node.
--- LVM2/lib/metadata/raid_manip.c	2011/12/01 00:21:04	1.20
+++ LVM2/lib/metadata/raid_manip.c	2012/01/24 14:33:38	1.21
@@ -762,7 +762,7 @@
 		return 0;
 	}
 
-	if (!suspend_lv(cmd, lv)) {
+	if (!suspend_lv_origin(cmd, lv)) {
 		log_error("Failed to suspend %s/%s before committing changes",
 			  lv->vg->name, lv->name);
 		return 0;
@@ -774,7 +774,7 @@
 		return 0;
 	}
 
-	if (!resume_lv(cmd, lv)) {
+	if (!resume_lv_origin(cmd, lv)) {
 		log_error("Failed to resume %s/%s after committing changes",
 			  lv->vg->name, lv->name);
 		return 0;
--- LVM2/test/shell/lvconvert-raid.sh	2011/11/21 00:15:46	1.1
+++ LVM2/test/shell/lvconvert-raid.sh	2012/01/24 14:33:39	1.2
@@ -25,10 +25,14 @@
 	if ! a=(`dmsetup status $dm_name`); then
 		echo "Unable to get sync status of $1"
 		exit 1
+	elif [ ${a[2]} = "snapshot-origin" ]; then
+		if ! a=(`dmsetup status ${dm_name}-real`); then
+			echo "Unable to get sync status of $1"
+			exit 1
+		fi
 	fi
 
 	# 6th argument is the sync ratio for RAID and mirror
-	echo ${a[@]}
 	if [ ${a[2]} = "raid" ]; then
 		# Last argument is the sync ratio for RAID
 		idx=$((${#a[@]} - 1))
@@ -103,6 +107,11 @@
 ###########################################
 # RAID1 convert tests
 ###########################################
+#
+# FIXME: Snapshots of RAID is available, but there are kernel bugs that
+#        still prevent its use.
+#for under_snap in false true; do
+for under_snap in false; do
 for i in 1 2 3 4; do
 	for j in 1 2 3 4; do
 		if [ $i -eq 1 ]; then
@@ -115,7 +124,13 @@
 		else
 			to="$j-way"
 		fi
-		echo "Converting from $from to $to"
+
+		echo -n "Converting from $from to $to"
+		if $under_snap; then
+			echo -n " (while under a snapshot)"
+		fi
+		echo
+
 		if [ $i -eq 1 ]; then
 			# Shouldn't be able to create with just 1 image
 			not lvcreate --type raid1 -m 0 -l 2 -n $lv1 $vg
@@ -125,6 +140,11 @@
 			lvcreate --type raid1 -m $(($i - 1)) -l 2 -n $lv1 $vg
 			wait_for_sync $vg/$lv1
 		fi
+
+		if $under_snap; then
+			lvcreate -s $vg/$lv1 -n snap -l 2
+		fi
+
 		lvconvert -m $((j - 1))  $vg/$lv1
 
 		# FIXME: ensure no residual devices
@@ -135,7 +155,7 @@
 		lvremove -ff $vg
 	done
 done
-
+done
 #
 # FIXME: Add tests that specify particular devices to be removed
 #


