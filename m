From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Nov 2011 20:37:56 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/activ ...
Message-ID: <20111128203756.22454.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-11-28 20:37:54

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/activate   : activate.h dev_manager.c 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : defaults.h 
	lib/mirror     : mirrored.c 
	lib/replicator : replicator.c 
	lib/striped    : striped.c 
	lib/thin       : thin.c 

Log message:
	Add activation/use_linear_target enabled by default.   (prajnoha)
	
	LVM metadata knows only of striped segments - not linear ones.
	The activation code detects segments with a single stripe and switches
	them to use the linear target.
	
	If the new lvm.conf setting is set to 0 (e.g. in a test script), this
	'optimisation' is turned off.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2197&r2=1.2198
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.h.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.252&r2=1.253
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/replicator/replicator.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/WHATS_NEW	2011/11/23 12:21:41	1.2197
+++ LVM2/WHATS_NEW	2011/11/28 20:37:51	1.2198
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add activation/use_linear_target enabled by default.
   Use gcc warning options only with .c to .o compilation.
   Move y/n prompts to stderr and repeat if response has both 'n' and 'y'.
   Replace the unit testing framework with CUnit (--enable-testing).
--- LVM2/doc/example.conf.in	2011/11/11 15:11:09	1.36
+++ LVM2/doc/example.conf.in	2011/11/28 20:37:51	1.37
@@ -490,6 +490,11 @@
     # or snapshotted volumes is likely to result in data corruption.
     missing_stripe_filler = "error"
 
+    # The linear target is an optimised version of the striped target
+    # that only handles a single stripe.  Set this to 0 to disable this
+    # optimisation and always use the striped target.
+    use_linear_target = 1
+
     # How much stack (in KB) to reserve for use while devices suspended
     # Prior to version 2.02.89 this used to be set to 256KB
     reserved_stack = 64
--- LVM2/lib/activate/activate.h	2011/11/11 16:41:37	1.88
+++ LVM2/lib/activate/activate.h	2011/11/28 20:37:51	1.89
@@ -128,6 +128,10 @@
 			    int evmask __attribute__((unused)), int set, int timeout);
 #endif
 
+int add_linear_area_to_dtree(struct dm_tree_node *node, uint64_t size,
+			     uint32_t extent_size, int use_linear_target,
+			     const char *vgname, const char *lvname);
+
 /*
  * Returns 1 if PV has a dependency tree that uses anything in VG.
  */
--- LVM2/lib/activate/dev_manager.c	2011/11/18 19:42:03	1.252
+++ LVM2/lib/activate/dev_manager.c	2011/11/28 20:37:51	1.253
@@ -441,6 +441,42 @@
 	return r;
 }
 
