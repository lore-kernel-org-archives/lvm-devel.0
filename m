From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 23 May 2016 17:05:13 +0000 (UTC)
Subject: master - pvscan: use process_each_vg for autoactivate
Message-ID: <20160523170513.1A20860D7B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9b640c36841e2790731d54a5830dcea8203f9e80
Commit:        9b640c36841e2790731d54a5830dcea8203f9e80
Parent:        55683a659f9bf6875dd930e2dff62f1e1bdb88aa
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 28 09:37:03 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 23 11:57:32 2016 -0500

pvscan: use process_each_vg for autoactivate

This refactors the code for autoactivation.  Previously,
as each PV was found, it would be sent to lvmetad, and
the VG would be autoactivated using a non-standard VG
processing function (the "activation_handler") called via
a function pointer from within the lvmetad notification path.

Now, any scanning that the command needs to do (scanning
only the named device args, or scanning all devices when
there are no args), is done first, before any activation
is attempted.  During the scans, the VG names are saved.
After scanning is complete, process_each_vg is used to do
autoactivation of the saved VG names.  This makes pvscan
activation much more similar to activation done with
vgchange or lvchange.

The separate autoactivate phase also means that if lvmetad
is disabled (either before or during the scan), the command
can continue with the activation step by simply not using
lvmetad and reverting to disk scanning to do the
activation.
---
 lib/cache/lvmetad.c                |  154 +++++---------
 lib/cache/lvmetad.h                |   27 ++--
 lib/metadata/metadata.c            |    5 +-
 lib/metadata/pv_manip.c            |    2 +-
 test/shell/lvmetad-pvscan-nomda.sh |   10 +-
 tools/lvmcmdline.c                 |    2 +-
 tools/lvscan.c                     |    4 +-
 tools/pvscan.c                     |  406 ++++++++++++++++++++++--------------
 tools/toollib.c                    |    4 +-
 tools/vgimport.c                   |    2 +-
 tools/vgscan.c                     |    2 +-
 11 files changed, 334 insertions(+), 284 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 9f7bf32..6f914b2 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -23,6 +23,7 @@
 #include "crc.h"
 #include "lvm-signal.h"
 #include "lvmlockd.h"
+#include "str_list.h"
 
 #include <time.h>
 
@@ -399,9 +400,6 @@ out:
 	return ret;
 }
 
-static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler,
-				    int ignore_obsolete, int do_wait);
-
 static daemon_reply _lvmetad_send(struct cmd_context *cmd, const char *id, ...)
 {
 	va_list ap;
@@ -1017,9 +1015,9 @@ int lvmetad_vg_update(struct volume_group *vg)
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		/* NB. the PV fmt pointer is sometimes wrong during vgconvert */
-		if (pvl->pv->dev && !lvmetad_pv_found(&pvl->pv->id, pvl->pv->dev,
+		if (pvl->pv->dev && !lvmetad_pv_found(vg->cmd, &pvl->pv->id, pvl->pv->dev,
 						      vg->fid ? vg->fid->fmt : pvl->pv->fmt,
-						      pvl->pv->label_sector, NULL, NULL))
+						      pvl->pv->label_sector, NULL, NULL, NULL))
 			return 0;
 	}
 
@@ -1303,14 +1301,16 @@ static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
 	return 1;
 }
 
-int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct format_type *fmt,
-		     uint64_t label_sector, struct volume_group *vg, activation_handler handler)
+int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct device *dev, const struct format_type *fmt,
+		     uint64_t label_sector, struct volume_group *vg,
+		     struct dm_list *found_vgnames,
+		     struct dm_list *changed_vgnames)
 {
 	char uuid[64];
 	daemon_reply reply;
 	struct lvmcache_info *info;
 	struct dm_config_tree *pvmeta, *vgmeta;
-	const char *status, *vgname, *vgid;
+	const char *status, *vgname;
 	int64_t changed;
 	int result;
 
@@ -1358,7 +1358,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 		}
 
 		log_debug_lvmetad("Telling lvmetad to store PV %s (%s) in VG %s", dev_name(dev), uuid, vg->name);
-		reply = _lvmetad_send(vg->cmd, "pv_found",
+		reply = _lvmetad_send(cmd, "pv_found",
 				      "pvmeta = %t", pvmeta,
 				      "vgname = %s", vg->name,
 				      "metadata = %t", vgmeta,
@@ -1382,65 +1382,41 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 	     daemon_reply_int(reply, "seqno_after", -1) != daemon_reply_int(reply, "seqno_before", -1)))
 		log_warn("WARNING: Inconsistent metadata found for VG %s", vg->name);
 
