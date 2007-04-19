From: bmr@sourceware.org <bmr@sourceware.org>
Date: 19 Apr 2007 22:56:16 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20070419225616.2969.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	bmr at sourceware.org	2007-04-19 23:56:16

Modified files:
	.              : WHATS_NEW 

Log message:
	Make lvm_dump.sh list /dev recursively to aid identifying devices.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.596&r2=1.597

--- LVM2/WHATS_NEW	2007/04/19 02:10:42	1.596
+++ LVM2/WHATS_NEW	2007/04/19 22:56:16	1.597
@@ -8,6 +8,7 @@
   Fix vgsplit for lvm1 format (set and validate VG name in PVs metadata).
   Split metadata areas in vgsplit properly.
   Add extra internal error checking to clvmd
+  Make lvm_dump.sh list /dev recursively
 
 Version 2.02.24 - 19th March 2007
 =================================


