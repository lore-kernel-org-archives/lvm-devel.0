From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Oct 2010 09:55:37 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101015095537.30425.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-15 09:55:37

Modified files:
	.              : WHATS_NEW 

Log message:
	Update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1762&r2=1.1763

--- LVM2/WHATS_NEW	2010/10/14 20:03:12	1.1762
+++ LVM2/WHATS_NEW	2010/10/15 09:55:37	1.1763
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Remove dependency on libm, floor() is replaced with integer algorithm.
   Fix hang when repairing a mirrored-log that had both devs fail.
   Convey need for snapshot-merge target in lvconvert error message and man page.
   Add "devices/disable_after_error_count" to lvm.conf.


