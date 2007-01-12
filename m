From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jan 2007 20:38:31 -0000
Subject: LVM2 ./VERSION ./WHATS_NEW dmeventd/mirror/dme ...
Message-ID: <20070112203831.20631.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-12 20:38:30

Modified files:
	.              : VERSION WHATS_NEW 
	dmeventd/mirror: dmeventd_mirror.c 
	lib/activate   : activate.c 
	lib/metadata   : segtype.h 
	lib/mirror     : mirrored.c 
	tools          : lvchange.c lvrename.c vgchange.c 

Log message:
	Report dmeventd mirror monitoring status.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.539&r2=1.540
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.115&r2=1.116
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/segtype.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvchange.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvrename.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgchange.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/VERSION	2007/01/11 23:17:26	1.137
+++ LVM2/VERSION	2007/01/12 20:38:29	1.138
@@ -1 +1 @@
-2.02.19-cvs (2007-01-11)
+2.02.19-cvs (2007-01-12)
--- LVM2/WHATS_NEW	2007/01/11 23:17:26	1.539
+++ LVM2/WHATS_NEW	2007/01/12 20:38:29	1.540
@@ -1,5 +1,7 @@
 Version 2.02.19 - 
 ===================================
+  Report dmeventd mirror monitoring status.
+  Fix dmeventd mirror status line processing.
 
 Version 2.02.18 - 11th January 2007
 ===================================
--- LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/11 22:24:31	1.13
+++ LVM2/dmeventd/mirror/dmeventd_mirror.c	2007/01/12 20:38:29	1.14
@@ -15,7 +15,6 @@
 #include "libdevmapper.h"
 #include "libdevmapper-event.h"
 #include "lvm2cmd.h"
-#include "lvm-string.h"
 
 #include <errno.h>
 #include <signal.h>
@@ -62,8 +61,12 @@
 	int log_argc, num_devs;
 
 	/*
-	 * Unused:  0 409600 mirror
-	 * Used  :  2 253:4 253:5 400/400 1 AA 3 cluster 253:3 A
+	 * dm core parms:	     0 409600 mirror
+	 * Mirror core parms:	     2 253:4 253:5 400/400
+	 * New-style failure params: 1 AA
+	 * New-style log params:     3 cluster 253:3 A
+	 *			 or  3 disk 253:3 A
+	 *			 or  1 core
 	 */
 
 	/* number of devices */
@@ -74,9 +77,9 @@
 		goto out_parse;
 	p += strlen(p) + 1;
 
-	/* devices names + max log parameters */
-	args = dm_malloc((num_devs + 8) * sizeof(char *));
-	if (!args || dm_split_words(p, num_devs + 8, 0, args) < num_devs + 8)
+	/* devices names + "400/400" + "1 AA" + 1 or 3 log parms + NULL */
+	args = dm_malloc((num_devs + 7) * sizeof(char *));
+	if (!args || dm_split_words(p, num_devs + 7, 0, args) < num_devs + 5)
 		goto out_parse;
 
 	dev_status_str = args[2 + num_devs];
