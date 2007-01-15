From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Jan 2007 18:22:02 -0000
Subject: LVM2 ./WHATS_NEW dmeventd/mirror/dmeventd_mirr ...
Message-ID: <20070115182202.10577.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-15 18:22:02

Modified files:
	.              : WHATS_NEW 
	dmeventd/mirror: dmeventd_mirror.c 
	lib/mirror     : mirrored.c 

Log message:
	Some libdevmapper-event interface changes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.540&r2=1.541
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40

--- LVM2/WHATS_NEW	2007/01/12 20:38:29	1.540
+++ LVM2/WHATS_NEW	2007/01/15 18:22:01	1.541
@@ -1,5 +1,6 @@
 Version 2.02.19 - 
 ===================================
+  Some libdevmapper-event interface changes.
   Report dmeventd mirror monitoring status.
   Fix dmeventd mirror status line processing.
 
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/12 20:38:29	1.14
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/15 18:22:01	1.15
@@ -164,7 +164,7 @@
 	return (r == 1) ? 0 : -1;
 }
 
-void process_event(struct dm_task *dmt, enum dm_event_type event)
+void process_event(struct dm_task *dmt, enum dm_event_mask event)
 {
 	void *next = NULL;
 	uint64_t start, length;
--- LVM2/lib/mirror/mirrored.c	2007/01/12 20:38:30	1.39
+++ LVM2/lib/mirror/mirrored.c	2007/01/15 18:22:02	1.40
@@ -393,7 +393,7 @@
 	char *dso, *name;
 	struct logical_volume *lv;
 	struct volume_group *vg;
-	enum dm_event_type events = 0;
+	enum dm_event_mask evmask = 0;
 
 	lv = seg->lv;
 	vg = lv->vg;
@@ -407,27 +407,27 @@
 	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
-	if (!dm_event_get_registered_device(&dso, &name, &events, 0))
+	if (!dm_event_get_registered_device(&dso, &name, &evmask, 0))
 		return 0;
 
-	if (events & DM_EVENT_REGISTRATION_PENDING) {
+	if (evmask & DM_EVENT_REGISTRATION_PENDING) {
 		*pending = 1;
-		events &= ~DM_EVENT_REGISTRATION_PENDING;
+		evmask &= ~DM_EVENT_REGISTRATION_PENDING;
 	}
 
-	return events;
+	return evmask;
 }
 
 /* FIXME This gets run while suspended and performs banned operations. */
 /* FIXME Merge these two functions */
 static int _target_register_events(struct cmd_context *cmd,
 				   struct lv_segment *seg,
-				   int events)
+				   int evmask)
 {
 	char *dso, *name;
 	struct logical_volume *lv;
 	struct volume_group *vg;
-	struct dm_event_handler *handler;
+	struct dm_event_handler *dmevh;
 
 	lv = seg->lv;
 	vg = lv->vg;
@@ -440,17 +440,17 @@
 	if (!(name = build_dm_name(cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
-	if (!(handler = dm_event_handler_create()))
+	if (!(dmevh = dm_event_handler_create()))
 		return_0;
 
-	dm_event_handler_set_dso(handler, dso);
-	dm_event_handler_set_name(handler, name);
-	dm_event_handler_set_events(handler, DM_EVENT_ALL_ERRORS);
-	if (!dm_event_register(handler)) {
-		dm_event_handler_destroy(handler);
+	dm_event_handler_set_dso(dmevh, dso);
+	dm_event_handler_set_devname(dmevh, name);
+	dm_event_handler_set_event_mask(dmevh, DM_EVENT_ALL_ERRORS);
+	if (!dm_event_register_handler(dmevh)) {
+		dm_event_handler_destroy(dmevh);
 		return_0;
 	}
-	dm_event_handler_destroy(handler);
+	dm_event_handler_destroy(dmevh);
 
 	log_info("Registered %s for events", name);
 
@@ -459,13 +459,13 @@
 
 static int _target_unregister_events(struct cmd_context *cmd,
 				     struct lv_segment *seg,
-				     int events)
+				     int evmask)
 {
 	char *dso;
 	char *name;
 	struct logical_volume *lv;
 	struct volume_group *vg;
-	struct dm_event_handler *handler;
+	struct dm_event_handler *dmevh;
 
 	lv = seg->lv;
 	vg = lv->vg;
@@ -477,17 +477,17 @@
 	if (!(name = build_dm_name(cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
-	if (!(handler = dm_event_handler_create()))
+	if (!(dmevh = dm_event_handler_create()))
 		return_0;
 
-	dm_event_handler_set_dso(handler, dso);
-	dm_event_handler_set_name(handler, name);
-	dm_event_handler_set_events(handler, DM_EVENT_ALL_ERRORS);
-	if (!dm_event_unregister(handler)) {
-		dm_event_handler_destroy(handler);
+	dm_event_handler_set_dso(dmevh, dso);
+	dm_event_handler_set_devname(dmevh, name);
+	dm_event_handler_set_event_mask(dmevh, DM_EVENT_ALL_ERRORS);
+	if (!dm_event_unregister_handler(dmevh)) {
+		dm_event_handler_destroy(dmevh);
 		return_0;
 	}
-	dm_event_handler_destroy(handler);
+	dm_event_handler_destroy(dmevh);
 
 	log_info("Unregistered %s for events", name);
 


