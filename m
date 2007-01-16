From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2007 23:05:17 -0000
Subject: LVM2/lib/mirror mirrored.c
Message-ID: <20070116230517.13775.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-16 23:05:15

Modified files:
	lib/mirror     : mirrored.c 

Log message:
	use updated dm_event_get_registered_device interface

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/lib/mirror/mirrored.c	2007/01/16 18:06:11	1.41
+++ LVM2/lib/mirror/mirrored.c	2007/01/16 23:05:13	1.42
@@ -394,6 +394,7 @@
 	struct logical_volume *lv;
 	struct volume_group *vg;
 	enum dm_event_mask evmask = 0;
+	struct dm_event_handler *dmevh;
 
 	lv = seg->lv;
 	vg = lv->vg;
@@ -407,14 +408,26 @@
 	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
-	if (!dm_event_get_registered_device(&dso, &name, &evmask, 0))
+	if (!(dmevh = dm_event_handler_create()))
+		return_0;
+
+	dm_event_handler_set_dso(dmevh, dso);
+	dm_event_handler_set_dev_name(dmevh, name);
+	dm_event_handler_set_event_mask(dmevh, DM_EVENT_ALL_ERRORS);
+
+	if (dm_event_get_registered_device(dmevh, 0)) {
+		dm_event_handler_destroy(dmevh);
 		return 0;
+	}
 
+	evmask = dm_event_handler_get_event_mask(dmevh);
 	if (evmask & DM_EVENT_REGISTRATION_PENDING) {
 		*pending = 1;
 		evmask &= ~DM_EVENT_REGISTRATION_PENDING;
 	}
 
+	dm_event_handler_destroy(dmevh);
+
 	return evmask;
 }
 


