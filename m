From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Apr 2008 14:32:32 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20080403143232.4203.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-03 14:32:31

Modified files:
	.              : WHATS_NEW 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.819&r2=1.820

--- LVM2/WHATS_NEW	2008/04/03 10:29:00	1.819
+++ LVM2/WHATS_NEW	2008/04/03 14:32:31	1.820
@@ -1,7 +1,7 @@
 Version 2.02.34 -
 ===================================
   Add per-command flags to control which commands use the VG metadata cache.
-  Fix vgsplit locking, remove unneeded error messages when split into new VG.
+  Fix vgsplit locking of new VG and avoid erroneous error message. (2.02.29)
   Suppress duplicate message when lvresize fails because of invalid vgname.
   Cache VG metadata internally while VG lock is held.
   Fix redundant lvresize message if vg doesn't exist.


