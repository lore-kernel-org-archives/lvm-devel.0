From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 23 Apr 2008 12:53:11 -0000
Subject: LVM2 ./WHATS_NEW tools/vgmerge.c
Message-ID: <20080423125311.22330.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-04-23 12:53:10

Modified files:
	.              : WHATS_NEW 
	tools          : vgmerge.c 

Log message:
	Fix internal snapshot_count when vgmerge with snapshots in source VG.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.858&r2=1.859
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgmerge.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/WHATS_NEW	2008/04/23 09:53:49	1.858
+++ LVM2/WHATS_NEW	2008/04/23 12:53:10	1.859
@@ -1,5 +1,6 @@
 Version 2.02.36 - 
 =================================
+  Fix internal snapshot_count when vgmerge with snapshots in source VG.
   Simply clvmd-openais by using non-async saLckResourceLock.
   Check lv_count in vg_validate.
   Fix internal LV counter when a snapshot is removed.
--- LVM2/tools/vgmerge.c	2008/04/10 19:14:26	1.47
+++ LVM2/tools/vgmerge.c	2008/04/23 12:53:10	1.48
@@ -99,6 +99,7 @@
 	}
 
 	vg_to->lv_count += vg_from->lv_count;
+	vg_to->snapshot_count += vg_from->snapshot_count;
 
 	vg_to->extent_count += vg_from->extent_count;
 	vg_to->free_count += vg_from->free_count;