--- LVM2/lib/activate/activate.c	2006/12/20 16:19:01	1.115
+++ LVM2/lib/activate/activate.c	2007/01/12 20:38:29	1.116
@@ -655,10 +655,11 @@
 			    struct logical_volume *lv, int do_reg)
 {
 #ifdef DMEVENTD
+	int i, pending = 0, registered;
 	int r = 0;
 	struct list *tmp;
 	struct lv_segment *seg;
-	int (*reg) (struct lv_segment *, int events);
+	int (*reg) (struct cmd_context *c, struct lv_segment *s, int e);
 
 	if (do_reg && !dmeventd_register_mode())
 		return 1;
@@ -666,24 +667,59 @@
 	list_iterate(tmp, &lv->segments) {
 		seg = list_item(tmp, struct lv_segment);
 
+		if (!seg_monitored(seg) || (seg->status & PVMOVE))
+			continue;
 		reg = NULL;
 
+		/* Check monitoring status */
+		if (seg->segtype->ops->target_registered)
+			registered = seg->segtype->ops->target_registered(seg, &pending);
+		else
+			continue;  /* segtype doesn't support registration */
+
+		/*
+		 * FIXME: We should really try again if pending
+		 */
+		registered = (pending) ? 0 : registered;
+
 		if (do_reg) {
-			if (seg->segtype->ops->target_register_events)
+			if (registered)
+				log_verbose("%s/%s already monitored.", lv->vg->name, lv->name);
+			else if (seg->segtype->ops->target_register_events)
 				reg = seg->segtype->ops->target_register_events;
-		} else if (seg->segtype->ops->target_unregister_events)
-			reg = seg->segtype->ops->target_unregister_events;
+		} else {
+			if (!registered)
+				log_verbose("%s/%s already not monitored.", lv->vg->name, lv->name);
+			else if (seg->segtype->ops->target_unregister_events)
+				reg = seg->segtype->ops->target_unregister_events;
+		}
 
+		/* Do [un]monitor */
 		if (!reg)
 			continue;
 
 		/* FIXME specify events */
-		if (!reg(seg, 0)) {
+		if (!reg(cmd, seg, 0)) {
 			stack;
 			return -1;
 		}
 
-		r = 1;
+		/* Check [un]monitor results */
+		/* Try a couple times if pending, but not forever... */
+		for (i = 0; i < 10; i++) {
+			pending = 0;
+			registered = seg->segtype->ops->target_registered(seg, &pending);
+			if (pending ||
+			    (!registered && do_reg) ||
+			    (registered && !do_reg))
+				log_very_verbose("%s/%s %smonitoring still pending.",
+						 lv->vg->name, lv->name, do_reg ? "" : "un");
+			else
+				break;
+			sleep(1);
+		}
+
+		r = (registered && do_reg) || (!registered && !do_reg);
 	}
 
 	return r;
@@ -728,7 +764,7 @@
 		}
 	}
 
-	if (register_dev_for_events(cmd, lv, 0) != 1)
+	if (register_dev_for_events(cmd, lv, 0) < 0)
 		/* FIXME Consider aborting here */
 		stack;
 
@@ -786,7 +822,7 @@
 	memlock_dec();
 	fs_unlock();
 
-	if (register_dev_for_events(cmd, lv, 1) != 1)
+	if (register_dev_for_events(cmd, lv, 1) < 0)
 		stack;
 
 	return 1;
@@ -832,7 +868,7 @@
 		return 0;
 	}
 
-	if (register_dev_for_events(cmd, lv, 0) != 1)
+	if (register_dev_for_events(cmd, lv, 0) < 0)
 		stack;
 
 	memlock_inc();
@@ -905,7 +941,7 @@
 	memlock_dec();
 	fs_unlock();
 
-	if (!register_dev_for_events(cmd, lv, 1) != 1)
+	if (!register_dev_for_events(cmd, lv, 1) < 0)
 		stack;
 
 	return r;
--- LVM2/lib/metadata/segtype.h	2006/10/18 18:01:52	1.14
+++ LVM2/lib/metadata/segtype.h	2007/01/12 20:38:29	1.15
@@ -32,6 +32,7 @@
 #define SEG_FORMAT1_SUPPORT	0x00000010U
 #define SEG_VIRTUAL		0x00000020U
 #define SEG_CANNOT_BE_ZEROED	0x00000040U
+#define SEG_MONITORED		0x00000080U
 
 #define seg_is_mirrored(seg)	((seg)->segtype->flags & SEG_AREAS_MIRRORED ? 1 : 0)
 #define seg_is_striped(seg)	((seg)->segtype->flags & SEG_AREAS_STRIPED ? 1 : 0)
