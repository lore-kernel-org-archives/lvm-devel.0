From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Dec 2016 22:38:21 +0000 (UTC)
Subject: master - validation: rework segment validation
Message-ID: <20161222223821.B4C316119F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9491ab41cd61501039027fa5d7cfe89f78504132
Commit:        9491ab41cd61501039027fa5d7cfe89f78504132
Parent:        eacff5c189d0cb3c6ac17a8f0af0fe440f12c4b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 20 15:59:11 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 22 23:37:07 2016 +0100

validation: rework segment validation

Move individual segment validation to a separate function
executed for 'complete_vg'.

Move some 'extra' validation bits from 'raid' validation to global
segtype validation (so extending existing normal validation)

TODO: still some test are left to be moved.
Reduce some duplication in validation process - there are still
some left thought so still room for improving overal speed.
---
 WHATS_NEW            |    1 +
 lib/metadata/merge.c |  527 ++++++++++++++++++++++----------------------------
 2 files changed, 233 insertions(+), 295 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fa8f5c3..6ab385d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Extend validation of metadata processing.
   Enable usage of cached volumes as snapshot origin LV.
   Fix displayed lv name when splitting snapshot (2.02.146).
   Warn about command not making metadata backup just once per command.
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 947513b..a1c9455 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -71,6 +71,13 @@ int lv_merge_segments(struct logical_volume *lv)
 	if (error_count++ > ERROR_MAX)	\
 		goto out
 
+#define seg_error(msg) { \
+		log_error("LV %s, segment %u invalid: %s for %s segment.", \
+			  seg->lv->name, seg_count, (msg), lvseg_name(seg)); \
+		if ((*error_count)++ > ERROR_MAX) \
+			return; \
+	}
+
 /*
  * RAID segment property checks.
  *
@@ -188,44 +195,10 @@ static void _check_non_raid_seg_members(struct lv_segment *seg, int *error_count
 {
 	if (seg->origin) /* snap and thin */
 		raid_seg_error("non-zero origin LV");
-	if (seg->indirect_origin) /* thin */
-		raid_seg_error("non-zero indirect_origin LV");
-	if (seg->merge_lv) /* thin */
-		raid_seg_error("non-zero merge LV");
 	if (seg->cow) /* snap */
 		raid_seg_error("non-zero cow LV");
 	if (!dm_list_empty(&seg->origin_list)) /* snap */
 		raid_seg_error("non-zero origin_list");
-	if (seg->log_lv)
-		raid_seg_error("non-zero log LV");
-	if (seg->segtype_private)
-		raid_seg_error("non-zero segtype_private");
-	/* thin members */
-	if (seg->metadata_lv)
-		raid_seg_error("non-zero metadata LV");
-	if (seg->transaction_id)
-		raid_seg_error("non-zero transaction_id");
-	if (seg->zero_new_blocks)
-		raid_seg_error("non-zero zero_new_blocks");
-	if (seg->discards)
-		raid_seg_error("non-zero discards");
-	if (!dm_list_empty(&seg->thin_messages))
-		raid_seg_error("non-zero thin_messages list");
-	if (seg->external_lv)
-		raid_seg_error("non-zero external LV");
-	if (seg->pool_lv)
-		raid_seg_error("non-zero pool LV");
-	if (seg->device_id)
-		raid_seg_error("non-zero device_id");
-	/* cache members */
-	if (seg->cache_mode)
-		raid_seg_error("non-zero cache_mode");
-	if (seg->policy_name)
-		raid_seg_error("non-zero policy_name");
-	if (seg->policy_settings)
-		raid_seg_error("non-zero policy_settings");
-	if (seg->cleaner_policy)
-		raid_seg_error("non-zero cleaner_policy");
 	/* replicator members (deprecated) */
 	if (seg->replicator)
 		raid_seg_error("non-zero replicator");
@@ -249,9 +222,6 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 	uint32_t area_len, s;
 
 	/* General checks applying to all RAIDs */
-	if (!seg_is_raid(seg))
-		raid_seg_error("erroneous RAID check");
-
 	if (!seg->area_count)
 		raid_seg_error("zero area count");
 
@@ -276,9 +246,6 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 				return;
 	}
 
