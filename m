From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 23 Jun 2015 21:39:16 +0000 (UTC)
Subject: master - Reread global state the lvmetad copy is stale
Message-ID: <20150623213916.8919360E71@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c23e7ff2a02c65619d05eb525adaaf9336de2692
Commit:        c23e7ff2a02c65619d05eb525adaaf9336de2692
Parent:        679b6b5b29b2257672087f387ef04bc4c8a4cca7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 7 12:51:42 2014 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 23 16:36:40 2015 -0500

Reread global state the lvmetad copy is stale

This is the client side handling of the global_invalid state
added to lvmetad in commit c595b50cec8a6b95c6ac4988912d1412f3cc0237.

The function added here:
. checks if the global state in lvmetad is invalid
. if so, scans disks to update the state in lvmetad
. clears the global_invalid flag in lvmetad
. updates the local udev db to reflect any changes
---
 lib/cache/lvmetad.c |  296 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/cache/lvmetad.h |    2 +
 2 files changed, 298 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 3c07cd1..01c3f08 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1283,3 +1283,299 @@ int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg)
 
 	return result;
 }
+
+/*
+ * Records the state of cached PVs in lvmetad so we can look for changes
+ * after rescanning.
+ */
+struct pv_cache_list {
+	struct dm_list list;
+	dev_t devt;
+	struct id pvid;
+	const char *vgid;
+	unsigned found : 1;
+	unsigned update_udev : 1;
+};
+
+/*
+ * Get the list of PVs known to lvmetad.
+ */
+static int _lvmetad_get_pv_cache_list(struct cmd_context *cmd, struct dm_list *pvc_list)
+{
+	daemon_reply reply;
+	struct dm_config_node *cn;
+	struct pv_cache_list *pvcl;
+	const char *pvid_txt;
+	const char *vgid;
+
+	if (!lvmetad_active())
+		return 1;
+
+	log_debug_lvmetad("Asking lvmetad for complete list of known PVs");
+	reply = _lvmetad_send("pv_list", NULL);
+	if (!_lvmetad_handle_reply(reply, "list PVs", "", NULL)) {
+		log_error("lvmetad message failed.");
+		daemon_reply_destroy(reply);
+		return_0;
+	}
+
+	if ((cn = dm_config_find_node(reply.cft->root, "physical_volumes"))) {
+		for (cn = cn->child; cn; cn = cn->sib) {
+			if (!(pvcl = dm_pool_zalloc(cmd->mem, sizeof(*pvcl)))) {
+				log_error("pv_cache_list allocation failed.");
+				return 0;
+			}
+
+			pvid_txt = cn->key;
+			if (!id_read_format(&pvcl->pvid, pvid_txt)) {
+				stack;
+				continue;
+			}
+
+			pvcl->devt = dm_config_find_int(cn->child, "device", 0);
+
+			if ((vgid = dm_config_find_str(cn->child, "vgid", NULL)))
+				pvcl->vgid = dm_pool_strdup(cmd->mem, vgid);
+
+			dm_list_add(pvc_list, &pvcl->list);
+		}
+	}
+
+	daemon_reply_destroy(reply);
+
+	return 1;
+}
+
+/*
+ * Opening the device RDWR should trigger a udev db update.
+ * FIXME: is there a better way to update the udev db than
+ * doing an open/close of the device?
+ */
+static void _update_pv_in_udev(struct cmd_context *cmd, dev_t devt)
+{
+	struct device *dev;
+
+	log_debug_devs("device %d:%d open to update udev",
+		       (int)MAJOR(devt), (int)MINOR(devt));
+
+	if (!(dev = dev_cache_get_by_devt(devt, cmd->lvmetad_filter))) {
+		log_error("_update_pv_in_udev no dev found");
+		return;
+	}
+
+	if (!dev_open(dev))
+		return;
+	dev_close(dev);
+}
+
+/*
+ * Compare before and after PV lists from before/after rescanning,
+ * and update udev db for changes.
+ *
+ * For PVs that have changed pvid or vgid in lvmetad from rescanning,
+ * there may be information in the udev database to update, so open
+ * these devices to trigger a udev update.
+ *
+ * "before" refers to the list of pvs from lvmetad before rescanning
+ * "after" refers to the list of pvs from lvmetad after rescanning
+ *
+ * Comparing both lists, we can see which PVs changed (pvid or vgid),
+ * and trigger a udev db update for those.
+ */
+static void _update_changed_pvs_in_udev(struct cmd_context *cmd,
+					struct dm_list *pvc_before,
+					struct dm_list *pvc_after)
+{
+	struct pv_cache_list *before;
+	struct pv_cache_list *after;
+	char id_before[ID_LEN + 1]  __attribute__((aligned(8)));
+	char id_after[ID_LEN + 1]  __attribute__((aligned(8)));
+	int found;
+
+	dm_list_iterate_items(before, pvc_before) {
+		found = 0;
+
+		dm_list_iterate_items(after, pvc_after) {
+			if (after->found)
+				continue;
+
+			if (before->devt != after->devt)
+				continue;
+
+			if (!id_equal(&before->pvid, &after->pvid)) {
+				memset(id_before, 0, sizeof(id_before));
+				memset(id_after, 0, sizeof(id_after));
+				strncpy(&id_before[0], (char *) &before->pvid, sizeof(id_before) - 1);
+				strncpy(&id_after[0], (char *) &after->pvid, sizeof(id_after) - 1);
+
+				log_debug_devs("device %d:%d changed pvid from %s to %s",
+					       (int)MAJOR(before->devt), (int)MINOR(before->devt),
+					       id_before, id_after);
+
+				before->update_udev = 1;
+
+			} else if ((before->vgid && !after->vgid) ||
+				   (after->vgid && !before->vgid) ||
+				   (before->vgid && after->vgid && strcmp(before->vgid, after->vgid))) {
+
+				log_debug_devs("device %d:%d changed vg from %s to %s",
+					       (int)MAJOR(before->devt), (int)MINOR(before->devt),
+					       before->vgid ?: "none", after->vgid ?: "none");
+
+				before->update_udev = 1;
+			}
+
+			after->found = 1;
+			before->found = 1;
+			found = 1;
+			break;
+		}
+
+		if (!found) {
+			memset(id_before, 0, sizeof(id_before));
+			strncpy(&id_before[0], (char *) &before->pvid, sizeof(id_before) - 1);
+
+			log_debug_devs("device %d:%d pvid %s vg %s is gone",
+				       (int)MAJOR(before->devt), (int)MINOR(before->devt),
+				       id_before, before->vgid ? before->vgid : "none");
+
+			before->update_udev = 1;
+		}
+	}
+
+	dm_list_iterate_items(before, pvc_before) {
+		if (before->update_udev)
+			_update_pv_in_udev(cmd, before->devt);
+	}
+
+	dm_list_iterate_items(after, pvc_after) {
+		if (after->update_udev)
+			_update_pv_in_udev(cmd, after->devt);
+	}
+}
+
+/*
+ * Before this command was run, some external entity may have
+ * invalidated lvmetad's cache of global information, e.g. lvmlockd.
+ *
+ * The global information includes things like a new VG, a
+ * VG that was removed, the assignment of a PV to a VG;
+ * any change that is not isolated within a single VG.
+ *
+ * The external entity, like a lock manager, would invalidate
+ * the lvmetad global cache if it detected that the global
+ * information had been changed on disk by something other
+ * than a local lvm command, e.g. an lvm command on another
+ * host with access to the same devices.  (How it detects
+ * the change is specific to lock manager or other entity.)
+ *
+ * The effect is that metadata on disk is newer than the metadata
+ * in the local lvmetad daemon, and the local lvmetad's cache
+ * should be updated from disk before this command uses it.
+ *
+ * So, using this function, a command checks if lvmetad's global
+ * cache is valid.  If so, it does nothing.  If not, it rescans
+ * devices to update the lvmetad cache, then it notifies lvmetad
+ * that it's cache is valid again (consistent with what's on disk.)
+ * This command can then go ahead and use the newly refreshed metadata.
+ *
+ * 1. Check if the lvmetad global cache is invalid.
+ * 2. If so, reread metadata from all devices and update the lvmetad cache.
+ * 3. Tell lvmetad that the global cache is now valid.
+ */
+
+void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
+{
+	struct dm_list pvc_before; /* pv_cache_list */
+	struct dm_list pvc_after; /* pv_cache_list */
+	daemon_reply reply;
+	int global_invalid;
+
+	dm_list_init(&pvc_before);
+	dm_list_init(&pvc_after);
+
+	if (!lvmetad_used())
+		return;
+
+	if (force)
+		goto do_scan;
+
+	reply = daemon_send_simple(_lvmetad, "get_global_info",
+				   "token = %s", "skip",
+				   NULL);
+
+	if (reply.error) {
+		log_error("lvmetad_validate_global_cache get_global_info error %d", reply.error);
+		goto do_scan;
+	}
+
+	if (strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
+		log_error("lvmetad_validate_global_cache get_global_info not ok");
+		goto do_scan;
+	}
+
+	global_invalid = daemon_reply_int(reply, "global_invalid", -1);
+
+	daemon_reply_destroy(reply);
+
+	if (!global_invalid) {
+		/* cache is valid */
+		return;
+	}
+
+ do_scan:
+	/*
+	 * Save the current state of pvs from lvmetad so after devices are
+	 * scanned, we can compare to the new state to see if pvs changed.
+	 */
+	_lvmetad_get_pv_cache_list(cmd, &pvc_before);
+
+	/*
+	 * Update the local lvmetad cache so it correctly reflects any
+	 * changes made on remote hosts.
+	 */
+	lvmetad_pvscan_all_devs(cmd, NULL);
+
+	/*
+	 * Clear the global_invalid flag in lvmetad.
+	 * Subsequent local commands that read global state
+	 * from lvmetad will not see global_invalid until
+	 * another host makes another global change.
+	 */
+	reply = daemon_send_simple(_lvmetad, "set_global_info",
+				   "token = %s", "skip",
+				   "global_invalid = %d", 0,
+				   NULL);
+	if (reply.error)
+		log_error("lvmetad_validate_global_cache set_global_info error %d", reply.error);
+
+	if (strcmp(daemon_reply_str(reply, "response", ""), "OK"))
+		log_error("lvmetad_validate_global_cache set_global_info not ok");
+
+	daemon_reply_destroy(reply);
+
+	/*
+	 * Populate this command's lvmcache structures from lvmetad.
+	 */
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
+	/*
+	 * Update the local udev database to reflect PV changes from
+	 * other hosts.
+	 *
+	 * Compare the before and after PV lists, and if a PV's
+	 * pvid or vgid has changed, then open that device to trigger
+	 * a uevent to update the udev db.
+	 *
+	 * This has no direct benefit to lvm, but is just a best effort
+	 * attempt to keep the udev db updated and reflecting current
+	 * lvm information.
+	 *
+	 * FIXME: lvmcache_seed_infos_from_lvmetad() and _lvmetad_get_pv_cache_list()
+	 * each get pv_list from lvmetad, and they could share a single pv_list reply.
+	 */
+	if (!dm_list_empty(&pvc_before)) {
+		_lvmetad_get_pv_cache_list(cmd, &pvc_after);
+		_update_changed_pvs_in_udev(cmd, &pvc_before, &pvc_after);
+	}
+}
diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 8224675..af0d562 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -167,6 +167,7 @@ int lvmetad_pvscan_all_devs(struct cmd_context *cmd, activation_handler handler)
 int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handler);
 
 int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg);
+void lvmetad_validate_global_cache(struct cmd_context *cmd, int force);
 
 #  else		/* LVMETAD_SUPPORT */
 
@@ -195,6 +196,7 @@ int lvmetad_vg_clear_outdated_pvs(struct volume_group *vg);
 #    define lvmetad_pvscan_all_devs(cmd, handler)	(0)
 #    define lvmetad_pvscan_foreign_vgs(cmd, handler)	(0)
 #    define lvmetad_vg_clear_outdated_pvs(vg)           (1)
+#    define lvmetad_validate_global_cache(cmd, force)	do { } while (0)
 
 #  endif	/* LVMETAD_SUPPORT */
 


