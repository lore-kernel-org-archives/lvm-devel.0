From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:49:06 -0400
Subject: master - lvmetad: use new label_scan for update from pvscan
Message-ID: <201804231349.w3NDn6db031575@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3e5beec74ac0037917f5e9a2693c6ccb16debac
Commit:        e3e5beec74ac0037917f5e9a2693c6ccb16debac
Parent:        9c71fa02144619a67993920cee2146fed820f49c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 7 13:58:40 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:43 2018 -0500

lvmetad: use new label_scan for update from pvscan

Take advantage of the common implementation with aio
and reduced disk reads.
---
 lib/cache/lvmetad.c           |   38 ++++++++++++++++++++++++-------
 lib/commands/toolcontext.h    |    2 +-
 lib/format_text/import_vsn1.c |    6 ++++-
 tools/pvscan.c                |   49 +++++++++++++++++++++++++++++++++++------
 4 files changed, 77 insertions(+), 18 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 552dbf0..81ba1b7 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2240,9 +2240,12 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	struct label *label;
 	struct lvmcache_info *info;
 	struct _lvmetad_pvscan_baton baton;
+	const struct format_type *fmt;
 	/* Create a dummy instance. */
 	struct format_instance_ctx fic = { .type = 0 };
 
+	log_debug_lvmetad("Scan metadata from dev %s", dev_name(dev));
+
 	if (!lvmetad_used()) {
 		log_error("Cannot proceed since lvmetad is not active.");
 		return 0;
@@ -2253,23 +2256,31 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 		return 1;
 	}
 