+	if (result && found_vgnames) {
+		status = daemon_reply_str(reply, "status", NULL);
+		vgname = daemon_reply_str(reply, "vgname", NULL);
+		changed = daemon_reply_int(reply, "changed", 0);
+	}
+
 	/*
-	 * pvscan --cache does not perform any lvmlockd locking, and
-	 * pvscan --cache -aay skips autoactivation in lockd VGs.
-	 *
-	 * pvscan --cache populates lvmetad with VG metadata from disk.
-	 * No lvmlockd locking is needed.  It is expected that lockd VG
-	 * metadata that is read by pvscan and populated in lvmetad may
-	 * be immediately stale due to changes to the VG from other hosts
-	 * during or after this pvscan.  This is normal and not a problem.
-	 * When a subsequent lvm command uses the VG, it will lock the VG
-	 * with lvmlockd, read the VG from lvmetad, and update the cached
-	 * copy from disk if necessary.
-	 *
-	 * pvscan --cache -aay does not activate LVs in lockd VGs because
-	 * activation requires locking, and a lock-start operation is needed
-	 * on a lockd VG before any locking can be performed in it.
+	 * If lvmetad now sees all PVs in the VG, it returned the
+	 * "complete" status string.  Add this VG name to the list
+	 * of found VGs so that the caller can do autoactivation.
 	 *
-	 * An equivalent of pvscan --cache -aay for lockd VGs is:
-	 * 1. pvscan --cache
-	 * 2. vgchange --lock-start
-	 * 3. vgchange -aay -S 'locktype=sanlock || locktype=dlm'
+	 * If there was a problem notifying lvmetad about the new
+	 * PV, e.g. lvmetad was disabled due to a duplicate, then
+	 * no autoactivation is attempted.
 	 *
-	 * [We could eventually add support for autoactivating lockd VGs
-	 * using pvscan by incorporating the lock start step (which can
-	 * take a long time), but there may be a better option than
-	 * continuing to overload pvscan.]
-	 * 
-	 * Stages of starting a lockd VG:
+	 * FIXME: there was a previous fixme indicating that
+	 * autoactivation might also be done for VGs with the
+	 * "partial" status.
 	 *
-	 * . pvscan --cache populates lockd VGs in lvmetad without locks,
-	 *   and this initial cached copy may quickly become stale.
-	 *
-	 * . vgchange --lock-start VG reads the VG without the VG lock
-	 *   because no locks are available until the locking is started.
-	 *   It only uses the VG name and lock_type from the VG metadata,
-	 *   and then only uses it to start the VG lockspace in lvmlockd.
-	 *
-	 * . Further lvm commands, e.g. activation, can then lock the VG
-	 *   with lvmlockd and use current VG metdata.
+	 * If the VG has "changed" by finding the PV, lvmetad returns
+	 * the "changed" flag.  The names of "changed" VGs are saved
+	 * in the changed_vgnames lists, which is used during autoactivation.
+	 * If a VG is changed, then autoactivation refreshes LVs in the VG.
 	 */
-	if (handler && vg && is_lockd_type(vg->lock_type)) {
-		log_debug_lvmetad("Skip pvscan activation for lockd type VG %s", vg->name);
-		handler = NULL;
-	}
 
-	if (result && handler) {
-		status = daemon_reply_str(reply, "status", "<missing>");
-		vgname = daemon_reply_str(reply, "vgname", "<missing>");
-		vgid = daemon_reply_str(reply, "vgid", "<missing>");
-		changed = daemon_reply_int(reply, "changed", 0);
-		if (!strcmp(status, "partial"))
-			handler(_lvmetad_cmd, vgname, vgid, 1, changed, CHANGE_AAY);
-		else if (!strcmp(status, "complete"))
-			handler(_lvmetad_cmd, vgname, vgid, 0, changed, CHANGE_AAY);
-		else if (!strcmp(status, "orphan"))
-			;
-		else
-			log_error("Request to %s %s in lvmetad gave status %s.",
-			  "update PV", uuid, status);
+	if (found_vgnames && vgname && status && !strcmp(status, "complete")) {
+		log_debug("VG %s is complete in lvmetad with dev %s.", vgname, dev_name(dev));
+		if (!str_list_add(cmd->mem, found_vgnames, dm_pool_strdup(cmd->mem, vgname)))
+			log_error("str_list_add failed");
+
+		if (changed_vgnames && changed) {
+			log_debug("VG %s is changed in lvmetad.", vgname);
+			if (!str_list_add(cmd->mem, changed_vgnames, dm_pool_strdup(cmd->mem, vgname)))
+				log_error("str_list_add failed");
+		}
 	}
 
 	daemon_reply_destroy(reply);
@@ -1448,7 +1424,7 @@ int lvmetad_pv_found(const struct id *pvid, struct device *dev, const struct for
 	return result;
 }
 
-int lvmetad_pv_gone(dev_t devno, const char *pv_name, activation_handler handler)
+int lvmetad_pv_gone(dev_t devno, const char *pv_name)
 {
 	daemon_reply reply;
 	int result;
@@ -1475,9 +1451,9 @@ int lvmetad_pv_gone(dev_t devno, const char *pv_name, activation_handler handler
 	return result;
 }
 
-int lvmetad_pv_gone_by_dev(struct device *dev, activation_handler handler)
+int lvmetad_pv_gone_by_dev(struct device *dev)
 {
-	return lvmetad_pv_gone(dev->dev, dev_name(dev), handler);
+	return lvmetad_pv_gone(dev->dev, dev_name(dev));
 }
 
 /*
@@ -1546,10 +1522,8 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 			return NULL;
 
 		if (baton.fid->fmt->features & FMT_OBSOLETE) {
-			log_error("WARNING: Ignoring obsolete format of metadata (%s) on device %s when using lvmetad",
-			  	baton.fid->fmt->name, dev_name(pvl->pv->dev));
 			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
-			log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
+			log_warn("WARNING: Disabling lvmetad cache which does not support obsolete (lvm1) metadata.");
 			lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_LVM1);
 			_found_lvm1_metadata = 1;
 			return NULL;
@@ -1635,7 +1609,8 @@ out:
 }
 
 int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
-			  activation_handler handler, int ignore_obsolete)
+			  struct dm_list *found_vgnames,
+			  struct dm_list *changed_vgnames)
 {
 	struct label *label;
 	struct lvmcache_info *info;
@@ -1651,7 +1626,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 
 	if (!label_read(dev, &label, 0)) {
 		log_print_unless_silent("No PV label found on %s.", dev_name(dev));
-		if (!lvmetad_pv_gone_by_dev(dev, handler))
+		if (!lvmetad_pv_gone_by_dev(dev))
 			goto_bad;
 		return 1;
 	}
@@ -1665,21 +1640,11 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 		goto_bad;
 
 	if (baton.fid->fmt->features & FMT_OBSOLETE) {
-		if (ignore_obsolete)
-			log_warn("WARNING: Ignoring obsolete format of metadata (%s) on device %s when using lvmetad",
-				  baton.fid->fmt->name, dev_name(dev));
-		else
-			log_error("Ignoring obsolete format of metadata (%s) on device %s when using lvmetad.",
-				  baton.fid->fmt->name, dev_name(dev));
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
-
-		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete metadata.");
+		log_warn("WARNING: Disabling lvmetad cache which does not support obsolete (lvm1) metadata.");
 		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_LVM1);
 		_found_lvm1_metadata = 1;
-
-		if (ignore_obsolete)
-			return 1;
-		return 0;
+		return 1;
 	}
 
 	lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
@@ -1700,8 +1665,8 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	if (!baton.vg)
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 
-	if (!lvmetad_pv_found((const struct id *) &dev->pvid, dev, lvmcache_fmt(info),
-			      label->sector, baton.vg, handler)) {
+	if (!lvmetad_pv_found(cmd, (const struct id *) &dev->pvid, dev, lvmcache_fmt(info),
+			      label->sector, baton.vg, found_vgnames, changed_vgnames)) {
 		release_vg(baton.vg);
 		goto_bad;
 	}
@@ -1738,8 +1703,7 @@ bad:
  * generally revert disk scanning and not use lvmetad.
  */
 
-static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler,
-				    int ignore_obsolete, int do_wait)
+int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait)
 {
 	struct dev_iter *iter;
 	struct device *dev;
@@ -1820,7 +1784,7 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 			stack;
 			break;
 		}
