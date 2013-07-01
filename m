From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  1 Jul 2013 21:13:34 +0000 (UTC)
Subject: master - cleanup: stack usage
Message-ID: <20130701211334.234ED60DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47419d21acec64a4d23968f6991a1d976673859f
Commit:        47419d21acec64a4d23968f6991a1d976673859f
Parent:        b90450b8a082b349297eac23f50cf4ac2e0ed8f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 1 11:27:11 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 1 23:11:14 2013 +0200

cleanup: stack usage

Shortening code with macros return_0, return_NULL.
Add some missing stack prints in error paths.
---
 daemons/dmeventd/libdevmapper-event.c |   12 ++++--------
 lib/locking/cluster_locking.c         |    3 +--
 libdm/libdm-deptree.c                 |   12 ++++--------
 libdm/regex/parse_rx.c                |   12 ++++--------
 libdm/regex/ttree.c                   |   12 ++++--------
 tools/lvconvert.c                     |   22 ++++++++--------------
 tools/lvmcmdline.c                    |    4 ++--
 tools/lvrename.c                      |   20 ++++++++------------
 tools/reporter.c                      |    2 +-
 tools/vgcfgbackup.c                   |    2 +-
 tools/vgchange.c                      |    6 ++----
 tools/vgsplit.c                       |    3 +--
 12 files changed, 40 insertions(+), 70 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index c692a88..72f0f92 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -614,10 +614,8 @@ int dm_event_register_handler(const struct dm_event_handler *dmevh)
 	struct dm_task *dmt;
 	struct dm_event_daemon_message msg = { 0, 0, NULL };
 
-	if (!(dmt = _get_device_info(dmevh))) {
-		stack;
-		return 0;
-	}
+	if (!(dmt = _get_device_info(dmevh)))
+		return_0;
 
 	uuid = dm_task_get_uuid(dmt);
 
@@ -643,10 +641,8 @@ int dm_event_unregister_handler(const struct dm_event_handler *dmevh)
 	struct dm_task *dmt;
 	struct dm_event_daemon_message msg = { 0, 0, NULL };
 
-	if (!(dmt = _get_device_info(dmevh))) {
-		stack;
-		return 0;
-	}
+	if (!(dmt = _get_device_info(dmevh)))
+		return_0;
 
 	uuid = dm_task_get_uuid(dmt);
 
diff --git a/lib/locking/cluster_locking.c b/lib/locking/cluster_locking.c
index 1350d18..89d7307 100644
--- a/lib/locking/cluster_locking.c
+++ b/lib/locking/cluster_locking.c
@@ -516,8 +516,7 @@ static int decode_lock_type(const char *response)
 	else if (!strcmp(response, "PR"))
 		return LCK_PREAD;
 
