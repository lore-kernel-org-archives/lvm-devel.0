From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Dec 2016 13:42:17 +0000 (UTC)
Subject: master - cache: support cached origin for snapshot
Message-ID: <20161219134217.6FABE60FF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0c56eb8f438a17a8c98470f9f6b2222235a7bf59
Commit:        0c56eb8f438a17a8c98470f9f6b2222235a7bf59
Parent:        eb3f83357afd2b7462f5be9f409424f588a138c8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 19 14:08:56 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 19 14:41:42 2016 +0100

cache: support cached origin for snapshot

Enable  'lvcreate/lvconvert -s' for cached LV.
and supported operations:

Create a snapshot of cached LV

Split/Join snapshot LV to cached origin LV.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    2 +-
 lib/metadata/lv_manip.c    |    2 +-
 tools/lvconvert.c          |   16 +++++++++++++++-
 4 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ab113ae..fa8f5c3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Enable usage of cached volumes as snapshot origin LV.
   Fix displayed lv name when splitting snapshot (2.02.146).
   Warn about command not making metadata backup just once per command.
   Enable usage of cached volume as thin volume's external origin.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 12b1054..404b1af 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -322,7 +322,7 @@ int validate_lv_cache_create_origin(const struct logical_volume *origin_lv)
 	if (lv_is_cache_type(origin_lv) ||
 	    lv_is_mirror_type(origin_lv) ||
 	    lv_is_thin_volume(origin_lv) || lv_is_thin_pool_metadata(origin_lv) ||
-	    lv_is_origin(origin_lv) || lv_is_merging_origin(origin_lv) ||
+	    lv_is_merging_origin(origin_lv) ||
 	    lv_is_cow(origin_lv) || lv_is_merging_cow(origin_lv) ||
 	    lv_is_virtual(origin_lv)) {
 		log_error("Cache is not supported with %s segment type of the original logical volume %s.",
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 92a6d44..3862f11 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7428,7 +7428,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				return NULL;
 			}
 
-			if (lv_is_cache_type(origin_lv)) {
+			if (lv_is_cache_type(origin_lv) && !lv_is_cache(origin_lv)) {
 				log_error("Snapshots of cache type volume %s "
 					  "is not supported.", display_lvname(origin_lv));
 				return NULL;
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4103995..0f0f0ad 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2336,7 +2336,7 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return_0;
 
 	if (lv_is_locked(org) ||
-	    lv_is_cache_type(org) ||
+	    (lv_is_cache_type(org) && !lv_is_cache(org)) ||
 	    lv_is_thin_type(org) ||
 	    lv_is_pvmove(org) ||
 	    lv_is_mirrored(org) ||
@@ -3771,6 +3771,16 @@ static int _convert_cache_volume_thin_pool(struct cmd_context *cmd, struct logic
 }
 
 /*
+ * Convert/Recombine  cacheLV to be an origin for snapshot
+ * lvconvert --type snapshot cacheLV snapshotLV
+ */
+static int _convert_cache_volume_snapshot(struct cmd_context *cmd, struct logical_volume *lv,
+					  struct lvconvert_params *lp)
+{
+	return _lvconvert_snapshot(cmd, lv, lp);
+}
+
+/*
  * Split a cache volume from a cache pool LV.
  * lvconvert --splitcache LV
  */
@@ -4311,6 +4321,10 @@ static int _convert_cache_volume(struct cmd_context *cmd, struct logical_volume
 	    arg_is_set(cmd, thinpool_ARG))
 		return _convert_cache_volume_thin_pool(cmd, lv, lp);
 
+	if (!strcmp(lp->type_str, SEG_TYPE_NAME_SNAPSHOT) ||
+	    arg_is_set(cmd, snapshot_ARG))
+		return _convert_cache_volume_snapshot(cmd, lv, lp);
+
 	/* The --thinpool alternative for --type thin-pool is not preferred, so not shown. */
 
 	log_error("Operation not permitted on cache LV %s.", display_lvname(lv));