-		if (!lvmetad_pvscan_single(cmd, dev, handler, ignore_obsolete))
+		if (!lvmetad_pvscan_single(cmd, dev, NULL, NULL))
 			ret = 0;
 	}
 
@@ -1850,20 +1814,6 @@ static int _lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler
 	return ret;
 }
 
-int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler, int do_wait)
-{
-	return _lvmetad_pvscan_all_devs(cmd, handler, 0, do_wait);
-}
-
-/* 
- * FIXME Implement this function, skipping PVs known to belong to local or clustered,
- * non-exported VGs.
- */
-int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handler)
-{
-	return _lvmetad_pvscan_all_devs(cmd, handler, 1, 1);
-}
-
 int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg)
 {
 	char uuid[64];
@@ -2145,7 +2095,7 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 	 * we rescanned for the token, and the time we acquired the global
 	 * lock.)
 	 */
-	if (!lvmetad_pvscan_all_devs(cmd, NULL, 1)) {
+	if (!lvmetad_pvscan_all_devs(cmd, 1)) {
 		log_warn("WARNING: Not using lvmetad because cache update failed.");
 		lvmetad_make_unused(cmd);
 		return;
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 0985a54..3bb2b7c 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -95,15 +95,17 @@ int lvmetad_vg_remove(struct volume_group *vg);
  * number on the cached and on the discovered PV match but the metadata content
  * does not.
  */
-int lvmetad_pv_found(const struct id *pvid, struct device *dev,
+int lvmetad_pv_found(struct cmd_context *cmd, const struct id *pvid, struct device *dev,
 		     const struct format_type *fmt, uint64_t label_sector,
-		     struct volume_group *vg, activation_handler handler);
+		     struct volume_group *vg,
+		     struct dm_list *found_vgnames,
+		     struct dm_list *changed_vgnames);
 
 /*
  * Inform the daemon that the device no longer exists.
  */
-int lvmetad_pv_gone(dev_t devno, const char *pv_name, activation_handler handler);
-int lvmetad_pv_gone_by_dev(struct device *dev, activation_handler handler);
+int lvmetad_pv_gone(dev_t devno, const char *pv_name);
+int lvmetad_pv_gone_by_dev(struct device *dev);
 
 /*
  * Request a list of all PVs available to lvmetad. If requested, this will also
@@ -142,10 +144,10 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd,
  * Scan a single device and update lvmetad with the result(s).
  */
 int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
-			  activation_handler handler, int ignore_obsolete);
+			  struct dm_list *found_vgnames,
+			  struct dm_list *changed_vgnames);
 
-int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler, int do_wait);
-int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handler);
+int lvmetad_pvscan_all_devs(struct cmd_context *cmd, int do_wait);
 
 int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg);
 void lvmetad_validate_global_cache(struct cmd_context *cmd, int force);
@@ -170,18 +172,17 @@ void lvmetad_clear_disabled(struct cmd_context *cmd);
 #    define lvmetad_release_token()	do { } while (0)
 #    define lvmetad_vg_update(vg)	(1)
 #    define lvmetad_vg_remove(vg)	(1)
-#    define lvmetad_pv_found(pvid, dev, fmt, label_sector, vg, handler)	(1)
-#    define lvmetad_pv_gone(devno, pv_name, handler)	(1)
-#    define lvmetad_pv_gone_by_dev(dev, handler)	(1)
+#    define lvmetad_pv_found(cmd, pvid, dev, fmt, label_sector, vg, found_vgnames, changed_vgnames)	(1)
+#    define lvmetad_pv_gone(devno, pv_name)	(1)
+#    define lvmetad_pv_gone_by_dev(dev)	(1)
 #    define lvmetad_pv_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_pv_lookup(cmd, pvid, found)	(0)
 #    define lvmetad_pv_lookup_by_dev(cmd, dev, found)	(0)
 #    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
 #    define lvmetad_get_vgnameids(cmd, vgnameids)       do { } while (0)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
