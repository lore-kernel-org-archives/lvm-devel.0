From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  6 Jan 2015 13:29:06 +0000 (UTC)
Subject: master - lvmetad: Re-use fmt from the VG for PVs when possible.
Message-ID: <20150106132906.9F7BA60781@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0987f290a7b53840c2811392868f050d9a632ea3
Commit:        0987f290a7b53840c2811392868f050d9a632ea3
Parent:        509650ec4cb1ef65e277870e96976d7dd8882170
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jan 6 12:39:57 2015 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jan 6 14:27:30 2015 +0100

lvmetad: Re-use fmt from the VG for PVs when possible.

---
 lib/cache/lvmetad.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 5612c1b..20302c1 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -264,7 +264,7 @@ static int _read_mda(struct lvmcache_info *info,
 
 static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 						   struct dm_config_node *cn,
-						   dev_t fallback)
+						   struct format_type *fmt, dev_t fallback)
 {
 	struct device *dev;
 	struct id pvid, vgid;
@@ -283,7 +283,8 @@ static struct lvmcache_info *_pv_populate_lvmcache(struct cmd_context *cmd,
 	uint64_t devsize = dm_config_find_int64(cn->child, "dev_size", 0),
 		 label_sector = dm_config_find_int64(cn->child, "label_sector", 0);
 
-	struct format_type *fmt = fmt_name ? get_format_by_name(cmd, fmt_name) : NULL;
+	if (!fmt && fmt_name)
+		fmt = get_format_by_name(cmd, fmt_name);
 
 	if (!fmt) {
 		log_error("PV %s not recognised. Is the device missing?", pvid_txt);
@@ -422,7 +423,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 
 		if ((pvcn = dm_config_find_node(top, "metadata/physical_volumes")))
 			for (pvcn = pvcn->child; pvcn; pvcn = pvcn->sib)
-				_pv_populate_lvmcache(cmd, pvcn, 0);
+				_pv_populate_lvmcache(cmd, pvcn, fmt, 0);
 
 		top->key = name;
 		if (!(vg = import_vg_from_config_tree(reply.cft, fid)))
@@ -573,7 +574,7 @@ int lvmetad_pv_lookup(struct cmd_context *cmd, struct id pvid, int *found)
 
 	if (!(cn = dm_config_find_node(reply.cft->root, "physical_volume")))
 		goto_out;
-        else if (!_pv_populate_lvmcache(cmd, cn, 0))
+        else if (!_pv_populate_lvmcache(cmd, cn, NULL, 0))
 		goto_out;
 
 out_success:
@@ -603,7 +604,7 @@ int lvmetad_pv_lookup_by_dev(struct cmd_context *cmd, struct device *dev, int *f
 		goto out_success;
 
 	cn = dm_config_find_node(reply.cft->root, "physical_volume");
-	if (!cn || !_pv_populate_lvmcache(cmd, cn, dev->dev))
+	if (!cn || !_pv_populate_lvmcache(cmd, cn, NULL, dev->dev))
 		goto_out;
 
 out_success:
@@ -631,7 +632,7 @@ int lvmetad_pv_list_to_lvmcache(struct cmd_context *cmd)
 
 	if ((cn = dm_config_find_node(reply.cft->root, "physical_volumes")))
 		for (cn = cn->child; cn; cn = cn->sib)
-			_pv_populate_lvmcache(cmd, cn, 0);
+			_pv_populate_lvmcache(cmd, cn, NULL, 0);
 
 	daemon_reply_destroy(reply);
 


