From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Sep 2015 15:29:57 +0000 (UTC)
Subject: master - cache: warn if caching causes troubles
Message-ID: <20150910152957.E864960B43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5911fa1d914220a182630a5f353b665478917df1
Commit:        5911fa1d914220a182630a5f353b665478917df1
Parent:        e1edb5676e3ee6f84a3451fcbfe5d5be0d349188
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 15:07:59 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 17:27:30 2015 +0200

cache: warn if caching causes troubles

Certain stacks of cached LVs may have unexpected consequences.
So add a warning function called when LV is cached to detect
such caces and WARN user about them - the best we could do ATM.
---
 WHATS_NEW                          |    1 +
 lib/metadata/cache_manip.c         |   19 ++++++++++++++++++-
 lib/metadata/lv_manip.c            |    2 ++
 lib/metadata/metadata-exported.h   |    1 +
 test/shell/lvconvert-cache-raid.sh |   14 ++++++++------
 tools/lvconvert.c                  |    2 ++
 6 files changed, 32 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3119f12..3f897ce 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.131 - 
 =====================================
+  Warn user when caching raid or thin pool data LV.
   When layering LV, move LV flags with segments.
   Ignore persistent cache if configuration changed. (2.02.127)
   Fix devices/filter to be applied before disk-accessing filters. (2.02.112)
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 30d890c..04b8308 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -101,6 +101,23 @@ int cache_set_mode(struct lv_segment *seg, const char *str)
 	return 1;
 }
 
+/*
+ * At least warn a user if certain cache stacks may present some problems
+ */
+void cache_check_for_warns(const struct lv_segment *seg)
+{
+	struct logical_volume *origin_lv = seg_lv(seg, 0);
+
+	if (lv_is_raid(origin_lv) &&
+	    first_seg(seg->pool_lv)->feature_flags & DM_CACHE_FEATURE_WRITEBACK)
+		log_warn("WARNING: Data redundancy is lost with writeback "
+			 "caching of raid logical volume!");
+
+	if (lv_is_thin_pool_data(seg->lv))
+		log_warn("WARNING: Cached thin pool's data cannot be currently "
+			 "resized and require manual uncache before resize!");
+}
+
 int update_cache_pool_params(const struct segment_type *segtype,
 			     struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t pool_data_extents,
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7412da7..f43d281 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7516,6 +7516,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		if (!cache_set_policy(first_seg(lv), lp->policy_name, lp->policy_settings))
 			return_NULL; /* revert? */
 
+		cache_check_for_warns(first_seg(lv));
+
 		if (!lv_update_and_reload(lv)) {
 			/* FIXME Do a better revert */
 			log_error("Aborting. Manual intervention required.");
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index fff24f0..25320fd 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1158,6 +1158,7 @@ int cache_mode_is_set(const struct lv_segment *seg);
 int cache_set_mode(struct lv_segment *cache_seg, const char *str);
 int cache_set_policy(struct lv_segment *cache_seg, const char *name,
 		     const struct dm_config_tree *settings);
+void cache_check_for_warns(const struct lv_segment *seg);
 int update_cache_pool_params(const struct segment_type *segtype,
 			     struct volume_group *vg, unsigned attr,
 			     int passed_args, uint32_t pool_data_extents,
diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 5f51fee..284ffbe 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -24,7 +24,7 @@ aux prepare_vg 5 80
 
 # Bug 1095843
 # lvcreate RAID1 origin, lvcreate cache-pool, and lvconvert to cache
-lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+lvcreate --type raid1 -m 1 --nosync -l 2 -n $lv1 $vg
 lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
 lvconvert --cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
 check lv_exists $vg/${lv1}_corig_rimage_0 # ensure images are properly renamed
@@ -33,17 +33,19 @@ lvremove -f $vg
 
 
 # lvcreate RAID1 origin, lvcreate RAID1 cache-pool, and lvconvert to cache
-lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
-lvcreate --type raid1 -m 1 -l 2 -n ${lv1}_cachepool $vg
+lvcreate --type raid1 -m 1 --nosync -l 2 -n $lv1 $vg
+lvcreate --type raid1 -m 1 --nosync -l 2 -n ${lv1}_cachepool $vg
 #should lvs -a $vg/${lv1}_cdata_rimage_0  # ensure images are properly renamed
-lvconvert --yes --type cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
+lvconvert --yes --type cache --cachemode writeback --cachepool $vg/${lv1}_cachepool $vg/$lv1 2>&1 | tee out
+grep "WARNING: Data redundancy is lost" out
 check lv_exists $vg/${lv1}_corig_rimage_0        # ensure images are properly renamed
 dmsetup table ${vg}-$lv1 | grep cache   # ensure it is loaded in kernel
 lvremove -f $vg
 
 
-lvcreate -n corigin -m 1 --type raid1 -l 10 $vg
-lvcreate -n cpool --type cache $vg/corigin -l 10
+lvcreate -n corigin -m 1 --type raid1 --nosync -l 10 $vg
+lvcreate -n cpool --type cache $vg/corigin --cachemode writeback -l 10 2>&1 | tee out
+grep "WARNING: Data redundancy is lost" out
 lvconvert --splitmirrors 1 --name split $vg/corigin "$dev1"
 
 lvremove -f $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 2bffb07..237de2d 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3191,6 +3191,8 @@ static int _lvconvert_cache(struct cmd_context *cmd,
 	if (!cache_set_policy(first_seg(cache_lv), lp->policy_name, lp->policy_settings))
 		return_0;
 
+	cache_check_for_warns(first_seg(cache_lv));
+
 	if (!lv_update_and_reload(cache_lv))
 		return_0;
 