-#    define lvmetad_pvscan_single(cmd, dev, handler, ignore_obsolete)	(0)
-#    define lvmetad_pvscan_all_devs(cmd, handler, do_wait)	(0)
-#    define lvmetad_pvscan_foreign_vgs(cmd, handler)	(0)
+#    define lvmetad_pvscan_single(cmd, dev, found_vgnames, changed_vgnames)	(0)
+#    define lvmetad_pvscan_all_devs(cmd, do_wait)	(0)
 #    define lvmetad_vg_clear_outdated_pvs(vg)           do { } while (0)
 #    define lvmetad_validate_global_cache(cmd, force)	do { } while (0)
 #    define lvmetad_vg_is_foreign(cmd, vgname, vgid) (0)
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 8adcbbd..9e31ba4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5242,7 +5242,7 @@ int scan_vgs_for_pvs(struct cmd_context *cmd, uint32_t warn_flags)
 	return _get_pvs(cmd, warn_flags, NULL, NULL);
 }
 
-int pv_write(struct cmd_context *cmd __attribute__((unused)),
+int pv_write(struct cmd_context *cmd,
 	     struct physical_volume *pv, int allow_non_orphan)
 {
 	if (!pv->fmt->ops->pv_write) {
@@ -5268,8 +5268,7 @@ int pv_write(struct cmd_context *cmd __attribute__((unused)),
 
 	pv->status &= ~UNLABELLED_PV;
 
-	if (!lvmetad_pv_found(&pv->id, pv->dev, pv->fmt, pv->label_sector,
-			      NULL, NULL))
+	if (!lvmetad_pv_found(cmd, &pv->id, pv->dev, pv->fmt, pv->label_sector, NULL, NULL, NULL))
 		return_0;
 
 	return 1;
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index d38262d..fa18c99 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -810,7 +810,7 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 	if (info)
 		lvmcache_del(info);
 
-	if (!lvmetad_pv_gone_by_dev(dev, NULL))
+	if (!lvmetad_pv_gone_by_dev(dev))
 		goto_out;
 
 	log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped",
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index 59912ad..6cb2062 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -37,13 +37,19 @@ aux lvmconf 'global/use_lvmetad = 0'
 check inactive $vg1 foo
 aux lvmconf 'global/use_lvmetad = 1'
 
-pvscan --cache "$dev2" -aay
+# Tell lvmetad about dev2, but the VG is not complete with
+# only dev2, so the -aay should not yet activate the LV.
+
+pvscan --cache -aay "$dev2"
 
 aux lvmconf 'global/use_lvmetad = 0'
 check inactive $vg1 foo
 aux lvmconf 'global/use_lvmetad = 1'
 
-pvscan --cache "$dev1" -aay
+# Tell lvmetad about dev1, now the VG is complete with
+# both devs, so the -aay should activate the LV.
+
+pvscan --cache -aay "$dev1"
 
 aux lvmconf 'global/use_lvmetad = 0'
 check active $vg1 foo
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4009921..be6821b 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1681,7 +1681,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	 */
 	if (lvmetad_used() && !(cmd->command->flags & NO_LVMETAD_AUTOSCAN)) {
 		if (cmd->include_foreign_vgs || !lvmetad_token_matches(cmd)) {
-			if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, cmd->include_foreign_vgs ? 1 : 0)) {
+			if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, cmd->include_foreign_vgs ? 1 : 0)) {
 				log_warn("WARNING: Not using lvmetad because cache update failed.");
 				lvmetad_make_unused(cmd);
 			}
diff --git a/tools/lvscan.c b/tools/lvscan.c
index 4ae3ce6..23d3d7f 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -38,7 +38,7 @@ static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume
 					 pvid_s);
 			continue;
 		}
-		if (!lvmetad_pvscan_single(cmd, pvl->pv->dev, NULL, 0))
+		if (!lvmetad_pvscan_single(cmd, pvl->pv->dev, NULL, NULL))
 			return ECMD_FAILED;
 	}
 
@@ -103,7 +103,7 @@ int lvscan(struct cmd_context *cmd, int argc, char **argv)
 
 	/* Needed because this command has NO_LVMETAD_AUTOSCAN. */
 	if (lvmetad_used() && (!lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
-		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, 0)) {
+		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, 0)) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
 			lvmetad_make_unused(cmd);
 		}
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 50753fd..3e9efef 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -29,6 +29,12 @@ struct pvscan_params {
 	char *pv_tmp_name;
 };
 
+struct pvscan_aa_params {
+	int refresh_all;
+	unsigned int activate_errors;
+	struct dm_list changed_vgnames;
+};
+
 static int _pvscan_display_single(struct cmd_context *cmd,
 				  struct physical_volume *pv,
 				  struct pvscan_params *params)
@@ -120,70 +126,85 @@ static int _pvscan_single(struct cmd_context *cmd, struct volume_group *vg,
 	return ECMD_PROCESSED;
 }
 
