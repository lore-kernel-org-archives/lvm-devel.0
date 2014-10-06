From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:21 +0000 (UTC)
Subject: master - lvconvert: cache and thin conversion validation
Message-ID: <20141006133321.6CC5A60DDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=60d2a63368686d309c01f1e59d695d0ee8ec9153
Commit:        60d2a63368686d309c01f1e59d695d0ee8ec9153
Parent:        ee344f1a9ee8536eab235ea3d971f59ed769cdd5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 6 13:44:59 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:06 2014 +0200

lvconvert: cache and thin conversion validation

More test for supported conversion.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   28 ++++++++++++++++++++++++++--
 2 files changed, 27 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 980809c..5fc42d6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Fix detection of unsupported cache and thin pool lvconversions.
   Fix detection of unsupported lvconversion of cache to snapshot.
   Improve code for creation of cache and cache pool volumes.
   Check cluster-wide (not local) active status before removing LV.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1a5d559..36fafbe 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2802,13 +2802,18 @@ static int _lvconvert_pool(struct cmd_context *cmd,
 	}
 
 	if (lv_is_thin_pool(pool_lv) && (segtype_is_cache_pool(lp->segtype) || lp->cache)) {
-		log_error("Cannot convert thin pool volume %s as cache pool data volume.",
+		log_error("Can't convert thin pool LV %s.", display_lvname(pool_lv));
+		return 0;
+	}
+
+	if (lv_is_cache(pool_lv) && !segtype_is_thin_pool(lp->segtype)) {
+		log_error("Cached LV %s could be only converted into a thin pool volume.",
 			  display_lvname(pool_lv));
 		return 0;
 	}
 
 	if (lv_is_cache_pool(pool_lv) && (segtype_is_thin_pool(lp->segtype) || lp->thin)) {
-		log_error("Cannot convert cache pool %s as thin pool data volume.",
+		log_error("Cannot convert cache pool %s as pool data volume.",
 			  display_lvname(pool_lv));
 		return 0;
 	}
@@ -3250,6 +3255,25 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 		return ECMD_PROCESSED;
 	}
 
+	if (lp->cache) {
+		if (lv_is_thin_pool(lv))
+			lv = seg_lv(first_seg(lv), 0); /* cache _tdata */
+		if (!validate_lv_cache_create(NULL, lv))
+			return_ECMD_FAILED;
+	}
+
+	if (lp->thin) {
+		if (lv_is_cache_type(lv) ||
+		    lv_is_pool(lv) ||
+		    lv_is_thin_pool_data(lv) ||
+		    lv_is_thin_pool_metadata(lv)) {
+			log_error("Can't convert %s %s to external origin.",
+				  first_seg(lv)->segtype->name,
+				  display_lvname(lv));
+			return ECMD_FAILED;
+		}
+	}
+
 	if (arg_count(cmd, repair_ARG)) {
 		if (lv_is_pool(lv)) {
 			if (!_lvconvert_pool_repair(cmd, lv, lp))


