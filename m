From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Sep 2016 19:00:19 +0000 (UTC)
Subject: master - cache: fix reporting of dirty cache
Message-ID: <20160909190019.602CE605B6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=454b891f6d0c482cd6c1655dc4e5c7eeee321d32
Commit:        454b891f6d0c482cd6c1655dc4e5c7eeee321d32
Parent:        9350aa72184e08da0faa5f1fda2f245e6342a426
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 20:45:37 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 9 20:53:36 2016 +0200

cache: fix reporting of dirty cache

When cache has zero used blocks it's been wrongly reported as 100.00% dirty.
Fix it and report 0.00.
---
 WHATS_NEW                    |    1 +
 lib/activate/dev_manager.c   |    5 +++--
 lib/metadata/lv.c            |    5 +++--
 test/shell/lvcreate-cache.sh |    6 +++---
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2c47452..46e0c1a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Report 0% as dirty (copy%) for cache without any used block.
   Fix lvm2api reporting of cache data and metadata percent.
   Restore reporting of metadata usage for cache volumes (2.02.155).
   Support raid scrubbing on cache origin LV.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 233a216..9fbd689 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1432,8 +1432,9 @@ int dev_manager_cache_status(struct dev_manager *dm,
 							c->total_blocks);
 		(*status)->metadata_usage = dm_make_percent(c->metadata_used_blocks,
 							    c->metadata_total_blocks);
-		(*status)->dirty_usage = dm_make_percent(c->dirty_blocks,
-							 c->used_blocks);
+		(*status)->dirty_usage = (s->cache->used_blocks) ?
+			dm_make_percent(c->dirty_blocks,
+					c->used_blocks) : DM_PERCENT_0;
 	}
 	r = 1;
 out:
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 9ee67b4..33129e3 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -366,8 +366,9 @@ dm_percent_t lvseg_percent_with_info_and_seg_status(const struct lv_with_info_an
 		else {
 			switch (type) {
 			case PERCENT_GET_DIRTY:
-				p = dm_make_percent(s->cache->dirty_blocks,
-						    s->cache->used_blocks);
+				p = (s->cache->used_blocks) ?
+					dm_make_percent(s->cache->dirty_blocks,
+							s->cache->used_blocks) : DM_PERCENT_0;
 				break;
 			case PERCENT_GET_METADATA:
 				p = dm_make_percent(s->cache->metadata_used_blocks,
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 52d36a1..c53d243 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -85,15 +85,15 @@ lvremove -f $vg
 lvcreate --type cache-pool  -L1 $vg/cpool
 lvcreate -H -L4 -n $lv1 $vg/cpool
 
-check lv_field $vg/$lv1 copy_percent "100.00"
+check lv_field $vg/$lv1 copy_percent "0.00"
 check lv_field $vg/$lv1 data_percent "0.00"
 check lv_field $vg/$lv1 metadata_percent "0.78"
-check lv_field $vg/cpool copy_percent "100.00"
+check lv_field $vg/cpool copy_percent "0.00"
 check lv_field $vg/cpool data_percent "0.00"
 check lv_field $vg/cpool metadata_percent "0.78"
 # check we also display percent value for segmented output (-o+devices)
 lvs -a -o+devices $vg/cpool | tee out
-grep "100.00" out
+grep "0.00" out
 lvremove -f $vg
 
 