-	if (!label_read(dev, &label, 0)) {
-		log_print_unless_silent("No PV label found on %s.", dev_name(dev));
+	if (!(info = lvmcache_info_from_pvid(dev->pvid, dev, 0))) {
+		log_print_unless_silent("No PV info found on %s for PVID %s.", dev_name(dev), dev->pvid);
+		if (!lvmetad_pv_gone_by_dev(dev))
+			goto_bad;
+		return 1;
+	}
+
+	if (!(label = lvmcache_get_label(info))) {
+		log_print_unless_silent("No PV label found for %s.", dev_name(dev));
 		if (!lvmetad_pv_gone_by_dev(dev))
 			goto_bad;
 		return 1;
 	}
 
-	info = (struct lvmcache_info *) label->info;
+	fmt = lvmcache_fmt(info);
 
+	baton.cmd = cmd;
 	baton.vg = NULL;
-	baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
+	baton.fid = fmt->ops->create_instance(fmt, &fic);
 
 	if (!baton.fid)
 		goto_bad;
 
-	if (baton.fid->fmt->features & FMT_OBSOLETE) {
-		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+	if (fmt->features & FMT_OBSOLETE) {
+		fmt->ops->destroy_instance(baton.fid);
 		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete (lvm1) metadata.");
 		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_LVM1);
 		_found_lvm1_metadata = 1;
@@ -2283,9 +2294,9 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
 
 	if (!baton.vg)
-		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+		fmt->ops->destroy_instance(baton.fid);
 
-	if (!lvmetad_pv_found(cmd, (const struct id *) &dev->pvid, dev, lvmcache_fmt(info),
+	if (!lvmetad_pv_found(cmd, (const struct id *) &dev->pvid, dev, fmt,
 			      label->sector, baton.vg, found_vgnames, changed_vgnames)) {
 		release_vg(baton.vg);
 		goto_bad;
@@ -2351,6 +2362,13 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 		replacing_other_update = 1;
 	}
 
+	label_scan(cmd);
+
+	if (lvmcache_found_duplicate_pvs()) {
+		log_warn("WARNING: Scan found duplicate PVs.");
+		return 0;
+	}
+
 	log_verbose("Scanning all devices to update lvmetad.");
 
 	if (!(iter = dev_iter_create(cmd->lvmetad_filter, 1))) {
@@ -2721,6 +2739,8 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 	 */
 	_lvmetad_get_pv_cache_list(cmd, &pvc_before);
 
+	log_debug_lvmetad("Rescan all devices to validate global cache.");
+
 	/*
 	 * Update the local lvmetad cache so it correctly reflects any
 	 * changes made on remote hosts.  (It's possible that this command
@@ -2789,7 +2809,7 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 		_update_changed_pvs_in_udev(cmd, &pvc_before, &pvc_after);
 	}
 
-	log_debug_lvmetad("Validating global lvmetad cache finished");
+	log_debug_lvmetad("Rescanned all devices");
 }
 
 int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid)
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index f04afec..d20cef1 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -167,8 +167,8 @@ struct cmd_context {
 	unsigned pv_notify:1;
 	unsigned activate_component:1;		/* command activates component LV */
 	unsigned process_component_lvs:1;	/* command processes also component LVs */
-
 	unsigned mirror_warn_printed:1;		/* command already printed warning about non-monitored mirrors */
+	unsigned pvscan_cache_single:1;
 	/*
 	 * Filtering.
 	 */
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index b41d83c..dee5379 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -221,7 +221,11 @@ static int _read_pv(struct format_instance *fid,
 
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
 			buffer[0] = '\0';
-		log_error_once("Couldn't find device with uuid %s.", buffer);
+
+		if (fid->fmt->cmd && !fid->fmt->cmd->pvscan_cache_single)
+			log_error_once("Couldn't find device with uuid %s.", buffer);
+		else
+			log_debug_metadata("Couldn't find device with uuid %s.", buffer);
 	}
 
 	if (!(pv->vg_name = dm_pool_strdup(mem, vg->name)))
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 6581990..ab6ea0b 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -300,8 +300,10 @@ static int _pvscan_autoactivate(struct cmd_context *cmd, struct pvscan_aa_params
 static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct pvscan_aa_params pp = { 0 };
+	struct dm_list single_devs;
 	struct dm_list found_vgnames;
 	struct device *dev;
+	struct device_list *devl;
 	const char *pv_name;
 	const char *reason = NULL;
 	int32_t major = -1;
@@ -434,8 +436,12 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 	 *  to drop any devices that have left.)
 	 */
 
-	if (argc || devno_args)
+	if (argc || devno_args) {
 		log_verbose("Scanning devices on command line.");
+		cmd->pvscan_cache_single = 1;
+	}
+
+	dm_list_init(&single_devs);
 
 	while (argc--) {
 		pv_name = *argv++;
@@ -453,8 +459,11 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 			} else {
 				/* Add device path to lvmetad. */
 				log_debug("Scanning dev %s for lvmetad cache.", pv_name);
-				if (!lvmetad_pvscan_single(cmd, dev, &found_vgnames, &pp.changed_vgnames))
-					add_errors++;
+
+				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+					return_0;
+				devl->dev = dev;
+				dm_list_add(&single_devs, &devl->list);
 			}
 		} else {
 			if (sscanf(pv_name, "%d:%d", &major, &minor) != 2) {
@@ -471,8 +480,11 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 			} else {
 				/* Add major:minor to lvmetad. */
 				log_debug("Scanning dev %d:%d for lvmetad cache.", major, minor);
-				if (!lvmetad_pvscan_single(cmd, dev, &found_vgnames, &pp.changed_vgnames))
-					add_errors++;
+
+				if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+					return_0;
+				devl->dev = dev;
+				dm_list_add(&single_devs, &devl->list);
 			}
 		}
 
@@ -482,9 +494,20 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
+	if (!dm_list_empty(&single_devs)) {
+		label_scan_devs(cmd, &single_devs);
+
+		dm_list_iterate_items(devl, &single_devs) {
+			if (!lvmetad_pvscan_single(cmd, devl->dev, &found_vgnames, &pp.changed_vgnames))
+				add_errors++;
+		}
+	}
+
 	if (!devno_args)
 		goto activate;
 
+	dm_list_init(&single_devs);
+
 	/* Process any grouped --major --minor args */
 	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
 		major = grouped_arg_int_value(current_group->arg_values, major_ARG, major);
@@ -503,8 +526,11 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		} else {
 			/* Add major:minor to lvmetad. */
 			log_debug("Scanning dev %d:%d for lvmetad cache.", major, minor);
-			if (!lvmetad_pvscan_single(cmd, dev, &found_vgnames, &pp.changed_vgnames))
-				add_errors++;
+
+			if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+				return_0;
+			devl->dev = dev;
+			dm_list_add(&single_devs, &devl->list);
 		}
 
 		if (sigint_caught()) {
@@ -513,6 +539,15 @@ static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
+	if (!dm_list_empty(&single_devs)) {
+		label_scan_devs(cmd, &single_devs);
+
+		dm_list_iterate_items(devl, &single_devs) {
+			if (!lvmetad_pvscan_single(cmd, devl->dev, &found_vgnames, &pp.changed_vgnames))
+				add_errors++;
+		}
+	}
+
 	/*
 	 * In the process of scanning devices, lvmetad may have become
 	 * disabled.  If so, revert to scanning for the autoactivation step.