-#define REFRESH_BEFORE_AUTOACTIVATION_RETRIES 5
-#define REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY 100000
-
-static int _auto_activation_handler(struct cmd_context *cmd,
-				    const char *vgname, const char *vgid,
-				    int partial, int changed,
-				    activation_change_t activate)
+static int _lvmetad_clear_dev(dev_t devno, int32_t major, int32_t minor)
 {
-	unsigned int refresh_retries = REFRESH_BEFORE_AUTOACTIVATION_RETRIES;
-	int refresh_done = 0;
-	struct volume_group *vg;
-	struct id vgid_raw;
-	uint32_t read_error;
-	int r = 0;
+	char buf[24];
 
-	/* TODO: add support for partial and clustered VGs */
-	if (partial)
-		return 1;
+	(void) dm_snprintf(buf, sizeof(buf), FMTi32 ":" FMTi32, major, minor);
 
-	if (!id_read_format(&vgid_raw, vgid))
+	if (!lvmetad_pv_gone(devno, buf))
 		return_0;
 
-	/*
-	 * FIXME: pvscan activation really needs to be changed to use
-	 * the standard process_each_vg() interface.  It should save
-	 * a list of VG names that are found during the scan, then
-	 * call process_each_vg() with that list to do activation.
-	 */
+	log_print_unless_silent("Device %s not found. Cleared from lvmetad cache.", buf);
 
-	cmd->vg_read_print_access_error = 0;
-
-	/* NB. This is safe because we know lvmetad is running and we won't hit disk. */
-	vg = vg_read(cmd, vgname, (const char *)&vgid_raw, 0, 0);
-	read_error = vg_read_error(vg);
-	if (read_error) {
-		/*
-		 * foreign VGs: we want to read and update lvmetad, but that's
-		 * all, we don't want to even attempt to autoactivate.
-		 *
-		 * shared VGs: we want to read and update lvmetad, and for now
-		 * ignore them for autoactivation.  Once pvscan autoactivation
-		 * uses process_each_vg, then shared VGs could be autoactivated.
-		 */
-		if (read_error & (FAILED_SYSTEMID | FAILED_LOCK_TYPE | FAILED_LOCK_MODE)) {
-			release_vg(vg);
-			return 1;
-		}
+	return 1;
+}
 
-		log_error("Failed to read Volume Group \"%s\" (%s) during autoactivation.", vgname, vgid);
-		release_vg(vg);
-		return 0;
-	}
+/*
+ * pvscan --cache does not perform any lvmlockd locking, and
+ * pvscan --cache -aay skips autoactivation in lockd VGs.
+ *
+ * pvscan --cache populates lvmetad with VG metadata from disk.
+ * No lvmlockd locking is needed.  It is expected that lockd VG
+ * metadata that is read by pvscan and populated in lvmetad may
+ * be immediately stale due to changes to the VG from other hosts
+ * during or after this pvscan.  This is normal and not a problem.
+ * When a subsequent lvm command uses the VG, it will lock the VG
+ * with lvmlockd, read the VG from lvmetad, and update the cached
+ * copy from disk if necessary.
+ *
+ * pvscan --cache -aay does not activate LVs in lockd VGs because
+ * activation requires locking, and a lock-start operation is needed
+ * on a lockd VG before any locking can be performed in it.
+ *
+ * An equivalent of pvscan --cache -aay for lockd VGs is:
+ * 1. pvscan --cache
+ * 2. vgchange --lock-start
+ * 3. vgchange -aay -S 'locktype=sanlock || locktype=dlm'
+ *
+ * [We could eventually add support for autoactivating lockd VGs
+ * using pvscan by incorporating the lock start step (which can
+ * take a long time), but there may be a better option than
+ * continuing to overload pvscan.]
+ * 
+ * Stages of starting a lockd VG:
+ *
+ * . pvscan --cache populates lockd VGs in lvmetad without locks,
+ *   and this initial cached copy may quickly become stale.
+ *
+ * . vgchange --lock-start VG reads the VG without the VG lock
+ *   because no locks are available until the locking is started.
+ *   It only uses the VG name and lock_type from the VG metadata,
+ *   and then only uses it to start the VG lockspace in lvmlockd.
+ *
+ * . Further lvm commands, e.g. activation, can then lock the VG
+ *   with lvmlockd and use current VG metdata.
+ */
 
-	if (is_lockd_type(vg->lock_type)) {
-		r = 1;
-		goto out;
-	}
+#define REFRESH_BEFORE_AUTOACTIVATION_RETRIES 5
+#define REFRESH_BEFORE_AUTOACTIVATION_RETRY_USLEEP_DELAY 100000
 
