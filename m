From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2012 21:49:45 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/activ ...
Message-ID: <20120302214945.23364.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-02 21:49:44

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/activate   : dev_manager.c 
	lib/config     : defaults.h 

Log message:
	Add support for thin check
	
	Use libdm callback to execute thin_check before activation
	thin pool and after deactivation as well.
	
	Supporting thin_check_executable which may pass in extra options for
	the tool.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2333&r2=1.2334
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.272&r2=1.273
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/WHATS_NEW	2012/03/02 17:25:21	1.2333
+++ LVM2/WHATS_NEW	2012/03/02 21:49:43	1.2334
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Add support to execute thin_check with each de/active of thin pool.
   Fix automatic estimation of metadata device size for thin pool.
   Test for alloc fail from _alloc_pv_segment() in _extend_pv().
   Check for alloc fail from get_segtype_from_string() in _lvcreate_params().
--- LVM2/doc/example.conf.in	2012/02/23 13:11:10	1.44
+++ LVM2/doc/example.conf.in	2012/03/02 21:49:43	1.45
@@ -650,6 +650,16 @@
     thin_pool_autoextend_threshold = 100
     thin_pool_autoextend_percent = 20
 
+    # Full path of the utility called to check that a thin metadata device
+    # is in a state that allows it to be used.
+    # Each time a thin pool needs to be activated, this utility is executed.
+    # The activation will only proceed if the utility has an exit status of 0.
+    # Set to "" to skip this check.  (Not recommended.)
+    # The thin tools are available as part of the device-mapper-persistent-data
+    # package from https://github.com/jthornber/thin-provisioning-tools.
+    #
+    thin_check_executable = "/sbin/thin_check -q"
+
     # While activating devices, I/O to devices being (re)configured is
     # suspended, and as a precaution against deadlocks, LVM2 needs to pin
     # any memory it is using so it is not paged out.  Groups of pages that
--- LVM2/lib/activate/dev_manager.c	2012/02/28 14:24:57	1.272
+++ LVM2/lib/activate/dev_manager.c	2012/03/02 21:49:44	1.273
@@ -26,6 +26,7 @@
 #include "config.h"
 #include "filter.h"
 #include "activate.h"
+#include "lvm-exec.h"
 
 #include <limits.h>
 #include <dirent.h>
@@ -1193,6 +1194,89 @@
 	return 1;
 }
 
+struct thin_cb_data {
+	const struct logical_volume *pool_lv;
+	struct dev_manager *dm;
+};
+
+static int _thin_pool_callback(struct dm_tree_node *node,
+			       dm_node_callback_t type, void *cb_data)
+{
+	int ret, status;
+	const struct thin_cb_data *data = cb_data;
+	const char *dmdir = dm_dir();
+	const char *thin_check =
+		find_config_tree_str_allow_empty(data->pool_lv->vg->cmd,
+						 "global/thin_check_executable",
+						 DEFAULT_THIN_CHECK_EXECUTABLE);
+	const struct logical_volume *mlv = first_seg(data->pool_lv)->metadata_lv;
+	size_t len = strlen(dmdir) + strlen(mlv->vg->name) + strlen(mlv->name) + 3;
+	char meta_path[len];
+	int args;
+	char *argv[19]; /* Max supported 15 args */
+	char *split;
+
+	if (!thin_check[0])
+		return 1; /* Checking disabled */
+
+	if (dm_snprintf(meta_path, len, "%s/%s-%s", dmdir,
+			mlv->vg->name, mlv->name) < 0) {
+		log_error("Failed to build thin metadata path.");
+		return 0;
+	}
+
+	if (!(split = dm_pool_strdup(data->dm->mem, thin_check))) {
+		log_error("Failed to duplicate thin check string.");
+		return 0;
+	}
+
+	args = dm_split_words(split, 16, 0, argv);
+	argv[args++] = meta_path;
+	argv[args] = NULL;
+
+	if (!(ret = exec_cmd(data->pool_lv->vg->cmd, (const char * const *)argv,
+			     &status, 0))) {
+		log_err_once("Check of thin pool %s/%s failed (status:%d). "
+			     "Manual repair required (thin_repair %s)!",
+			     data->pool_lv->vg->name, data->pool_lv->name,
+			     status, meta_path);
+		/*
+		 * FIXME: What should we do here??
+		 *
+		 * Maybe mark the node, so it's not activating
+		 * as thin_pool but as error/linear and let the
+		 * dm tree resolve the issue.
+		 */
+	}
+
+	dm_pool_free(data->dm->mem, split);
+
+	return ret;
+}
+
+static int _thin_pool_register_callback(struct dev_manager *dm,
+					struct dm_tree_node *node,
+					const struct logical_volume *lv)
+{
+	struct thin_cb_data *data;
+
+	/* Skip metadata testing for unused pool. */
+	if (!first_seg(lv)->transaction_id)
+		return 1;
+
+	if (!(data = dm_pool_alloc(dm->mem, sizeof(*data)))) {
+		log_error("Failed to allocated path for callback.");
+		return 0;
+	}
+
+	data->dm = dm;
+	data->pool_lv = lv;
+
+	dm_tree_node_set_callback(node, _thin_pool_callback, data);
+
+	return 1;
+}
+
 /*
  * Add LV and any known dependencies
  */
@@ -1202,11 +1286,8 @@
 	uint32_t s;
 	struct seg_list *sl;
 	struct lv_segment *seg = first_seg(lv);
-#if 0
-	/* FIXME For dm_tree_node_skip_children optimisation below */
 	struct dm_tree_node *thin_node;
 	const char *uuid;
-#endif
 
 	if ((!origin_only || lv_is_thin_volume(lv)) &&
 	    !_add_dev_to_dtree(dm, dtree, lv, NULL))
@@ -1263,6 +1344,12 @@
 			return_0;
 		if (!_add_dev_to_dtree(dm, dtree, lv, _thin_layer))
 			return_0;
+		/* If the partial tree is used for deactivation, setup callback */
+		if (!(uuid = build_dm_uuid(dm->mem, lv->lvid.s, _thin_layer)))
+			return_0;
+		if ((thin_node = dm_tree_find_node_by_uuid(dtree, uuid)) &&
+		    !_thin_pool_register_callback(dm, thin_node, lv))
+			return_0;
 	}
 
 	return 1;
@@ -1879,6 +1966,11 @@
 
 	dm_tree_node_set_read_ahead(dnode, read_ahead, read_ahead_flags);
 
+	/* Setup thin pool callback */
+	if (layer && lv_is_thin_pool(lv) &&
+	    !_thin_pool_register_callback(dm, dnode, lv))
+		return_0;
+
 	/* Add any LVs referencing a PVMOVE LV unless told not to */
 	if (dm->track_pvmove_deps && (lv->status & PVMOVE))
 		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
--- LVM2/lib/config/defaults.h	2012/01/26 14:02:44	1.96
+++ LVM2/lib/config/defaults.h	2012/03/02 21:49:44	1.97
@@ -64,6 +64,7 @@
 #define DEFAULT_DMEVENTD_MONITOR 1
 #define DEFAULT_BACKGROUND_POLLING 1
 
+#define DEFAULT_THIN_CHECK_EXECUTABLE  "/sbin/thin_check -q"
 #define DEFAULT_THIN_POOL_METADATA_REQUIRE_SEPARATE_PVS 0
 #define DEFAULT_THIN_POOL_MAX_METADATA_SIZE (16 * 1024 * 1024)  /* KB */
 #define DEFAULT_THIN_POOL_MIN_METADATA_SIZE 2048  /* KB */


