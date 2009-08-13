From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 13 Aug 2009 12:04:02 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20090813120402.10096.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-08-13 12:04:01

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW for recent checkins.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1235&r2=1.1236

--- LVM2/WHATS_NEW	2009/08/13 10:39:41	1.1235
+++ LVM2/WHATS_NEW	2009/08/13 12:04:01	1.1236
@@ -1,6 +1,10 @@
 Version 2.02.52 -
 =================================
+  Fix vgextend error path - if ORPHAN lock fails, unlock / release vg (2.02.49).
   Fix compile warning in clvmd.
+  Update lv{convert|create|extend|resize} man pages - clarify use of PE ranges.
+  Remove useless _pv_write wrapper.
+  Update test/api/test.c to call lvm_vg_create and lvm_vg_remove.
 
 Version 2.02.51 - 6th August 2009
 =================================


