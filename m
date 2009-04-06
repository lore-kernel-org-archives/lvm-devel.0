From: Milan Broz <mbroz@redhat.com>
Date: Mon, 06 Apr 2009 10:30:51 +0200
Subject: [PATCH] fix allocation handle memory pool leak in mirror code
Message-ID: <49D9BDBB.1070506@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix alloc memory pool leak.

Call the alloc_destory call always after finishing operation
with handle otherwise it will leak a memory pool.

Also fix return code in lv_extend.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c |   14 +++++---------
 lib/metadata/mirror.c   |   22 +++++++++++++++-------
 2 files changed, 20 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 991d63c..ec9e19e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1608,16 +1608,12 @@ int lv_extend(struct logical_volume *lv,
 				    extents, allocatable_pvs, alloc, NULL)))
 		return_0;
 
-	if (mirrors < 2) {
-		if (!lv_add_segment(ah, 0, ah->area_count, lv, segtype, stripe_size,
-			    status, 0, NULL))
-			goto_out;
-	} else {
-		if (!_lv_extend_mirror(ah, lv, extents, 0))
-			return_0;
-	}
+	if (mirrors < 2)
+		r = lv_add_segment(ah, 0, ah->area_count, lv, segtype,
+				   stripe_size, status, 0, NULL);
+	else
+		r = _lv_extend_mirror(ah, lv, extents, 0);
 
-      out:
 	alloc_destroy(ah);
 	return r;
 }
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index c7f16df..b98892b 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -1160,6 +1160,7 @@ int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
 	const struct segment_type *segtype;
 	struct dm_list *parallel_areas;
 	uint32_t adjusted_region_size;
+	int r = 1;
 
 	if (!(parallel_areas = build_parallel_areas_from_lv(cmd, lv)))
 		return_0;
@@ -1180,10 +1181,11 @@ int add_mirrors_to_segments(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (!lv_add_mirror_areas(ah, lv, 0, adjusted_region_size)) {
 		log_error("Failed to add mirror areas to %s", lv->name);
-		return 0;
+		r = 0;
 	}
 
-	return 1;
+	alloc_destroy(ah);
+	return r;
 }
 
 /*
@@ -1349,6 +1351,7 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 	int in_sync;
 	struct logical_volume *log_lv;
 	struct lvinfo info;
+	int r = 0;
 
 	/* Unimplemented features */
 	if (log_count > 1) {
@@ -1404,13 +1407,15 @@ int add_mirror_log(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (!(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count,
 					  region_size, alloc, in_sync)))
-		return_0;
+		goto_out;
 
 	if (!attach_mirror_log(first_seg(lv), log_lv))
-		return_0;
+		goto_out;
 
+	r = 1;
+out:
 	alloc_destroy(ah);
-	return 1;
+	return r;
 }
 
 /*
@@ -1455,8 +1460,10 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 	 */
 	if (log_count &&
 	    !(log_lv = _set_up_mirror_log(cmd, ah, lv, log_count, region_size,
-					  alloc, mirror_in_sync())))
-		return_0;
+					  alloc, mirror_in_sync()))) {
+		stack;
+		goto out_remove_imgs;
+	}
 
 	/* The log initialization involves vg metadata commit.
 	   So from here on, if failure occurs, the log must be explicitly
@@ -1503,6 +1510,7 @@ int add_mirror_images(struct cmd_context *cmd, struct logical_volume *lv,
 			  "abandoned log LV before retrying.");
 
   out_remove_imgs:
+	alloc_destroy(ah);
 	return 0;
 }
 



