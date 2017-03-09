From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 9 Mar 2017 08:11:31 -0500
Subject: master - lvconvert: prompt when splitting off LV of a 2-legged raid1 LV
Message-ID: <201703091311.v29DBVM1017048@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6dfe1ce251b1e2d01779817255d3beb3b9cfe2e9
Commit:        6dfe1ce251b1e2d01779817255d3beb3b9cfe2e9
Parent:        6b1b66c2669d0da8aade44fa063a930ca402c363
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 9 13:59:47 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 9 13:59:47 2017 +0100

lvconvert: prompt when splitting off LV of a 2-legged raid1 LV

Splitting off an image LV of a 2-legged
raid1 LV causes loss of resilience.

Ask user to avoid uninformed loss of all resilience.

Don't ask for N > 2 legged raid1 LVs.

Adjust tests.
---
 lib/metadata/metadata-exported.h   |    2 +-
 lib/metadata/raid_manip.c          |   10 +++++++++-
 test/shell/lvconvert-cache-raid.sh |    8 +++++---
 test/shell/lvconvert-raid.sh       |    7 ++++---
 tools/lvconvert.c                  |    2 +-
 5 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1b06354..9e1f4b6 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1216,7 +1216,7 @@ int lv_raid_change_image_count(struct logical_volume *lv,
 			       uint32_t new_count,
 			       uint32_t new_region_size,
 			       struct dm_list *allocate_pvs);
-int lv_raid_split(struct logical_volume *lv, const char *split_name,
+int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs);
 int lv_raid_split_and_track(struct logical_volume *lv,
 			    int yes,
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9f1ea8d..515e4b8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3071,7 +3071,7 @@ int lv_raid_change_image_count(struct logical_volume *lv, int yes, uint32_t new_
 	return _lv_raid_change_image_count(lv, yes, new_count, allocate_pvs, NULL, 1, 0);
 }
 
-int lv_raid_split(struct logical_volume *lv, const char *split_name,
+int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 		  uint32_t new_count, struct dm_list *splittable_pvs)
 {
 	struct lv_list *lvl;
@@ -3116,6 +3116,14 @@ int lv_raid_split(struct logical_volume *lv, const char *split_name,
 		return 0;
 	}
 
+	/* Split on a 2-legged raid1 LV causes loosing all resilience */
+	if (new_count == 1 &&
+	    !yes && yes_no_prompt("Are you sure you want to split %s LV %s loosing all resilience? [y/n]: ",
+				  lvseg_name(first_seg(lv)), display_lvname(lv)) == 'n') {
+		log_error("Logical volume %s NOT split.", display_lvname(lv));
+		return 0;
+	}
+
 	/*
 	 * We only allow a split while there is tracking if it is to
 	 * complete the split of the tracking sub-LV
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 5b693a1..3ad91c4 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -47,7 +47,8 @@ lvremove -f $vg
 lvcreate -n corigin -m 1 --type raid1 --nosync -l 10 $vg
 lvcreate -n cpool --type cache $vg/corigin --cachemode writeback -l 10 2>&1 | tee out
 grep "WARNING: Data redundancy is lost" out
-lvconvert --splitmirrors 1 --name split $vg/corigin "$dev1"
+not lvconvert --splitmirrors 1 --name split $vg/corigin "$dev1"
+lvconvert --yes --splitmirrors 1 --name split $vg/corigin "$dev1"
 
 lvremove -f $vg
 
@@ -75,8 +76,9 @@ not lvconvert --splitmirrors 1 --name split_cdata $vg/cpool_cdata "$dev1"
 # but allow manipulating existing LVs with reserved names
 aux wait_for_sync $vg cpool_cmeta
 aux wait_for_sync $vg cpool_cdata
-lvconvert --splitmirrors 1 --name split_meta $vg/cpool_cmeta "$dev1"
-lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
+lvconvert --yes --splitmirrors 1 --name split_meta $vg/cpool_cmeta "$dev1"
+lvconvert --yes --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
+not lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
 
 lvremove -f $vg
 
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index b5bfede..a9b36e2 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -134,7 +134,8 @@ lvremove -ff $vg
 # 2-way to linear/linear
 lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
-lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
+not lvconvert --splitmirrors 1 -n $lv2 $vg/$lv1
+lvconvert --yes --splitmirrors 1 -n $lv2 $vg/$lv1
 check linear $vg $lv1
 check linear $vg $lv2
 check active $vg $lv2
@@ -144,7 +145,7 @@ lvremove -ff $vg
 # 4-way
 lvcreate --type raid1 -m 4 -l 2 -n $lv1 $vg
 aux wait_for_sync $vg $lv1
-lvconvert --yes --splitmirrors 1 --name $lv2 $vg/$lv1 "$dev2"
+lvconvert --splitmirrors 1 --name $lv2 $vg/$lv1 "$dev2"
 lvremove -ff $vg
 
 ###########################################
@@ -179,7 +180,7 @@ fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv1"
 aux wait_for_sync $vg $lv1
 fsck.ext4 -fn "$DM_DEV_DIR/$vg/$lv1"
 not lvconvert --splitmirrors 1 --trackchanges $vg/$lv1
-lvconvert -y --splitmirrors 1 --trackchanges $vg/$lv1
+lvconvert --yes --splitmirrors 1 --trackchanges $vg/$lv1
 # FIXME: ensure no residual devices
 lvremove -ff $vg
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9153633..d5c8d49 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1349,7 +1349,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 		return lv_raid_split_and_track(lv, lp->yes, lp->pvh);
 
 	if (lp->keep_mimages)
-		return lv_raid_split(lv, lp->lv_split_name, image_count, lp->pvh);
+		return lv_raid_split(lv, lp->yes, lp->lv_split_name, image_count, lp->pvh);
 
 	if (lp->mirrors_supplied) {
 		if (!*lp->type_str || !strcmp(lp->type_str, SEG_TYPE_NAME_RAID1) || !strcmp(lp->type_str, SEG_TYPE_NAME_LINEAR) ||


