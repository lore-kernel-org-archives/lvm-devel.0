From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 28 Jun 2012 13:49:02 +0000 (UTC)
Subject: master - activate: add autoactivation hooks
Message-ID: <20120628134902.59706173A@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95ced7a7be26499fed2ffa03d71002e73c2d3ca9
Commit:        95ced7a7be26499fed2ffa03d71002e73c2d3ca9
Parent:        2729720fd329f2c33cddeeded591a06fe4b6a147
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 27 08:59:34 2012 -0400
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 28 09:42:47 2012 -0400

activate: add autoactivation hooks

Define an 'activation_handler' that gets called automatically on
PV appearance/disappearance while processing the lvmetad_pv_found
and lvmetad_pv_gone functions that are supposed to update the
lvmetad state based on PV availability state. For now, the actual
support is for PV appearance only, leaving room for PV disappearance
support as well (which is a more complex problem to solve as this
needs to count with possible device stack).

Add a new activation change mode - CHANGE_AAY exposed as
'--activate ay/-aay' argument ('activate automatically').

Factor out the vgchange activation functionality for use in other
tools (like pvscan...).
---
 WHATS_NEW                        |    1 +
 lib/activate/activate.c          |   24 +++++++++++++++++-----
 lib/activate/activate.h          |    8 +++++++
 lib/cache/lvmetad.c              |   39 ++++++++++++++++++++++++++++++-------
 lib/cache/lvmetad.h              |   19 ++++++++++-------
 lib/metadata/metadata-exported.h |    3 +-
 lib/metadata/metadata.c          |    3 +-
 tools/lvmcmdline.c               |    6 +++++
 tools/pvremove.c                 |    2 +-
 tools/pvscan.c                   |   13 ++++++-----
 tools/tools.h                    |    3 ++
 tools/vgchange.c                 |   31 +++++++++++++----------------
 12 files changed, 104 insertions(+), 48 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0f90080..7e29cb0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Add support for volume autoactivation using lvmetad.
   Add --activate synonym for --available arg and prefer --activate.
   Never issue discards when LV extents are being reconfigured, not deleted.
   Allow release_lv_segment_area to fail as functions it calls can fail.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1f21573..939de6c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -328,10 +328,8 @@ int activation(void)
 	return _activation;
 }
 
-static int _passes_volumes_filter(struct cmd_context *cmd,
-				  struct logical_volume *lv,
-				  const struct dm_config_node *cn,
-				  const char *config_path)
+int lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_volume *lv,
+			     const struct dm_config_node *cn, const char *config_path)
 {
 	const struct dm_config_value *cv;
 	const char *str;
@@ -429,7 +427,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 		return 0;
 	}
 
-	return _passes_volumes_filter(cmd, lv, cn, "activation/volume_list");
+	return lv_passes_volumes_filter(cmd, lv, cn, "activation/volume_list");
 }
 
 static int _passes_readonly_filter(struct cmd_context *cmd,
@@ -440,7 +438,21 @@ static int _passes_readonly_filter(struct cmd_context *cmd,
 	if (!(cn = find_config_tree_node(cmd, "activation/read_only_volume_list")))
 		return 0;
 
-	return _passes_volumes_filter(cmd, lv, cn, "activation/read_only_volume_list");
+	return lv_passes_volumes_filter(cmd, lv, cn, "activation/read_only_volume_list");
+}
+
+
+int lv_passes_auto_activation_filter(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	const struct dm_config_node *cn;
+
+	if (!(cn = find_config_tree_node(cmd, "activation/auto_activation_volume_list"))) {
+		log_verbose("activation/auto_activation_volume_list configuration setting "
+			    "not defined: All logical volumes will be auto-activated.");
+		return 1;
+	}
+
+	return lv_passes_volumes_filter(cmd, lv, cn, "activation/auto_activation_volume_list");
 }
 
 int library_version(char *version, size_t size)
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 2b90a7b..f698fc9 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -93,6 +93,14 @@ int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
  */
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 			 int *activate_lv);
+int lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_volume *lv,
+			     const struct dm_config_node *cn, const char *config_path);
+
+/*
+ * Checks against the auto_activation_volume_list and
+ * returns 1 if the LV should be activated, 0 otherwise.
+ */
+int lv_passes_auto_activation_filter(struct cmd_context *cmd, struct logical_volume *lv);
 
 int lv_check_transient(struct logical_volume *lv);
 /*
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index d70e490..6ef30db 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -322,7 +322,7 @@ int lvmetad_vg_update(struct volume_group *vg)
 		/* NB. the PV fmt pointer is sometimes wrong during vgconvert */
 		if (pvl->pv->dev && !lvmetad_pv_found(pvl->pv->id, pvl->pv->dev,
 						      vg->fid ? vg->fid->fmt : pvl->pv->fmt,
-						      pvl->pv->label_sector, NULL))
+						      pvl->pv->label_sector, NULL, NULL))
 			return 0;
 	}
 
