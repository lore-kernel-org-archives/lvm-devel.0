From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:20 +0000 (UTC)
Subject: master - display: show C only for cache and cachepool
Message-ID: <20140711113420.04EE061381@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4db5d78cefa99c053ba1f0bf73aa0eb55cafb279
Commit:        4db5d78cefa99c053ba1f0bf73aa0eb55cafb279
Parent:        ba048612a3dcb9ca35c54f05a006ec458da4164f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 7 22:26:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:50:44 2014 +0200

display: show C only for cache and cachepool

Keep target type (attr6) as the cache data and metadata volume has.
(i.e. when will show 'raid' type if metadata is raid)
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |   10 ++++------
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7891d76..6cbf221 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Display 'C' only for cache and cache-pool target types in lvs.
   Prompt for confirmation before change LV into a snapshot exception store.
   Return proper error codes for some failing lvconvert funtions.
   Add initial code to use cache tools (cache_check|dump|repair|restore).
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index d8fd320..f2c9b12 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -640,14 +640,12 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 	/* Origin takes precedence over mirror and thin volume */
 	else if (lv_is_origin(lv) || lv_is_external_origin(lv))
 		repstr[0] = (lv_is_merging_origin(lv)) ? 'O' : 'o';
-	else if (lv_is_cache_pool_metadata(lv))
+	else if (lv_is_pool_metadata(lv) ||
+		 lv_is_pool_metadata_spare(lv) ||
+		 lv_is_raid_metadata(lv))
 		repstr[0] = 'e';
 	else if (lv_is_cache_type(lv))
 		repstr[0] = 'C';
-	else if (lv_is_thin_pool_metadata(lv) ||
-		 lv_is_pool_metadata_spare(lv) ||
-		 (lv->status & RAID_META))
-		repstr[0] = 'e';
 	else if (lv->status & RAID)
 		repstr[0] = (lv->status & LV_NOTSYNCED) ? 'R' : 'r';
 	else if (lv->status & MIRRORED)
@@ -739,7 +737,7 @@ char *lv_attr_dup(struct dm_pool *mem, const struct logical_volume *lv)
 
 	if (lv_is_thin_pool(lv) || lv_is_thin_volume(lv))
 		repstr[6] = 't';
-	else if (lv_is_cache_type(lv))
+	else if (lv_is_cache_pool(lv) || lv_is_cache(lv))
 		repstr[6] = 'C';
 	else if (lv_is_raid_type(lv))
 		repstr[6] = 'r';


