From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  4 Nov 2014 14:33:10 +0000 (UTC)
Subject: master - thin: new pool is activated without overlay
Message-ID: <20141104143310.40E6D608F0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00a45ca491de21336f8d1d0253344995cea3b4f0
Commit:        00a45ca491de21336f8d1d0253344995cea3b4f0
Parent:        8563c3e1a96f0d7ad180c859e9bf23a90e63e907
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 10:33:35 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 4 15:29:22 2014 +0100

thin: new pool is activated without overlay

Activate of new/unused/empty thin pool volume skips
the 'overlay' part and directly provides 'visible' thin-pool LV to the user.

Such thin pool still gets 'private' -tpool UUID suffix for easier
udev detection of protected lvm2 devices, and also gets udev flags to
avoid any scan.

Such pool device is 'public' LV with regular /dev/vgname/poolname link,
but it's still 'udev' hidden device for any other use.

To display proper active state we need to do few explicit tests
for this condition.

Before it's used for any lvm2 thin volume, deactivation is
now needed to avoid any 'race' with external usage.
---
 lib/activate/activate.c    |    4 ++++
 lib/activate/dev_manager.c |   15 ++++++++++++---
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 49e86e7..c2a662f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -641,6 +641,10 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, int use_la
 			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
 	}
 
+	/* New thin-pool has no layer, but -tpool suffix needs to be queried */
+	if (!use_layer && lv_is_new_thin_pool(lv))
+		use_layer = 1;
+
 	if (!dev_manager_info(cmd->mem, lv,
 			      (use_layer) ? lv_layer(lv) : NULL,
 			      with_open_count, with_read_ahead,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 41911c1..e81c5d3 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1527,7 +1527,11 @@ static uint16_t _get_udev_flags(struct dev_manager *dm, const struct logical_vol
 	 * If not, create just the /dev/mapper content.
 	 */
 	/* FIXME: add target's method for this */
-	if (layer || !lv_is_visible(lv) || lv_is_thin_pool(lv))
+	if (lv_is_new_thin_pool(lv))
+		/* New thin-pool is regular LV with -tpool UUID suffix. */
+		udev_flags |= DM_UDEV_DISABLE_DISK_RULES_FLAG |
+		              DM_UDEV_DISABLE_OTHER_RULES_FLAG;
+	else if (layer || !lv_is_visible(lv) || lv_is_thin_pool(lv))
 		udev_flags |= DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG |
 			      DM_UDEV_DISABLE_DISK_RULES_FLAG |
 			      DM_UDEV_DISABLE_OTHER_RULES_FLAG;
@@ -2604,6 +2608,10 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(name = dm_build_dm_name(dm->mem, lv->vg->name, lv->name, layer)))
 		return_0;
 
+        /* Even unused thin-pool still needs to get layered  UUID -suffix */
+	if (!layer && lv_is_new_thin_pool(lv))
+		layer = lv_layer(lv);
+
 	if (!(dlid = build_dm_uuid(dm->mem, lv, layer)))
 		return_0;
 
@@ -2679,8 +2687,9 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 			return_0;
 		if (!_add_snapshot_target_to_dtree(dm, dnode, lv, laopts))
 			return_0;
-	} else if ((lv_is_external_origin(lv) || lv_is_thin_pool(lv)) && !layer) {
-		/* External origin or Thin pool is using layer */
+	} else if (!layer && ((lv_is_thin_pool(lv) && !lv_is_new_thin_pool(lv)) ||
+			      lv_is_external_origin(lv))) {
+		/* External origin or 'used' Thin pool is using layer */
 		if (!_add_new_lv_to_dtree(dm, dtree, lv, laopts, lv_layer(lv)))
 			return_0;
 		if (!_add_layer_target_to_dtree(dm, dnode, lv))