-	if (vg_is_clustered(vg)) {
-		r = 1;
-		goto out;
-	}
+static int _pvscan_autoactivate_single(struct cmd_context *cmd, const char *vg_name,
+				       struct volume_group *vg, struct processing_handle *handle)
+{
+	struct pvscan_aa_params *pp = (struct pvscan_aa_params *)handle->custom_handle;
+	unsigned int refresh_retries = REFRESH_BEFORE_AUTOACTIVATION_RETRIES;
+	int refresh_done = 0;
 
-	/* FIXME: There's a tiny race when suspending the device which is part
+	if (vg_is_clustered(vg))
+		return ECMD_PROCESSED;
+
+	if (is_lockd_type(vg->lock_type))
+		return ECMD_PROCESSED;
+
+	log_debug("pvscan autoactivating VG %s.", vg_name);
+
+	/*
+	 * Refresh LVs in a VG that has "changed" from finding a PV.
+	 * The meaning of "changed" is determined in lvmetad, and is
+	 * returned to the command as a flag.
+	 *
+	 * FIXME: There's a tiny race when suspending the device which is part
 	 * of the refresh because when suspend ioctl is performed, the dm
 	 * kernel driver executes (do_suspend and dm_suspend kernel fn):
 	 *
@@ -202,9 +223,10 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	 *
 	 * Remove this workaround with "refresh_retries" once we have proper locking in!
 	 */
-	if (changed) {
+	if (pp->refresh_all || str_list_match_item(&pp->changed_vgnames, vg_name)) {
 		while (refresh_retries--) {
-			if (vg_refresh_visible(vg->cmd, vg)) {
+			log_debug_activation("Refreshing VG %s before autoactivation.", vg_name);
+			if (vg_refresh_visible(cmd, vg)) {
 				refresh_done = 1;
 				break;
 			}
@@ -215,8 +237,11 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 			log_warn("%s: refresh before autoactivation failed.", vg->name);
 	}
 
-	if (!vgchange_activate(vg->cmd, vg, activate)) {
+	log_debug_activation("Autoactivating VG %s.", vg_name);
+
+	if (!vgchange_activate(cmd, vg, CHANGE_AAY)) {
 		log_error("%s: autoactivation failed.", vg->name);
+		pp->activate_errors++;
 		goto out;
 	}
 
@@ -226,35 +251,53 @@ static int _auto_activation_handler(struct cmd_context *cmd,
 	 * be adding --poll y|n cmdline option for pvscan and call
 	 * init_background_polling routine in autoactivation handler.
 	 */
-	if (!(vgchange_background_polling(vg->cmd, vg)))
-		goto_out;
-
-	r = 1;
+	log_debug_activation("Starting background polling for VG %s.", vg_name);
 
+	if (!(vgchange_background_polling(cmd, vg)))
+		goto_out;
 out:
-	unlock_and_release_vg(cmd, vg, vgname);
-	return r;
+	return ECMD_PROCESSED;
 }
 
-static int _clear_dev_from_lvmetad_cache(dev_t devno, int32_t major, int32_t minor,
-					 activation_handler handler)
+static int _pvscan_autoactivate(struct cmd_context *cmd, struct pvscan_aa_params *pp,
+				int all_vgs, struct dm_list *vgnames)
 {
-	char buf[24];
+	struct processing_handle *handle = NULL;
+	int ret;
 
-	(void) dm_snprintf(buf, sizeof(buf), FMTi32 ":" FMTi32, major, minor);
+	if (!all_vgs && dm_list_empty(vgnames)) {
+		log_debug("No VGs to autoactivate.");
+		return ECMD_PROCESSED;
+	}
 
-	if (!lvmetad_pv_gone(devno, buf, handler))
-		return_0;
+	if (!lvmetad_used())
+		log_warn("WARNING: Autoactivation reading from disk instead of lvmetad.");
+
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
 
-	log_print_unless_silent("Device %s not found. "
-				"Cleared from lvmetad cache.", buf);
+	handle->custom_handle = pp;
 
-	return 1;
+	if (all_vgs) {
+		cmd->command->flags |= ALL_VGS_IS_DEFAULT;
+		pp->refresh_all = 1;
+	}
+
+	dev_cache_full_scan(cmd->full_filter);
+
+	ret = process_each_vg(cmd, 0, NULL, NULL, vgnames, 0, handle, _pvscan_autoactivate_single);
+
+	destroy_processing_handle(cmd, handle);
+
+	return ret;
 }
 
-static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
+static int _pvscan_cache(struct cmd_context *cmd, int argc, char **argv)
 {
-	int ret = ECMD_PROCESSED;
+	struct pvscan_aa_params pp = { 0 };
+	struct dm_list found_vgnames;
 	struct device *dev;
 	const char *pv_name;
 	const char *reason = NULL;
@@ -263,28 +306,26 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	int devno_args = 0;
 	struct arg_value_group_list *current_group;
 	dev_t devno;
-	activation_handler handler = NULL;
+	int do_activate = 0;
+	int all_vgs = 0;
+	int remove_errors = 0;
+	int add_errors = 0;
+	int ret = ECMD_PROCESSED;
+
+	dm_list_init(&found_vgnames);
+	dm_list_init(&pp.changed_vgnames);
 
-	/*
-	 * Return here immediately if lvmetad is not used.
-	 * Also return if locking_type=3 (clustered) as we
-	 * dont't support cluster + lvmetad yet.
-	 *
-	 * This is to avoid taking the global lock uselessly
-	 * and to prevent hangs in clustered environment.
-	 */
-	/* TODO: Remove this once lvmetad + cluster supported! */
 	if (!lvmetad_used()) {
 		log_verbose("Ignoring pvscan --cache command because lvmetad is not in use.");
 		return ret;
 	}
 
-	if (arg_count(cmd, activate_ARG)) {
+	if (arg_is_set(cmd, activate_ARG)) {
 		if (arg_uint_value(cmd, activate_ARG, CHANGE_AAY) != CHANGE_AAY) {
 			log_error("Only --activate ay allowed with pvscan.");
 			return 0;
 		}
-		handler = _auto_activation_handler;
+		do_activate = 1;
 	}
 
 	if (arg_count(cmd, major_ARG) + arg_count(cmd, minor_ARG))
@@ -300,96 +341,130 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
-	/* Scan everything? */
+	/*
+	 * Scan all devices when no args are given.
+	 */
 	if (!argc && !devno_args) {
-		if (!lvmetad_pvscan_all_devs(cmd, handler, 1)) {
-			log_error("Failed to update cache.");
-			ret = ECMD_FAILED;
+		log_verbose("Scanning all devices.");
+
+		if (!lvmetad_pvscan_all_devs(cmd, 1)) {
+			log_warn("WARNING: Not using lvmetad because cache update failed.");
+			lvmetad_make_unused(cmd);
 		}
-		goto out;
+		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
+			log_warn("WARNING: Not using lvmetad because %s.", reason);
+			lvmetad_make_unused(cmd);
+		}
+		all_vgs = 1;
+		goto activate;
+	}
+       
+	/*
+	 * FIXME: when specific devs are named, we generally don't want to scan
+	 * any other devs, but if lvmetad is not yet populated, the first
+	 * 'pvscan --cache dev' does need to do a full scan.  We want to remove
+	 * the need for this case so that 'pvscan --cache dev' is guaranteed to
+	 * never scan any devices other than those specified.
+	 */
+	if (!lvmetad_token_matches(cmd)) {
+		log_verbose("Scanning all devices to initialize lvmetad.");
+
+		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, 0)) {
+			log_warn("WARNING: Not using lvmetad because cache update failed.");
+			lvmetad_make_unused(cmd);
+		}
+		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
+			log_warn("WARNING: Not using lvmetad because %s.", reason);
+			lvmetad_make_unused(cmd);
+		}
+		all_vgs = 1;
+		goto activate;
 	}
 
 	/*
-	 * When lvmetad is disabled, all devices need to be rescanned,
-	 * i.e. the !argc case above, pvscan --cache.
+	 * When args are given, scan only those devices.  If lvmetad is already
+	 * disabled, a full scan is required to reenable it, so there's no
+	 * point in doing individual device scans, so go directly to
+	 * autoactivation.  (FIXME: Should we also skip autoactivation in this
+	 * case since that will read disks with lvmetad disabled?
+	 * i.e. avoid disk access and not activate LVs, or or read from disk
+	 * and activate LVs?)
 	 */
-	if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
+	if (lvmetad_is_disabled(cmd, &reason)) {
 		log_warn("WARNING: Not using lvmetad because %s.", reason);
-		log_warn("WARNING: Rescan all devices to update lvmetad cache (pvscan --cache).");
-		log_error("Failed to update cache.");
-		ret = ECMD_FAILED;
-		goto out;
+		lvmetad_make_unused(cmd);
+		all_vgs = 1;
+		goto activate;
 	}
 
 	/*
-	 * FIXME: when specific devs are named, we generally don't
-	 * want to scan any other devs, but if lvmetad is not yet
-	 * populated, the first 'pvscan --cache dev' does need to
-	 * do a full scan.  We want to remove the need for this
-	 * case so that 'pvscan --cache dev' is guaranteed to never
-	 * scan any devices other than those specified.
+	 * Step 1: for each device, if it's no longer found, then tell lvmetad
+	 * to drop it.  If the device exists, read metadata from it and send
+	 * that to lvmetad.
+	 *
+	 * When given a device name, check if the device is not visible to
+	 * lvmetad, but still visible to the system, and if so, tell lvmetad to
+	 * drop it (using the major:minor from the system).
+	 *
+	 * When given a major:minor which is not visible to the system, just
+	 * tell lvmetad to drop it directly using that major:minor.
+	 *
+	 * When a device has left the system, it must be dropped using
+	 * --major/--minor because we cannot map the device name to major:minor
+	 *  after the device has left.  (A full rescan could of course be used
+	 *  to drop any devices that have left.)
 	 */
-	if (lvmetad_used() && !lvmetad_token_matches(cmd)) {
-		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, 0)) {
-			log_error("Failed to update cache.");
-			ret = ECMD_FAILED;
-			goto out;
-		}
-	}
 
-	log_verbose("Using physical volume(s) on command line");
+	if (argc || devno_args)
+		log_verbose("Scanning devices on command line.");
 
-	/* Process any command line PVs first. */
 	while (argc--) {
 		pv_name = *argv++;
 		if (pv_name[0] == '/') {
-			/* device path */
 			if (!(dev = dev_cache_get(pv_name, cmd->lvmetad_filter))) {
+				/* Remove device path from lvmetad. */
+				log_debug("Removing dev %s from lvmetad cache.", pv_name);
 				if ((dev = dev_cache_get(pv_name, NULL))) {
-					if (!_clear_dev_from_lvmetad_cache(dev->dev, MAJOR(dev->dev), MINOR(dev->dev), handler)) {
-						stack;
-						ret = ECMD_FAILED;
-						break;
-					}
+					if (!_lvmetad_clear_dev(dev->dev, MAJOR(dev->dev), MINOR(dev->dev)))
+						remove_errors++;
 				} else {
 					log_error("Physical Volume %s not found.", pv_name);
 					ret = ECMD_FAILED;
-					break;
 				}
-				continue;
+			} else {
+				/* Add device path to lvmetad. */
+				log_debug("Scanning dev %s for lvmetad cache.", pv_name);
+				if (!lvmetad_pvscan_single(cmd, dev, &found_vgnames, &pp.changed_vgnames))
+					add_errors++;
 			}
-		}
-		else {
-			/* device major:minor */
+		} else {
 			if (sscanf(pv_name, "%d:%d", &major, &minor) != 2) {
-				log_error("Failed to parse major:minor from %s", pv_name);
-				ret = ECMD_FAILED;
+				log_warn("WARNING: Failed to parse major:minor from %s, skipping.", pv_name);
 				continue;
 			}
 			devno = MKDEV((dev_t)major, (dev_t)minor);
+
 			if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
-				if (!(_clear_dev_from_lvmetad_cache(devno, major, minor, handler))) {
-					stack;
-					ret = ECMD_FAILED;
-					break;
-				}
-				continue;
+				/* Remove major:minor from lvmetad. */
+				log_debug("Removing dev %d:%d from lvmetad cache.", major, minor);
+				if (!_lvmetad_clear_dev(devno, major, minor))
+					remove_errors++;
+			} else {
+				/* Add major:minor to lvmetad. */
+				log_debug("Scanning dev %d:%d for lvmetad cache.", major, minor);
+				if (!lvmetad_pvscan_single(cmd, dev, &found_vgnames, &pp.changed_vgnames))
+					add_errors++;
 			}
 		}
+
 		if (sigint_caught()) {
 			ret = ECMD_FAILED;
-			stack;
-			break;
-		}
-		if (!lvmetad_pvscan_single(cmd, dev, handler, 0)) {
-			ret = ECMD_FAILED;
-			stack;
-			break;
+			goto_out;
 		}
 	}
 
 	if (!devno_args)
-		goto out;
+		goto activate;
 
 	/* Process any grouped --major --minor args */
 	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
@@ -402,27 +477,47 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 		devno = MKDEV((dev_t)major, (dev_t)minor);
 
 		if (!(dev = dev_cache_get_by_devt(devno, cmd->lvmetad_filter))) {
-			if (!(_clear_dev_from_lvmetad_cache(devno, major, minor, handler))) {
-				stack;
-				ret = ECMD_FAILED;
-				break;
-			}
-			continue;
+			/* Remove major:minor from lvmetad. */
+			log_debug("Removing dev %d:%d from lvmetad cache.", major, minor);
+			if (!_lvmetad_clear_dev(devno, major, minor))
+				remove_errors++;
+		} else {
+			/* Add major:minor to lvmetad. */
+			log_debug("Scanning dev %d:%d for lvmetad cache.", major, minor);
+			if (!lvmetad_pvscan_single(cmd, dev, &found_vgnames, &pp.changed_vgnames))
+				add_errors++;
 		}
+
 		if (sigint_caught()) {
 			ret = ECMD_FAILED;
-			stack;
-			break;
-		}
-		if (!lvmetad_pvscan_single(cmd, dev, handler, 0)) {
-			ret = ECMD_FAILED;
-			stack;
-			break;
+			goto_out;
 		}
+	}
 
