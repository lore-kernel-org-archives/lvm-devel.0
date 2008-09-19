From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 06:42:05 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c ...
Message-ID: <20080919064205.16217.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 06:42:00

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 
	doc            : example.conf 
	lib/activate   : activate.c dev_manager.c 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : defaults.h 
	lib/display    : display.c 
	lib/format1    : disk-rep.h format1.c import-export.c 
	lib/format_text: archiver.c flags.c import_vsn1.c 
	lib/locking    : cluster_locking.c locking.h 
	lib/log        : log.c log.h 
	lib/metadata   : metadata-exported.h metadata.c metadata.h 
	lib/report     : report.c 
	man            : lvm.conf.5 vgreduce.8 
	tools          : commands.h lvmcmdline.c lvremove.c pvcreate.c 
	                 vgcfgbackup.c vgreduce.c 

Log message:
	Improve the way VGs with PVs missing are handled so manual intervention
	is required in fewer circumstances.  (mornfall)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.959&r2=1.960
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.37&r2=1.38
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.137&r2=1.138
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.43&r2=1.44
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/disk-rep.h.diff?cvsroot=lvm2&r1=1.51&r2=1.52
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/import-export.c.diff?cvsroot=lvm2&r1=1.98&r2=1.99
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/flags.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/import_vsn1.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/cluster_locking.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.h.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.47&r2=1.48
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.h.diff?cvsroot=lvm2&r1=1.41&r2=1.42
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.190&r2=1.191
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.diff?cvsroot=lvm2&r1=1.22&r2=1.23
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgreduce.8.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.118&r2=1.119
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.69&r2=1.70
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvremove.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvcreate.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgcfgbackup.c.diff?cvsroot=lvm2&r1=1.25&r2=1.26
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/WHATS_NEW	2008/09/19 05:33:37	1.959
+++ LVM2/WHATS_NEW	2008/09/19 06:41:57	1.960
@@ -1,5 +1,11 @@
 Version 2.02.40 - 
 ================================
+  In VG with PVs missing, by default allow activation of LVs that are complete.
+  Track PARTIAL_LV and MISSING_PV flags internally.
+  Require --force with --removemissing in vgreduce to remove partial LVs.
+  No longer write out PARTIAL flag into metadata backups.
+  Treat new default activation/missing_stripe_filler "error" as an error target.
+  Remove internal partial_mode.
   Add device/md_chunk_alignment to lvm.conf.
   Pass struct physical_volume to pe_align and adjust for md chunk size.
   Store sysfs location in struct cmd_context.
--- LVM2/daemons/clvmd/lvm-functions.c	2008/06/06 16:37:51	1.44
+++ LVM2/daemons/clvmd/lvm-functions.c	2008/09/19 06:41:57	1.45
@@ -413,9 +413,6 @@
 		}
 	}
 
-	if (lock_flags & LCK_PARTIAL_MODE)
-		init_partial(1);
-
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(1);
 
@@ -454,9 +451,6 @@
 		break;
 	}
 
-	if (lock_flags & LCK_PARTIAL_MODE)
-		init_partial(0);
-
 	if (lock_flags & LCK_MIRROR_NOSYNC_MODE)
 		init_mirror_in_sync(0);
 
--- LVM2/doc/example.conf	2008/09/19 05:33:36	1.37
+++ LVM2/doc/example.conf	2008/09/19 06:41:57	1.38
@@ -271,11 +271,13 @@
 }
 
 activation {
-    # Device used in place of missing stripes if activating incomplete volume.
-    # For now, you need to set this up yourself first (e.g. with 'dmsetup')
-    # For example, you could make it return I/O errors using the 'error' 
-    # target or make it return zeros.
-    missing_stripe_filler = "/dev/ioerror"
+    # How to fill in missing stripes if activating an incomplete volume.
+    # Using "error" will make inaccessible parts of the device return
+    # I/O errors on access.  You can instead use a device path, in which 
+    # case, that device will be used to in place of missing stripes.
+    # But note that using anything other than "error" with mirrored 
+    # or snapshotted volumes is likely to result in data corruption.
+    missing_stripe_filler = "error"
 
     # How much stack (in KB) to reserve for use while devices suspended
     reserved_stack = 256
--- LVM2/lib/activate/activate.c	2008/06/08 11:33:15	1.137
+++ LVM2/lib/activate/activate.c	2008/09/19 06:41:57	1.138
@@ -1027,6 +1027,12 @@
 		return 0;
 	}
 
+	if ((!lv->vg->cmd->partial_activate) && (lv->status & PARTIAL_LV)) {
+		log_error("Refusing activation of partial LV %s. Use --partial to override.",
+			  lv->name);
+		return_0;
+	}
+
 	if (test_mode()) {
 		_skip("Activating '%s'.", lv->name);
 		return 1;
--- LVM2/lib/activate/dev_manager.c	2008/07/15 00:25:51	1.139
+++ LVM2/lib/activate/dev_manager.c	2008/09/19 06:41:57	1.140
@@ -47,7 +47,6 @@
 
 	struct cmd_context *cmd;
 
-	const char *stripe_filler;
 	void *target_state;
 	uint32_t pvmove_mirror_count;
 
@@ -59,8 +58,6 @@
 	const char *old_name;
 };
 
-static const char *stripe_filler = NULL;
-
 static char *_build_dlid(struct dm_pool *mem, const char *lvid, const char *layer)
 {
 	char *dlid;
@@ -443,13 +440,6 @@
 	dm->cmd = cmd;
 	dm->mem = mem;
 
-	if (!stripe_filler) {
-		stripe_filler = find_config_tree_str(cmd,
-						"activation/missing_stripe_filler",
-						DEFAULT_STRIPE_FILLER);
-	}
-	dm->stripe_filler = stripe_filler;
-
 	if (!(dm->vg_name = dm_pool_strdup(dm->mem, vg_name)))
 		goto_bad;
 
@@ -699,6 +689,68 @@
 	return NULL;
 }
 
