From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 May 2012 13:06:19 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120516130619.18283.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-05-16 13:06:19

Modified files:
	.              : WHATS_NEW 

Log message:
	update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2406&r2=1.2407

--- LVM2/WHATS_NEW	2012/05/16 12:50:14	1.2406
+++ LVM2/WHATS_NEW	2012/05/16 13:06:18	1.2407
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix partial activation of volumes (2.02.90)
   Re-enable partial activation of non-thin LVs until it can be fixed. (2.02.90)
   Fix alloc cling to cling to PVs already found with contiguous policy.
   Fix cling policy not to behave like normal policy if no previous LV seg.


