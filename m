From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Aug 2010 13:18:02 -0000
Subject: LVM2/test lvm-utils.sh t-000-basic.sh t-pvmove ...
Message-ID: <20100802131802.8206.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-02 13:18:02

Modified files:
	test           : lvm-utils.sh t-000-basic.sh t-pvmove-basic.sh 

Log message:
	Visually better align lines which are executed as a result of true
	or false result of previous command.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lvm-utils.sh.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-000-basic.sh.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/lvm-utils.sh	2010/04/07 14:46:26	1.24
+++ LVM2/test/lvm-utils.sh	2010/08/02 13:18:01	1.25
@@ -129,9 +129,9 @@
 
 	lvs -a -o+devices $local_vg
 
-	check_vg_field_ $local_vg pv_count $num_pvs &&
-	check_vg_field_ $local_vg lv_count $num_lvs &&
-	check_vg_field_ $local_vg snap_count $num_snaps
+	check_vg_field_ $local_vg pv_count $num_pvs && \
+	  check_vg_field_ $local_vg lv_count $num_lvs && \
+	  check_vg_field_ $local_vg snap_count $num_snaps
 }
 
 dmsetup_has_dm_devdir_support_()
--- LVM2/test/t-000-basic.sh	2010/04/20 15:19:36	1.9
+++ LVM2/test/t-000-basic.sh	2010/08/02 13:18:02	1.10
@@ -20,9 +20,9 @@
 # ensure they are the same
 diff -u actual expected
 
-mknod $DM_DEV_DIR/null c 1 3 ||
+mknod $DM_DEV_DIR/null c 1 3 || \
   error "Can't create nodes on filesystem"
-echo >$DM_DEV_DIR/null || 
+echo >$DM_DEV_DIR/null || \
   error "Filesystem for tests does not allow using device nodes (check nodev)"
 
 # ensure we can create devices (uses dmsetup, etc)
--- LVM2/test/t-pvmove-basic.sh	2010/04/08 01:58:06	1.10
+++ LVM2/test/t-pvmove-basic.sh	2010/08/02 13:18:02	1.11
@@ -33,8 +33,7 @@
 }
 
 save_dev_sum_() {
-  mkfs.ext3 $1 > /dev/null &&
-  md5sum $1 > md5.$(basename $1)
+  mkfs.ext3 $1 > /dev/null && md5sum $1 > md5.$(basename $1)
 }
 
 check_dev_sum_() {
@@ -83,8 +82,8 @@
   lvs -a -o name $vg > out && ! grep ^pvmove out
   lvremove -ff $vg
 	if ! dmsetup table|not grep $vg; then
-		echo "ERROR: lvremove did leave some some mappings in DM behind!" &&
-		return 1
+		echo "ERROR: lvremove did leave some some mappings in DM behind!" && \
+			return 1
 	fi
 	:
 }