-	if (seg->chunk_size)
-		raid_seg_error_val("non-zero chunk_size", seg->chunk_size);
-
 	/* FIXME: should we check any non-RAID segment struct members at all? */
 	_check_non_raid_seg_members(seg, error_count);
 
@@ -329,6 +296,167 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 }
 /* END: RAID segment property checks. */
 
+static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
+			      unsigned seg_count, int *error_count)
+{
+	struct lv_segment *seg2;
+
+	if (lv_is_mirror_image(lv) &&
+	    (!(seg2 = find_mirror_seg(seg)) || !seg_is_mirrored(seg2)))
+		seg_error("mirror image is not mirrored");
+
+	if (seg_is_cache(seg)) {
+		if (!lv_is_cache(lv))
+			seg_error("is not flagged as cache LV");
+
+		if (!seg->pool_lv) {
+			seg_error("is missing cache pool LV");
+		} else if (!lv_is_cache_pool(seg->pool_lv))
+			seg_error("is not referencing cache pool LV");
+	} else { /* !cache */
+		if (seg->cleaner_policy)
+			seg_error("sets cleaner_policy");
+	}
+
+	if (seg_is_cache_pool(seg)) {
+		if (!dm_list_empty(&seg->lv->segs_using_this_lv)) {
+			switch (seg->cache_mode) {
+			case CACHE_MODE_WRITETHROUGH:
+			case CACHE_MODE_WRITEBACK:
+			case CACHE_MODE_PASSTHROUGH:
+				break;
+			default:
+				seg_error("has invalid cache's feature flag")
+			}
+			if (!seg->policy_name)
+				seg_error("is missing cache policy name");
+		}
+	} else { /* !cache_pool */
+		if (seg->cache_mode)
+			seg_error("sets cache mode");
+		if (seg->policy_name)
+			seg_error("sets policy name");
+		if (seg->policy_settings)
+			seg_error("sets policy settings");
+	}
+
+	if (!seg_can_error_when_full(seg) && lv_is_error_when_full(lv))
+		seg_error("does not support flag ERROR_WHEN_FULL.");
+
+	if (seg_is_mirrored(seg)) {
+		/* Check mirror log - which is attached to the mirrored seg */
+		if (seg->log_lv) {
+			if (!lv_is_mirror_log(seg->log_lv))
+				seg_error("log LV is not a mirror log");
+
+			if (!(seg2 = first_seg(seg->log_lv)) || (find_mirror_seg(seg2) != seg))
+				seg_error("log LV does not point back to mirror segment");
+		}
+	} else { /* !mirrored */
+		if (seg->log_lv) {
+			if (lv_is_raid_image(lv))
+				seg_error("log LV is not a mirror log or a RAID image");
+		}
+	}
+
+	if (seg_is_raid(seg))
+		_check_raid_seg(seg, error_count);
+
+	if (seg_is_pool(seg)) {
+		if ((seg->area_count != 1) || (seg_type(seg, 0) != AREA_LV)) {
+			seg_error("is missing a pool data LV");
+		} else if (!(seg2 = first_seg(seg_lv(seg, 0))) || (find_pool_seg(seg2) != seg))
+			seg_error("data LV does not refer back to pool LV");
+
+		if (!seg->metadata_lv) {
+			seg_error("is missing a pool metadata LV");
+		} else if (!(seg2 = first_seg(seg->metadata_lv)) || (find_pool_seg(seg2) != seg))
+			seg_error("metadata LV does not refer back to pool LV");
+
+		if (!validate_pool_chunk_size(lv->vg->cmd, seg->segtype, seg->chunk_size))
+			seg_error("has invalid chunk size.");
+	} else { /* !thin_pool && !cache_pool */
+		if (seg->metadata_lv)
+			seg_error("must not have pool metadata LV set");
+	}
+
+	if (seg_is_thin_pool(seg)) {
+		if (!lv_is_thin_pool(lv))
+			seg_error("is not flagged as thin pool LV");
+
+		if (lv_is_thin_volume(lv))
+			seg_error("is a thin volume that must not contain thin pool segment");
+	} else { /* !thin_pool */
+		if (seg->zero_new_blocks)
+			seg_error("sets zero_new_blocks");
+		if (seg->discards)
+			seg_error("sets discards");
+		if (!dm_list_empty(&seg->thin_messages))
+			seg_error("sets thin_messages list");
+	}
+
+	if (seg_is_thin_volume(seg)) {
+		if (!lv_is_thin_volume(lv))
+			seg_error("is not flagged as thin volume LV");
+
+		if (lv_is_thin_pool(lv))
+			seg_error("is a thin pool that must not contain thin volume segment");
+
+		if (!seg->pool_lv) {
+			seg_error("is missing thin pool LV");
+		} else if (!lv_is_thin_pool(seg->pool_lv))
+			seg_error("is not referencing thin pool LV");
+
+		if (seg->device_id > DM_THIN_MAX_DEVICE_ID)
+			seg_error("has too large device id");
+
+		if (seg->external_lv &&
+		    !lv_is_external_origin(seg->external_lv))
+			seg_error("external LV is not flagged as a external origin LV");
+
+		if (seg->merge_lv) {
+			if (!lv_is_thin_volume(seg->merge_lv))
+				seg_error("merge LV is not flagged as a thin LV");
+
+			if (!lv_is_merging_origin(seg->merge_lv))
+				seg_error("merge LV is not flagged as merging");
+		}
+	} else { /* !thin */
+		if (seg->device_id)
+			seg_error("sets device_id");
+		if (seg->external_lv)
+			seg_error("sets external LV");
+		if (seg->merge_lv)
+			seg_error("sets merge LV");
+		if (seg->indirect_origin)
+			seg_error("sets indirect_origin LV");
+	}
+
+	/* Some multi-seg vars excluded here */
+	if (!seg_is_cache(seg) &&
+	    !seg_is_thin_volume(seg)) {
+		if (seg->pool_lv)
+			seg_error("sets pool LV");
+	}
+
+	if (!seg_is_pool(seg) &&
+	    !seg_is_snapshot(seg)) {
+		if (seg->chunk_size)
+			seg_error("sets chunk_size");
+	}
+
+	if (!seg_is_thin_pool(seg) &&
+	    !seg_is_thin_volume(seg)) {
+		if (seg->transaction_id)
+			seg_error("sets transaction_id");
+	}
+
+	if (!seg_unknown(seg)) {
+		if (seg->segtype_private)
+			seg_error("set segtype_private");
+	}
+}
+
 /*
  * Verify that an LV's segments are consecutive, complete and don't overlap.
  */
