From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 24 Feb 2010 18:21:16 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20100224182116.20636.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-02-24 18:21:16

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1436&r2=1.1437

--- LVM2/WHATS_NEW	2010/02/17 22:59:46	1.1436
+++ LVM2/WHATS_NEW	2010/02/24 18:21:15	1.1437
@@ -1,5 +1,10 @@
 Version 2.02.62 -
 ====================================
+  Update lvm2app.h Doxygen comments and add lvm2app Doxygen config file.
+  Update nightly tests and lvm2app unit tests to cover tags.
+  Add lvm2app functions lvm_{vg|lv}_{get|add|remove}_tag() functions.
+  Add dm_pool_strdup to allocate and copy memory in tag library function.
+  Refactor vgcreate, vgchange, and lvchange for tag library function.
   Refactor snapshot-merge deptree and device removal to support info-by-uuid.
 
 Version 2.02.61 - 15th February 2010