@@ -39,6 +40,7 @@
 #define seg_is_virtual(seg)	((seg)->segtype->flags & SEG_VIRTUAL ? 1 : 0)
 #define seg_can_split(seg)	((seg)->segtype->flags & SEG_CAN_SPLIT ? 1 : 0)
 #define seg_cannot_be_zeroed(seg) ((seg)->segtype->flags & SEG_CANNOT_BE_ZEROED ? 1 : 0)
+#define seg_monitored(seg)	((seg)->segtype->flags & SEG_MONITORED ? 1 : 0)
 
 #define segtype_is_striped(segtype)	((segtype)->flags & SEG_AREAS_STRIPED ? 1 : 0)
 #define segtype_is_mirrored(segtype)	((segtype)->flags & SEG_AREAS_MIRRORED ? 1 : 0)
@@ -81,8 +83,11 @@
 			       const struct lv_segment *seg,
 			       struct list *modules);
 	void (*destroy) (const struct segment_type * segtype);
-	int (*target_register_events) (struct lv_segment *seg, int events);
-	int (*target_unregister_events) (struct lv_segment *seg, int events);
+	int (*target_registered) (struct lv_segment *seg, int *pending);
+	int (*target_register_events) (struct cmd_context *cmd,
+				       struct lv_segment *seg, int events);
+	int (*target_unregister_events) (struct cmd_context *cmd,
+					 struct lv_segment *seg, int events);
 };
 
 struct segment_type *get_segtype_from_string(struct cmd_context *cmd,
--- LVM2/lib/mirror/mirrored.c	2007/01/11 22:24:32	1.38
+++ LVM2/lib/mirror/mirrored.c	2007/01/12 20:38:30	1.39
@@ -368,13 +368,12 @@
 }
 
 #ifdef DMEVENTD
