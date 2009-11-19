From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Nov 2009 01:17:02 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20091119011702.32554.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-11-19 01:17:01

Modified files:
	.              : WHATS_NEW 

Log message:
	What's new.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1316&r2=1.1317

--- LVM2/WHATS_NEW	2009/11/18 17:20:18	1.1316
+++ LVM2/WHATS_NEW	2009/11/19 01:17:01	1.1317
@@ -1,5 +1,7 @@
 Version 2.02.55 -
 ===================================
+  Fix a possible deadlock in mirror code due to memlock refcount mismatch.
+  Enable dmeventd event handlers to properly scan devices.
   Do not activate directly not visible volumes in vgchange.
   Fix pvmove region_size oveflow for very large PVs.
   Fix lvcreate and lvresize processing of %PVS argument.


