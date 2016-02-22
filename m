From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 22 Feb 2016 13:28:30 +0000 (UTC)
Subject: master - cleanup: indent changes
Message-ID: <20160222132830.0C9DF60F3F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d6ef123a673d0982e9d3900ab4953ce146e4fc6
Commit:        2d6ef123a673d0982e9d3900ab4953ce146e4fc6
Parent:        fba54ae55e888d290f8783d813bbecf3f1cfdd61
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 22 10:44:46 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 22 14:26:15 2016 +0100

cleanup: indent changes

Some code indention.
Use dm_strncpy() for simplier code.

TODO: we could possibly use   %32s  for printing pvid...
so maybe adding extra  FMT_PVID....
---
 lib/cache/lvmetad.c |   50 +++++++++++++++++++++++++++++++-------------------
 1 files changed, 31 insertions(+), 19 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index dbb3739..b68e6c9 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -105,6 +105,7 @@ void lvmetad_disconnect(void)
 {
 	if (_lvmetad_connected)
 		daemon_close(_lvmetad);
+
 	_lvmetad_connected = 0;
 }
 
@@ -165,14 +166,17 @@ int lvmetad_socket_present(void)
 int lvmetad_active(void)
 {
 	lvmetad_connect_or_warn();
+
 	return _lvmetad_connected;
 }
 
 void lvmetad_set_active(struct cmd_context *cmd, int active)
 {
 	_lvmetad_use = active;
+
 	if (!active && lvmetad_active())
 		lvmetad_disconnect();
+
 	if (cmd && !refresh_filters(cmd))
 		stack;
 }
@@ -282,6 +286,7 @@ static int _token_update(void)
 	}
 
 	daemon_reply_destroy(repl);
+
 	return 1;
 }
 
@@ -490,6 +495,7 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 static int _pv_update_struct_pv(struct physical_volume *pv, struct format_instance *fid)
 {
 	struct lvmcache_info *info;
+
 	if ((info = lvmcache_info_from_pvid((const char *)&pv->id, 0))) {
 		pv->label_sector = lvmcache_get_label(info)->sector;
 		pv->dev = lvmcache_device(info);
@@ -497,9 +503,10 @@ static int _pv_update_struct_pv(struct physical_volume *pv, struct format_instan
 			pv->status |= MISSING_PV;
 		if (!lvmcache_fid_add_mdas_pv(info, fid))
 			return_0;
-                pv->fid = fid;
+		pv->fid = fid;
 	} else
 		pv->status |= MISSING_PV; /* probably missing */
+
 	return 1;
 }
 
@@ -680,9 +687,12 @@ struct _fixup_baton {
 
 static int _fixup_ignored(struct metadata_area *mda, void *baton) {
 	struct _fixup_baton *b = baton;
+
 	if (b->i == b->find)
 		mda_set_ignored(mda, b->ignore);
+
 	b->i ++;
+
 	return 1;
 }
 
@@ -829,6 +839,7 @@ out_success:
 
 out:
 	daemon_reply_destroy(reply);
+
 	return result;
 }
 
@@ -903,6 +914,7 @@ int lvmetad_get_vgnameids(struct cmd_context *cmd, struct dm_list *vgnameids)
 	}
 
 	daemon_reply_destroy(reply);
+
 	return 1;
 }
 
@@ -938,6 +950,7 @@ int lvmetad_vg_list_to_lvmcache(struct cmd_context *cmd)
 		}
 
 	daemon_reply_destroy(reply);
+
 	return 1;
 }
 
