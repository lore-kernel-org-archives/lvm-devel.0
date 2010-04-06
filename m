From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Apr 2010 17:36:45 -0000
Subject: LVM2 ./WHATS_NEW lib/device/device.c test/test ...
Message-ID: <20100406173645.23305.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-06 17:36:43

Modified files:
	.              : WHATS_NEW 
	lib/device     : device.c 
	test           : test-utils.sh 

Log message:
	Fix is_partitioned_dev not to attempt to reopen device.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1503&r2=1.1504
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/device/device.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/WHATS_NEW	2010/04/06 15:29:30	1.1503
+++ LVM2/WHATS_NEW	2010/04/06 17:36:41	1.1504
@@ -1,5 +1,6 @@
 Version 2.02.63 -  
 ================================
+  Fix is_partitioned_dev not to attempt to reopen device.
   Fix another thread race in clvmd.
   Refactor management of vg->pvs list.
   Fix lcov rules and generate better coverage report.
--- LVM2/lib/device/device.c	2009/08/01 17:14:52	1.32
+++ LVM2/lib/device/device.c	2010/04/06 17:36:42	1.33
@@ -62,13 +62,8 @@
 	uint16_t *part_magic;
 	struct partition *part;
 
-	if (!dev_open(dev)) {
-		stack;
-		return -1;
-	}
-
 	if (!dev_read(dev, UINT64_C(0), sizeof(buf), &buf))
-		goto_out;
+		return_0;
 
 	/* FIXME Check for other types of partition table too */
 
@@ -88,10 +83,6 @@
 		}
 	}
 
-      out:
-	if (!dev_close(dev))
-		stack;
-
 	return ret;
 }
 
--- LVM2/test/test-utils.sh	2010/04/06 14:25:07	1.28
+++ LVM2/test/test-utils.sh	2010/04/06 17:36:43	1.29
@@ -247,6 +247,15 @@
 	done
 	finish_udev_transaction
 
+	for i in `seq 1 $n`; do
+		local name="${PREFIX}$pvname$i"
+		dmsetup info -c $name
+	done
+	for i in `seq 1 $n`; do
+		local name="${PREFIX}$pvname$i"
+		dmsetup table $name
+	done
+
     # set up some default names
 	vg=${PREFIX}vg
 	vg1=${PREFIX}vg1


