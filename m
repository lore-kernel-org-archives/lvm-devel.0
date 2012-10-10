From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 10 Oct 2012 19:22:58 +0000 (UTC)
Subject: master - thin: support non power of 2 chunk size
Message-ID: <20121010192258.9A25FAB3BA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca09c9ab4c082c1b3291748630a0133fb5f8f780
Commit:        ca09c9ab4c082c1b3291748630a0133fb5f8f780
Parent:        b296e30f98dc0bab12e8a184f0a93b69cbe291f8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 2 14:37:51 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 10 21:21:00 2012 +0200

thin: support non power of 2 chunk size

Support thin chunk size with multiple of 64KiB if user has
thin-pool target version at least 1.2.
---
 WHATS_NEW         |    1 +
 lib/thin/thin.c   |   13 ++++++++++---
 man/lvcreate.8.in |    5 ++++-
 tools/lvchange.c  |    8 +++++++-
 tools/lvcreate.c  |   22 +++++++++++++++++-----
 5 files changed, 39 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ed6464f..5a3364a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Allow non power of 2 thin chunk sizes if thin pool driver supports that.
   Allow limited metadata changes when PVs are missing via [vg|lv]change.
   Do not start dmeventd for lvchange --resync when monitoring is off.
   Remove ExecStartPost with pvscan --cache from lvm2-lvmetad.service.
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 8aa8121..fd0c117 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -241,6 +241,13 @@ static int _thin_pool_add_target_line(struct dev_manager *dm,
 	if (!_thin_target_present(cmd, seg, &attr))
 		return_0;
 
+	if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
+	    (seg->chunk_size & (seg->chunk_size - 1))) {
+		log_error("Thin pool target does not support %uKiB chunk size "
+			  "(needs kernel >= 3.5).", seg->chunk_size / 2);
+		return 0;
+	}
+
 	if (!laopts->real_pool) {
 		if (!(pool_dlid = build_dm_uuid(mem, seg->lv->lvid.s, "tpool"))) {
 			log_error("Failed to build uuid for thin pool LV %s.", seg->pool_lv->name);
@@ -551,13 +558,13 @@ static int _thin_target_present(struct cmd_context *cmd,
 		else
 		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
 			log_debug("Target " THIN_MODULE " does not support external origins.");
-#if 0
-		if (maj >=1 && min >= 1)
+
+		if (maj >=1 && min >= 2)
 			_attrs |= THIN_FEATURE_BLOCK_SIZE;
 		else
 		/* FIXME Log this as WARNING later only if the user asked for the feature to be used but it's not present */
 			log_debug("Target " THIN_MODULE " does not support non power of 2 block sizes.");
-#endif
+
 		_checked = 1;
 	}
 
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index a87136a..0c39278 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -129,10 +129,13 @@ activate only on the local node.
 Gives the size of chunk for snapshot and thin pool logical volumes.
 For snapshots the value must be power of 2 between 4KiB and 512KiB
 and the default value is 4.
-For thin pools the value must be power of 2 between 64KiB and
+For thin pools the value must be between 64KiB and
 1048576KiB and the default value starts with 64 and scales
 up to fit the pool metadata size within 128MB,
 if the poolmetadata size is not specified.
+Older dm thin pool target version (<1.2) requires the value to be power of 2.
+The newer version requires to be the multiple of 64KiB, however discard is
+not supported for non power of 2 values.
 Default unit is in kilobytes.
 .TP
 .BR \-C ", " \-\-contiguous " {" \fIy | \fIn }
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 8fb8d3a..b787672 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -105,7 +105,13 @@ static int lvchange_pool_update(struct cmd_context *cmd,
 	if (arg_count(cmd, discards_ARG)) {
 		discards = (thin_discards_t) arg_uint_value(cmd, discards_ARG, THIN_DISCARDS_IGNORE);
 		if (discards != first_seg(lv)->discards) {
-			if (((discards == THIN_DISCARDS_IGNORE) ||
+			if ((discards != THIN_DISCARDS_IGNORE) &&
+				 (first_seg(lv)->chunk_size &
+				  (first_seg(lv)->chunk_size - 1)))
+				log_error("Cannot change discards state for "
+					  "logical volume \"%s\" "
+					  "with non power of 2 chunk size.", lv->name);
+			else if (((discards == THIN_DISCARDS_IGNORE) ||
 			     (first_seg(lv)->discards == THIN_DISCARDS_IGNORE)) &&
 			    lv_is_active(lv))
 				log_error("Cannot change discards state for active "
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 45a117f..7d01685 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -684,6 +684,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	struct arg_value_group_list *current_group;
 	const char *segtype_str;
 	const char *tag;
+	unsigned attr = 0;
 
 	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
@@ -799,7 +800,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	}
 
 	if (activation() && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
+	    !lp->segtype->ops->target_present(cmd, NULL, &attr)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;
@@ -851,14 +852,25 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 			lp->chunk_size = arg_uint_value(cmd, chunksize_ARG,
 							DM_THIN_MIN_DATA_BLOCK_SIZE);
 			if ((lp->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE) ||
-			    (lp->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE) ||
-			    (lp->chunk_size & (lp->chunk_size - 1))) {
-				log_error("Chunk size must be a power of 2 in the "
-					  "range %uK to %uK",
+			    (lp->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE)) {
+				log_error("Chunk size must be in the range %uK to %uK",
 					  (DM_THIN_MIN_DATA_BLOCK_SIZE / 2),
 					  (DM_THIN_MAX_DATA_BLOCK_SIZE / 2));
 				return 0;
 			}
+			if (!(attr & THIN_FEATURE_BLOCK_SIZE) &&
+			    (lp->chunk_size & (lp->chunk_size - 1))) {
+				log_error("Chunk size must be a power of 2 for this thin target version.");
+				return 0;
+			} else if (lp->chunk_size & (DM_THIN_MIN_DATA_BLOCK_SIZE - 1)) {
+				log_error("Chunk size must be multiple of %uK.",
+					  DM_THIN_MIN_DATA_BLOCK_SIZE / 2);
+				return 0;
+			} else if ((lp->discards != THIN_DISCARDS_IGNORE) &&
+				   (lp->chunk_size & (lp->chunk_size - 1))) {
+				log_warn("WARNING: Using discards ignore for chunk size non power of 2.");
+				lp->discards = THIN_DISCARDS_IGNORE;
+			}
 		}
 		log_verbose("Setting chunksize to %u sectors.", lp->chunk_size);
 