+int add_linear_area_to_dtree(struct dm_tree_node *node, uint64_t size, uint32_t extent_size, int use_linear_target, const char *vgname, const char *lvname)
+{
+	uint32_t page_size;
+
+	/*
+	 * Use striped or linear target?
+	 */
+	if (!use_linear_target) {
+		page_size = lvm_getpagesize() >> SECTOR_SHIFT;
+
+		/*
+		 * We'll use the extent size as the stripe size.
+		 * Extent size and page size are always powers of 2.
+		 * The striped target requires that the stripe size is
+		 * divisible by the page size.
+		 */
+		if (extent_size >= page_size) {
+			/* Use striped target */
+			if (!dm_tree_node_add_striped_target(node, size, extent_size))
+				return_0;
+			return 1;
+		} else
+			/* Some exotic cases are unsupported by striped. */
+			log_warn("WARNING: Using linear target for %s/%s: Striped requires extent size (%" PRIu32 " sectors) >= page size (%" PRIu32 ").",
+				 vgname, lvname, extent_size, page_size);
+	}
+
+	/*
+	 * Use linear target.
+	 */
+	if (!dm_tree_node_add_linear_target(node, size))
+		return_0;
+
+	return 1;
+}
+
 static percent_range_t _combine_percent(percent_t a, percent_t b,
                                         uint32_t numerator, uint32_t denominator)
 {
--- LVM2/lib/commands/toolcontext.c	2011/11/18 19:31:09	1.141
+++ LVM2/lib/commands/toolcontext.c	2011/11/28 20:37:51	1.142
@@ -333,6 +333,10 @@
 	cmd->default_settings.udev_fallback = 1;
 #endif
 
+	cmd->use_linear_target = find_config_tree_int(cmd,
+						      "activation/use_linear_target",
+						       DEFAULT_USE_LINEAR_TARGET);
+
 	cmd->stripe_filler = find_config_tree_str(cmd,
 						  "activation/missing_stripe_filler",
 						  DEFAULT_STRIPE_FILLER);
--- LVM2/lib/commands/toolcontext.h	2011/09/02 01:32:09	1.46
+++ LVM2/lib/commands/toolcontext.h	2011/11/28 20:37:52	1.47
@@ -81,6 +81,7 @@
 	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
 	unsigned handles_missing_pvs:1;
 	unsigned handles_unknown_segments:1;
+	unsigned use_linear_target:1;
 	unsigned partial_activation:1;
 	unsigned si_unit_consistency:1;
 	unsigned metadata_read_only:1;
--- LVM2/lib/config/defaults.h	2011/11/11 15:11:11	1.88
+++ LVM2/lib/config/defaults.h	2011/11/28 20:37:52	1.89
@@ -127,6 +127,7 @@
 #  define DEFAULT_ACTIVATION 0
 #endif
 
+#define DEFAULT_USE_LINEAR_TARGET 1
 #define DEFAULT_STRIPE_FILLER "error"
 #define DEFAULT_MIRROR_REGION_SIZE 512	/* KB */
 #define DEFAULT_INTERVAL 15
--- LVM2/lib/mirror/mirrored.c	2011/08/31 15:19:20	1.91
+++ LVM2/lib/mirror/mirrored.c	2011/11/28 20:37:52	1.92
@@ -427,7 +427,9 @@
 	}
 
 	if (mirror_status != MIRR_RUNNING) {
-		if (!dm_tree_node_add_linear_target(node, len))
+		if (!add_linear_area_to_dtree(node, len, seg->lv->vg->extent_size,
+					      cmd->use_linear_target,
+					      seg->lv->vg->name, seg->lv->name))
 			return_0;
 		goto done;
 	}
--- LVM2/lib/replicator/replicator.c	2011/08/30 14:55:18	1.9
+++ LVM2/lib/replicator/replicator.c	2011/11/28 20:37:52	1.10
@@ -625,7 +625,9 @@
 		/* Create passive linear mapping */
 		log_very_verbose("Inactive replicator %s using %s.",
 				 seg->lv->name, seg->lv->rdevice->lv->name);
-		if (!dm_tree_node_add_linear_target(node, seg->lv->size))
+		if (!add_linear_area_to_dtree(node, seg->lv->size, seg->lv->vg->extent_size,
+					      dm->cmd->use_linear_target,
+					      seg->lv->vg->name, seg->lv_name))
 			return_0;
 		if (!(rdev_dlid = build_dm_uuid(mem, seg->lv->rdevice->lv->lvid.s, NULL)))
 			return_0;
--- LVM2/lib/striped/striped.c	2011/08/31 15:19:20	1.39
+++ LVM2/lib/striped/striped.c	2011/11/28 20:37:52	1.40
@@ -174,7 +174,9 @@
 		return 0;
 	}
 	if (seg->area_count == 1) {
-		if (!dm_tree_node_add_linear_target(node, len))
+		if (!add_linear_area_to_dtree(node, len, seg->lv->vg->extent_size,
+					      cmd->use_linear_target,
+					      seg->lv->vg->name, seg->lv->name))
 			return_0;
 	} else if (!dm_tree_node_add_striped_target(node, len,
 						  seg->stripe_size))
--- LVM2/lib/thin/thin.c	2011/11/12 22:44:10	1.33
+++ LVM2/lib/thin/thin.c	2011/11/28 20:37:52	1.34
@@ -230,7 +230,9 @@
 			return 0;
 		}
 
-		if (!dm_tree_node_add_linear_target(node, len) ||
+		if (!add_linear_area_to_dtree(node, len, seg->lv->vg->extent_size,
+					      cmd->use_linear_target,
+					      seg->lv->vg->name, seg->lv->name) ||
 		    !dm_tree_node_add_target_area(node, NULL, pool_dlid, 0))
 			return_0;
 


