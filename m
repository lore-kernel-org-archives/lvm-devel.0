From: Milan Broz <mbroz@redhat.com>
Date: Fri, 13 Nov 2009 21:39:11 +0100
Subject: [PATCH] Fix pvmove region_size overflow for very large PVs.
In-Reply-To: <1258131620-31470-1-git-send-email-mbroz@redhat.com>
References: <1258131620-31470-1-git-send-email-mbroz@redhat.com>
Message-ID: <4AFDC3EF.6030502@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As usually, I forgot that we must support separate
loadable target module here, so duplicating the code is inevitable...
Milan
---

Fix pvmove region_size overflow for very large PVs.

Fixes problem reported in
https://www.redhat.com/archives/dm-devel/2009-November/msg00104.html

The region size multiplication can overflow when using 32bit integer.

(Also moving the warning message into verbose level.)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 WHATS_NEW             |    1 +
 lib/mirror/mirrored.c |   35 ++++++++++++++++++++++-------------
 2 files changed, 23 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b16bcb4..30e26d9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.55 -
 ===================================
+  Fix pvmove region_size oveflow for very large PVs.
   Fix lvcreate and lvresize processing of %PVS argument.
   Tidy some uses of arg_count and introduce arg_is_set.
   Export outnl and indent functions for modules.
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index e93ed0b..12e3041 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -280,6 +280,22 @@ static int _add_log(struct dev_manager *dm, struct lv_segment *seg,
 	return dm_tree_node_add_mirror_target_log(node, region_size, clustered, log_dlid, area_count, log_flags);
 }
 
+uint32_t _adjusted_mirror_region_size(uint32_t extent_size, uint32_t extents,
+				     uint32_t region_size)
+{
+	uint64_t region_max;
+
+	region_max = (1 << (ffs((int)extents) - 1)) * (uint64_t) extent_size;
+
+	if (region_max < UINT32_MAX && region_size > region_max) {
+		region_size = (uint32_t) region_max;
+		log_verbose("Using reduced mirror region size of %" PRIu32
+			    " sectors", region_size);
+	}
+
+	return region_size;
+}
+
 static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem,
 				struct cmd_context *cmd, void **target_state,
 				struct lv_segment *seg,
@@ -290,7 +306,7 @@ static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem
 	uint32_t area_count = seg->area_count;
 	unsigned start_area = 0u;
 	int mirror_status = MIRR_RUNNING;
-	uint32_t region_size, region_max;
+	uint32_t region_size;
 	int r;
 
 	if (!*target_state)
@@ -333,18 +349,11 @@ static int _mirrored_add_target_line(struct dev_manager *dm, struct dm_pool *mem
 			return 0;
 		}
 		region_size = seg->region_size;
-	} else {
-		/* Find largest power of 2 region size unit we can use */
-		region_max = (1 << (ffs((int)seg->area_len) - 1)) *
-		      seg->lv->vg->extent_size;
-
-		region_size = mirr_state->default_region_size;
-		if (region_max < region_size) {
-			region_size = region_max;
-			log_verbose("Using reduced mirror region size of %u sectors",
-				    region_size);
-		}
-	}
+
+	} else
+		region_size = _adjusted_mirror_region_size(seg->lv->vg->extent_size,
+							   seg->area_len,
+							   mirr_state->default_region_size);
 
 	if (!dm_tree_node_add_mirror_target(node, len))
 		return_0;



