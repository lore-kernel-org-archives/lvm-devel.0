From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 29 Aug 2007 20:19:12 -0000
Subject: LVM2 lib/metadata/mirror.c tools/lvconvert.c
Message-ID: <20070829201912.3786.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2007-08-29 20:19:11

Modified files:
	lib/metadata   : mirror.c 
	tools          : lvconvert.c 

Log message:
	When mirrors are created with the --nosync option, a status flag
	(MIRROR_NOTSYNCED) is added to the LVM metadata.  This flag is
	not cleared when converting to linear.  Subsequently, if you
	up-convert the linear to a mirror, the flag remains - even though
	an up-convert will always force a complete resync.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/lib/metadata/mirror.c	2007/08/22 14:38:17	1.41
+++ LVM2/lib/metadata/mirror.c	2007/08/29 20:19:11	1.42
@@ -198,6 +198,7 @@
 		extents = lv1->le_count;
 		_move_lv_segments(mirrored_seg->lv, lv1);
 		mirrored_seg->lv->status &= ~MIRRORED;
+		mirrored_seg->lv->status &= ~MIRROR_NOTSYNCED;
 		remove_log = 1;
 		/* Replace mirror with error segment */
 		segtype = get_segtype_from_string(mirrored_seg->lv->vg->cmd, "error");
--- LVM2/tools/lvconvert.c	2007/08/22 20:03:46	1.38
+++ LVM2/tools/lvconvert.c	2007/08/29 20:19:11	1.39
@@ -418,8 +418,11 @@
 
 			if (sync_percent >= 100.0)
 				init_mirror_in_sync(1);
-			else
+			else {
+				/* A full resync will take place */
+				lv->status &= ~MIRROR_NOTSYNCED;
 				init_mirror_in_sync(0);
+			}
 
 			if (!remove_mirror_images(seg, lp->mirrors,
 						  lp->pv_count ?