-	stack;
-	return 0;
+	return_0;
 }
 
 #ifdef CLUSTER_LOCKING_INTERNAL
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index ba415b2..fae9445 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -672,10 +672,8 @@ static int _children_suspended(struct dm_tree_node *node,
 		if (dlink->node->presuspend_node == node)
 			continue;
 
-		if (!(dinfo = dm_tree_node_get_info(dlink->node))) {
-			stack;	/* FIXME Is this normal? */
-			return 0;
-		}
+		if (!(dinfo = dm_tree_node_get_info(dlink->node)))
+			return_0;	/* FIXME Is this normal? */
 
 		if (!dinfo->suspended)
 			return 0;
@@ -920,10 +918,8 @@ static int _node_has_closed_parents(struct dm_tree_node *node,
 		if (!_uuid_prefix_matches(uuid, uuid_prefix, uuid_prefix_len))
 			continue;
 
-		if (!(dinfo = dm_tree_node_get_info(dlink->node))) {
-			stack;	/* FIXME Is this normal? */
-			return 0;
-		}
+		if (!(dinfo = dm_tree_node_get_info(dlink->node)))
+			return_0;	/* FIXME Is this normal? */
 
 		/* Refresh open_count */
 		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info, NULL, NULL, NULL) ||
diff --git a/libdm/regex/parse_rx.c b/libdm/regex/parse_rx.c
index ea3922f..0ad033a 100644
--- a/libdm/regex/parse_rx.c
+++ b/libdm/regex/parse_rx.c
@@ -303,10 +303,8 @@ static struct rx_node *_term(struct parse_sp *ps)
 
 	switch (ps->type) {
 	case 0:
-		if (!(n = _node(ps->mem, CHARSET, NULL, NULL))) {
-			stack;
-			return NULL;
-		}
+		if (!(n = _node(ps->mem, CHARSET, NULL, NULL)))
+			return_NULL;
 
 		dm_bit_copy(n->charset, ps->charset);
 		_rx_get_token(ps);	/* match charset */
@@ -354,10 +352,8 @@ static struct rx_node *_closure_term(struct parse_sp *ps)
 			return l;
 		}
 
-		if (!n) {
-			stack;
-			return NULL;
-		}
+		if (!n)
+			return_NULL;
 
 		_rx_get_token(ps);
 		l = n;
diff --git a/libdm/regex/ttree.c b/libdm/regex/ttree.c
index 00b371e..9c3cc65 100644
--- a/libdm/regex/ttree.c
+++ b/libdm/regex/ttree.c
@@ -87,10 +87,8 @@ int ttree_insert(struct ttree *tt, unsigned int *key, void *data)
 		count++;
 
 		while (count--) {
-			if (!(*c = _tree_node(tt->mem, k))) {
-				stack;
-				return 0;
-			}
+			if (!(*c = _tree_node(tt->mem, k)))
+				return_0;
 
 			if (count) {
 				k = *key++;
@@ -107,10 +105,8 @@ struct ttree *ttree_create(struct dm_pool *mem, unsigned int klen)
 {
 	struct ttree *tt;
 
-	if (!(tt = dm_pool_zalloc(mem, sizeof(*tt)))) {
-		stack;
-		return NULL;
-	}
+	if (!(tt = dm_pool_zalloc(mem, sizeof(*tt))))
+		return_NULL;
 
 	tt->klen = klen;
 	tt->mem = mem;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ac84aa6..650b1be 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -485,10 +485,8 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 		}
 
 		/* Default is never striped, regardless of existing LV configuration. */
-		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size)) {
-			stack;
-			return 0;
-		}
+		if (!get_stripe_params(cmd, &lp->stripes, &lp->stripe_size))
+			return_0;
 
 		lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, find_config_tree_str(cmd, global_mirror_segtype_default_CFG)));
 		if (!lp->segtype)
@@ -1283,10 +1281,8 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 		 * linear-to-mirror conversion.
 		 */
 		if (!_lv_update_log_type(cmd, lp, lv,
-					 operable_pvs, new_log_count)) {
-			stack;
-			return 0;
-		}
+					 operable_pvs, new_log_count))
+			return_0;
 
 		/* Insert a temporary layer for syncing,
 		 * only if the original lv is using disk log. */
@@ -1314,8 +1310,8 @@ static int _lvconvert_mirrors_aux(struct cmd_context *cmd,
 					  "and dmsetup may be required.");
 				return 0;
 			}
-			stack;
-			return 0;
+
+			return_0;
 		}
 		if (seg->log_lv)
 			lv->status |= CONVERTING;
@@ -1356,10 +1352,8 @@ out:
 	 */
 	if ((lv->status & MIRRORED) && (old_log_count != new_log_count)) {
 		if (!_lv_update_log_type(cmd, lp, lv,
-					 operable_pvs, new_log_count)) {
-			stack;
-			return 0;
-		}
+					 operable_pvs, new_log_count))
+			return_0;
 	}
 
 out_skip_log_convert:
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9c50918..827b072 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1123,7 +1123,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!init_locking(locking_type, cmd, arg_count(cmd, sysinit_ARG))) {
 		ret = ECMD_FAILED;
-		goto out;
+		goto_out;
 	}
 
 	ret = cmd->command->fn(cmd, argc, argv);
@@ -1539,7 +1539,7 @@ int lvm2_main(int argc, char **argv)
 		}
 		_exec_lvm1_command(argv);
 		ret = ECMD_FAILED;
