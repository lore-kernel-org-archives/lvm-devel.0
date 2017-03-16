From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Mar 2017 20:02:44 -0400
Subject: master - coverity: make sure segtype pointer is valid
Message-ID: <201703160002.v2G02iSf017663@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3a51537c57f8ebe2ecb49f3d221710cd59163ae
Commit:        e3a51537c57f8ebe2ecb49f3d221710cd59163ae
Parent:        42b970d4f34a0cf70ac07d551852cbd7b924079f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 16 00:46:48 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 16 01:02:10 2017 +0100

coverity: make sure segtype pointer is valid

---
 lib/metadata/raid_manip.c |    6 +++---
 tools/lvconvert.c         |    3 ++-
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b2ea241..9f0de4c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1023,6 +1023,7 @@ static int _alloc_image_components(struct logical_volume *lv,
 	struct alloc_handle *ah = NULL;
 	struct dm_list *parallel_areas;
 	struct lv_list *lvl_array;
+	const char *raid_segtype;
 
 	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem,
 					sizeof(*lvl_array) * count * 2)))
@@ -1036,9 +1037,8 @@ static int _alloc_image_components(struct logical_volume *lv,
 	else
 		region_size = seg->region_size;
 
-	if (seg_is_raid(seg))
-		segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID0_META);
-	else if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
+	raid_segtype = seg_is_raid(seg) ? SEG_TYPE_NAME_RAID0_META : SEG_TYPE_NAME_RAID1;
+	if (!(segtype = get_segtype_from_string(lv->vg->cmd, raid_segtype)))
 		return_0;
 
 	/*
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 41d32df..a37dc25 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2704,7 +2704,8 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 
 	pool_segtype = get_segtype_from_string(cmd, str_seg_type);
 
-	if (!pool_segtype->ops->target_present(cmd, NULL, &target_attr)) {
+	if (!pool_segtype ||
+	    !pool_segtype->ops->target_present(cmd, NULL, &target_attr)) {
 		log_error("%s: Required device-mapper target(s) not detected in your kernel.",
 			  pool_segtype->name);
 		return 0;


