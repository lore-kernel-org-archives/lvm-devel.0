From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jul 2009 15:38:41 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090715153841.16870.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-15 15:38:41

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.201&r2=1.202
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1187&r2=1.1188
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.287&r2=1.288

--- LVM2/VERSION	2009/07/15 13:20:06	1.201
+++ LVM2/VERSION	2009/07/15 15:38:41	1.202
@@ -1 +1 @@
-2.02.49-cvs (2009-07-15)
+2.02.50-cvs (2009-07-15)
--- LVM2/VERSION_DM	2009/07/15 13:20:06	1.14
+++ LVM2/VERSION_DM	2009/07/15 15:38:41	1.15
@@ -1 +1 @@
-1.02.34-cvs (2009-07-15)
+1.02.35-cvs (2009-07-15)
--- LVM2/WHATS_NEW	2009/07/15 15:16:48	1.1187
+++ LVM2/WHATS_NEW	2009/07/15 15:38:41	1.1188
@@ -1,3 +1,6 @@
+Version 2.02.50 - 
+================================
+
 Version 2.02.49 - 15th July 2009
 ================================
   Exclude VG_GLOBAL from vg_write_lock_held so scans open devs read-only again.
--- LVM2/WHATS_NEW_DM	2009/07/15 14:18:38	1.287
+++ LVM2/WHATS_NEW_DM	2009/07/15 15:38:41	1.288
@@ -1,3 +1,6 @@
+Version 1.02.35 - 
+================================
+
 Version 1.02.34 - 15th July 2009
 ================================
   Use _exit() not exit() after forking to avoid flushing libc buffers twice.


