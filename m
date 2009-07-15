From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jul 2009 13:20:10 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090715132010.636.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-15 13:20:08

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.200&r2=1.201
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1184&r2=1.1185
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.285&r2=1.286

--- LVM2/VERSION	2009/07/01 09:31:46	1.200
+++ LVM2/VERSION	2009/07/15 13:20:06	1.201
@@ -1 +1 @@
-2.02.49-cvs (2009-06-30)
+2.02.49-cvs (2009-07-15)
--- LVM2/VERSION_DM	2009/07/01 09:31:46	1.13
+++ LVM2/VERSION_DM	2009/07/15 13:20:06	1.14
@@ -1 +1 @@
-1.02.34-cvs (2009-06-30)
+1.02.34-cvs (2009-07-15)
--- LVM2/WHATS_NEW	2009/07/14 19:59:41	1.1184
+++ LVM2/WHATS_NEW	2009/07/15 13:20:06	1.1185
@@ -1,4 +1,4 @@
-Version 2.02.49 - 
+Version 2.02.49 - 15th July 2009
 ================================
   Fix vgck and vgremove segfault if non-existent vg given.
   Enable use of new multi-segment registration for static registration too.
--- LVM2/WHATS_NEW_DM	2009/07/10 09:59:37	1.285
+++ LVM2/WHATS_NEW_DM	2009/07/15 13:20:07	1.286
@@ -1,4 +1,4 @@
-Version 1.02.34 - 
+Version 1.02.34 - 15th July 2009
 ================================
   Rename plog macro to LOG_LINE and use in dm_dump_memory_debug.
   Change plog to use dm_log_with_errno unless deprecated dm_log_init was used.


