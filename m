From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Oct 2010 17:04:03 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20101015170403.15595.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-15 17:04:02

Modified files:
	.              : WHATS_NEW 

Log message:
	Update WHATS_NEW.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1763&r2=1.1764

--- LVM2/WHATS_NEW	2010/10/15 09:55:37	1.1763
+++ LVM2/WHATS_NEW	2010/10/15 17:04:02	1.1764
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Add an option to automatically extend snapshots through dmeventd.
   Remove dependency on libm, floor() is replaced with integer algorithm.
   Fix hang when repairing a mirrored-log that had both devs fail.
   Convey need for snapshot-merge target in lvconvert error message and man page.


