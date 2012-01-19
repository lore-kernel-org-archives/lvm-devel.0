From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:25:41 -0000
Subject: LVM2 lib/activate/activate.c lib/activate/acti ...
Message-ID: <20120119152541.27186.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:25:39

Modified files:
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 
	tools          : lvresize.c 

Log message:
	Thin updated support for thin pool percent
	
	Support to check also for metadata percent
	(By checking whether seg pointer is set)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.228&r2=1.229
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.259&r2=1.260
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.42&r2=1.43
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvresize.c.diff?cvsroot=lvm2&r1=1.147&r2=1.148

--- LVM2/lib/activate/activate.c	2012/01/12 09:08:55	1.228
+++ LVM2/lib/activate/activate.c	2012/01/19 15:25:37	1.229
@@ -710,9 +710,11 @@
 }
 
 /*
+ * Returns data or metadata percent usage, depends on metadata 0/1.
  * Returns 1 if percent set, else 0 on failure.
  */
-int lv_thin_pool_percent(const struct logical_volume *lv, percent_t *percent)
+int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
+			 percent_t *percent)
 {
 	int r;
 	struct dev_manager *dm;
@@ -720,12 +722,13 @@
 	if (!activation())
 		return 0;
 
-	log_debug("Checking thin pool percent for LV %s/%s", lv->vg->name, lv->name);
+	log_debug("Checking thin %sdata percent for LV %s/%s",
+		  (metadata) ? "meta" : "", lv->vg->name, lv->name);
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, 1)))
 		return_0;
 
-	if (!(r = dev_manager_thin_pool_percent(dm, lv, percent)))
+	if (!(r = dev_manager_thin_pool_percent(dm, lv, metadata, percent)))
 		stack;
 
 	dev_manager_destroy(dm);
--- LVM2/lib/activate/activate.h	2012/01/12 01:51:56	1.91
+++ LVM2/lib/activate/activate.h	2012/01/19 15:25:38	1.92
@@ -101,7 +101,8 @@
 int lv_mirror_percent(struct cmd_context *cmd, const struct logical_volume *lv,
 		      int wait, percent_t *percent, uint32_t *event_nr);
 int lv_raid_percent(const struct logical_volume *lv, percent_t *percent);
-int lv_thin_pool_percent(const struct logical_volume *lv, percent_t *percent);
+int lv_thin_pool_percent(const struct logical_volume *lv, int metadata,
+			 percent_t *percent);
 
 /*
  * Return number of LVs in the VG that are active.
--- LVM2/lib/activate/dev_manager.c	2012/01/19 15:23:50	1.259
+++ LVM2/lib/activate/dev_manager.c	2012/01/19 15:25:38	1.260
@@ -874,7 +874,7 @@
 
 int dev_manager_thin_pool_percent(struct dev_manager *dm,
 				  const struct logical_volume *lv,
-				  percent_t *percent)
+				  int metadata, percent_t *percent)
 {
 	char *name;
 	const char *dlid;
@@ -888,8 +888,8 @@
 		return_0;
 
 	log_debug("Getting device status percentage for %s", name);
-	if (!(_percent(dm, name, dlid, "thin-pool", 0, NULL, percent,
-		       NULL, 1)))
+	if (!(_percent(dm, name, dlid, "thin-pool", 0,
+		       (metadata) ? lv : NULL, percent, NULL, 1)))
 		return_0;
 
 	return 1;
--- LVM2/lib/activate/dev_manager.h	2012/01/12 01:51:56	1.42
+++ LVM2/lib/activate/dev_manager.h	2012/01/19 15:25:38	1.43
@@ -56,7 +56,7 @@
 			       percent_t *percent, uint32_t *event_nr);
 int dev_manager_thin_pool_percent(struct dev_manager *dm,
 				  const struct logical_volume *lv,
-				  percent_t *percent);
+				  int metadata, percent_t *percent);
 int dev_manager_suspend(struct dev_manager *dm, struct logical_volume *lv,
 			struct lv_activate_opts *laopts, int lockfs, int flush_required);
 int dev_manager_activate(struct dev_manager *dm, struct logical_volume *lv,
--- LVM2/tools/lvresize.c	2012/01/09 12:31:53	1.147
+++ LVM2/tools/lvresize.c	2012/01/19 15:25:39	1.148
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -305,7 +305,16 @@
 		return 1; /* nothing to do */
 
 	if (lv_is_thin_pool(lv)) {
-		if (!lv_thin_pool_percent(lv, &percent))
+		if (!lv_thin_pool_percent(lv, 1, &percent))
+			return_0;
+		if (percent > policy_threshold) {
+			/* FIXME: metadata resize support missing */
+			log_error("Resize for %s/%s is not yet supported.",
+				  lp->vg_name, lp->lv_name);
+			return ECMD_FAILED;
+		}
+
+		if (!lv_thin_pool_percent(lv, 0, &percent))
 			return_0;
 		if (!(PERCENT_0 < percent && percent <= PERCENT_100) ||
 		    percent <= policy_threshold)


