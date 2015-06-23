From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 23 Jun 2015 21:39:14 +0000 (UTC)
Subject: master - Reread a VG if the lvmetad copy is stale
Message-ID: <20150623213914.7450F611E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=679b6b5b29b2257672087f387ef04bc4c8a4cca7
Commit:        679b6b5b29b2257672087f387ef04bc4c8a4cca7
Parent:        bf77f717119c0e567a36d7d48e06d81bf5aa2fb9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 6 14:01:12 2014 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 23 16:36:40 2015 -0500

Reread a VG if the lvmetad copy is stale

and update the lvmetad copy after it is reread from disk.

This is the client side handling of the vg_invalid state
added to lvmetad in commit c595b50cec8a6b95c6ac4988912d1412f3cc0237.
---
 lib/cache/lvmetad.c |  106 +++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 106 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 92998bc..3c07cd1 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -34,6 +34,8 @@ static char *_lvmetad_token = NULL;
 static const char *_lvmetad_socket = NULL;
 static struct cmd_context *_lvmetad_cmd = NULL;
 
+static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg);
+
 void lvmetad_disconnect(void)
 {
 	if (_lvmetad_connected)
@@ -417,6 +419,7 @@ static int _pv_update_struct_pv(struct physical_volume *pv, struct format_instan
 struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgname, const char *vgid)
 {
 	struct volume_group *vg = NULL;
+	struct volume_group *vg2 = NULL;
 	daemon_reply reply;
 	int found;
 	char uuid[64];
@@ -486,6 +489,18 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 		if (!(vg = import_vg_from_lvmetad_config_tree(reply.cft, fid)))
 			goto_out;
 
+		/*
+		 * locking may have detected a newer vg version and
+		 * invalidated the cached vg.
+		 */
+		if (dm_config_find_node(reply.cft->root, "vg_invalid")) {
+			log_debug_lvmetad("Update invalid lvmetad cache for VG %s", vgname);
+			vg2 = lvmetad_pvscan_vg(cmd, vg);
+			release_vg(vg);
+			vg = vg2;
+			fid = vg->fid;
+		}
+
 		dm_list_iterate_items(pvl, &vg->pvs) {
 			if (!_pv_update_struct_pv(pvl->pv, fid)) {
 				vg = NULL;
@@ -1012,6 +1027,97 @@ static int _lvmetad_pvscan_single(struct metadata_area *mda, void *baton)
 	return 1;
 }
 
+/*
+ * The lock manager may detect that the vg cached in lvmetad is out of date,
+ * due to something like an lvcreate from another host.
+ * This is limited to changes that only affect the vg (not global state like
+ * orphan PVs), so we only need to reread mdas on the vg's existing pvs.
+ */
+
+static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg)
+{
+	struct volume_group *vg_ret = NULL;
+	struct dm_config_tree *vgmeta_ret = NULL;
+	struct dm_config_tree *vgmeta;
+	struct pv_list *pvl;
+	struct lvmcache_info *info;
+	struct format_instance *fid;
+	struct format_instance_ctx fic = { .type = 0 };
+	struct _lvmetad_pvscan_baton baton;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		/* missing pv */
+		if (!pvl->pv->dev)
+			continue;
+
+		info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0);
+
+		baton.vg = NULL;
+		baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
+
+		if (!baton.fid)
+			return NULL;
+
+		if (baton.fid->fmt->features & FMT_OBSOLETE) {
+			log_error("WARNING: Ignoring obsolete format of metadata (%s) on device %s when using lvmetad",
+			  	baton.fid->fmt->name, dev_name(pvl->pv->dev));
+			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+			return NULL;
+		}
+
+		lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
+
+		if (!baton.vg) {
+			lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
+			return NULL;
+		}
+
+		if (!(vgmeta = export_vg_to_config_tree(baton.vg))) {
+			log_error("VG export to config tree failed");
+			release_vg(baton.vg);
+			return NULL;
+		}
+
+		if (!vgmeta_ret) {
+			vgmeta_ret = vgmeta;
+		} else {
+			if (!compare_config(vgmeta_ret->root, vgmeta->root)) {
+				log_error("VG metadata comparison failed");
+				dm_config_destroy(vgmeta);
+				dm_config_destroy(vgmeta_ret);
+				release_vg(baton.vg);
+				return NULL;
+			}
+			dm_config_destroy(vgmeta);
+		}
+
+		release_vg(baton.vg);
+	}
+
+	if (vgmeta_ret) {
+		fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
+		if (!(vg_ret = import_vg_from_config_tree(vgmeta_ret, fid))) {
+			log_error("VG import from config tree failed");
+			lvmcache_fmt(info)->ops->destroy_instance(fid);
+			goto out;
+		}
+
+		/*
+		 * Update lvmetad with the newly read version of the VG.
+		 * The "precommitted" name is a misnomer in this case,
+		 * but that is the field which lvmetad_vg_update() uses
+		 * to send the metadata cft to lvmetad.
+		 */
+		vg_ret->cft_precommitted = vgmeta_ret;
+		if (!lvmetad_vg_update(vg_ret))
+			log_error("Failed to update lvmetad with new VG meta");
+		vg_ret->cft_precommitted = NULL;
+		dm_config_destroy(vgmeta_ret);
+	}
+out:
+	return vg_ret;
+}
+
 int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 			  activation_handler handler, int ignore_obsolete)
 {


