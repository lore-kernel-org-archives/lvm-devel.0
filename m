From: David Teigland <teigland@sourceware.org>
Date: Fri, 11 Oct 2019 12:32:01 -0400
Subject: master - pvmove: remove some cmirror related code
Message-ID: <201910111632.x9BGW1Ct017878@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe16d296b058333fddd5102afbebf95a18f85468
Commit:        fe16d296b058333fddd5102afbebf95a18f85468
Parent:        df26b73b8e4355df7f6d4d664edad2b86991b352
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 11 11:12:11 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 11 11:31:42 2019 -0500

pvmove: remove some cmirror related code

which is no longer used
---
 lib/metadata/metadata-exported.h |    2 -
 lib/metadata/mirror.c            |   41 +-------------------------------------
 lib/mirror/mirrored.c            |   30 ---------------------------
 tools/pvmove.c                   |   14 +------------
 4 files changed, 2 insertions(+), 85 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 71e4c77..8239fed 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1152,8 +1152,6 @@ int is_temporary_mirror_layer(const struct logical_volume *lv);
 struct logical_volume * find_temporary_mirror(const struct logical_volume *lv);
 uint32_t lv_mirror_count(const struct logical_volume *lv);
 
-/* Remove CMIRROR_REGION_COUNT_LIMIT when http://bugzilla.redhat.com/682771 is fixed */
-#define CMIRROR_REGION_COUNT_LIMIT (256*1024 * 8)
 uint32_t adjusted_mirror_region_size(struct cmd_context *cmd,
 				     uint32_t extent_size, uint32_t extents,
 				     uint32_t region_size, int internal, int clustered);
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 8459457..75dc18c 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -161,8 +161,7 @@ uint32_t adjusted_mirror_region_size(struct cmd_context *cmd,
 				     uint32_t extent_size, uint32_t extents,
 				     uint32_t region_size, int internal, int clustered)
 {
-	uint64_t region_max, region_min;
-	uint32_t region_min_pow2;
+	uint64_t region_max;
 
 	region_max = (uint64_t) extents * extent_size;
 
@@ -176,44 +175,6 @@ uint32_t adjusted_mirror_region_size(struct cmd_context *cmd,
 				    display_size(cmd, region_size));
 	}
 
-#ifdef CMIRROR_REGION_COUNT_LIMIT
-	if (clustered) {
-		/*
-		 * The CPG code used by cluster mirrors can only handle a
-		 * payload of < 1MB currently.  (This deficiency is tracked by
-		 * http://bugzilla.redhat.com/682771.)  The region size for cluster
-		 * mirrors must be restricted in such a way as to limit the
-		 * size of the bitmap to < 512kB, because there are two bitmaps
-		 * which get sent around during checkpointing while a cluster
-		 * mirror starts up.  Ergo, the number of regions must not
-		 * exceed 512k * 8.  We also need some room for the other
-		 * checkpointing structures as well, so we reduce by another
-		 * factor of two.
-		 *
-		 * This code should be removed when the CPG restriction is
-		 * lifted.
-		 */
-		region_min = region_max / CMIRROR_REGION_COUNT_LIMIT;
-		if (region_min > UINT32_MAX / 2) {
-			log_error("Can't find proper region size for too big mirror.");
-			return 0;
-		}
-		region_min_pow2 = UINT64_C(1) << (1 + 31 - clz(region_min));
-
-		if (region_size < region_min_pow2) {
-			if (internal)
-				log_print_unless_silent("Increasing mirror region size from %s to %s",
-							display_size(cmd, region_size),
-							display_size(cmd, region_min_pow2));
-			else
-				log_verbose("Increasing mirror region size from %s to %s",
-					    display_size(cmd, region_size),
-					    display_size(cmd, region_min_pow2));
-			region_size = region_min_pow2;
-		}
-	}
-#endif /* CMIRROR_REGION_COUNT_LIMIT */
-
 	return region_size;
 }
 
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index aaaa0b8..75893a6 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -429,40 +429,10 @@ static int _mirrored_target_present(struct cmd_context *cmd,
 		      sscanf(vsn, "%u.%u.%u", &maj2, &min2, &patchlevel2) == 3 &&
 		      maj2 == 4 && min2 == 5 && patchlevel2 == 0)))	/* RHEL4U3 */
 			_block_on_error_available = 1;
-
-#ifdef CMIRRORD_PIDFILE
-		/*
-		 * The cluster mirror log daemon must be running,
-		 * otherwise, the kernel module will fail to make
-		 * contact.
-		 */
-		if (cmirrord_is_running()) {
-			struct utsname uts;
-			unsigned kmaj, kmin, krel;
-			/*
-			 * The dm-log-userspace module was added to the
-			 * 2.6.31 kernel.
-			 */
-			if (!uname(&uts) &&
-			    (sscanf(uts.release, "%u.%u.%u", &kmaj, &kmin, &krel) == 3) &&
-			    KERNEL_VERSION(kmaj, kmin, krel) < KERNEL_VERSION(2, 6, 31)) {
-				if (module_present(cmd, MODULE_NAME_LOG_CLUSTERED))
-				_mirror_attributes |= MIRROR_LOG_CLUSTERED;
-			} else if (module_present(cmd, MODULE_NAME_LOG_USERSPACE))
-				_mirror_attributes |= MIRROR_LOG_CLUSTERED;
-
-			if (!(_mirror_attributes & MIRROR_LOG_CLUSTERED))
-				log_verbose("Cluster mirror log module is not available.");
-		} else
-			log_verbose("Cluster mirror log daemon is not running.");
-#else
-		log_verbose("Cluster mirror log daemon not included in build.");
-#endif
 	}
 
 	/*
 	 * Check only for modules if atttributes requested and no previous check.
-	 * FIXME: Fails incorrectly if cmirror was built into kernel.
 	 */
 	if (attributes)
 		*attributes = _mirror_attributes;
diff --git a/tools/pvmove.c b/tools/pvmove.c
index ebbdb4c..674decf 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -40,27 +40,15 @@ struct pvmove_params {
 static int _pvmove_target_present(struct cmd_context *cmd, int clustered)
 {
 	const struct segment_type *segtype;
-	unsigned attr = 0;
 	int found = 1;
-	static int _clustered_found = -1;
-
-	if (clustered && _clustered_found >= 0)
-		return _clustered_found;
 
 	if (!(segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_MIRROR)))
 		return_0;
 
 	if (activation() && segtype->ops->target_present &&
-	    !segtype->ops->target_present(cmd, NULL, clustered ? &attr : NULL))
+	    !segtype->ops->target_present(cmd, NULL, NULL))
 		found = 0;
 
-	if (activation() && clustered) {
-		if (found && (attr & MIRROR_LOG_CLUSTERED))
-			_clustered_found = found = 1;
-		else
-			_clustered_found = found = 0;
-	}
-
 	return found;
 }
 