@@ -336,7 +464,7 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 {
 	struct lv_segment *seg, *seg2;
 	uint32_t le = 0;
-	unsigned seg_count = 0, seg_found;
+	unsigned seg_count = 0, seg_found, external_lv_found = 0;
 	uint32_t area_multiplier, s;
 	struct seg_list *sl;
 	struct glv_list *glvl;
@@ -344,80 +472,15 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 	struct replicator_site *rsite;
 	struct replicator_device *rdev;
 
-	/* Check LV flags match first segment type */
-	if (complete_vg) {
-		if (lv_is_thin_volume(lv)) {
-			if (dm_list_size(&lv->segments) != 1) {
-				log_error("LV %s is thin volume without exactly one segment.",
-					  lv->name);
-				inc_error_count;
-			} else if (!seg_is_thin_volume(first_seg(lv))) {
-				log_error("LV %s is thin volume without first thin volume segment.",
-					  lv->name);
-				inc_error_count;
-			}
-		}
-
-		if (lv_is_thin_pool(lv)) {
-			if (dm_list_size(&lv->segments) != 1) {
-				log_error("LV %s is thin pool volume without exactly one segment.",
-					  lv->name);
-				inc_error_count;
-			} else if (!seg_is_thin_pool(first_seg(lv))) {
-				log_error("LV %s is thin pool without first thin pool segment.",
-					  lv->name);
-				inc_error_count;
-			}
-		}
+	dm_list_iterate_items(seg, &lv->segments) {
+		seg_count++;
 
-		if (lv_is_pool_data(lv) &&
-		    (!(seg2 = first_seg(lv)) || !(seg2 = find_pool_seg(seg2)) ||
-		     seg2->area_count != 1 || seg_type(seg2, 0) != AREA_LV ||
-		     seg_lv(seg2, 0) != lv)) {
-			log_error("LV %s: segment 1 pool data LV does not point back to same LV",
-				  lv->name);
+		if (seg->lv != lv) {
+			log_error("LV %s invalid: segment %u is referencing different LV.",
+				  lv->name, seg_count);
 			inc_error_count;
 		}
 
-		if (lv_is_pool_metadata(lv)) {
-			if (!(seg2 = first_seg(lv)) || !(seg2 = find_pool_seg(seg2)) ||
-			    seg2->metadata_lv != lv) {
-				log_error("LV %s: segment 1 pool metadata LV does not point back to same LV",
-					  lv->name);
-				inc_error_count;
-			}
-			if (lv_is_thin_pool_metadata(lv) &&
-			    !strstr(lv->name, "_tmeta")) {
-				log_error("LV %s: thin pool metadata LV does not use _tmeta",
-					  lv->name);
-				inc_error_count;
-			} else if (lv_is_cache_pool_metadata(lv) &&
-				   !strstr(lv->name, "_cmeta")) {
-				log_error("LV %s: cache pool metadata LV does not use _cmeta",
-					  lv->name);
-				inc_error_count;
-			}
-		}
-
-		if (lv_is_external_origin(lv)) {
-			seg_found = 0;
-			dm_list_iterate_items(sl, &lv->segs_using_this_lv)
-				if (sl->seg->external_lv == lv)
-					seg_found++;
-			if (seg_found != lv->external_count) {
-				log_error("LV %s: external origin count does not match.",
-					  lv->name);
-				inc_error_count;
-			}
-		}
-	}
-
-	dm_list_iterate_items(seg, &lv->segments) {
-		seg_count++;
-
-		if (complete_vg && seg_is_raid(seg))
-			 _check_raid_seg(seg, &error_count);
-		
 		if (seg->le != le) {
 			log_error("LV %s invalid: segment %u should begin at "
 				  "LE %" PRIu32 " (found %" PRIu32 ").",
@@ -435,186 +498,6 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 			inc_error_count;
 		}
 
-		if (lv_is_error_when_full(lv) &&
-		    !seg_can_error_when_full(seg)) {
-			log_error("LV %s: segment %u (%s) does not support flag "
-				  "ERROR_WHEN_FULL.", lv->name, seg_count, seg->segtype->name);
-			inc_error_count;
-		}
-
-		if (complete_vg && seg->log_lv &&
-		    !seg_is_mirrored(seg) && lv_is_raid_image(lv)) {
-			log_error("LV %s: segment %u log LV %s is not a "
-				  "mirror log or a RAID image",
-				  lv->name, seg_count, seg->log_lv->name);
-			inc_error_count;
-		}
-
-		/*
-		 * Check mirror log - which is attached to the mirrored seg
-		 */
-		if (complete_vg && seg->log_lv && seg_is_mirrored(seg)) {
-			if (!lv_is_mirror_log(seg->log_lv)) {
-				log_error("LV %s: segment %u log LV %s is not "
-					  "a mirror log",
-					  lv->name, seg_count, seg->log_lv->name);
-				inc_error_count;
-			}
-
-			if (!(seg2 = first_seg(seg->log_lv)) ||
-			    find_mirror_seg(seg2) != seg) {
-				log_error("LV %s: segment %u log LV does not "
-					  "point back to mirror segment",
-					  lv->name, seg_count);
-				inc_error_count;
-			}
-		}
-
-		if (complete_vg && lv_is_mirror_image(lv)) {
-			if (!(seg2 = find_mirror_seg(seg)) ||
-			    !seg_is_mirrored(seg2)) {
-				log_error("LV %s: segment %u mirror image "
-					  "is not mirrored",
-					  lv->name, seg_count);
-				inc_error_count;
-			}
-		}
-
-		/* Check the various thin segment types */
-		if (complete_vg) {
-			if (seg_is_thin_pool(seg)) {
-				if (!lv_is_thin_pool(lv)) {
-					log_error("LV %s is missing thin pool flag for segment %u",
-						  lv->name, seg_count);
-					inc_error_count;
-				}
-
-				if (lv_is_thin_volume(lv)) {
-					log_error("LV %s is a thin volume that must not contain thin pool segment %u",
-						  lv->name, seg_count);
-					inc_error_count;
-				}
-
-			}
-			if (seg_is_cache_pool(seg) &&
-			    !dm_list_empty(&seg->lv->segs_using_this_lv)) {
-				switch (seg->cache_mode) {
-				case CACHE_MODE_WRITETHROUGH:
-				case CACHE_MODE_WRITEBACK:
-				case CACHE_MODE_PASSTHROUGH:
-					break;
-				default:
-					log_error("LV %s has invalid cache's feature flag.",
-						  lv->name);
-					inc_error_count;
-				}
-				if (!seg->policy_name) {
-					log_error("LV %s is missing cache policy name.", lv->name);
-					inc_error_count;
-				}
-			}
-			if (seg_is_pool(seg)) {
-				if (seg->area_count != 1 ||
-				    seg_type(seg, 0) != AREA_LV) {
-					log_error("LV %s: %s segment %u is missing a pool data LV",
-						  lv->name, seg->segtype->name, seg_count);
-					inc_error_count;
-				} else if (!(seg2 = first_seg(seg_lv(seg, 0))) || find_pool_seg(seg2) != seg) {
-					log_error("LV %s: %s segment %u data LV does not refer back to pool LV",
-						  lv->name, seg->segtype->name, seg_count);
-					inc_error_count;
-				}
-
-				if (!seg->metadata_lv) {
-					log_error("LV %s: %s segment %u is missing a pool metadata LV",
-						  lv->name, seg->segtype->name, seg_count);
-					inc_error_count;
-				} else if (!(seg2 = first_seg(seg->metadata_lv)) ||
-					   find_pool_seg(seg2) != seg) {
-					log_error("LV %s: %s segment %u metadata LV does not refer back to pool LV",
-						  lv->name, seg->segtype->name, seg_count);
-					inc_error_count;
-				}
-
-				if (!validate_pool_chunk_size(lv->vg->cmd, seg->segtype, seg->chunk_size)) {
-					log_error("LV %s: %s segment %u has invalid chunk size %u.",
-						  lv->name, seg->segtype->name, seg_count, seg->chunk_size);
-					inc_error_count;
-				}
-			} else {
-				if (seg->metadata_lv) {
-					log_error("LV %s: segment %u must not have pool metadata LV set",
-						  lv->name, seg_count);
-					inc_error_count;
-				}
-			}
-
-			if (seg_is_thin_volume(seg)) {
-				if (!lv_is_thin_volume(lv)) {
-					log_error("LV %s is missing thin volume flag for segment %u",
-						  lv->name, seg_count);
-					inc_error_count;
-				}
-
-				if (lv_is_thin_pool(lv)) {
-					log_error("LV %s is a thin pool that must not contain thin volume segment %u",
-						  lv->name, seg_count);
-					inc_error_count;
-				}
-
-				if (!seg->pool_lv) {
-					log_error("LV %s: segment %u is missing thin pool LV",
-						  lv->name, seg_count);
-					inc_error_count;
-				} else if (!lv_is_thin_pool(seg->pool_lv)) {
-					log_error("LV %s: thin volume segment %u pool LV is not flagged as a pool LV",
-						  lv->name, seg_count);
-					inc_error_count;
-				}
-
-				if (seg->device_id > DM_THIN_MAX_DEVICE_ID) {
-					log_error("LV %s: thin volume segment %u has too large device id %u",
-						  lv->name, seg_count, seg->device_id);
-					inc_error_count;
-				}
-				if (seg->external_lv && (seg->external_lv->status & LVM_WRITE)) {
-					log_error("LV %s: external origin %s is writable.",
-						  lv->name, seg->external_lv->name);
-					inc_error_count;
-				}
-
-				if (seg->merge_lv) {
-					if (!lv_is_thin_volume(seg->merge_lv)) {
-						log_error("LV %s: thin volume segment %u merging LV %s is not flagged as a thin LV",
-							  lv->name, seg_count, seg->merge_lv->name);
-						inc_error_count;
-					}
-					if (!lv_is_merging_origin(seg->merge_lv)) {
-						log_error("LV %s: merging LV %s is not flagged as merging.",
-							  lv->name, seg->merge_lv->name);
-						inc_error_count;
-					}
-				}
-			} else if (seg_is_cache(seg)) {
-				if (!lv_is_cache(lv)) {
-					log_error("LV %s is missing cache flag for segment %u",
-						  lv->name, seg_count);
-					inc_error_count;
-				}
-				if (!seg->pool_lv) {
-					log_error("LV %s: segment %u is missing cache_pool LV",
-						  lv->name, seg_count);
-					inc_error_count;
-				}
-			} else {
-				if (seg->pool_lv) {
-					log_error("LV %s: segment %u must not have pool LV set",
-						  lv->name, seg_count);
-					inc_error_count;
-				}
-			}
-		}
-
 		if (seg_is_snapshot(seg)) {
 			if (seg->cow && seg->cow == seg->origin) {
 				log_error("LV %s: segment %u has same LV %s for "
@@ -627,6 +510,9 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		if (seg_is_replicator(seg) && !check_replicator_segment(seg))
 			inc_error_count;
 
+		if (complete_vg)
+			_check_lv_segment(lv, seg, seg_count, &error_count);
+
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) == AREA_UNASSIGNED) {
 				log_error("LV %s: segment %u has unassigned "
@@ -708,6 +594,12 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		le += seg->len;
 	}
 
+	if (le != lv->le_count) {
+		log_error("LV %s: inconsistent LE count %u != %u",
+			  lv->name, le, lv->le_count);
+		inc_error_count;
+	}
+
 	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
 		seg = sl->seg;
 		seg_found = 0;
@@ -768,6 +660,10 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 				  lv->name);
 			inc_error_count;
 		}
+
+		/* Validation of external origin counter */
+		if (seg->external_lv == lv)
+			external_lv_found++;
 	}
 
 	dm_list_iterate_items(glvl, &lv->indirect_glvs) {
@@ -789,10 +685,51 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		}
 	}
 
-	if (le != lv->le_count) {
-		log_error("LV %s: inconsistent LE count %u != %u",
-			  lv->name, le, lv->le_count);
-		inc_error_count;
+	/* Check LV flags match first segment type */
+	if (complete_vg) {
+		if ((seg_count != 1) &&
+		    (lv_is_cache(lv) ||
+		     lv_is_cache_pool(lv) ||
+		     lv_is_raid(lv) ||
+		     lv_is_snapshot(lv) ||
+		     lv_is_thin_pool(lv) ||
+		     lv_is_thin_volume(lv))) {
+			log_error("LV %s must have exactly one segment.",
+				  lv->name);
+			inc_error_count;
+		}
+
+		if (lv_is_pool_data(lv) &&
+		    (!(seg2 = first_seg(lv)) || !(seg2 = find_pool_seg(seg2)) ||
+		     seg2->area_count != 1 || seg_type(seg2, 0) != AREA_LV ||
+		     seg_lv(seg2, 0) != lv)) {
+			log_error("LV %s: segment 1 pool data LV does not point back to same LV",
+				  lv->name);
+			inc_error_count;
+		}
+
+		if (lv_is_thin_pool_metadata(lv) && !strstr(lv->name, "_tmeta")) {
+			log_error("LV %s: thin pool metadata LV does not use _tmeta.",
+				  lv->name);
+			inc_error_count;
+		} else if (lv_is_cache_pool_metadata(lv) && !strstr(lv->name, "_cmeta")) {
+			log_error("LV %s: cache pool metadata LV does not use _cmeta.",
+				  lv->name);
+			inc_error_count;
+		}
+
+		if (lv_is_external_origin(lv)) {
+			if (lv->external_count != external_lv_found) {
+				log_error("LV %s: external origin count does not match.",
+					  lv->name);
+				inc_error_count;
+			}
+			if (lv->status & LVM_WRITE) {
+				log_error("LV %s: external origin cant't be writable.",
+					  lv->name);
+				inc_error_count;
+			}
+		}
 	}
 
 out:


