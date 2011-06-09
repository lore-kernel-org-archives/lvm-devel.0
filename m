From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 9 Jun 2011 18:58:02 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh api/perce ...
Message-ID: <20110609185802.7537.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-06-09 18:58:01

Modified files:
	test           : t-pvcreate-operation-md.sh 
	test/api       : percent.sh 
	test/lib       : utils.sh 

Log message:
	Fix kernel version parsing in tests, use common function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/percent.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/t-pvcreate-operation-md.sh	2011/01/28 16:12:45	1.14
+++ LVM2/test/t-pvcreate-operation-md.sh	2011/06/09 18:58:00	1.15
@@ -70,12 +70,10 @@
     $mddev
 check pv_field $mddev pe_start $pv_align
 
-# Get linux minor version
-linux_minor=$(echo `uname -r` | cut -d'.' -f3 | cut -d'-' -f1)
 
 # Test newer topology-aware alignment detection
 # - first added to 2.6.31 but not "reliable" until 2.6.33
-if [ $linux_minor -ge 33 ]; then
+if kernel_at_least 2 6 33 ; then
     pv_align="1.00m"
     # optimal_io_size=131072, minimum_io_size=65536
     pvcreate --metadatasize 128k \
@@ -84,7 +82,7 @@
 fi
 
 # partition MD array directly, depends on blkext in Linux >= 2.6.28
-if [ $linux_minor -ge 28 ]; then
+if kernel_at_least 2 6 28 ; then
     # create one partition
     sfdisk $mddev <<EOF
 ,,83
@@ -111,11 +109,11 @@
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
     # but reliable alignment_offset support requires kernel.org Linux >= 2.6.33
     sysfs_alignment_offset=/sys/dev/block/${mddev_maj_min}/${base_mddev_p}/alignment_offset
-    [ -f $sysfs_alignment_offset -a $linux_minor -ge 33 ] && \
+    [ -f $sysfs_alignment_offset ] && kernel_at_least 2 6 33 && \
 	alignment_offset=`cat $sysfs_alignment_offset` || \
 	alignment_offset=0
 
-    if [ $alignment_offset -gt 0 ]; then    
+    if [ $alignment_offset -gt 0 ]; then
         # default alignment is 1M, add alignment_offset
 	pv_align=$((1048576+$alignment_offset))B
 	pvcreate --metadatasize 128k $mddev_p
@@ -125,7 +123,7 @@
 fi
 
 # Test newer topology-aware alignment detection w/ --dataalignment override
-if [ $linux_minor -ge 33 ]; then
+if kernel_at_least 2 6 33 ; then
     cleanup_md
     pvcreate -f $dev1
     pvcreate -f $dev2
--- LVM2/test/api/percent.sh	2011/01/28 16:11:14	1.5
+++ LVM2/test/api/percent.sh	2011/06/09 18:58:01	1.6
@@ -13,8 +13,7 @@
 
 . lib/test
 
-linux_minor=$(echo `uname -r` | cut -d'.' -f3 | cut -d'-' -f1)
-test $linux_minor -le 32 && skip
+kernel_at_least 2 6 33 || skip
 
 aux prepare_devs 2
 vgcreate -c n -s 4k $vg $(cat DEVICES)
--- LVM2/test/lib/utils.sh	2011/01/31 22:05:30	1.4
+++ LVM2/test/lib/utils.sh	2011/06/09 18:58:01	1.5
@@ -152,6 +152,23 @@
     exit 200
 }
 
+kernel_at_least() {
+    major=$(uname -r |cut -d. -f1)
+    minor=$(uname -r |cut -d. -f2 | cut -d- -f1)
+
+    test $major -gt $1 && return 0
+    test $major -lt $1 && return 1
+    test $minor -gt $2 && return 0
+    test $minor -lt $2 && return 1
+    test -z "$3" && return 0
+
+    minor2=$(uname -r | cut -d. -f3)
+    test -z "$minor2" && return 0
+    test $minor2 -ge $3 2>/dev/null && return 0
+
+    return 1
+}
+
 . lib/paths || { echo >&2 you must run make first; exit 1; }
 
 PATH=$abs_top_builddir/test/lib:$PATH


