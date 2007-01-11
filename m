From: agk@sourceware.org <agk@sourceware.org>
Date: 11 Jan 2007 22:24:32 -0000
Subject: LVM2 ./WHATS_NEW dmeventd/mirror/dmeventd_mirr ...
Message-ID: <20070111222432.29912.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-11 22:24:32

Modified files:
	.              : WHATS_NEW 
	dmeventd/mirror: dmeventd_mirror.c 
	lib/mirror     : mirrored.c 

Log message:
	updated dmeventd interface

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.536&r2=1.537
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/WHATS_NEW	2007/01/11 19:52:06	1.536
+++ LVM2/WHATS_NEW	2007/01/11 22:24:31	1.537
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Revised libdevmapper-event interface for dmeventd.
   Remove dmeventd mirror status line word limit.
   Use CFLAGS when linking so mixed sparc builds can supply -m64.
   Prevent permission changes on active mirrors.
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/11 20:11:19	1.12
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/11 22:24:31	1.13
@@ -161,34 +161,18 @@
 	return (r == 1) ? 0 : -1;
 }
 
-void process_event(const char *device, enum dm_event_type event)
+void process_event(struct dm_task *dmt, enum dm_event_type event)
 {
-	struct dm_task *dmt;
 	void *next = NULL;
 	uint64_t start, length;
 	char *target_type = NULL;
 	char *params;
+	const char *device = dm_task_get_name(dmt);
 
 	if (pthread_mutex_trylock(&_event_mutex)) {
 		syslog(LOG_NOTICE, "Another thread is handling an event.  Waiting...");
 		pthread_mutex_lock(&_event_mutex);
 	}
-	/* FIXME Move inside libdevmapper */
-	if (!(dmt = dm_task_create(DM_DEVICE_STATUS))) {
-		syslog(LOG_ERR, "Unable to create dm_task.\n");
-		goto fail;
-	}
-
-	if (!dm_task_set_name(dmt, device)) {
-		syslog(LOG_ERR, "Unable to set device name.\n");
-		goto fail;
-	}
-
-	if (!dm_task_run(dmt)) {
-		syslog(LOG_ERR, "Unable to run task.\n");
-		goto fail;
-	}
-
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
@@ -226,24 +210,21 @@
 		case ME_IGNORE:
 			break;
 		default:
-			/* FIXME Wrong: it can also return -E2BIG but it's never used! */
+			/* FIXME Provide value then! */
 			syslog(LOG_INFO, "Unknown event received.\n");
 		}
 	} while (next);
 
- fail:
-	if (dmt)
-		dm_task_destroy(dmt);
 	pthread_mutex_unlock(&_event_mutex);
 }
 
-int register_device(const char *device)
+int register_device(const char *device, const char *uuid, int major, int minor)
 {
 	int r = 0;
 
 	pthread_mutex_lock(&_register_mutex);
 
-	syslog(LOG_INFO, "Monitoring mirror device, %s for events\n", device);
+	syslog(LOG_INFO, "Monitoring mirror device %s for events\n", device);
 
 	/*
 	 * Need some space for allocations.  1024 should be more
@@ -273,10 +254,13 @@
 	return r;
 }
 
-int unregister_device(const char *device)
+int unregister_device(const char *device, const char *uuid, int major, int minor)
 {
 	pthread_mutex_lock(&_register_mutex);
 
+	syslog(LOG_INFO, "No longer monitoring mirror device %s for events\n",
+	       device);
+
 	if (!--_register_count) {
 		dm_pool_destroy(_mem_pool);
 		_mem_pool = NULL;
--- LVM2/lib/mirror/mirrored.c	2006/10/18 18:01:52	1.37
+++ LVM2/lib/mirror/mirrored.c	2007/01/11 22:24:32	1.38
@@ -397,6 +397,7 @@
 	char *dso, *name;
 	struct logical_volume *lv;
 	struct volume_group *vg;
+	struct dm_event_handler *handler;
 
 	lv = seg->lv;
 	vg = lv->vg;
@@ -409,10 +410,18 @@
 	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
-	/* FIXME Save a returned handle here so we can unregister it later */
-	if (!dm_event_register(dso, name, DM_EVENT_ALL_ERRORS))
+	if (!(handler = dm_event_handler_create()))
 		return_0;
 
+	dm_event_handler_set_dso(handler, dso);
+	dm_event_handler_set_name(handler, name);
+	dm_event_handler_set_events(handler, DM_EVENT_ALL_ERRORS);
+	if (!dm_event_register(handler)) {
+		dm_event_handler_destroy(handler);
+		return_0;
+	}
+	dm_event_handler_destroy(handler);
+
 	log_info("Registered %s for events", name);
 
 	return 1;
@@ -425,6 +434,7 @@
 	char *name;
 	struct logical_volume *lv;
 	struct volume_group *vg;
+	struct dm_event_handler *handler;
 
 	lv = seg->lv;
 	vg = lv->vg;
@@ -436,10 +446,18 @@
 	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
-	/* FIXME Use handle returned by registration function instead of dso */
-	if (!dm_event_unregister(dso, name, DM_EVENT_ALL_ERRORS))
+	if (!(handler = dm_event_handler_create()))
 		return_0;
 
+	dm_event_handler_set_dso(handler, dso);
+	dm_event_handler_set_name(handler, name);
+	dm_event_handler_set_events(handler, DM_EVENT_ALL_ERRORS);
+	if (!dm_event_unregister(handler)) {
+		dm_event_handler_destroy(handler);
+		return_0;
+	}
+	dm_event_handler_destroy(handler);
+
 	log_info("Unregistered %s for events", name);
 
 	return 1;


