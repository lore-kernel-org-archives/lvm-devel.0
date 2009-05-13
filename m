From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 13 May 2009 14:13:57 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20090513141357.26343.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2009-05-13 14:13:55

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Do not query nonexistent devices for readahead.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1102&r2=1.1103
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/WHATS_NEW	2009/05/13 13:02:52	1.1102
+++ LVM2/WHATS_NEW	2009/05/13 14:13:54	1.1103
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Do not query nonexistent devices for readahead.
   Remove NON_BLOCKING lock flag from tools and set a policy to auto-set.
   Remove snapshot_count from VG and use function instead.
   Fix first_seg() call for empty segment list.
--- LVM2/lib/activate/dev_manager.c	2009/05/07 12:01:21	1.147
+++ LVM2/lib/activate/dev_manager.c	2009/05/13 14:13:55	1.148
@@ -141,7 +141,7 @@
 	if (!dm_task_get_info(dmt, info))
 		goto_out;
 
-	if (with_read_ahead) {
+	if (with_read_ahead && info->exists) {
 		if (!dm_task_get_read_ahead(dmt, read_ahead))
 			goto_out;
 	} else if (read_ahead)


