From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 19 Jan 2010 15:59:34 -0000
Subject: LVM2/test t-pvcreate-operation-md.sh
Message-ID: <20100119155934.15758.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-01-19 15:59:34

Modified files:
	test           : t-pvcreate-operation-md.sh 

Log message:
	update test/t-pvcreate-operation-md.sh attempt loading raid0.ko if raid0
	isn't already available (in /proc/mdstat).
	
	switch to requiring 2.6.33 for the alignment_offset tests; 2.6.{31,32}
	alignment_offset values aren't reliable.  2.6.33 _should_ have mkp's
	alignment_offset fixes but so far it doesn't (as of 2.6.33-rc4).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvcreate-operation-md.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-pvcreate-operation-md.sh	2009/09/30 16:13:53	1.3
+++ LVM2/test/t-pvcreate-operation-md.sh	2010/01/19 15:59:34	1.4
@@ -14,7 +14,9 @@
 which perl || exit 200
 which awk || exit 200
 which cut || exit 200
-test -f /proc/mdstat || exit 200
+
+test -f /proc/mdstat && grep -q raid0 /proc/mdstat || \
+modprobe raid0 || exit 200
 
 . ./test-utils.sh
 
@@ -66,7 +68,8 @@
 linux_minor=$(echo `uname -r` | cut -d'.' -f3 | cut -d'-' -f1)
 
 # Test newer topology-aware alignment detection
-if [ $linux_minor -gt 31 ]; then
+# - first added to 2.6.31 but not "reliable" until 2.6.33
+if [ $linux_minor -ge 33 ]; then
     pv_align="256.00k"
     pvcreate --metadatasize 128k \
 	--config 'devices { md_chunk_alignment=0 }' $mddev
@@ -74,7 +77,7 @@
 fi
 
 # partition MD array directly, depends on blkext in Linux >= 2.6.28
-if [ $linux_minor -gt 27 ]; then
+if [ $linux_minor -ge 28 ]; then
     # create one partition
     sfdisk $mddev <<EOF
 ,,83
@@ -95,7 +98,7 @@
 
     # Checking for 'alignment_offset' in sysfs implies Linux >= 2.6.31
     sysfs_alignment_offset=/sys/dev/block/${mddev_maj_min}/${base_mddev_p}/alignment_offset
-    [ -f $sysfs_alignment_offset ] && \
+    [ -f $sysfs_alignment_offset -a $linux_minor -ge 33 ] && \
 	alignment_offset=`cat $sysfs_alignment_offset` || \
 	alignment_offset=0
 


