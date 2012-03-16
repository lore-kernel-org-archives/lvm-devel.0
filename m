From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 16 Mar 2012 10:46:25 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120316104625.15420.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-03-16 10:46:25

Modified files:
	.              : WHATS_NEW 

Log message:
	It's new.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2357&r2=1.2358

--- LVM2/WHATS_NEW	2012/03/15 20:00:54	1.2357
+++ LVM2/WHATS_NEW	2012/03/16 10:46:25	1.2358
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Fix a regression in handling of lvchange/lvcreate --major/--minor.
   Fix name conflicts that prevent down-converting RAID1 when specifying a device
   Improve thin_check option passing and use configured path.
   Add --with-thin-check configure option for path to thin_check.


