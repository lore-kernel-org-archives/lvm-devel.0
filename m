From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 29 Sep 2015 18:52:09 +0000 (UTC)
Subject: master - lockd: add debug logging for metadata error
Message-ID: <20150929185209.DD2E36104D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c805fa7c40ffd704523093edf4749e362f5c46ae
Commit:        c805fa7c40ffd704523093edf4749e362f5c46ae
Parent:        634bf8c953caba4550463281fc0a90ee43c80c8d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 29 13:40:52 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 29 13:51:24 2015 -0500

lockd: add debug logging for metadata error

When lvmetad_pvscan_vg() reads VG metadata from each PV,
it compares it to the last one to verify it matches.
If the VG metadata does not match on the PVs, an error
is printed and it fails to read the VG.  In this error
case, use log_debug to show the differences between
the two unmatching copies of the metadata.
---
 lib/cache/lvmetad.c            |   70 +++++++++++++++++++++++++++++++++++++++-
 libdaemon/client/config-util.c |    2 +-
 libdaemon/client/config-util.h |    1 +
 3 files changed, 71 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 721c4a2..0545aff 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -37,6 +37,70 @@ static struct cmd_context *_lvmetad_cmd = NULL;
 
 static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg);
 
+static int _log_debug_inequality(struct dm_config_node *a, struct dm_config_node *b)
+{
+	int result = 0;
+	int final_result = 0;
+
+	if (a->v && b->v) {
+		result = compare_value(a->v, b->v);
+		if (result) {
+			struct dm_config_value *av = a->v;
+			struct dm_config_value *bv = b->v;
+
+			if (!strcmp(a->key, b->key)) {
+				if (a->v->type == DM_CFG_STRING && b->v->type == DM_CFG_STRING)
+					log_debug_lvmetad("VG metadata inequality at %s / %s: %s / %s",
+							  a->key, b->key, av->v.str, bv->v.str);
+				else if (a->v->type == DM_CFG_INT && b->v->type == DM_CFG_INT)
+					log_debug_lvmetad("VG metadata inequality at %s / %s: %li / %li",
+							  a->key, b->key, (int64_t)av->v.i, (int64_t)bv->v.i);
+				else
+					log_debug_lvmetad("VG metadata inequality at %s / %s: type %d / type %d",
+							  a->key, b->key, av->type, bv->type);
+			} else {
+				log_debug_lvmetad("VG metadata inequality at %s / %s", a->key, b->key);
+			}
+			final_result = result;
+		}
+	}
+
+	if (a->v && !b->v) {
+		log_debug_lvmetad("VG metadata inequality at %s / %s", a->key, b->key);
+		final_result = 1;
+	}
+
+	if (!a->v && b->v) {
+		log_debug_lvmetad("VG metadata inequality at %s / %s", a->key, b->key);
+		final_result = -1;
+	}
+
+	if (a->child && b->child) {
+		result = _log_debug_inequality(a->child, b->child);
+		if (result)
+			final_result = result;
+	}
+
+	if (a->sib && b->sib) {
+		result = _log_debug_inequality(a->sib, b->sib);
+		if (result)
+			final_result = result;
+	}
+	
+
+	if (a->sib && !b->sib) {
+		log_debug_lvmetad("VG metadata inequality at %s / %s", a->key, b->key);
+		final_result = 1;
+	}
+
+	if (!a->sib && b->sib) {
+		log_debug_lvmetad("VG metadata inequality at %s / %s", a->key, b->key);
+		final_result = -1;
+	}
+
+	return final_result;
+}
+
 void lvmetad_disconnect(void)
 {
 	if (_lvmetad_connected)
@@ -1136,6 +1200,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 	struct format_instance *fid;
 	struct format_instance_ctx fic = { .type = 0 };
 	struct _lvmetad_pvscan_baton baton;
+	struct device *save_dev = NULL;
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		/* missing pv */
@@ -1191,9 +1256,12 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 
 		if (!vgmeta_ret) {
 			vgmeta_ret = vgmeta;
+			save_dev = pvl->pv->dev;
 		} else {
 			if (compare_config(vgmeta_ret->root, vgmeta->root)) {
-				log_error("VG metadata comparison failed");
+				log_error("VG %s metadata comparison failed for device %s vs %s",
+					  vg->name, dev_name(pvl->pv->dev), save_dev ? dev_name(save_dev) : "none");
+				_log_debug_inequality(vgmeta_ret->root, vgmeta->root);
 				dm_config_destroy(vgmeta);
 				dm_config_destroy(vgmeta_ret);
 				release_vg(baton.vg);
diff --git a/libdaemon/client/config-util.c b/libdaemon/client/config-util.c
index 023257e..ec5ea98 100644
--- a/libdaemon/client/config-util.c
+++ b/libdaemon/client/config-util.c
@@ -289,7 +289,7 @@ static int close_enough(double d1, double d2)
 	return fabs(d1 - d2) < DBL_EPSILON;
 }
 
-static int compare_value(struct dm_config_value *a, struct dm_config_value *b)
+int compare_value(struct dm_config_value *a, struct dm_config_value *b)
 {
 	int r = 0;
 
diff --git a/libdaemon/client/config-util.h b/libdaemon/client/config-util.h
index 0e7de7e..c56c268 100644
--- a/libdaemon/client/config-util.h
+++ b/libdaemon/client/config-util.h
@@ -42,6 +42,7 @@ struct dm_config_node *make_config_node(struct dm_config_tree *cft,
 					struct dm_config_node *parent,
 					struct dm_config_node *pre_sib);
 
+int compare_value(struct dm_config_value *a, struct dm_config_value *b);
 int compare_config(struct dm_config_node *a, struct dm_config_node *b);
 
 struct dm_config_node *make_text_node(struct dm_config_tree *cft,