-static int _setup_registration(struct dm_pool *mem, struct cmd_context *cmd,
-			       char **dso)
+static int _setup_registration(struct cmd_context *cmd, char **dso)
 {
 	char *path;
 	const char *libpath;
 
-	if (!(path = dm_pool_alloc(mem, PATH_MAX))) {
+	if (!(path = dm_pool_alloc(cmd->mem, PATH_MAX))) {
 		log_error("Failed to allocate dmeventd library path.");
 		return 0;
 	}
@@ -389,9 +388,40 @@
 	return 1;
 }
 
+static int _target_registered(struct lv_segment *seg, int *pending)
+{
+	char *dso, *name;
+	struct logical_volume *lv;
+	struct volume_group *vg;
+	enum dm_event_type events = 0;
+
+	lv = seg->lv;
+	vg = lv->vg;
+
+	*pending = 0;
+	if (!_setup_registration(vg->cmd, &dso)) {
+		stack;
+		return 0;
+	}
+
+	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
+		return_0;
+
+	if (!dm_event_get_registered_device(&dso, &name, &events, 0))
+		return 0;
+
+	if (events & DM_EVENT_REGISTRATION_PENDING) {
+		*pending = 1;
+		events &= ~DM_EVENT_REGISTRATION_PENDING;
+	}
+
+	return events;
+}
+
 /* FIXME This gets run while suspended and performs banned operations. */
 /* FIXME Merge these two functions */
-static int _target_register_events(struct lv_segment *seg,
+static int _target_register_events(struct cmd_context *cmd,
+				   struct lv_segment *seg,
 				   int events)
 {
 	char *dso, *name;
@@ -402,12 +432,12 @@
 	lv = seg->lv;
 	vg = lv->vg;
 
-	if (!_setup_registration(vg->cmd->mem, vg->cmd, &dso)) {
+	if (!_setup_registration(cmd, &dso)) {
 		stack;
 		return 0;
 	}
 
-	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
+	if (!(name = build_dm_name(cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
 	if (!(handler = dm_event_handler_create()))
@@ -427,7 +457,8 @@
 	return 1;
 }
 
-static int _target_unregister_events(struct lv_segment *seg,
+static int _target_unregister_events(struct cmd_context *cmd,
+				     struct lv_segment *seg,
 				     int events)
 {
 	char *dso;
@@ -440,10 +471,10 @@
 	vg = lv->vg;
 
 	/* FIXME Remove this and use handle to avoid config file race */
-	if (!_setup_registration(vg->cmd->mem, vg->cmd, &dso))
+	if (!_setup_registration(cmd, &dso))
 		return_0;
 
-	if (!(name = build_dm_name(vg->cmd->mem, vg->name, lv->name, NULL)))
+	if (!(name = build_dm_name(cmd->mem, vg->name, lv->name, NULL)))
 		return_0;
 
 	if (!(handler = dm_event_handler_create()))
@@ -504,6 +535,7 @@
 	.target_percent = _mirrored_target_percent,
 	.target_present = _mirrored_target_present,
 #ifdef DMEVENTD
+	.target_registered = _target_registered,
 	.target_register_events = _target_register_events,
 	.target_unregister_events = _target_unregister_events,
 #endif
@@ -530,7 +562,7 @@
 	segtype->ops = &_mirrored_ops;
 	segtype->name = "mirror";
 	segtype->private = NULL;
-	segtype->flags = SEG_AREAS_MIRRORED;
+	segtype->flags = SEG_AREAS_MIRRORED | SEG_MONITORED;
 
 	log_very_verbose("Initialised segtype: %s", segtype->name);
 
--- LVM2/tools/lvchange.c	2007/01/10 19:56:39	1.75
+++ LVM2/tools/lvchange.c	2007/01/12 20:38:30	1.76
@@ -104,8 +104,10 @@
 			  (dmeventd_register_mode()) ? "" : "un", lv->name);
 		r = 0;
 	} else if (!r) {
-		log_verbose("Logical volume %s needs no monitoring.",
-			    lv->name);
+		log_verbose("Logical volume %s needs no %smonitoring, or is already %smonitored",
+			    (dmeventd_register_mode()) ? "" : "un",
+			    lv->name,
+			    (dmeventd_register_mode()) ? "" : "un");
 		r = 1;
 	}
 
--- LVM2/tools/lvrename.c	2006/09/02 01:18:17	1.40
+++ LVM2/tools/lvrename.c	2007/01/12 20:38:30	1.41
@@ -152,6 +152,14 @@
 		goto error;
 	}
 
+	if ((lv->status & MIRRORED) ||
+	    (lv->status & MIRROR_LOG) ||
+	    (lv->status & MIRROR_IMAGE)) {
+		log_error("Mirrored LV, \"%s\" cannot be renamed: %s",
+			  lv->name, strerror(ENOSYS));
+		goto error;
+	}
+
 	if (!archive(lv->vg)) {
 		stack;
 		goto error;
--- LVM2/tools/vgchange.c	2006/08/16 14:41:42	1.54
+++ LVM2/tools/vgchange.c	2007/01/12 20:38:30	1.55
@@ -53,8 +53,7 @@
 	}
 
 	/*
-	 * returns the number of monitored devices, not the number
-	 * of _new_ monitored devices
+	 * returns the number of _new_ monitored devices
 	 */
 
 	return count;
@@ -117,7 +116,7 @@
 	if ((active = lvs_in_vg_activated(vg))) {
 		monitored = _register_lvs_in_vg(cmd, vg, dmeventd_register_mode());
 		log_print("%d logical volume(s) in volume group "
-			    "\"%s\" now %smonitored",
+			    "\"%s\" %smonitored",
 			    monitored, vg->name, (dmeventd_register_mode()) ? "" : "un");
 	}
 
@@ -157,7 +156,7 @@
 			    "already active", active, vg->name);
 		monitored = _register_lvs_in_vg(cmd, vg, dmeventd_register_mode());
 		log_verbose("%d existing logical volume(s) in volume "
-			    "group \"%s\" now %smonitored",
+			    "group \"%s\" %smonitored",
 			    monitored, vg->name,
 			    dmeventd_register_mode() ? "" : "un");
 	}


