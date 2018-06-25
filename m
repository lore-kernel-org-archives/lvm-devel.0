From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 25 Jun 2018 09:10:13 -0400
Subject: master - lv_manip: use vgmem pool
Message-ID: <201806251310.w5PDADdS031452@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cea88a9e4ee5a2aa28b52d673fba66327e88ff6e
Commit:        cea88a9e4ee5a2aa28b52d673fba66327e88ff6e
Parent:        357e9f9572361ec2ea89ca0bf165a30545fa747f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 23 11:59:35 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 25 15:07:55 2018 +0200

lv_manip: use vgmem pool

Switch to vgmem pool for allocation associated with modification
of particular VG.
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 11a6927..7b68313 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5901,7 +5901,7 @@ struct dm_list *build_parallel_areas_from_lv(struct logical_volume *lv,
 	uint32_t raid_multiple;
 	struct lv_segment *seg = first_seg(lv);
 
-	if (!(parallel_areas = dm_pool_alloc(cmd->mem, sizeof(*parallel_areas)))) {
+	if (!(parallel_areas = dm_pool_alloc(lv->vg->vgmem, sizeof(*parallel_areas)))) {
 		log_error("parallel_areas allocation failed");
 		return NULL;
 	}
@@ -5910,7 +5910,7 @@ struct dm_list *build_parallel_areas_from_lv(struct logical_volume *lv,
 
 	do {
 		if (!spvs || !create_single_list) {
-			if (!(spvs = dm_pool_zalloc(cmd->mem, sizeof(*spvs)))) {
+			if (!(spvs = dm_pool_zalloc(lv->vg->vgmem, sizeof(*spvs)))) {
 				log_error("allocation failed");
 				return NULL;
 			}


