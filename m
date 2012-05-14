From: agk@sourceware.org <agk@sourceware.org>
Date: 14 May 2012 16:29:52 -0000
Subject: LVM2/doc example.conf.in
Message-ID: <20120514162952.21162.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-14 16:29:51

Modified files:
	doc            : example.conf.in 

Log message:
	Refer to details of snapshot of raid problem.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.49&r2=1.50

--- LVM2/doc/example.conf.in	2012/05/10 00:18:49	1.49
+++ LVM2/doc/example.conf.in	2012/05/14 16:29:50	1.50
@@ -430,8 +430,12 @@
     # "mirror" - The original RAID1 implementation provided by LVM2/DM.  It is
     # 	         characterized by a flexible log solution (core, disk, mirrored)
     #		 and by the necessity to block I/O while reconfiguring in the
-    #		 event of a failure.  Snapshots of this type of RAID1 can be
-    #		 problematic.
+    #		 event of a failure.
+    #
+    #		 There is an inherent race in the dmeventd failure handling
+    #		 logic with snapshots of devices using this type of RAID1 that
+    #		 in the worst case could cause a deadlock.
+    #		   Ref: https://bugzilla.redhat.com/show_bug.cgi?id=817130#c10
     #
     # "raid1"  - This implementation leverages MD's RAID1 personality through
     # 	       	 device-mapper.  It is characterized by a lack of log options.


