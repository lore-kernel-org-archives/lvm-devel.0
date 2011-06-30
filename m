From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 30 Jun 2011 09:08:23 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110630090823.17427.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-06-30 09:08:22

Modified files:
	test/lib       : aux.sh 

Log message:
	Use -f to remove device
	
	Since some test may leave devices in suspend mode which would require
	carefull order of resume operation - use '-f' to replace them with
	error targets
	
	For disable_dev  - when  'error' target is used for open count - treat
	return code as ok (|| true) to avoid breaking futher test processing.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.22&r2=1.23

--- LVM2/test/lib/aux.sh	2011/06/30 08:50:10	1.22
+++ LVM2/test/lib/aux.sh	2011/06/30 09:08:22	1.23
@@ -71,7 +71,7 @@
 		while dmsetup table | grep -q ^$PREFIX; do
 			for s in `dmsetup info -c -o name --noheading | grep ^$PREFIX`; do
 				umount -fl $DM_DEV_DIR/mapper/$s >& /dev/null || true
-				dmsetup remove $s >& /dev/null || true
+				dmsetup remove -f $s >& /dev/null || true
 			done
 		done
 		finish_udev_transaction
@@ -292,7 +292,7 @@
 
 	init_udev_transaction
 	for dev in "$@"; do
-        	dmsetup remove -f $dev
+        	dmsetup remove -f $dev || true
 	done
 	finish_udev_transaction
 


