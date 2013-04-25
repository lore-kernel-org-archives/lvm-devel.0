From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 25 Apr 2013 15:34:35 +0000 (UTC)
Subject: master - lvchange: use vg mempool
Message-ID: <20130425153435.E20EB1C9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1eb17ab07f457d92bff58ea489c670be7bed9ed
Commit:        c1eb17ab07f457d92bff58ea489c670be7bed9ed
Parent:        a5ad1ee8587daf1001e64775d3478f345e77e324
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 25 10:15:13 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 25 17:33:24 2013 +0200

lvchange: use vg mempool

Using vg mempool for vg related data. Since we have VG in write mode,
prefer to use this mempool instead of cmd mempool.
---
 tools/lvchange.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 796e512..ed0a35a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -233,7 +233,6 @@ static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 {
 	uint32_t s;
 	uint32_t num_meta_lvs;
-	struct cmd_context *cmd = seg->lv->vg->cmd;
 	struct lv_list *lvl;
 
 	num_meta_lvs = seg_is_raid(seg) ? seg->area_count : !!seg->log_lv;
@@ -241,7 +240,7 @@ static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 	if (!num_meta_lvs)
 		return_0;
 
-	if (!(lvl = dm_pool_alloc(cmd->mem, sizeof(*lvl) * num_meta_lvs)))
+	if (!(lvl = dm_pool_alloc(seg->lv->vg->vgmem, sizeof(*lvl) * num_meta_lvs)))
 		return_0;
 
 	if (seg_is_raid(seg)) {
@@ -265,7 +264,6 @@ static int detach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 
 static int attach_metadata_devices(struct lv_segment *seg, struct dm_list *list)
 {
-	struct cmd_context *cmd = seg->lv->vg->cmd;
 	struct lv_list *lvl;
 
 	if (seg_is_raid(seg)) {
@@ -715,7 +713,7 @@ static int lvchange_writemostly(struct logical_volume *lv)
 	if (arg_count(cmd, writemostly_ARG)) {
 		/* writemostly can be specified more than once */
 		pv_count = arg_count(cmd, writemostly_ARG);
-		pv_names = dm_pool_alloc(cmd->mem, sizeof(char *) * pv_count);
+		pv_names = dm_pool_alloc(lv->vg->vgmem, sizeof(char *) * pv_count);
 		if (!pv_names)
 			return_0;
 
@@ -739,7 +737,7 @@ static int lvchange_writemostly(struct logical_volume *lv)
 			 * We allocate strlen + 3 to add our own ':{t|n|y}' if
 			 * not present plus the trailing '\0'.
 			 */
-			if (!(pv_names[i] = dm_pool_zalloc(cmd->mem,
+			if (!(pv_names[i] = dm_pool_zalloc(lv->vg->vgmem,
 							   strlen(tmp_str) + 3)))
 				return_0;
 


