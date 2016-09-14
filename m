From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 14 Sep 2016 15:45:15 +0000 (UTC)
Subject: master - lvmlockd: fix metadata validation when rescanning VG
Message-ID: <20160914154515.3173F60309@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d455300d7baff341f1c7fe5776d975369dd3a23a
Commit:        d455300d7baff341f1c7fe5776d975369dd3a23a
Parent:        629059ee84e83b9d013d80e0b382a3474b30c7a4
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 13 16:50:47 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 14 10:43:33 2016 -0500

lvmlockd: fix metadata validation when rescanning VG

When rescanning a VG from disk, the metadata read from
each PV was compared as a sanity check.  The comparison
is done by exporting the vg metadata from each dev to
a config tree, and then comparing the config trees.
The function to create the config tree inserts
extraneous information along with the actual VG metadata.
This extra info includes creation_time.  The config
trees for two devs can easily be created one second
apart in which case the different creation_times would
cause the metadata comparison to fail.  The fix is to
exclude the extraneous info from the metadata comparison.
---
 lib/cache/lvmetad.c |   31 ++++++++++++++++++++++++++++++-
 1 files changed, 30 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index b3cd1bf..727d3d3 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1918,15 +1918,44 @@ scan_more:
 			vgmeta_ret = vgmeta;
 			save_dev = devl->dev;
 		} else {
-			if (compare_config(vgmeta_ret->root, vgmeta->root)) {
+			struct dm_config_node *meta1 = vgmeta_ret->root;
+			struct dm_config_node *meta2 = vgmeta->root;
+			struct dm_config_node *sib1 = meta1->sib;
+			struct dm_config_node *sib2 = meta2->sib;
+
+			/*
+			 * Do not compare the extraneous data that
+			 * export_vg_to_config_tree() inserts next to the
+			 * actual VG metadata.  This includes creation_time
+			 * which may not match since it is generated separately
+			 * for each call to create the config tree.
+			 *
+			 * We're saving the sibling pointer and restoring it
+			 * after the compare because we're unsure if anything
+			 * later might want it.
+			 *
+			 * FIXME: make it clearer what we're doing here, e.g.
+			 * pass a parameter to export_vg_to_config_tree()
+			 * telling it to skip the extraneous data, or something.
+			 * It's very non-obvious that setting sib=NULL does that.
+			 */
+			meta1->sib = NULL;
+			meta2->sib = NULL;
+
+			if (compare_config(meta1, meta2)) {
 				log_error("VG %s metadata comparison failed for device %s vs %s",
 					  vg->name, dev_name(devl->dev), save_dev ? dev_name(save_dev) : "none");
 				_log_debug_inequality(vg->name, vgmeta_ret->root, vgmeta->root);
+
+				meta1->sib = sib1;
+				meta2->sib = sib2;
 				dm_config_destroy(vgmeta);
 				dm_config_destroy(vgmeta_ret);
 				release_vg(baton.vg);
 				return NULL;
 			}
+			meta1->sib = sib1;
+			meta2->sib = sib2;
 			dm_config_destroy(vgmeta);
 		}
 