@@ -536,7 +536,7 @@ static const char *_print_mdas(struct lvmcache_info *info)
 }
 
 int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_type *fmt,
-		     uint64_t label_sector, struct volume_group *vg)
+		     uint64_t label_sector, struct volume_group *vg, activation_handler handler)
 {
 	char uuid[64];
 	daemon_reply reply;
@@ -544,6 +544,7 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 	const char *mdas = NULL;
 	char *pvmeta;
 	char *buf = NULL;
+	const char *status;
 	int result;
 
 	if (!_using_lvmetad)
@@ -603,12 +604,26 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 	dm_free(pvmeta);
 
 	result = _lvmetad_handle_reply(reply, "update PV", uuid, NULL);
+
+	if (result && handler) {
+		status = daemon_reply_str(reply, "status", "<missing>");
+		if (!strcmp(status, "partial"))
+			handler(vg, 1, CHANGE_AAY);
+		else if (!strcmp(status, "complete"))
+			handler(vg, 0, CHANGE_AAY);
+		else if (!strcmp(status, "orphan"))
+			;
+		else
+			log_error("Request to %s %s in lvmetad gave status %s.",
+			  "update PV", uuid, status);
+	}
+
 	daemon_reply_destroy(reply);
 
 	return result;
 }
 
-int lvmetad_pv_gone(dev_t device, const char *pv_name)
+int lvmetad_pv_gone(dev_t device, const char *pv_name, activation_handler handler)
 {
 	daemon_reply reply;
 	int result;
@@ -617,6 +632,13 @@ int lvmetad_pv_gone(dev_t device, const char *pv_name)
 	if (!_using_lvmetad)
 		return 1;
 
+	/*
+         *  TODO: automatic volume deactivation takes place here *before*
+         *        all cached info is gone - call handler. Also, consider
+         *        integrating existing deactivation script  that deactivates
+         *        the whole stack from top to bottom (not yet upstream).
+         */
+
 	reply = daemon_send_simple(_lvmetad, "pv_gone", "device = %d", device, NULL);
 
 	result = _lvmetad_handle_reply(reply, "drop PV", pv_name, &found);
@@ -627,9 +649,9 @@ int lvmetad_pv_gone(dev_t device, const char *pv_name)
 	return result;
 }
 
-int lvmetad_pv_gone_by_dev(struct device *dev)
+int lvmetad_pv_gone_by_dev(struct device *dev, activation_handler handler)
 {
-	return lvmetad_pv_gone(dev->dev, dev_name(dev));
+	return lvmetad_pv_gone(dev->dev, dev_name(dev), handler);
 }
 
 int lvmetad_active(void)
@@ -665,7 +687,8 @@ static int _pvscan_lvmetad_single(struct metadata_area *mda, void *baton)
 	return 1;
 }
 
-int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev)
+int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev,
+			  activation_handler handler)
 {
 	struct label *label;
 	struct lvmcache_info *info;
@@ -680,7 +703,7 @@ int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev)
 
 	if (!label_read(dev, &label, 0)) {
 		log_print("No PV label found on %s.", dev_name(dev));
-		if (!lvmetad_pv_gone_by_dev(dev))
+		if (!lvmetad_pv_gone_by_dev(dev, handler))
 			goto_bad;
 		return 1;
 	}
@@ -704,7 +727,7 @@ int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev)
 	 * sync needs to be killed.
 	 */
 	if (!lvmetad_pv_found(*(struct id *)dev->pvid, dev, lvmcache_fmt(info),
-			      label->sector, baton.vg)) {
+			      label->sector, baton.vg, handler)) {
 		release_vg(baton.vg);
 		goto_bad;
 	}
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 091ff5e..713c5a3 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -19,6 +19,8 @@ struct volume_group;
 struct cmd_context;
 struct dm_config_tree;
 
+typedef int (*activation_handler) (struct volume_group *vg, int partial, int activate);
+
 #ifdef LVMETAD_SUPPORT
 /*
  * Initialise the communication with lvmetad. Normally called by
@@ -64,13 +66,13 @@ int lvmetad_vg_remove(struct volume_group *vg);
  */
 int lvmetad_pv_found(struct id pvid, struct device *device,
 		     const struct format_type *fmt, uint64_t label_sector,
-		     struct volume_group *vg);
+		     struct volume_group *vg, activation_handler handler);
 
 /*
  * Inform the daemon that the device no longer exists.
  */
-int lvmetad_pv_gone(dev_t devno, const char *pv_name);
-int lvmetad_pv_gone_by_dev(struct device *dev);
+int lvmetad_pv_gone(dev_t devno, const char *pv_name, activation_handler handler);
+int lvmetad_pv_gone_by_dev(struct device *dev, activation_handler handler);
 
 /*
  * Request a list of all PVs available to lvmetad. If requested, this will also
@@ -102,7 +104,8 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd,
 /*
  * Scan a single device and update lvmetad with the result(s).
  */
-int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev);
+int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev,
+			  activation_handler handler);
 
 #  else		/* LVMETAD_SUPPORT */
 
@@ -111,15 +114,15 @@ int pvscan_lvmetad_single(struct cmd_context *cmd, struct device *dev);
 #    define lvmetad_active()	(0)
 #    define lvmetad_vg_update(vg)	(1)
 #    define lvmetad_vg_remove(vg)	(1)
-#    define lvmetad_pv_found(pvid, device, fmt, label_sector, vg)	(1)
-#    define lvmetad_pv_gone(devno, pv_name)	(1)
-#    define lvmetad_pv_gone_by_dev(dev)	(1)
+#    define lvmetad_pv_found(pvid, device, fmt, label_sector, vg, handler)	(1)
+#    define lvmetad_pv_gone(devno, pv_name, handler)	(1)
+#    define lvmetad_pv_gone_by_dev(dev, handler)	(1)
 #    define lvmetad_pv_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_pv_lookup(cmd, pvid, found)	(0)
 #    define lvmetad_pv_lookup_by_dev(cmd, dev, found)	(0)
 #    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
-#    define pvscan_lvmetad_single(cmd, dev)	(0)
+#    define pvscan_lvmetad_single(cmd, dev, handler)	(0)
 
 #  endif	/* LVMETAD_SUPPORT */
 
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 403367e..8c655c7 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -567,7 +567,8 @@ typedef enum {
 	CHANGE_AN = 1,  /* deactivate */
 	CHANGE_AE = 2,  /* activate exclusively */
 	CHANGE_ALY = 3, /* activate locally */
-	CHANGE_ALN = 4  /* deactivate locally */
+	CHANGE_ALN = 4, /* deactivate locally */
+	CHANGE_AAY = 5  /* automatic activation */
 } activation_change_t;
 
 /* FIXME: refactor and reduce the size of this struct! */
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 7c22785..c14125a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3800,7 +3800,8 @@ int pv_write(struct cmd_context *cmd __attribute__((unused)),
 	if (!pv->fmt->ops->pv_write(pv->fmt, pv))
 		return_0;
 
-	if (!lvmetad_pv_found(pv->id, pv->dev, pv->fmt, pv->label_sector, NULL))
+	if (!lvmetad_pv_found(pv->id, pv->dev, pv->fmt, pv->label_sector,
+			      NULL, NULL))
 		return_0;
 
 	return 1;
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 37b86da..16e15a1 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -188,6 +188,12 @@ int activation_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_v
 		av->ui_value = CHANGE_AY;
 	}
 
+	else if (!strcmp(av->value, "a") || !strcmp(av->value, "ay") ||
+		 !strcmp(av->value, "ya")) {
+		av->i_value = CHANGE_AAY;
+		av->ui_value = CHANGE_AAY;
+	}
+
 	else if (!strcmp(av->value, "n") || !strcmp(av->value, "en") ||
 		 !strcmp(av->value, "ne")) {
 		av->i_value = CHANGE_AN;
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 0c06c7f..7d05758 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -128,7 +128,7 @@ static int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		goto out;
 	}
 
-	if (!lvmetad_pv_gone_by_dev(dev))
+	if (!lvmetad_pv_gone_by_dev(dev, NULL))
 		goto_out;
 
 	log_print("Labels on physical volume \"%s\" successfully wiped",
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 62034c9..beba174 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -97,7 +97,7 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 					   pv_pe_size(pv)));
 }
 
