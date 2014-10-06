From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:19 +0000 (UTC)
Subject: master - lvconvert: validate cache conversion to snapshot
Message-ID: <20141006133319.3D91260DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee344f1a9ee8536eab235ea3d971f59ed769cdd5
Commit:        ee344f1a9ee8536eab235ea3d971f59ed769cdd5
Parent:        f76f2ce1df4e95774b8fded602a8e35f8ae71fe1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 12:27:35 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:06 2014 +0200

lvconvert: validate cache conversion to snapshot

Cache cannot be converted into snapshot cow nor origin.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   22 ++++++++++++++++++----
 2 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0ffb048..980809c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Fix detection of unsupported lvconversion of cache to snapshot.
   Improve code for creation of cache and cache pool volumes.
   Check cluster-wide (not local) active status before removing LV.
   Properly check if activation of removed cached LV really activated.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 11a10f7..1a5d559 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2139,6 +2139,12 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 {
 	struct logical_volume *org;
 
+	if (lv_is_cache_type(lv)) {
+		log_error("Snapshots are not yet supported with cache type LVs %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
 	if (lv_is_mirrored(lv)) {
 		log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);
 		return 0;
@@ -2150,14 +2156,15 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (lv_is_cache_type(lv)) {
-		log_error("Snapshots are not yet supported with cache type LVs %s.",
+	if (lv_is_pool(lv)) {
+		log_error("Unable to convert pool LVs %s into a snapshot.",
 			  display_lvname(lv));
 		return 0;
 	}
 
 	if (!(org = find_lv(lv->vg, lp->origin_lv_name))) {
-		log_error("Couldn't find origin volume %s.", lp->origin_lv_name);
+		log_error("Couldn't find origin volume %s in Volume group %s.",
+			  lp->origin_lv_name, lv->vg->name);
 		return 0;
 	}
 
@@ -2170,9 +2177,16 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 	if (!cow_has_min_chunks(lv->vg, lv->le_count, lp->chunk_size))
 		return_0;
 
-	if (lv_is_locked(org) || lv_is_pvmove(org) || lv_is_mirrored(org) || lv_is_cow(org)) {
+	if (lv_is_locked(org) ||
+	    lv_is_cache_type(org) ||
+	    lv_is_thin_type(org) ||
+	    lv_is_pvmove(org) ||
+	    lv_is_mirrored(org) ||
+	    lv_is_cow(org)) {
 		log_error("Unable to convert an LV into a snapshot of a %s LV.",
 			  lv_is_locked(org) ? "locked" :
+			  lv_is_cache_type(org) ? "cache type" :
+			  lv_is_thin_type(org) ? "thin type" :
 			  lv_is_pvmove(org) ? "pvmove" :
 			  lv_is_mirrored(org) ? "mirrored" :
 			  "snapshot");