+static char *_add_error_device(struct dev_manager *dm, struct dm_tree *dtree,
+			       struct lv_segment *seg, int s)
+{
+	char *id, *name;
+	char errid[32];
+	struct dm_tree_node *node;
+	struct lv_segment *seg_i;
+	int segno = -1, i = 0;;
+	uint64_t size = seg->len * seg->lv->vg->extent_size;
+
+	list_iterate_items(seg_i, &seg->lv->segments) {
+		if (seg == seg_i)
+			segno = i;
+		++i;
+	}
+
+	if (segno < 0) {
+		log_error("_add_error_device called with bad segment");
+		return_NULL;
+	}
+
+	sprintf(errid, "missing_%d_%d", segno, s);
+
+	if (!(id = build_dlid(dm, seg->lv->lvid.s, errid))) 
+		return_NULL;
+
+	if (!(name = build_dm_name(dm->mem, seg->lv->vg->name,
+				   seg->lv->name, errid)))
+		return_NULL;
+	if (!(node = dm_tree_add_new_dev(dtree, name, id, 0, 0, 0, 0, 0)))
+		return_NULL;
+	if (!dm_tree_node_add_error_target(node, size))
+		return_NULL;
+
+	return id;
+}
+
+static int _add_error_area(struct dev_manager *dm, struct dm_tree_node *node,
+			   struct lv_segment *seg, int s)
+{
+	char *dlid;
+	uint64_t extent_size = seg->lv->vg->extent_size;
+
+	if (!strcmp(dm->cmd->stripe_filler, "error")) {
+		/*
+		 * FIXME, the tree pointer is first field of dm_tree_node, but
+		 * we don't have the struct definition available.
+		 */
+		struct dm_tree **tree = (struct dm_tree **) node;
+		dlid = _add_error_device(dm, *tree, seg, s);
+		if (!dlid)
+			return_0;
+		dm_tree_node_add_target_area(node, NULL, dlid,
+					     extent_size * seg_le(seg, s));
+	} else {
+		dm_tree_node_add_target_area(node,
+					     dm->cmd->stripe_filler,
+					     NULL, UINT64_C(0));
+	}
+	return 1;
+}
+
 int add_areas_line(struct dev_manager *dm, struct lv_segment *seg,
 		   struct dm_tree_node *node, uint32_t start_area,
 		   uint32_t areas)
@@ -712,11 +764,10 @@
 		     (!seg_pvseg(seg, s) ||
 		      !seg_pv(seg, s) ||
 		      !seg_dev(seg, s))) ||
-		    (seg_type(seg, s) == AREA_LV && !seg_lv(seg, s)))
-			dm_tree_node_add_target_area(node,
-							dm->stripe_filler,
-							NULL, UINT64_C(0));
-		else if (seg_type(seg, s) == AREA_PV)
+		    (seg_type(seg, s) == AREA_LV && !seg_lv(seg, s))) {
+			if (!_add_error_area(dm, node, seg, s))
+				return_0;
+		} else if (seg_type(seg, s) == AREA_PV)
 			dm_tree_node_add_target_area(node,
 							dev_name(seg_dev(seg, s)),
 							NULL,
--- LVM2/lib/commands/toolcontext.c	2008/09/19 03:42:37	1.61
+++ LVM2/lib/commands/toolcontext.c	2008/09/19 06:41:58	1.62
@@ -197,6 +197,7 @@
 {
 	mode_t old_umask;
 	const char *read_ahead;
+	struct stat st;
 
 	/* umask */
 	cmd->default_settings.umask = find_config_tree_int(cmd,
@@ -263,6 +264,24 @@
 		return 0;
 	}
 
+	cmd->stripe_filler = find_config_tree_str(cmd,
+						  "activation/missing_stripe_filler",
+						  DEFAULT_STRIPE_FILLER);
+	if (strcmp(cmd->stripe_filler, "error")) {
+		if (stat(cmd->stripe_filler, &st)) {
+			log_warn("WARNING: activation/missing_stripe_filler = \"%s\" "
+				 "is invalid,", cmd->stripe_filler);
+			log_warn("         stat failed: %s", strerror(errno));
+			log_warn("Falling back to \"error\" missing_stripe_filler.");
+			cmd->stripe_filler = "error";
+		} else if (!S_ISBLK(st.st_mode)) {
+			log_warn("WARNING: activation/missing_stripe_filler = \"%s\" "
+				 "is not a block device.", cmd->stripe_filler);
+			log_warn("Falling back to \"error\" missing_stripe_filler.");
+			cmd->stripe_filler = "error";
+		}
+	}
+
 	return 1;
 }
 
@@ -981,6 +1000,7 @@
 	cmd->args = the_args;
 	cmd->is_static = is_static;
 	cmd->is_long_lived = is_long_lived;
+	cmd->handles_missing_pvs = 0;
 	cmd->hosttags = 0;
 	list_init(&cmd->formats);
 	list_init(&cmd->segtypes);
--- LVM2/lib/commands/toolcontext.h	2008/09/19 03:42:37	1.24
+++ LVM2/lib/commands/toolcontext.h	2008/09/19 06:41:58	1.25
@@ -66,8 +66,10 @@
 	struct command *command;
 	struct arg *args;
 	char **argv;
-	unsigned is_static;	/* Static binary? */
-	unsigned is_long_lived;	/* Optimises persistent_filter handling */
+	unsigned is_static:1;	/* Static binary? */
+	unsigned is_long_lived:1;	/* Optimises persistent_filter handling */
+	unsigned handles_missing_pvs:1;
+	unsigned partial_activate:1;
 
 	struct dev_filter *filter;
 	int dump_filter;	/* Dump filter when exiting? */
@@ -81,6 +83,7 @@
 
 	struct archive_params *archive_params;
 	struct backup_params *backup_params;
+	const char *stripe_filler;
 
 	/* List of defined tags */
 	struct list tags;
--- LVM2/lib/config/defaults.h	2008/09/19 05:33:37	1.43
+++ LVM2/lib/config/defaults.h	2008/09/19 06:41:58	1.44
@@ -92,7 +92,7 @@
 #  define DEFAULT_ACTIVATION 0
 #endif
 
-#define DEFAULT_STRIPE_FILLER "/dev/ioerror"
+#define DEFAULT_STRIPE_FILLER "error"
 #define DEFAULT_MIRROR_REGION_SIZE 512	/* KB */
 #define DEFAULT_INTERVAL 15
 
--- LVM2/lib/display/display.c	2008/08/07 14:01:17	1.91
+++ LVM2/lib/display/display.c	2008/09/19 06:41:58	1.92
@@ -578,10 +578,7 @@
 	struct lv_list *lvl;
 	char uuid[64] __attribute((aligned(8)));
 
-	if (vg->status & PARTIAL_VG)
-		active_pvs = list_size(&vg->pvs);
-	else
-		active_pvs = vg->pv_count;
+	active_pvs = vg->pv_count - vg_missing_pv_count(vg);
 
 	log_print("--- Volume group ---");
 	log_print("VG Name               %s", vg->name);
@@ -664,10 +661,7 @@
 	const char *access;
 	char uuid[64] __attribute((aligned(8)));
 
-	if (vg->status & PARTIAL_VG)
-		active_pvs = list_size(&vg->pvs);
-	else
-		active_pvs = vg->pv_count;
+	active_pvs = vg->pv_count - vg_missing_pv_count(vg);
 
 	list_iterate_items(lvl, &vg->lvs)
 		if (lv_is_visible(lvl->lv) && !(lvl->lv->status & SNAPSHOT))
--- LVM2/lib/format1/disk-rep.h	2007/08/20 20:55:25	1.51
+++ LVM2/lib/format1/disk-rep.h	2008/09/19 06:41:58	1.52
@@ -212,7 +212,7 @@
 	      struct pv_disk *pvd, struct physical_volume *pv);
 
 int import_vg(struct dm_pool *mem,
-	      struct volume_group *vg, struct disk_list *dl, int partial);
+	      struct volume_group *vg, struct disk_list *dl);
 int export_vg(struct vg_disk *vgd, struct volume_group *vg);
 
 int import_lv(struct dm_pool *mem, struct logical_volume *lv, struct lv_disk *lvd);