-static int _pvscan_lvmetad_all_devs(struct cmd_context *cmd)
+static int _pvscan_lvmetad_all_devs(struct cmd_context *cmd, activation_handler handler)
 {
 	struct dev_iter *iter;
 	struct device *dev;
@@ -109,7 +109,7 @@ static int _pvscan_lvmetad_all_devs(struct cmd_context *cmd)
 	}
 
 	while ((dev = dev_iter_get(iter))) {
-		if (!pvscan_lvmetad_single(cmd, dev)) {
+		if (!pvscan_lvmetad_single(cmd, dev, handler)) {
 			r = 0;
 			break;
 		}
@@ -134,6 +134,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	struct arg_value_group_list *current_group;
 	dev_t devno;
 	char *buf;
+	activation_handler handler = NULL;
 
 	if (arg_count(cmd, major_ARG) + arg_count(cmd, minor_ARG))
 		devno_args = 1;
@@ -150,7 +151,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 
 	/* Scan everything? */
 	if (!argc && !devno_args) {
-		if (!_pvscan_lvmetad_all_devs(cmd))
+		if (!_pvscan_lvmetad_all_devs(cmd, handler))
 			ret = ECMD_FAILED;
 		goto out;
 	}
@@ -167,7 +168,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 			continue;
 		}
 
-		if (!pvscan_lvmetad_single(cmd, dev)) {
+		if (!pvscan_lvmetad_single(cmd, dev, handler)) {
 			ret = ECMD_FAILED;
 			break;
 		}
@@ -192,7 +193,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 			if (!dm_asprintf(&buf, "%" PRIi32 ":%" PRIi32, major, minor))
 				stack;
 			/* FIXME Filters? */
-			if (!lvmetad_pv_gone(devno, buf ? : "")) {
+			if (!lvmetad_pv_gone(devno, buf ? : "", handler)) {
 				ret = ECMD_FAILED;
 				if (buf)
 					dm_free(buf);
@@ -206,7 +207,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 			continue;
 		}
 
-		if (!pvscan_lvmetad_single(cmd, dev)) {
+		if (!pvscan_lvmetad_single(cmd, dev, handler)) {
 			ret = ECMD_FAILED;
 			break;
 		}
diff --git a/tools/tools.h b/tools/tools.h
index 8ddd351..7a44651 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -185,4 +185,7 @@ int mirror_remove_missing(struct cmd_context *cmd,
 			  struct logical_volume *lv, int force);
 
 uint32_t percent_of_extents(uint32_t percents, uint32_t count, int roundup);
+
+int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
+		       activation_change_t activate);
 #endif
diff --git a/tools/vgchange.c b/tools/vgchange.c
index fdad81f..29562a5 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -81,8 +81,8 @@ static int _poll_lvs_in_vg(struct cmd_context *cmd,
 	return count;
 }
 
-static int _activate_lvs_in_vg(struct cmd_context *cmd,
-			       struct volume_group *vg, int activate)
+static int _activate_lvs_in_vg(struct cmd_context *cmd, struct volume_group *vg,
+			       activation_change_t activate)
 {
 	struct lv_list *lvl;
 	struct logical_volume *lv;
@@ -211,35 +211,32 @@ static int _vgchange_background_polling(struct cmd_context *cmd, struct volume_g
 	return 1;
 }
 
-static int _vgchange_activate(struct cmd_context *cmd, struct volume_group *vg)
+int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
+		      activation_change_t activate)
 {
-	int lv_open, active, monitored = 0;
-	int activate_arg, r = 1;
-	int activate = 1;
+	int lv_open, active, monitored = 0, r = 1, do_activate = 1;
+
+	if ((activate == CHANGE_AN) || (activate == CHANGE_ALN))
+		do_activate = 0;
 
 	/*
 	 * Safe, since we never write out new metadata here. Required for
 	 * partial activation to work.
 	 */
-	cmd->handles_missing_pvs = 1;
-
-	activate_arg = arg_uint_value(cmd, activate_ARG, 0);
-
-	if ((activate_arg == CHANGE_AN) || (activate_arg == CHANGE_ALN))
-		activate = 0;
+        cmd->handles_missing_pvs = 1;
 
 	/* FIXME: Force argument to deactivate them? */
-	if (!activate && (lv_open = lvs_in_vg_opened(vg))) {
+	if (!do_activate && (lv_open = lvs_in_vg_opened(vg))) {
 		log_error("Can't deactivate volume group \"%s\" with %d open "
 			  "logical volume(s)", vg->name, lv_open);
 		return 0;
 	}
 
 	/* FIXME Move into library where clvmd can use it */
-	if (activate)
+	if (do_activate)
 		check_current_backup(vg);
 
-	if (activate && (active = lvs_in_vg_activated(vg))) {
+	if (do_activate && (active = lvs_in_vg_activated(vg))) {
 		log_verbose("%d logical volume(s) in volume group \"%s\" "
 			    "already active", active, vg->name);
 		if (dmeventd_monitor_mode() != DMEVENTD_MONITOR_IGNORE) {
@@ -252,7 +249,7 @@ static int _vgchange_activate(struct cmd_context *cmd, struct volume_group *vg)
 		}
 	}
 
-	if (!_activate_lvs_in_vg(cmd, vg, activate_arg))
+	if (!_activate_lvs_in_vg(cmd, vg, activate))
 		r = 0;
 
 	/* Print message only if there was not found a missing VG */
@@ -509,7 +506,7 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	if (arg_count(cmd, activate_ARG)) {
-		if (!_vgchange_activate(cmd, vg))
+		if (!vgchange_activate(cmd, vg, arg_uint_value(cmd, activate_ARG, CHANGE_AY)))
 			return ECMD_FAILED;
 	}
 