+	/*
+	 * In the process of scanning devices, lvmetad may have become
+	 * disabled.  If so, revert to scanning for the autoactivation step.
+	 * Only autoactivate the VGs that were found during the dev scans.
+	 */
+	if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
+		log_warn("WARNING: Not using lvmetad because %s.", reason);
+		lvmetad_make_unused(cmd);
 	}
 
+activate:
+	/*
+	 * Step 2: when the PV was sent to lvmetad, the lvmetad reply
+	 * indicated if all the PVs for the VG are now found.  If so,
+	 * the vgname was added to the list, and we can attempt to
+	 * autoactivate LVs in the VG.
+	 */
+	if (do_activate)
+		ret = _pvscan_autoactivate(cmd, &pp, all_vgs, &found_vgnames);
+
 out:
+	if (remove_errors || add_errors || pp.activate_errors)
+		ret = ECMD_FAILED;
+
 	if (!sync_local_dev_names(cmd))
 		stack;
 	unlock_vg(cmd, VG_GLOBAL);
@@ -477,7 +572,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 	int ret;
 
 	if (arg_count(cmd, cache_long_ARG))
-		return _pvscan_lvmetad(cmd, argc, argv);
+		return _pvscan_cache(cmd, argc, argv);
 
 	if (argc) {
 		log_error("Too many parameters on command line.");
@@ -506,7 +601,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 
 	/* Needed because this command has NO_LVMETAD_AUTOSCAN. */
 	if (lvmetad_used() && (!lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
-		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, 0)) {
+		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, 0)) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
 			lvmetad_make_unused(cmd);
 		}
