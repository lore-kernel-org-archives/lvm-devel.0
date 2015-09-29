From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 29 Sep 2015 19:07:51 +0000 (UTC)
Subject: master - lockd: add VG name to debug logging
Message-ID: <20150929190751.21F7E60DE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=309979d57891912b977edbd89970bf25614ee9eb
Commit:        309979d57891912b977edbd89970bf25614ee9eb
Parent:        c805fa7c40ffd704523093edf4749e362f5c46ae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 29 14:07:08 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 29 14:07:08 2015 -0500

lockd: add VG name to debug logging

Add the VG name to the new debug logging in
the previous commit.
---
 lib/cache/lvmetad.c |   30 +++++++++++++++---------------
 1 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 0545aff..db15866 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -37,7 +37,7 @@ static struct cmd_context *_lvmetad_cmd = NULL;
 
 static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct volume_group *vg);
 
-static int _log_debug_inequality(struct dm_config_node *a, struct dm_config_node *b)
+static int _log_debug_inequality(const char *name, struct dm_config_node *a, struct dm_config_node *b)
 {
 	int result = 0;
 	int final_result = 0;
@@ -50,51 +50,51 @@ static int _log_debug_inequality(struct dm_config_node *a, struct dm_config_node
 
 			if (!strcmp(a->key, b->key)) {
 				if (a->v->type == DM_CFG_STRING && b->v->type == DM_CFG_STRING)
-					log_debug_lvmetad("VG metadata inequality at %s / %s: %s / %s",
-							  a->key, b->key, av->v.str, bv->v.str);
+					log_debug_lvmetad("VG %s metadata inequality at %s / %s: %s / %s",
+							  name, a->key, b->key, av->v.str, bv->v.str);
 				else if (a->v->type == DM_CFG_INT && b->v->type == DM_CFG_INT)
-					log_debug_lvmetad("VG metadata inequality at %s / %s: %li / %li",
-							  a->key, b->key, (int64_t)av->v.i, (int64_t)bv->v.i);
+					log_debug_lvmetad("VG %s metadata inequality at %s / %s: %li / %li",
+							  name, a->key, b->key, (int64_t)av->v.i, (int64_t)bv->v.i);
 				else
-					log_debug_lvmetad("VG metadata inequality at %s / %s: type %d / type %d",
-							  a->key, b->key, av->type, bv->type);
+					log_debug_lvmetad("VG %s metadata inequality at %s / %s: type %d / type %d",
+							  name, a->key, b->key, av->type, bv->type);
 			} else {
-				log_debug_lvmetad("VG metadata inequality at %s / %s", a->key, b->key);
+				log_debug_lvmetad("VG %s metadata inequality at %s / %s", name, a->key, b->key);
 			}
 			final_result = result;
 		}
 	}
 
 	if (a->v && !b->v) {
-		log_debug_lvmetad("VG metadata inequality at %s / %s", a->key, b->key);
+		log_debug_lvmetad("VG %s metadata inequality at %s / %s", name, a->key, b->key);
 		final_result = 1;
 	}
 
 	if (!a->v && b->v) {
-		log_debug_lvmetad("VG metadata inequality at %s / %s", a->key, b->key);
+		log_debug_lvmetad("VG %s metadata inequality at %s / %s", name, a->key, b->key);
 		final_result = -1;
 	}
 
 	if (a->child && b->child) {
-		result = _log_debug_inequality(a->child, b->child);
+		result = _log_debug_inequality(name, a->child, b->child);
 		if (result)
 			final_result = result;
 	}
 
 	if (a->sib && b->sib) {
-		result = _log_debug_inequality(a->sib, b->sib);
+		result = _log_debug_inequality(name, a->sib, b->sib);
 		if (result)
 			final_result = result;
 	}
 	
 
 	if (a->sib && !b->sib) {
-		log_debug_lvmetad("VG metadata inequality at %s / %s", a->key, b->key);
+		log_debug_lvmetad("VG %s metadata inequality at %s / %s", name, a->key, b->key);
 		final_result = 1;
 	}
 
 	if (!a->sib && b->sib) {
-		log_debug_lvmetad("VG metadata inequality at %s / %s", a->key, b->key);
+		log_debug_lvmetad("VG %s metadata inequality at %s / %s", name, a->key, b->key);
 		final_result = -1;
 	}
 
@@ -1261,7 +1261,7 @@ static struct volume_group *lvmetad_pvscan_vg(struct cmd_context *cmd, struct vo
 			if (compare_config(vgmeta_ret->root, vgmeta->root)) {
 				log_error("VG %s metadata comparison failed for device %s vs %s",
 					  vg->name, dev_name(pvl->pv->dev), save_dev ? dev_name(save_dev) : "none");
-				_log_debug_inequality(vgmeta_ret->root, vgmeta->root);
+				_log_debug_inequality(vg->name, vgmeta_ret->root, vgmeta->root);
 				dm_config_destroy(vgmeta);
 				dm_config_destroy(vgmeta_ret);
 				release_vg(baton.vg);