--- LVM2/lib/format1/format1.c	2008/03/17 16:51:31	1.107
+++ LVM2/lib/format1/format1.c	2008/09/19 06:41:58	1.108
@@ -23,7 +23,7 @@
 #include "segtype.h"
 
 /* VG consistency checks */
-static int _check_vgs(struct list *pvs, int *partial)
+static int _check_vgs(struct list *pvs)
 {
 	struct list *pvh, *t;
 	struct disk_list *dl = NULL;
@@ -33,8 +33,6 @@
 	uint32_t exported = 0;
 	int first_time = 1;
 
-	*partial = 0;
-
 	/*
 	 * If there are exported and unexported PVs, ignore exported ones.
 	 * This means an active VG won't be affected if disks are inserted
@@ -98,10 +96,6 @@
 				  dl->vgd.pe_total, dl->vgd.pe_allocated,
 				  dl->vgd.pvg_total);
 			list_del(pvh);
-			if (partial_mode()) {
-				*partial = 1;
-				continue;
-			}
 			return 0;
 		}
 		pv_count++;
@@ -111,9 +105,6 @@
 	if (pv_count != first->vgd.pv_cur) {
 		log_error("%d PV(s) found for VG %s: expected %d",
 			  pv_count, first->pvd.vg_name, first->vgd.pv_cur);
-		if (!partial_mode())
-			return 0;
-		*partial = 1;
 	}
 
 	return 1;
@@ -125,7 +116,6 @@
 	struct dm_pool *mem = fid->fmt->cmd->mem;
 	struct volume_group *vg = dm_pool_alloc(mem, sizeof(*vg));
 	struct disk_list *dl;
-	int partial;
 
 	if (!vg)
 		goto_bad;
@@ -142,12 +132,12 @@
 	list_init(&vg->lvs);
 	list_init(&vg->tags);
 
-	if (!_check_vgs(pvs, &partial))
+	if (!_check_vgs(pvs))
 		goto_bad;
 
 	dl = list_item(pvs->n, struct disk_list);
 
-	if (!import_vg(mem, vg, dl, partial))
+	if (!import_vg(mem, vg, dl))
 		goto_bad;
 
 	if (!import_pvs(fid->fmt, mem, vg, pvs, &vg->pvs, &vg->pv_count))
--- LVM2/lib/format1/import-export.c	2008/09/19 04:27:26	1.98
+++ LVM2/lib/format1/import-export.c	2008/09/19 06:41:58	1.99
@@ -214,7 +214,7 @@
 }
 
 int import_vg(struct dm_pool *mem,
-	      struct volume_group *vg, struct disk_list *dl, int partial)
+	      struct volume_group *vg, struct disk_list *dl)
 {
 	struct vg_disk *vgd = &dl->vgd;
 	memcpy(vg->id.uuid, vgd->vg_uuid, ID_LEN);
@@ -236,10 +236,10 @@
 	if (vgd->vg_status & VG_EXTENDABLE)
 		vg->status |= RESIZEABLE_VG;
 
-	if (partial || (vgd->vg_access & VG_READ))
+	if (vgd->vg_access & VG_READ)
 		vg->status |= LVM_READ;
 
-	if (!partial && (vgd->vg_access & VG_WRITE))
+	if (vgd->vg_access & VG_WRITE)
 		vg->status |= LVM_WRITE;
 
 	if (vgd->vg_access & VG_CLUSTERED)
@@ -255,9 +255,6 @@
 	vg->max_pv = vgd->pv_max;
 	vg->alloc = ALLOC_NORMAL;
 
-	if (partial)
-		vg->status |= PARTIAL_VG;
-
 	return 1;
 }
 
--- LVM2/lib/format_text/archiver.c	2008/01/30 13:59:59	1.13
+++ LVM2/lib/format_text/archiver.c	2008/09/19 06:41:58	1.14
@@ -134,10 +134,8 @@
 {
 	int r1, r2;
 
-	init_partial(1);
 	r1 = archive_list(cmd, cmd->archive_params->dir, vg_name);
 	r2 = backup_list(cmd, cmd->backup_params->dir, vg_name);
-	init_partial(0);
 
 	return r1 && r2;
 }
@@ -146,9 +144,7 @@
 {
 	int r;
 
-	init_partial(1);
 	r = archive_list_file(cmd, file);
-	init_partial(0);
 
 	return r;
 }
@@ -393,7 +389,7 @@
 	char path[PATH_MAX];
 	struct volume_group *vg_backup;
 
-	if ((vg->status & PARTIAL_VG) || (vg->status & EXPORTED_VG))
+	if (vg->status & EXPORTED_VG)
 		return;
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s",
--- LVM2/lib/format_text/flags.c	2008/07/10 11:30:57	1.34
+++ LVM2/lib/format_text/flags.c	2008/09/19 06:41:58	1.35
@@ -31,12 +31,12 @@
 static struct flag _vg_flags[] = {
 	{EXPORTED_VG, "EXPORTED", STATUS_FLAG},
 	{RESIZEABLE_VG, "RESIZEABLE", STATUS_FLAG},
-	{PARTIAL_VG, "PARTIAL", STATUS_FLAG},
 	{PVMOVE, "PVMOVE", STATUS_FLAG},
 	{LVM_READ, "READ", STATUS_FLAG},
 	{LVM_WRITE, "WRITE", STATUS_FLAG},
 	{CLUSTERED, "CLUSTERED", STATUS_FLAG},
 	{SHARED, "SHARED", STATUS_FLAG},
+	{PARTIAL_VG, NULL, 0},
 	{PRECOMMITTED, NULL, 0},
 	{0, NULL, 0}
 };
@@ -44,6 +44,7 @@
 static struct flag _pv_flags[] = {
 	{ALLOCATABLE_PV, "ALLOCATABLE", STATUS_FLAG},
 	{EXPORTED_VG, "EXPORTED", STATUS_FLAG},
+	{MISSING_PV, "MISSING", COMPATIBLE_FLAG},
 	{0, NULL, 0}
 };
 
@@ -62,6 +63,8 @@
 	{SNAPSHOT, NULL, 0},
 	{ACTIVATE_EXCL, NULL, 0},
 	{CONVERTING, NULL, 0},
+	{PARTIAL_LV, NULL, 0},
+	{POSTORDER_FLAG, NULL, 0},
 	{0, NULL, 0}
 };
 
@@ -155,7 +158,16 @@
 				break;
 			}
 
-		if (!flags[f].description && (type & STATUS_FLAG)) {
+		if (type == VG_FLAGS && !strcmp(cv->v.str, "PARTIAL")) {
+			/*
+			 * Exception: We no longer write this flag out, but it
+			 * might be encountered in old backup files, so restore
+			 * it in that case. It is never part of live metadata
+			 * though, so only vgcfgrestore needs to be concerned
+			 * by this case.
+			 */
+			s |= PARTIAL_VG;
+		} else if (!flags[f].description && (type & STATUS_FLAG)) {
 			log_err("Unknown status flag '%s'.", cv->v.str);
 			return 0;
 		}
