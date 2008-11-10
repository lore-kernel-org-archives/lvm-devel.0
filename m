From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Nov 2008 21:26:06 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20081110212606.9845.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-10 21:26:06

Modified files:
	.              : WHATS_NEW 

Log message:
	clarify

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.993&r2=1.994

--- LVM2/WHATS_NEW	2008/11/10 12:39:50	1.993
+++ LVM2/WHATS_NEW	2008/11/10 21:26:06	1.994
@@ -1,8 +1,8 @@
 Version 2.02.43 - 10th November 2008
 ====================================
   Merge device-mapper into the lvm2 tree.
-  Fix lvchange and lvcreate man pages permissions option.
-  Fix vgdisplay return code and exit status.
+  Correct prototype for --permission on lvchange and lvcreate man pages.
+  Exit with non-zero status from vgdisplay if couldn't show any requested VG.
   Move list.c into libdevmapper and rename functions.
   Rename a couple of variables that matched function names.
   Use simplified x.y.z version number in libdevmapper.pc.


