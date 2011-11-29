From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 29 Nov 2011 12:10:39 -0000
Subject: LVM2/lib/replicator replicator.c
Message-ID: <20111129121039.21012.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-11-29 12:10:39

Modified files:
	lib/replicator : replicator.c 

Log message:
	Fix last checkin for replicator.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/lib/replicator/replicator.c	2011/11/28 20:37:52	1.10
+++ LVM2/lib/replicator/replicator.c	2011/11/29 12:10:38	1.11
@@ -626,8 +626,8 @@
 		log_very_verbose("Inactive replicator %s using %s.",
 				 seg->lv->name, seg->lv->rdevice->lv->name);
 		if (!add_linear_area_to_dtree(node, seg->lv->size, seg->lv->vg->extent_size,
-					      dm->cmd->use_linear_target,
-					      seg->lv->vg->name, seg->lv_name))
+					      cmd->use_linear_target,
+					      seg->lv->vg->name, seg->lv->name))
 			return_0;
 		if (!(rdev_dlid = build_dm_uuid(mem, seg->lv->rdevice->lv->lvid.s, NULL)))
 			return_0;


