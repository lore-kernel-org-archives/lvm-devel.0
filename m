From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 27 May 2016 13:47:47 +0000 (UTC)
Subject: master - lvstatus: enhance seg_status to handle snapshot
Message-ID: <20160527134747.766BB6075A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f7f395667ee5446e9127fe772deb46f3e4f3812e
Commit:        f7f395667ee5446e9127fe772deb46f3e4f3812e
Parent:        067c0a23e5c0d41e92551c2d3e40bcaf4aeb1488
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 25 16:14:46 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 27 15:47:24 2016 +0200

lvstatus: enhance seg_status to handle snapshot

Add more code to properly store status for snapshot segment
maintaining lvm2 fiction of COW and snapshot internal volumes.

The key issue here is however not though-through reporting
logic - as there is no single answer for whole line state.
It not counting with layer and we may need few more ioctl to
cover all reporting needs depending upon what is actually
needed.

In reality we need to 'cache' more ioctl status queries for
individual LVs and their segments (so they checked at most once).

The other 'hard' topic for conversion is mirror segment handling.

Also we definitelly need to relocate some logic into segment's methods,
yet it might be complex as we have not clear border between targets.

TODO: define more clearly how are reporting fields defined in case
we 'stack' volumes like   -   cache of stacked  thin LV snapshot origin.
---
 WHATS_NEW                  |    1 +
 lib/activate/activate.c    |   30 +++++++++++++++++++++++++++++-
 lib/activate/dev_manager.c |   35 ++++++++++++++++++++++-------------
 3 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 48e0109..2265c9b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.155 - 
 ================================
+  Enhance internal seg_status handling to understand snapshots better.
   When refresh failed in suspend, call resume upon error path.
   Support passthrough cache mode when waiting for clean cache.
   Check cache status only for 'in-use' cache pools.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index d5e416d..2b22eec 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -691,8 +691,36 @@ static int _lv_info(struct cmd_context *cmd, const struct logical_volume *lv,
 			use_layer = 1;
 	}
 
-	if (seg_status)
+	if (seg_status) {
+		/* TODO: for now it's mess with seg_status */
 		seg_status->seg = seg;
+		if (lv_is_merging_cow(lv)) {
+			if (lv_has_target_type(cmd->mem, origin_from_cow(lv), NULL, TARGET_NAME_SNAPSHOT_MERGE)) {
+				/*
+				 * When the snapshot-merge has not yet started, query COW LVs as is.
+				 * When merge is in progress, query merging origin LV instead.
+				 * COW volume is already mapped as error target in this case.
+				 */
+				lv = origin_from_cow(lv);
+				seg_status->seg = first_seg(lv);
+				log_debug_activation("Snapshot merge is in progress, querying status of %s instead.",
+						     display_lvname(lv));
+			}
+		} else if (!use_layer && lv_is_origin(lv) && !lv_is_external_origin(lv)) {
+			/*
+			 * Query status for 'layered' (-real) device most of the time,
+			 * only when snapshot merge started, query its progress.
+			 * TODO: single LV may need couple status to be exposed at once....
+			 *       but this needs more logical background
+			 */
+			if (!lv_is_merging_origin(lv) ||
+			    !lv_has_target_type(cmd->mem, origin_from_cow(lv), NULL, TARGET_NAME_SNAPSHOT_MERGE))
+				use_layer = 1;
+		} else if (lv_is_cow(lv)) {
+			/* Hadle fictional lvm2 snapshot and query snapshotX volume */
+			seg_status->seg = find_snapshot(lv);
+		}
+	}
 
 	if (!dev_manager_info(cmd, lv,
 			      (use_layer) ? lv_layer(lv) : NULL,
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 63cfe9c..51f1a9a 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -127,6 +127,7 @@ static int _get_segment_status_from_target_params(const char *target_name,
 	struct segment_type *segtype;
 
 	seg_status->type = SEG_STATUS_UNKNOWN;
+
 	/*
 	 * TODO: Add support for other segment types too!
 	 * The segment to report status for must be properly
@@ -134,19 +135,27 @@ static int _get_segment_status_from_target_params(const char *target_name,
 	 * linear/striped, old snapshots and raids have proper
 	 * segment selected for status!
 	 */
-	if (strcmp(target_name, TARGET_NAME_CACHE) &&
-	    strcmp(target_name, TARGET_NAME_THIN_POOL) &&
-	    strcmp(target_name, TARGET_NAME_THIN))
-		return 1;
+	if (!strcmp(target_name, TARGET_NAME_SNAPSHOT_MERGE) &&
+	    lv_is_merging_origin(seg_status->seg->lv)) {
+		/* Snapshot merge has started, check snapshot status */
+		if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, TARGET_NAME_SNAPSHOT)))
+			return_0;
+	} else {
+		if (strcmp(target_name, TARGET_NAME_CACHE) &&
+		    strcmp(target_name, TARGET_NAME_SNAPSHOT) &&
+		    strcmp(target_name, TARGET_NAME_THIN_POOL) &&
+		    strcmp(target_name, TARGET_NAME_THIN))
+			return 1; /* TODO: Do not know how to handle yet */
 
-	if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name)))
-		return_0;
+		if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name)))
+			return_0;
 
-	if (segtype != seg_status->seg->segtype) {
-		log_error(INTERNAL_ERROR "_get_segment_status_from_target_params: "
-			  "segment type %s found does not match expected segment type %s",
-			   segtype->name, seg_status->seg->segtype->name);
-		return 0;
+		if (segtype != seg_status->seg->segtype) {
+			log_error(INTERNAL_ERROR "_get_segment_status_from_target_params: "
+				  "segment type %s found does not match expected segment type %s",
+				  segtype->name, seg_status->seg->segtype->name);
+			return 0;
+		}
 	}
 
 	if (segtype_is_cache(segtype)) {