@@ -1005,13 +1018,15 @@ static int _extract_ba(struct disk_locn *ba, void *baton)
 static int _extract_mdas(struct lvmcache_info *info, struct dm_config_tree *cft,
 			 struct dm_config_node *pre_sib)
 {
-	struct _extract_dl_baton baton = { .i = 0, .cft = cft, .pre_sib = NULL };
+	struct _extract_dl_baton baton = { .cft = cft };
 
 	if (!lvmcache_foreach_mda(info, &_extract_mda, &baton))
 		return 0;
+
 	baton.i = 0;
 	if (!lvmcache_foreach_da(info, &_extract_da, &baton))
 		return 0;
+
 	baton.i = 0;
 	if (!lvmcache_foreach_ba(info, &_extract_ba, &baton))
 		return 0;
@@ -1172,11 +1187,11 @@ int lvmetad_pv_gone(dev_t devno, const char *pv_name, activation_handler handler
 		return 1;
 
 	/*
-         *  TODO: automatic volume deactivation takes place here *before*
-         *        all cached info is gone - call handler. Also, consider
-         *        integrating existing deactivation script  that deactivates
-         *        the whole stack from top to bottom (not yet upstream).
-         */
+	 *  TODO: automatic volume deactivation takes place here *before*
+	 *        all cached info is gone - call handler. Also, consider
+	 *        integrating existing deactivation script  that deactivates
+	 *        the whole stack from top to bottom (not yet upstream).
+	 */
 
 	log_debug_lvmetad("Telling lvmetad to forget any PV on %s", pv_name);
 	reply = _lvmetad_send("pv_gone", "device = %" PRId64, (int64_t) devno, NULL);
@@ -1415,8 +1430,9 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 
 bad:
 	/* FIXME kill lvmetad automatically if we can */
-	log_error("Update of lvmetad failed. This is a serious problem.\n  "
+	log_error("Update of lvmetad failed. This is a serious problem.\n"
 		  "It is strongly recommended that you restart lvmetad immediately.");
+
 	return 0;
 }
 
@@ -1536,6 +1552,7 @@ static int _lvmetad_get_pv_cache_list(struct cmd_context *cmd, struct dm_list *p
 		return 1;
 
 	log_debug_lvmetad("Asking lvmetad for complete list of known PVs");
+
 	reply = _lvmetad_send("pv_list", NULL);
 	if (!_lvmetad_handle_reply(reply, "list PVs", "", NULL)) {
 		log_error("lvmetad message failed.");
@@ -1632,10 +1649,8 @@ static void _update_changed_pvs_in_udev(struct cmd_context *cmd,
 				continue;
 
 			if (!id_equal(&before->pvid, &after->pvid)) {
-				memset(id_before, 0, sizeof(id_before));
-				memset(id_after, 0, sizeof(id_after));
-				strncpy(&id_before[0], (char *) &before->pvid, sizeof(id_before) - 1);
-				strncpy(&id_after[0], (char *) &after->pvid, sizeof(id_after) - 1);
+				dm_strncpy(id_before, (char *) &before->pvid, sizeof(id_before));
+				dm_strncpy(id_after, (char *) &after->pvid, sizeof(id_after));
 
 				log_debug_devs("device %d:%d changed pvid from %s to %s",
 					       (int)MAJOR(before->devt), (int)MINOR(before->devt),
@@ -1661,8 +1676,7 @@ static void _update_changed_pvs_in_udev(struct cmd_context *cmd,
 		}
 
 		if (!found) {
-			memset(id_before, 0, sizeof(id_before));
-			strncpy(&id_before[0], (char *) &before->pvid, sizeof(id_before) - 1);
+			dm_strncpy(id_before, (char *) &before->pvid, sizeof(id_before));
 
 			log_debug_devs("device %d:%d pvid %s vg %s is gone",
 				       (int)MAJOR(before->devt), (int)MINOR(before->devt),
@@ -1754,10 +1768,8 @@ void lvmetad_validate_global_cache(struct cmd_context *cmd, int force)
 
 	daemon_reply_destroy(reply);
 
-	if (!global_invalid) {
-		/* cache is valid */
-		return;
-	}
+	if (!global_invalid)
+		return; /* cache is valid */
 
  do_scan:
 	/*
@@ -1839,6 +1851,6 @@ int lvmetad_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const cha
 	ret = !is_system_id_allowed(cmd, system_id);
 
 	daemon_reply_destroy(reply);
+
 	return ret;
 }
-