--- LVM2/lib/format_text/import_vsn1.c	2008/09/19 04:27:26	1.53
+++ LVM2/lib/format_text/import_vsn1.c	2008/09/19 06:41:58	1.54
@@ -194,11 +194,6 @@
 		else
 			log_error("Couldn't find device with uuid '%s'.",
 				  buffer);
-
-		if (partial_mode())
-			vg->status |= PARTIAL_VG;
-		else
-			return 0;
 	}
 
 	if (!(pv->vg_name = dm_pool_strdup(mem, vg->name)))
@@ -211,6 +206,9 @@
 		return 0;
 	}
 
+	if (!pv->dev)
+		pv->status |= MISSING_PV;
+
 	/* Late addition */
 	_read_int64(pvn, "dev_size", &pv->size);
 
@@ -800,11 +798,6 @@
 
 	dm_hash_destroy(pv_hash);
 
-	if (vg->status & PARTIAL_VG) {
-		vg->status &= ~LVM_WRITE;
-		vg->status |= LVM_READ;
-	}
-
 	/*
 	 * Finished.
 	 */
--- LVM2/lib/locking/cluster_locking.c	2008/05/09 18:45:15	1.29
+++ LVM2/lib/locking/cluster_locking.c	2008/09/19 06:41:58	1.30
@@ -315,9 +315,6 @@
 	args[0] = flags & 0x7F; /* Maskoff lock flags */
 	args[1] = flags & 0xC0; /* Bitmap flags */
 
-	if (partial_mode())
-		args[1] |= LCK_PARTIAL_MODE;
-
 	if (mirror_in_sync())
 		args[1] |= LCK_MIRROR_NOSYNC_MODE;
 
--- LVM2/lib/locking/locking.h	2008/05/09 19:26:58	1.41
+++ LVM2/lib/locking/locking.h	2008/09/19 06:41:58	1.42
@@ -83,7 +83,6 @@
 /*
  * Additional lock bits for cluster communication
  */
-#define LCK_PARTIAL_MODE	0x00000001U	/* Running in partial mode */
 #define LCK_MIRROR_NOSYNC_MODE	0x00000002U	/* Mirrors don't require sync */
 #define LCK_DMEVENTD_MONITOR_MODE	0x00000004U	/* Register with dmeventd */
 
--- LVM2/lib/log/log.c	2008/06/17 14:14:00	1.47
+++ LVM2/lib/log/log.c	2008/09/19 06:41:59	1.48
@@ -29,7 +29,6 @@
 
 static int _verbose_level = VERBOSE_BASE_LEVEL;
 static int _test = 0;
-static int _partial = 0;
 static int _md_filtering = 0;
 static int _pvmove = 0;
 static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
@@ -154,11 +153,6 @@
 	_test = level;
 }
 
-void init_partial(int level)
-{
-	_partial = level;
-}
-
 void init_md_filtering(int level)
 {
 	_md_filtering = level;
@@ -254,11 +248,6 @@
 	return _test;
 }
 
