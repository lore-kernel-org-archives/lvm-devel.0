From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:46:34 -0500
Subject: master - activation: support proper /dev names for component LVs
Message-ID: <201803061446.w26EkY1V027167@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eb3597acb3af2e6f21893b2e3bdfa84f2ca301b1
Commit:        eb3597acb3af2e6f21893b2e3bdfa84f2ca301b1
Parent:        112846ce0b01e5353dfa81979a2d8ccb3e25a900
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 28 17:22:09 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:42:49 2018 +0100

activation: support proper /dev names for component LVs

When LV is activated AS componet LV - ensure there will
be /dev/vgname/lvname  link present for such LV.
---
 lib/activate/activate.c    |    1 +
 lib/activate/activate.h    |    1 +
 lib/activate/dev_manager.c |   18 ++++++++++++------
 3 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 6333ba9..cb9b1cf 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2677,6 +2677,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	/* TODO: should not apply for LVs in maintenance mode */
 	if (!lv_is_visible(lv) && lv_is_component(lv)) {
 		laopts->read_only = 1;
+		laopts->component_lv = lv;
 	} else if (filter)
 		laopts->read_only = _passes_readonly_filter(cmd, lv);
 
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index dc4d3cd..2fc74ce 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -83,6 +83,7 @@ struct lv_activate_opts {
 				 * flags are persistent in udev db for any spurious event
 				 * that follows. */
 	unsigned resuming;	/* Set when resuming after a suspend. */
+	const struct logical_volume *component_lv;
 };
 
 void set_activation(int activation, int silent);
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8bf0e47..a40fd2b 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -72,6 +72,7 @@ struct dev_manager {
 struct lv_layer {
 	const struct logical_volume *lv;
 	const char *old_name;
+	int visible_component;
 };
 
 int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts *laopts)
@@ -1590,7 +1591,8 @@ int dev_manager_mknodes(const struct logical_volume *lv)
 		return_0;
 
 	if (dminfo.exists) {
-		if (_lv_has_mknode(lv))
+		/* read-only component LV is also made visible */
+		if (_lv_has_mknode(lv) || (dminfo.read_only && lv_is_component(lv)))
 			r = _dev_manager_lv_mknodes(lv);
 	} else
 		r = _dev_manager_lv_rmnodes(lv);
@@ -1652,7 +1654,8 @@ static int _check_udev_fallback(struct cmd_context *cmd)
 #endif /* UDEV_SYNC_SUPPORT */
 
 static uint16_t _get_udev_flags(struct dev_manager *dm, const struct logical_volume *lv,
-				const char *layer, int noscan, int temporary)
+				const char *layer, int noscan, int temporary,
+				int visible_component)
 {
 	uint16_t udev_flags = 0;
 
@@ -1668,7 +1671,7 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, const struct logical_vol
 	 * If not, create just the /dev/mapper content.
 	 */
 	/* FIXME: add target's method for this */
-	if (lv_is_new_thin_pool(lv))
+	if (lv_is_new_thin_pool(lv) || visible_component)
 		/* New thin-pool is regular LV with -tpool UUID suffix. */
 		udev_flags |= DM_UDEV_DISABLE_DISK_RULES_FLAG |
 		              DM_UDEV_DISABLE_OTHER_RULES_FLAG;
@@ -1866,7 +1869,8 @@ static int _add_dev_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	}
 
 	if (info.exists && !dm_tree_add_dev_with_udev_flags(dtree, info.major, info.minor,
-							_get_udev_flags(dm, lv, layer, 0, 0))) {
+							    _get_udev_flags(dm, lv, layer,
+									    0, 0, 0))) {
 		log_error("Failed to add device (%" PRIu32 ":%" PRIu32") to dtree.",
 			  info.major, info.minor);
 		return 0;
@@ -2806,6 +2810,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	}
 
 	lvlayer->lv = lv;
+	lvlayer->visible_component = (laopts->component_lv == lv) ? 1 : 0;
 
 	/*
 	 * Add LV to dtree.
@@ -2822,7 +2827,8 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 					     read_only_lv(lv, laopts),
 					     ((lv->vg->status & PRECOMMITTED) | laopts->revert) ? 1 : 0,
 					     lvlayer,
-					     _get_udev_flags(dm, lv, layer, laopts->noscan, laopts->temporary))))
+					     _get_udev_flags(dm, lv, layer, laopts->noscan, laopts->temporary,
+							     lvlayer->visible_component))))
 		return_0;
 
 	/* Store existing name so we can do rename later */
@@ -2966,7 +2972,7 @@ static int _create_lv_symlinks(struct dev_manager *dm, struct dm_tree_node *root
 				r = 0;
 			continue;
 		}
-		if (_lv_has_mknode(lvlayer->lv)) {
+		if (_lv_has_mknode(lvlayer->lv) || lvlayer->visible_component) {
 			if (!_dev_manager_lv_mknodes(lvlayer->lv))
 				r = 0;
 			continue;


