From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Jan 2012 01:51:57 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/activ ...
Message-ID: <20120112015157.23295.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-01-12 01:51:56

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/activate   : activate.c activate.h dev_manager.c 
	                 dev_manager.h 

Log message:
	Add activation/read_only_volume_list to override LV permission in metadata.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2219&r2=1.2220
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.226&r2=1.227
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.256&r2=1.257
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.h.diff?cvsroot=lvm2&r1=1.41&r2=1.42

--- LVM2/WHATS_NEW	2012/01/11 20:38:42	1.2219
+++ LVM2/WHATS_NEW	2012/01/12 01:51:56	1.2220
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add activation/read_only_volume_list to override LV permission in metadata.
   Give priority to emcpower devices with duplicate PVIDs.
   Add check for error in _adjust_policy_params() (lvextend --use-policies).
   Supports rounding of percentage (%LV, %VG...) for LV resize upward.
--- LVM2/doc/example.conf.in	2011/12/21 13:10:52	1.40
+++ LVM2/doc/example.conf.in	2012/01/12 01:51:56	1.41
@@ -513,6 +513,16 @@
     #
     # volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 
+    # If read_only_volume_list is defined, each LV that is to be activated 
+    # is checked against the list, and if it matches, it as activated
+    # in read-only mode.  (This overrides '--permission rw' stored in the
+    # metadata.)
+    #   "vgname" and "vgname/lvname" are matched exactly.
+    #   "@tag" matches any tag set in the LV or VG.
+    #   "@*" matches if any tag defined on the host is also set in the LV or VG
+    #
+    # read_only_volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
+
     # Size (in KB) of each copy operation when mirroring
     mirror_region_size = 512
 
--- LVM2/lib/activate/activate.c	2011/12/21 13:10:05	1.226
+++ LVM2/lib/activate/activate.c	2012/01/12 01:51:56	1.227
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -288,49 +288,29 @@
 	return _activation;
 }
 
-static int _passes_activation_filter(struct cmd_context *cmd,
-				     struct logical_volume *lv)
+static int _passes_volumes_filter(struct cmd_context *cmd,
+				  struct logical_volume *lv,
+				  const struct dm_config_node *cn,
+				  const char *config_path)
 {
-	const struct dm_config_node *cn;
 	const struct dm_config_value *cv;
 	const char *str;
 	static char path[PATH_MAX];
 
-	if (!(cn = find_config_tree_node(cmd, "activation/volume_list"))) {
-		log_verbose("activation/volume_list configuration setting "
-			    "not defined, checking only host tags for %s/%s",
-			    lv->vg->name, lv->name);
-
-		/* If no host tags defined, activate */
-		if (dm_list_empty(&cmd->tags))
-			return 1;
-
-		/* If any host tag matches any LV or VG tag, activate */
-		if (str_list_match_list(&cmd->tags, &lv->tags, NULL) ||
-		    str_list_match_list(&cmd->tags, &lv->vg->tags, NULL))
-			return 1;
-
-		log_verbose("No host tag matches %s/%s",
-			    lv->vg->name, lv->name);
-
-		/* Don't activate */
-		return 0;
-	}
-	else
-		log_verbose("activation/volume_list configuration setting "
-			    "defined, checking the list to match %s/%s",
-			    lv->vg->name, lv->name);
+	log_verbose("%s configuration setting defined: "
+		    "Checking the list to match %s/%s",
+		    config_path, lv->vg->name, lv->name);
 
 	for (cv = cn->v; cv; cv = cv->next) {
 		if (cv->type != DM_CFG_STRING) {
-			log_error("Ignoring invalid string in config file "
-				  "activation/volume_list");
+			log_error("Ignoring invalid string in config file %s",
+				  config_path);
 			continue;
 		}
 		str = cv->v.str;
 		if (!*str) {
-			log_error("Ignoring empty string in config file "
-				  "activation/volume_list");
+			log_error("Ignoring empty string in config file %s",
+				  config_path);
 			continue;
 		}
 
@@ -340,7 +320,7 @@
 			str++;
 			if (!*str) {
 				log_error("Ignoring empty tag in config file "
-					  "activation/volume_list");
+					  "%s", config_path);
 				continue;
 			}
 			/* If any host tag matches any LV or VG tag, activate */
@@ -377,12 +357,52 @@
 			return 1;
 	}
 
-	log_verbose("No item supplied in activation/volume_list configuration "
-		    "setting matches %s/%s", lv->vg->name, lv->name);
+	log_verbose("No item supplied in %s configuration setting "
+		    "matches %s/%s", config_path, lv->vg->name, lv->name);
 
 	return 0;
 }
 
