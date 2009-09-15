From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Sep 2009 10:57:17 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090915105717.15673.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-15 10:57:16

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.207&r2=1.208
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1261&r2=1.1262
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.297&r2=1.298

--- LVM2/VERSION	2009/08/06 19:32:26	1.207
+++ LVM2/VERSION	2009/09/15 10:57:16	1.208
@@ -1 +1 @@
-2.02.52(1)-cvs (2009-08-06)
+2.02.52(1)-cvs (2009-09-15)
--- LVM2/VERSION_DM	2009/08/06 19:32:26	1.19
+++ LVM2/VERSION_DM	2009/09/15 10:57:16	1.20
@@ -1 +1 @@
-1.02.37-cvs (2009-08-06)
+1.02.37-cvs (2009-09-15)
--- LVM2/WHATS_NEW	2009/09/15 01:38:59	1.1261
+++ LVM2/WHATS_NEW	2009/09/15 10:57:16	1.1262
@@ -1,5 +1,5 @@
-Version 2.02.52 -
-=================================
+Version 2.02.52 - 15th September 2009
+=====================================
   Update _process_one_vg to cleanup properly after vg_read_error.
   Add lots of missing stack debug messages to tools.
   Make readonly locking available as locking type 4.
--- LVM2/WHATS_NEW_DM	2009/09/11 15:53:57	1.297
+++ LVM2/WHATS_NEW_DM	2009/09/15 10:57:16	1.298
@@ -1,5 +1,5 @@
-Version 1.02.37 -
-=================================
+Version 1.02.37 - 15th September 2009
+====================================
   Add y|--yes option for dmsetup to provide a default 'YES' answer to questions.
   Fix Makefile to take into account dmsetup's reconfiguration.
   Restore umask when device node creation fails.