-		goto out;
+		goto_out;
 	}
 #ifdef READLINE_SUPPORT
 	if (!alias && argc == 1) {
diff --git a/tools/lvrename.c b/tools/lvrename.c
index a2182e8..5b1f50b 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -16,7 +16,6 @@
 #include "tools.h"
 #include "lvm-types.h"
 
-
 /*
  * lvrename command implementation.
  * Check arguments and call lv_rename() to execute the request.
@@ -27,10 +26,9 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	char *lv_name_old, *lv_name_new;
 	const char *vg_name, *vg_name_new, *vg_name_old;
 	char *st;
-	int r = ECMD_FAILED;
-
-	struct volume_group *vg = NULL;
+	struct volume_group *vg;
 	struct lv_list *lvl;
+	int r = ECMD_FAILED;
 
 	if (argc == 3) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
@@ -90,7 +88,7 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 
 	if (!validate_name(lv_name_new)) {
 		log_error("New logical volume name \"%s\" is invalid",
-		     lv_name_new);
+			  lv_name_new);
 		return EINVALID_CMD_LINE;
 	}
 
@@ -109,32 +107,30 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	if (!(lvl = find_lv_in_vg(vg, lv_name_old))) {
 		log_error("Existing logical volume \"%s\" not found in "
 			  "volume group \"%s\"", lv_name_old, vg_name);
-		goto error;
+		goto bad;
 	}
 
 	if (lvl->lv->status & (RAID_IMAGE | RAID_META)) {
 		log_error("Cannot rename a RAID %s directly",
 			  (lvl->lv->status & RAID_IMAGE) ? "image" :
 			  "metadata area");
-		r = ECMD_FAILED;
-		goto error;
+		goto bad;
 	}
 
 	if (lv_is_raid_with_tracking(lvl->lv)) {
 		log_error("Cannot rename %s while it is tracking a split image",
 			  lvl->lv->name);
-		r = ECMD_FAILED;
-		goto error;
+		goto bad;
 	}
 
 	if (!lv_rename(cmd, lvl->lv, lv_name_new))
-		goto error;
+		goto_bad;
 
 	log_print_unless_silent("Renamed \"%s\" to \"%s\" in volume group \"%s\"",
 				lv_name_old, lv_name_new, vg_name);
 
 	r = ECMD_PROCESSED;
-error:
+bad:
 	unlock_and_release_vg(cmd, vg, vg_name);
 	return r;
 }
diff --git a/tools/reporter.c b/tools/reporter.c
index e8ecf98..6e78355 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -98,7 +98,7 @@ static int _pvsegs_sub_single(struct cmd_context *cmd,
 	if (!report_object(handle, vg, seg ? seg->lv : &_free_logical_volume, pvseg->pv,
 			   seg ? : &_free_lv_segment, pvseg)) {
 		ret = ECMD_FAILED;
-                goto_out;
+		goto_out;
 	}
 
  out:
diff --git a/tools/vgcfgbackup.c b/tools/vgcfgbackup.c
index bee1b04..7cf19bc 100644
--- a/tools/vgcfgbackup.c
+++ b/tools/vgcfgbackup.c
@@ -65,7 +65,6 @@ static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 		if (vg_read_error(vg) == FAILED_INCONSISTENT) {
 			log_error("No backup taken: specify filename with -f "
 				  "to backup an inconsistent VG");
-			stack;
 			return ECMD_FAILED;
 		}
 
@@ -76,6 +75,7 @@ static int vg_backup_single(struct cmd_context *cmd, const char *vg_name,
 	}
 
 	log_print_unless_silent("Volume group \"%s\" successfully backed up.", vg_name);
+
 	return ECMD_PROCESSED;
 }
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 28747f6..6831597 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -246,10 +246,8 @@ static int _vgchange_refresh(struct cmd_context *cmd, struct volume_group *vg)
 {
 	log_verbose("Refreshing volume group \"%s\"", vg->name);
 
-	if (!vg_refresh_visible(cmd, vg)) {
-		stack;
-		return 0;
-	}
+	if (!vg_refresh_visible(cmd, vg))
+		return_0;
 
 	return 1;
 }
diff --git a/tools/vgsplit.c b/tools/vgsplit.c
index a204b26..ed31a57 100644
--- a/tools/vgsplit.c
+++ b/tools/vgsplit.c
@@ -298,8 +298,7 @@ static struct volume_group *_vgsplit_to(struct cmd_context *cmd,
 
 		if (vg_read_error(vg_to)) {
 			release_vg(vg_to);
-			stack;
-			return NULL;
+			return_NULL;
 		}
 
 	} else if (vg_read_error(vg_to) == SUCCESS) {