+static int _passes_activation_filter(struct cmd_context *cmd,
+				     struct logical_volume *lv)
+{
+	const struct dm_config_node *cn;
+
+	if (!(cn = find_config_tree_node(cmd, "activation/volume_list"))) {
+		log_verbose("activation/volume_list configuration setting "
+			    "not defined: Checking only host tags for %s/%s",
+			    lv->vg->name, lv->name);
+
+		/* If no host tags defined, activate */
+		if (dm_list_empty(&cmd->tags))
+			return 1;
+
+		/* If any host tag matches any LV or VG tag, activate */
+		if (str_list_match_list(&cmd->tags, &lv->tags, NULL) ||
+		    str_list_match_list(&cmd->tags, &lv->vg->tags, NULL))
+			return 1;
+
+		log_verbose("No host tag matches %s/%s",
+			    lv->vg->name, lv->name);
+
+		/* Don't activate */
+		return 0;
+	}
+
+	return _passes_volumes_filter(cmd, lv, cn, "activation/volume_list");
+}
+
+static int _passes_readonly_filter(struct cmd_context *cmd,
+				   struct logical_volume *lv)
+{
+	struct dm_config_node *cn;
+
+	if (!(cn = find_config_tree_node(cmd, "activation/read_only_volume_list")))
+		return 0;
+
+	return _passes_volumes_filter(cmd, lv, cn, "activation/read_only_volume_list");
+}
+
 int library_version(char *version, size_t size)
 {
 	if (!activation())
@@ -755,16 +775,22 @@
 static int _lv_preload(struct logical_volume *lv, struct lv_activate_opts *laopts,
 		       int *flush_required)
 {
-	int r;
+	int r = 0;
 	struct dev_manager *dm;
+	int old_readonly = laopts->read_only;
+
+	laopts->read_only = _passes_readonly_filter(lv->vg->cmd, lv);
 
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
-		return_0;
+		goto_out;
 
 	if (!(r = dev_manager_preload(dm, lv, laopts, flush_required)))
 		stack;
 
 	dev_manager_destroy(dm);
+
+	laopts->read_only = old_readonly;
+out:
 	return r;
 }
 
@@ -789,6 +815,8 @@
 	int r;
 	struct dev_manager *dm;
 
+	laopts->read_only = _passes_readonly_filter(lv->vg->cmd, lv);
+
 	/*
 	 * When we are asked to manipulate (normally suspend/resume) the PVMOVE
 	 * device directly, we don't want to touch the devices that use it.
@@ -1463,6 +1491,8 @@
 		goto out;
 	}
 
+	laopts->read_only = _passes_readonly_filter(cmd, lv);
+
 	if (!_lv_activate_lv(lv, laopts))
 		goto_out;
 
@@ -1652,13 +1682,21 @@
 		goto out;
 	}
 
-	log_debug("Activating %s/%s%s.", lv->vg->name, lv->name,
-		  laopts->exclusive ? " exclusively" : "");
+	if (filter)
+		laopts->read_only = _passes_readonly_filter(cmd, lv);
+
+	log_debug("Activating %s/%s%s%s.", lv->vg->name, lv->name,
+		  laopts->exclusive ? " exclusively" : "",
+		  laopts->read_only ? " read-only" : "");
 
 	if (!lv_info(cmd, lv, 0, &info, 0, 0))
 		goto_out;
 
-	if (info.exists && !info.suspended && info.live_table) {
+	/*
+	 * Nothing to do?
+	 */
+	if (info.exists && !info.suspended && info.live_table &&
+	    (info.read_only == read_only_lv(lv, laopts))) {
 		r = 1;
 		goto out;
 	}
--- LVM2/lib/activate/activate.h	2011/12/21 13:10:06	1.90
+++ LVM2/lib/activate/activate.h	2012/01/12 01:51:56	1.91
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -36,6 +36,7 @@
 	int no_merging;
 	int real_pool;
 	unsigned revert;
+	unsigned read_only;
 };
 
 /* target attribute flags */
--- LVM2/lib/activate/dev_manager.c	2011/12/21 13:09:33	1.256
+++ LVM2/lib/activate/dev_manager.c	2012/01/12 01:51:56	1.257
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -61,9 +61,9 @@
 
 static const char thin_layer[] = "tpool";
 
-static int _read_only_lv(struct logical_volume *lv)
+int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts)
 {
-	return (!(lv->vg->status & LVM_WRITE) || !(lv->status & LVM_WRITE));
+	return (laopts->read_only || !(lv->vg->status & LVM_WRITE) || !(lv->status & LVM_WRITE));
 }
 
 /*
@@ -1724,7 +1724,7 @@
 	if (!(dnode = dm_tree_add_new_dev_with_udev_flags(dtree, name, dlid,
 					     layer ? UINT32_C(0) : (uint32_t) lv->major,
 					     layer ? UINT32_C(0) : (uint32_t) lv->minor,
-					     _read_only_lv(lv),
+					     read_only_lv(lv, laopts),
 					     ((lv->vg->status & PRECOMMITTED) | laopts->revert) ? 1 : 0,
 					     lvlayer,
 					     _get_udev_flags(dm, lv, layer))))
--- LVM2/lib/activate/dev_manager.h	2011/12/21 13:09:34	1.41
+++ LVM2/lib/activate/dev_manager.h	2012/01/12 01:51:56	1.42
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -26,6 +26,8 @@
 struct dm_info;
 struct device;
 
+int read_only_lv(struct logical_volume *lv, struct lv_activate_opts *laopts);
+
 /*
  * Constructor and destructor.
  */