-int partial_mode()
-{
-	return _partial;
-}
-
 int md_filtering()
 {
 	return _md_filtering;
--- LVM2/lib/log/log.h	2008/06/06 19:28:34	1.41
+++ LVM2/lib/log/log.h	2008/09/19 06:41:59	1.42
@@ -64,7 +64,6 @@
 
 void init_verbose(int level);
 void init_test(int level);
-void init_partial(int level);
 void init_md_filtering(int level);
 void init_pvmove(int level);
 void init_full_scan_done(int level);
@@ -84,7 +83,6 @@
 void set_cmd_name(const char *cmd_name);
 
 int test_mode(void);
-int partial_mode(void);
 int md_filtering(void);
 int pvmove_mode(void);
 int full_scan_done(void);
--- LVM2/lib/metadata/metadata-exported.h	2008/09/19 04:27:27	1.52
+++ LVM2/lib/metadata/metadata-exported.h	2008/09/19 06:41:59	1.53
@@ -71,6 +71,13 @@
 //#define PRECOMMITTED		0x00200000U	/* VG - internal use only */
 #define CONVERTING		0x00400000U	/* LV */
 
+#define MISSING_PV              0x00800000U	/* PV */
+#define PARTIAL_LV              0x01000000U	/* LV - derived flag, not
+						   written out in metadata*/
+
+//#define POSTORDER_FLAG	0x02000000U /* Not a real flag, reserved for
+//					       temporary use inside vg_read. */
+
 #define LVM_READ              	0x00000100U	/* LV VG */
 #define LVM_WRITE             	0x00000200U	/* LV VG */
 #define CLUSTERED         	0x00000400U	/* VG */
@@ -564,6 +571,7 @@
 uint32_t pv_pe_count(const pv_t *pv);
 uint32_t pv_pe_alloc_count(const pv_t *pv);
 
+int vg_missing_pv_count(const vg_t *vg);
 uint32_t vg_status(const vg_t *vg);
 #define vg_is_clustered(vg) (vg_status((vg)) & CLUSTERED)
 
--- LVM2/lib/metadata/metadata.c	2008/09/19 05:33:36	1.190
+++ LVM2/lib/metadata/metadata.c	2008/09/19 06:41:59	1.191
@@ -334,9 +334,9 @@
 	struct pv_list *pvl;
 	int ret = 1;
 
-	if (!vg || !consistent || (vg_status(vg) & PARTIAL_VG)) {
-		log_error("Volume group \"%s\" not found or inconsistent.",
-			  vg_name);
+	if (!vg || !consistent || vg_missing_pv_count(vg)) {
+		log_error("Volume group \"%s\" not found, is inconsistent "
+			  "or has PVs missing.", vg_name);
 		log_error("Consider vgreduce --removemissing if metadata "
 			  "is inconsistent.");
 		return 0;
@@ -488,19 +488,15 @@
 	struct volume_group *vg;
 	struct dm_pool *mem = cmd->mem;
 	int consistent = 0;
-	int old_partial;
 
 	if (!(vg = dm_pool_zalloc(mem, sizeof(*vg))))
 		return_NULL;
 
 	/* is this vg name already in use ? */
-	old_partial = partial_mode();
-	init_partial(1);
 	if (vg_read(cmd, vg_name, NULL, &consistent)) {
 		log_err("A volume group called '%s' already exists.", vg_name);
 		goto bad;
 	}
-	init_partial(old_partial);
 
 	if (!id_create(&vg->id)) {
 		log_err("Couldn't create uuid for volume group '%s'.", vg_name);
@@ -1191,6 +1187,157 @@
 	return 1;
 }
 
+struct _lv_postorder_baton {
+	int (*fn)(struct logical_volume *lv, void *data);
+	void *data;
+};
+
+static int _lv_postorder_visit(struct logical_volume *,
+			       int (*fn)(struct logical_volume *lv, void *data),
+			       void *data);
+
+static int _lv_postorder_level(struct logical_volume *lv, void *data)
+{
+	struct _lv_postorder_baton *baton = data;
+	int r =_lv_postorder_visit(lv, baton->fn, baton->data);
+	lv->status |= POSTORDER_FLAG;
+	return r;
+};
+
+static int _lv_each_dependency(struct logical_volume *lv,
+			       int (*fn)(struct logical_volume *lv, void *data),
+			       void *data)
+{
+	int i, s;
+	struct lv_segment *lvseg;
+
+	struct logical_volume *deps[] = {
+		lv->snapshot ? lv->snapshot->origin : 0,
+		lv->snapshot ? lv->snapshot->cow : 0 };
+	for (i = 0; i < sizeof(deps) / sizeof(*deps); ++i) {
+		if (deps[i] && !fn(deps[i], data))
+			return_0;
+	}
+
+	list_iterate_items(lvseg, &lv->segments) {
+		if (lvseg->log_lv && !fn(lvseg->log_lv, data))
+			return_0;
+		for (s = 0; s < lvseg->area_count; ++s) {
+			if (seg_type(lvseg, s) == AREA_LV && !fn(seg_lv(lvseg,s), data))
+				return_0;
+		}
+	}
+	return 1;
+}
+
+static int _lv_postorder_cleanup(struct logical_volume *lv, void *data)
+{
+	if (!(lv->status & POSTORDER_FLAG))
+		return 1;
+	lv->status &= ~POSTORDER_FLAG;
+
+	if (!_lv_each_dependency(lv, _lv_postorder_cleanup, data))
+		return_0;
+	return 1;
+}
+
+static int _lv_postorder_visit(struct logical_volume *lv,
+			       int (*fn)(struct logical_volume *lv, void *data),
+			       void *data)
+{
+	struct _lv_postorder_baton baton;
+	int r;
+
+	if (lv->status & POSTORDER_FLAG)
+		return 1;
+
+	baton.fn = fn;
+	baton.data = data;
+	r = _lv_each_dependency(lv, _lv_postorder_level, &baton);
+	if (r) {
+		r = fn(lv, data);
+		log_verbose("visited %s", lv->name);
+	}
+	return r;
+}
+
+/*
+ * This will walk the LV dependency graph in depth-first order and in the
+ * postorder, call a callback function "fn". The void *data is passed along all
+ * the calls. The callback may return zero to indicate an error and terminate
+ * the depth-first walk. The error is propagated to return value of
+ * _lv_postorder.
+ */
+static int _lv_postorder(struct logical_volume *lv,
+			       int (*fn)(struct logical_volume *lv, void *data),
+			       void *data)
+{
+	int r;
+	r = _lv_postorder_visit(lv, fn, data);
+	_lv_postorder_cleanup(lv, 0);
+	return r;
+}
+
+struct _lv_mark_if_partial_baton {
+	int partial;
+};
+
+static int _lv_mark_if_partial_collect(struct logical_volume *lv, void *data)
+{
+	struct _lv_mark_if_partial_baton *baton = data;
+	if (lv->status & PARTIAL_LV)
+		baton->partial = 1;
+
+	return 1;
+}
+
+static int _lv_mark_if_partial_single(struct logical_volume *lv, void *data)
+{
+	int s;
+	struct _lv_mark_if_partial_baton baton;
+	struct lv_segment *lvseg;
+
+	list_iterate_items(lvseg, &lv->segments) {
+		for (s = 0; s < lvseg->area_count; ++s) {
+			if (seg_type(lvseg, s) == AREA_PV) {
+				if (seg_pv(lvseg, s)->status & MISSING_PV)
+					lv->status |= PARTIAL_LV;
+			}
+		}
+	}
+
+	baton.partial = 0;
+	_lv_each_dependency(lv, _lv_mark_if_partial_collect, &baton);
+
+	if (baton.partial)
+		lv->status |= PARTIAL_LV;
+
+	return 1;
+}
+
+static int _lv_mark_if_partial(struct logical_volume *lv)
+{
+	return _lv_postorder(lv, _lv_mark_if_partial_single, NULL);
+}
+
+/*
+ * Mark LVs with missing PVs using PARTIAL_LV status flag. The flag is
+ * propagated transitively, so LVs referencing other LVs are marked
+ * partial as well, if any of their referenced LVs are marked partial.
+ */
+static int _vg_mark_partial_lvs(struct volume_group *vg)
+{
+	struct logical_volume *lv;
+	struct lv_list *lvl;
+
+	list_iterate_items(lvl, &vg->lvs) {
+		lv = lvl->lv;
+		if (!_lv_mark_if_partial(lv))
+			return_0;
+	}
+	return 1;
+}
+
 int vg_validate(struct volume_group *vg)
 {
 	struct pv_list *pvl, *pvl2;
@@ -1295,8 +1442,13 @@
 		return_0;
 
 	if (vg->status & PARTIAL_VG) {
-		log_error("Cannot change metadata for partial volume group %s",
-			  vg->name);
+		log_error("Cannot update partial volume group %s.", vg->name);
+		return 0;
+	}
+
+	if (vg_missing_pv_count(vg) && !vg->cmd->handles_missing_pvs) {
+		log_error("Cannot update volume group %s while physical "
+			  "volumes are missing.", vg->name);
 		return 0;
 	}
 
@@ -1495,9 +1647,20 @@
 	return 1;
 }
 
+int vg_missing_pv_count(const vg_t *vg)
+{
+	int ret = 0;
+	struct pv_list *pvl;
+	list_iterate_items(pvl, &vg->pvs) {
+		if (pvl->pv->status & MISSING_PV)
+			++ ret;
+	}
+	return ret;
+}
+
 /* Caller sets consistent to 1 if it's safe for vg_read to correct
  * inconsistent metadata on disk (i.e. the VG write lock is held).
- * This guarantees only consistent metadata is returned unless PARTIAL_VG.
+ * This guarantees only consistent metadata is returned.
  * If consistent is 0, caller must check whether consistent == 1 on return
  * and take appropriate action if it isn't (e.g. abort; get write lock
  * and call vg_read again).
@@ -1536,6 +1699,11 @@
 	}
 
 	if ((correct_vg = lvmcache_get_vg(vgid, precommitted))) {
+		if (vg_missing_pv_count(correct_vg)) {
+			log_verbose("There are %d physical volumes missing.",
+				    vg_missing_pv_count(correct_vg));
+			_vg_mark_partial_lvs(correct_vg);
+		}
 		*consistent = 1;
 		return correct_vg;
 	}
@@ -1631,7 +1799,8 @@
 			}
 		}
 
-		if (list_size(&correct_vg->pvs) != list_size(pvids)) {
+		if (list_size(&correct_vg->pvs) != list_size(pvids)
+		    + vg_missing_pv_count(correct_vg)) {
 			log_debug("Cached VG %s had incorrect PV list",
 				  vgname);
 
@@ -1640,6 +1809,8 @@
 			else
 				correct_vg = NULL;
 		} else list_iterate_items(pvl, &correct_vg->pvs) {
+			if (pvl->pv->status & MISSING_PV)
+				continue;
 			if (!str_list_match_item(pvids, pvl->pv->dev->pvid)) {
 				log_debug("Cached VG %s had incorrect PV list",
 					  vgname);
@@ -1722,15 +1893,6 @@
 		if (!*consistent)
 			return correct_vg;
 
-		/* Don't touch partial volume group metadata */
-		/* Should be fixed manually with vgcfgbackup/restore etc. */
-		if ((correct_vg->status & PARTIAL_VG)) {
-			log_error("Inconsistent metadata copies found for "
-				  "partial volume group %s", vgname);
-			*consistent = 0;
-			return correct_vg;
-		}
-
 		/* Don't touch if vgids didn't match */
 		if (inconsistent_vgid) {
 			log_error("Inconsistent metadata UUIDs found for "
@@ -1769,6 +1931,12 @@
 		}
 	}
 
+	if (vg_missing_pv_count(correct_vg)) {
+		log_verbose("There are %d physical volumes missing.",
+			    vg_missing_pv_count(correct_vg));
+		_vg_mark_partial_lvs(correct_vg);
+	}
+
 	if ((correct_vg->status & PVMOVE) && !pvmove_mode()) {
 		log_error("WARNING: Interrupted pvmove detected in "
 			  "volume group %s", correct_vg->name);
@@ -1828,11 +1996,10 @@
 		if ((vg = _vg_read(cmd, NULL, vgid,
 				   &consistent, precommitted)) &&
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
+
 			if (!consistent) {
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vg->name);
-				if (!partial_mode())
-					return NULL;
 			}
 			return vg;
 		}
@@ -1860,6 +2027,7 @@
 		if ((vg = _vg_read(cmd, vgname, vgid, &consistent,
 				   precommitted)) &&
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
+
 			if (!consistent) {
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vgname);
@@ -1993,7 +2161,6 @@
 	struct list *vgids;
 	struct volume_group *vg;
 	int consistent = 0;
-	int old_partial;
 	int old_pvmove;
 
 	lvmcache_label_scan(cmd, 0);
@@ -2015,9 +2182,7 @@
 
 	/* Read every VG to ensure cache consistency */
 	/* Orphan VG is last on list */
-	old_partial = partial_mode();
 	old_pvmove = pvmove_mode();
-	init_partial(1);
 	init_pvmove(1);
 	list_iterate_items(strl, vgids) {
 		vgid = strl->str;
@@ -2042,7 +2207,6 @@
 				list_add(results, pvh);
 	}
 	init_pvmove(old_pvmove);
-	init_partial(old_partial);
 
 	if (pvslist)
 		*pvslist = results;
--- LVM2/lib/metadata/metadata.h	2008/09/19 04:28:58	1.181
+++ LVM2/lib/metadata/metadata.h	2008/09/19 06:41:59	1.182
@@ -61,6 +61,14 @@
 //#define MIRROR_NOTSYNCED	0x00080000U	/* LV */
 #define ACTIVATE_EXCL		0x00100000U	/* LV - internal use only */
 #define PRECOMMITTED		0x00200000U	/* VG - internal use only */
+//#define CONVERTING		0x00400000U	/* LV */
+
+//#define MISSING_PV		0x00800000U	/* PV */
+//#define PARTIAL_LV		0x01000000U	/* LV - derived flag, not
+//						   written out in metadata*/
+
+#define POSTORDER_FLAG		0x02000000U /* Not a real flag, reserved for
+					       temporary use inside vg_read. */
 
 //#define LVM_READ              	0x00000100U	/* LV VG */
 //#define LVM_WRITE             	0x00000200U	/* LV VG */
--- LVM2/lib/report/report.c	2008/06/25 16:52:27	1.87
+++ LVM2/lib/report/report.c	2008/09/19 06:41:59	1.88
@@ -439,7 +439,7 @@
 	else
 		repstr[2] = '-';
 
-	if (vg->status & PARTIAL_VG)
+	if (vg_missing_pv_count(vg))
 		repstr[3] = 'p';
 	else
 		repstr[3] = '-';
--- LVM2/man/lvm.conf.5	2008/04/10 18:50:02	1.22
+++ LVM2/man/lvm.conf.5	2008/09/19 06:41:59	1.23
@@ -300,12 +300,16 @@
 .TP
 \fBactivation\fP \(em Settings affecting device-mapper activation
 .IP
-\fBmissing_stripe_filler\fP \(em When activating an incomplete
-logical volume in partial mode, this missing data is replaced
-with this device.  It could perhaps be a block device that always
-returns an error when it is accessed, or one that always
-returns zeros.  See \fBlvcreate\fP (8) for how to create
-such devices.
+\fBmissing_stripe_filler\fP \(em When activating an incomplete logical
+volume in partial mode, this option dictates how the missing data is
+replaced.  A value of "error" will cause activation to create error
+mappings for the missing data, meaning that read access to missing
+portions of the volume will result in I/O errors. You can instead also
+use a device path, and in that case this device will be used in place of
+missing stripes. However, note that using anything other than
+"error" with mirrored or snapshotted volumes is likely to result in data
+corruption.  For instructions on how to create a device that always
+returns zeros, see \fBlvcreate\fP (8).
 .IP
 \fBmirror_region_size\fP \(em Unit size in KB for copy operations
 when mirroring.
--- LVM2/man/vgreduce.8	2003/01/17 21:04:26	1.3
+++ LVM2/man/vgreduce.8	2008/09/19 06:41:59	1.4
@@ -18,11 +18,13 @@
 Removes all empty physical volumes if none are given on command line.
 .TP
 .I \-\-removemissing
-Removes all missing physical volumes from the volume group and makes 
-the volume group consistent again.  
+Removes all missing physical volumes from the volume group, if there are no
+logical volumes allocated on those. This resumes normal operation of the volume
+group (new logical volumes may again be created, changed and so on).
 
-It's a good idea to run this option with --test first to find out what it 
-would remove before running it for real.  
+If this is not possible (there are logical volumes referencing the missing
+physical volumes) and you cannot or do not want to remove them manually, you
+can run this option with --force to have vgreduce remove any partial LVs.
 
 Any logical volumes and dependent snapshots that were partly on the 
 missing disks get removed completely. This includes those parts 
--- LVM2/tools/commands.h	2008/06/24 22:48:53	1.118
+++ LVM2/tools/commands.h	2008/09/19 06:42:00	1.119
@@ -850,13 +850,15 @@
    "\t[-h|--help]\n"
    "\t[--mirrorsonly]\n"
    "\t[--removemissing]\n"
+   "\t[-f|--force]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
    "\tVolumeGroupName\n"
    "\t[PhysicalVolumePath...]\n",
 
-   all_ARG, autobackup_ARG, mirrorsonly_ARG, removemissing_ARG, test_ARG)
+   all_ARG, autobackup_ARG, mirrorsonly_ARG, removemissing_ARG,
+   force_ARG, test_ARG)
 
 xx(vgremove,
    "Remove volume group(s)",
--- LVM2/tools/lvmcmdline.c	2008/08/01 19:51:27	1.69
+++ LVM2/tools/lvmcmdline.c	2008/09/19 06:42:00	1.70
@@ -710,13 +710,13 @@
 	cmd->current_settings.archive = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.archive);
 	cmd->current_settings.backup = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.backup);
 	cmd->current_settings.cache_vgmetadata = cmd->command->flags & CACHE_VGMETADATA ? 1 : 0;
+	cmd->partial_activate = 0;
 
 	if (arg_count(cmd, partial_ARG)) {
-		init_partial(1);
+		cmd->partial_activate = 1;
 		log_print("Partial mode. Incomplete volume groups will "
 			  "be activated read-only.");
-	} else
-		init_partial(0);
+	}
 
 	if (arg_count(cmd, ignorelockingfailure_ARG))
 		init_ignorelockingfailure(1);
@@ -826,6 +826,7 @@
 
 	cmd->fmt = arg_ptr_value(cmd, metadatatype_ARG,
 				 cmd->current_settings.fmt);
+	cmd->handles_missing_pvs = 0;
 }
 
 static char *_copy_command_line(struct cmd_context *cmd, int argc, char **argv)
--- LVM2/tools/lvremove.c	2008/01/30 14:00:02	1.54
+++ LVM2/tools/lvremove.c	2008/09/19 06:42:00	1.55
@@ -31,6 +31,8 @@
 		return EINVALID_CMD_LINE;
 	}
 
+	cmd->handles_missing_pvs = 1;
+
 	return process_each_lv(cmd, argc, argv, LCK_VG_WRITE, NULL,
 			       &lvremove_single);
 }
--- LVM2/tools/pvcreate.c	2008/07/29 21:05:20	1.74
+++ LVM2/tools/pvcreate.c	2008/09/19 06:42:00	1.75
@@ -49,7 +49,6 @@
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
-	/* FIXME Use partial mode here? */
 	pv = pv_read(cmd, name, NULL, NULL, 0);
 
 	/*
@@ -272,13 +271,11 @@
 	if (arg_count(cmd, restorefile_ARG)) {
 		pp->restorefile = arg_str_value(cmd, restorefile_ARG, "");
 		/* The uuid won't already exist */
-		init_partial(1);
 		if (!(vg = backup_read_vg(cmd, NULL, pp->restorefile))) {
 			log_error("Unable to read volume group from %s",
 				  pp->restorefile);
 			return 0;
 		}
-		init_partial(0);
 		if (!(existing_pv = find_pv_in_vg_by_uuid(vg, pp->idp))) {
 			log_error("Can't find uuid %s in backup file %s",
 				  uuid, pp->restorefile);
--- LVM2/tools/vgcfgbackup.c	2008/08/13 12:44:24	1.25
+++ LVM2/tools/vgcfgbackup.c	2008/09/19 06:42:00	1.26
@@ -96,8 +96,7 @@
 	int ret;
 	char *last_filename = NULL;
 
-	if (partial_mode())
-		init_pvmove(1);
+	init_pvmove(1);
 
 	ret = process_each_vg(cmd, argc, argv, LCK_VG_READ, 0, &last_filename,
 			      &vg_backup_single);
--- LVM2/tools/vgreduce.c	2008/09/19 03:45:34	1.82
+++ LVM2/tools/vgreduce.c	2008/09/19 06:42:00	1.83
@@ -16,7 +16,7 @@
 #include "tools.h"
 #include "lv_alloc.h"
 
-static int _remove_pv(struct volume_group *vg, struct pv_list *pvl)
+static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 {
 	char uuid[64] __attribute((aligned(8)));
 
@@ -31,8 +31,9 @@
 	log_verbose("Removing PV with UUID %s from VG %s", uuid, vg->name);
 
 	if (pvl->pv->pe_alloc_count) {
-		log_error("LVs still present on PV with UUID %s: Can't remove "
-			  "from VG %s", uuid, vg->name);
+		if (!silent)
+			log_error("LVs still present on PV with UUID %s: "
+				  "Can't remove from VG %s", uuid, vg->name);
 		return 0;
 	}
 
@@ -130,11 +131,39 @@
 	return 1;
 }
 
+static int _consolidate_vg(struct cmd_context *cmd, struct volume_group *vg)
+{
+	struct pv_list *pvl;
+	struct lv_list *lvl;
+	int r = 1;
+
+	list_iterate_items(lvl, &vg->lvs)
+		if (lvl->lv->status & PARTIAL_LV) {
+			log_warn("WARNING: Partial LV %s needs to be repaired "
+				 "or removed. ", lvl->lv->name);
+			r = 0;
+		}
+
+	if (!r) {
+		cmd->handles_missing_pvs = 1;
+		log_warn("WARNING: There are still partial LVs in VG %s.", vg->name);
+		log_warn("To remove them unconditionally use: vgreduce --removemissing --force.");
+		log_warn("Proceeding to remove empty missing PVs.");
+	}
+
+	list_iterate_items(pvl, &vg->pvs) {
+		if (pvl->pv->dev && !(pvl->pv->status & MISSING_PV))
+			continue;
+		if (r && !_remove_pv(vg, pvl, 0))
+			return_0;
+	}
+
+	return r;
+}
+
 static int _make_vg_consistent(struct cmd_context *cmd, struct volume_group *vg)
 {
-	struct list *pvh, *pvht;
 	struct list *lvh, *lvht;
-	struct pv_list *pvl;
 	struct lv_list *lvl, *lvl2, *lvlt;
 	struct logical_volume *lv;
 	struct physical_volume *pv;
@@ -182,20 +211,8 @@
 		return 0;
 	}
 
-	/* Remove missing PVs */
-	list_iterate_safe(pvh, pvht, &vg->pvs) {
-		pvl = list_item(pvh, struct pv_list);
-		if (pvl->pv->dev)
-			continue;
-		if (!_remove_pv(vg, pvl))
-			return_0;
-	}
-
-	/* VG is now consistent */
-	vg->status &= ~PARTIAL_VG;
-	vg->status |= LVM_WRITE;
-
-	init_partial(0);
+	if (!_consolidate_vg(cmd, vg))
+		return_0;
 
 	/* FIXME Recovery.  For now people must clean up by hand. */
 
@@ -208,14 +225,11 @@
 
 		if (!test_mode()) {
 			/* Suspend lvs_changed */
-			init_partial(1);
 			if (!suspend_lvs(cmd, &lvs_changed)) {
 				stack;
-				init_partial(0);
 				vg_revert(vg);
 				return 0;
 			}
-			init_partial(0);
 		}
 
 		if (!vg_commit(vg)) {
@@ -439,26 +453,26 @@
 	char *vg_name;
 	int ret = 1;
 	int consistent = 1;
+	int fixed = 1;
+	int repairing = arg_count(cmd, removemissing_ARG);
 
-	if (!argc && !arg_count(cmd, removemissing_ARG)) {
+	if (!argc && !repairing) {
 		log_error("Please give volume group name and "
 			  "physical volume paths");
 		return EINVALID_CMD_LINE;
 	}
-
-	if (!argc && arg_count(cmd, removemissing_ARG)) {
+	
+	if (!argc && repairing) {
 		log_error("Please give volume group name");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_count(cmd, mirrorsonly_ARG) &&
-	    !arg_count(cmd, removemissing_ARG)) {
+	if (arg_count(cmd, mirrorsonly_ARG) && !repairing) {
 		log_error("--mirrorsonly requires --removemissing");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc == 1 && !arg_count(cmd, all_ARG)
-	    && !arg_count(cmd, removemissing_ARG)) {
+	if (argc == 1 && !arg_count(cmd, all_ARG) && !repairing) {
 		log_error("Please enter physical volume paths or option -a");
 		return EINVALID_CMD_LINE;
 	}
@@ -469,7 +483,7 @@
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc > 1 && arg_count(cmd, removemissing_ARG)) {
+	if (argc > 1 && repairing) {
 		log_error("Please only specify the volume group");
 		return EINVALID_CMD_LINE;
 	}
@@ -490,8 +504,8 @@
 		return ECMD_FAILED;
 	}
 
-	if ((!(vg = vg_read(cmd, vg_name, NULL, &consistent)) || !consistent) &&
-	    !arg_count(cmd, removemissing_ARG)) {
+	if ((!(vg = vg_read(cmd, vg_name, NULL, &consistent)) || !consistent)
+	    && !repairing) {
 		log_error("Volume group \"%s\" doesn't exist", vg_name);
 		unlock_vg(cmd, vg_name);
 		return ECMD_FAILED;
@@ -502,16 +516,15 @@
 		return ECMD_FAILED;
 	}
 
-	if (arg_count(cmd, removemissing_ARG)) {
-		if (vg && consistent) {
+	if (repairing) {
+		if (vg && consistent && !vg_missing_pv_count(vg)) {
 			log_error("Volume group \"%s\" is already consistent",
 				  vg_name);
 			unlock_vg(cmd, vg_name);
 			return ECMD_PROCESSED;
 		}
 
-		init_partial(1);
-		consistent = 0;
+		consistent = !arg_count(cmd, force_ARG);
 		if (!(vg = vg_read(cmd, vg_name, NULL, &consistent))) {
 			log_error("Volume group \"%s\" not found", vg_name);
 			unlock_vg(cmd, vg_name);
@@ -522,16 +535,17 @@
 			return ECMD_FAILED;
 		}
 		if (!archive(vg)) {
-			init_partial(0);
 			unlock_vg(cmd, vg_name);
 			return ECMD_FAILED;
 		}
 
-		if (!_make_vg_consistent(cmd, vg)) {
-			init_partial(0);
-			unlock_vg(cmd, vg_name);
-			return ECMD_FAILED;
-		}
+		if (arg_count(cmd, force_ARG)) {
+			if (!_make_vg_consistent(cmd, vg)) {
+				unlock_vg(cmd, vg_name);
+				return ECMD_FAILED;
+			}
+		} else
+			fixed = _consolidate_vg(cmd, vg);
 
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to write out a consistent VG for %s",
@@ -542,7 +556,9 @@
 
 		backup(vg);
 
-		log_print("Wrote out consistent volume group %s", vg_name);
+		if (fixed)
+			log_print("Wrote out consistent volume group %s",
+				  vg_name);
 
 	} else {
 		if (!vg_check_status(vg, EXPORTED_VG | LVM_WRITE | RESIZEABLE_VG)) {