@@ -526,7 +621,6 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 	if (!lockd_gl(cmd, "sh", 0))
 		return_ECMD_FAILED;
 
-
 	if (!(handle = init_processing_handle(cmd))) {
 		log_error("Failed to initialize processing handle.");
 		ret = ECMD_FAILED;
diff --git a/tools/toollib.c b/tools/toollib.c
index e879850..5383734 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4624,7 +4624,7 @@ do_command:
 		if (info)
 			lvmcache_del(info);
 
-		if (!lvmetad_pv_gone_by_dev(pd->dev, NULL)) {
+		if (!lvmetad_pv_gone_by_dev(pd->dev)) {
 			log_error("Failed to remove PV %s from lvmetad.", pd->name);
 			dm_list_move(&pp->arg_fail, &pd->list);
 			continue;
@@ -4644,7 +4644,7 @@ do_command:
 			continue;
 		}
 
-		if (!lvmetad_pv_gone_by_dev(pd->dev, NULL)) {
+		if (!lvmetad_pv_gone_by_dev(pd->dev)) {
 			log_error("Failed to remove PV %s from lvmetad.", pd->name);
 			dm_list_move(&pp->arg_fail, &pd->list);
 			continue;
diff --git a/tools/vgimport.c b/tools/vgimport.c
index c499f8b..1f2e14d 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -96,7 +96,7 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 	 * import it.
 	 */
 	if (lvmetad_used()) {
-		if (!lvmetad_pvscan_all_devs(cmd, NULL, 1)) {
+		if (!lvmetad_pvscan_all_devs(cmd, 1)) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
 			lvmetad_make_unused(cmd);
 		}
diff --git a/tools/vgscan.c b/tools/vgscan.c
index 67797f5..688e361 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -101,7 +101,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 		log_verbose("Ignoring vgscan --cache command because lvmetad is not in use.");
 
 	if (lvmetad_used() && (arg_is_set(cmd, cache_long_ARG) || !lvmetad_token_matches(cmd) || lvmetad_is_disabled(cmd, &reason))) {
-		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, NULL, arg_is_set(cmd, cache_long_ARG))) {
+		if (lvmetad_used() && !lvmetad_pvscan_all_devs(cmd, arg_is_set(cmd, cache_long_ARG))) {
 			log_warn("WARNING: Not using lvmetad because cache update failed.");
 			lvmetad_make_unused(cmd);
 		}


