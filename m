From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 23 Jan 2012 20:56:44 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20120123205644.21793.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-01-23 20:56:43

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Fix the way RAID meta LVs are added to the dependency tree.
	
	Similar to the "mirror" segment type's log device, _add_dev_to_dtree should
	be called and not _add_lv_to_dtree when adding metadata sub-LVs to the deptree.
	Since _add_lv_to_dtree was being called, 'origin_only' could be set if a
	snapshot sits on top of the RAID device.  This would cause the actual device
	that needed to be added to be skipped in favor of the non-existant device,
	"<foo>-real".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2234&r2=1.2235
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.263&r2=1.264

--- LVM2/WHATS_NEW	2012/01/21 05:29:51	1.2234
+++ LVM2/WHATS_NEW	2012/01/23 20:56:42	1.2235
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Fix the way RAID meta LVs are added to the dependency tree.
   Change exclusive LV activation logic to try local node before remote nodes.
   Add CLVMD_FLAG_REMOTE to skip processing on local node.
   Prompt if request is made to remove a snapshot whose "Merge failed".
--- LVM2/lib/activate/dev_manager.c	2012/01/20 22:02:04	1.263
+++ LVM2/lib/activate/dev_manager.c	2012/01/23 20:56:43	1.264
@@ -1176,8 +1176,8 @@
 
 	if (lv->status & RAID)
 		for (s = 0; s < seg->area_count; s++)
-			if (!_add_lv_to_dtree(dm, dtree,
-					      seg_metalv(seg, s), origin_only))
+			if (!_add_dev_to_dtree(dm, dtree,
+					       seg_metalv(seg, s), NULL))
 				return_0;
 
 	/* Add any LVs referencing a PVMOVE LV unless told not to. */


