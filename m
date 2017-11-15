From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Nov 2017 08:09:46 -0500
Subject: master - layers: collect only lock holding LVs
Message-ID: <201711151309.vAFD9kJl001993@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=eab9097b46b10ce61344c02934fe5c44b9f8c7c7
Commit:        eab9097b46b10ce61344c02934fe5c44b9f8c7c7
Parent:        cc854c0617034613b0335e43eaabf4e4ff2a26bd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 9 11:41:16 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 15 12:11:33 2017 +0100

layers: collect only lock holding LVs

---
 lib/metadata/lv_manip.c |   23 +++++++++++++++++------
 1 files changed, 17 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4fc9708..33a4f7d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7057,6 +7057,7 @@ int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
 	struct lv_list *lvl;
 	int lv_used = 0;
 	uint32_t s;
+	struct logical_volume *holder = (struct logical_volume *) lv_lock_holder(lv_where);
 
 	log_very_verbose("Inserting layer %s for segments of %s on %s",
 			 layer_lv->name, lv_where->name,
@@ -7083,13 +7084,23 @@ int insert_layer_for_segments_on_pv(struct cmd_context *cmd,
 
 			/* First time, add LV to list of LVs affected */
 			if (!lv_used && lvs_changed) {
-				if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
-					log_error("lv_list alloc failed");
-					return 0;
+				/* First check if LV is listed already */
+				dm_list_iterate_items(lvl, lvs_changed)
+					if (lvl->lv == holder) {
+						lv_used = 1;
+						break;
+					}
+
+				if (!lv_used) {
+					if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl)))) {
+						log_error("lv_list alloc failed.");
+						return 0;
+					}
+
+					lvl->lv = holder;
+					dm_list_add(lvs_changed, &lvl->list);
+					lv_used = 1;
 				}
-				lvl->lv = lv_where;
-				dm_list_add(lvs_changed, &lvl->list);
-				lv_used = 1;
 			}
 
 			if (!_extend_layer_lv_for_segment(layer_lv, seg, s,


