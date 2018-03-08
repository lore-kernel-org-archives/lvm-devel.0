From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 8 Mar 2018 04:43:06 -0500
Subject: master - snapshot: keep COW writable for read-only volumes
Message-ID: <201803080943.w289h6as019624@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a6fdb9d9d70f51c49ad11a87ab4243344e6701a3
Commit:        a6fdb9d9d70f51c49ad11a87ab4243344e6701a3
Parent:        15b6793528de99a70e988d09502ca33ad1d7c575
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 8 10:27:04 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 8 10:39:03 2018 +0100

snapshot: keep COW writable for read-only volumes

When snapshot is created in read-only mode with 'lvcreate -s -pr...',
lvm2 still needs to be able to write to layered -cow volume
to store metadata and exceptions blocks.

TODO: in some case we might be able to do full tree with read-only
volume but this probably needs futher validation:
1. checking snapshot header already exist
2. origin & snapshot are both in read-only mode.
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |    2 +-
 lib/activate/dev_manager.c |    7 +++++--
 lib/activate/dev_manager.h |    2 +-
 4 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 69345c6..d0bc386 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Ensure COW device is writable even for read-only thick snapshots.
   Support activation of component LVs in read-only mode.
   Extend internal library to recognize and work with component LV.
   Skip duplicate check for active LV when prompting for its removal.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index cb9b1cf..777fc21 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2694,7 +2694,7 @@ static int _lv_activate(struct cmd_context *cmd, const char *lvid_s,
 	 * Nothing to do?
 	 */
 	if (info.exists && !info.suspended && info.live_table &&
-	    (info.read_only == read_only_lv(lv, laopts))) {
+	    (info.read_only == read_only_lv(lv, laopts, NULL))) {
 		r = 1;
 		log_debug_activation("LV %s is already active.", display_lvname(lv));
 		goto out;
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a40fd2b..b8b937d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -75,8 +75,11 @@ struct lv_layer {
 	int visible_component;
 };
 
-int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts *laopts)
+int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts *laopts, const char *layer)
 {
+	if (layer && lv_is_cow(lv))
+		return 0; /* Keep snapshot's COW volume writable */
+
 	return (laopts->read_only || !(lv->status & LVM_WRITE));
 }
 
@@ -2824,7 +2827,7 @@ static int _add_new_lv_to_dtree(struct dev_manager *dm, struct dm_tree *dtree,
 	if (!(dnode = dm_tree_add_new_dev_with_udev_flags(dtree, name, dlid,
 					     layer ? UINT32_C(0) : (uint32_t) lv->major,
 					     layer ? UINT32_C(0) : (uint32_t) lv->minor,
-					     read_only_lv(lv, laopts),
+					     read_only_lv(lv, laopts, layer),
 					     ((lv->vg->status & PRECOMMITTED) | laopts->revert) ? 1 : 0,
 					     lvlayer,
 					     _get_udev_flags(dm, lv, layer, laopts->noscan, laopts->temporary,
diff --git a/lib/activate/dev_manager.h b/lib/activate/dev_manager.h
index ba198f5..5be417b 100644
--- a/lib/activate/dev_manager.h
+++ b/lib/activate/dev_manager.h
@@ -27,7 +27,7 @@ struct dm_info;
 struct device;
 struct lv_seg_status;
 
-int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts *laopts);
+int read_only_lv(const struct logical_volume *lv, const struct lv_activate_opts *laopts, const char *layer);
 
 /*
  * Constructor and destructor.


