From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 25 Apr 2012 09:32:37 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120425093237.21244.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-04-25 09:32:37

Modified files:
	.              : WHATS_NEW 

Log message:
	WHATS_NEW

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2391&r2=1.2392

--- LVM2/WHATS_NEW	2012/04/24 20:05:31	1.2391
+++ LVM2/WHATS_NEW	2012/04/25 09:32:36	1.2392
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix lvconvert error message for non-mergeable volumes.
   Allow subset of failed devices to be replaced in RAID LVs.
   Prevent resume from creating error devices that already exist from suspend.
   Improve clmvd singlenode locking for better testing.


