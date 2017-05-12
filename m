From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 11 May 2017 21:31:52 -0400
Subject: master - lvcreate: Fix mirror percentage size calculations.
Message-ID: <201705120131.v4C1Vqpk018801@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf73f6cf61793e9d71391bb7a8f35162509898a4
Commit:        cf73f6cf61793e9d71391bb7a8f35162509898a4
Parent:        d49a20b7bdc9b741def219be897c5057db5e05ff
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri May 12 02:04:05 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri May 12 02:31:35 2017 +0100

lvcreate: Fix mirror percentage size calculations.

Trap cases where the percentage calculation currently leads to an empty
LV and the message:

  Internal error: Unable to create new logical volume with no extents

Additionally convert the calculated number of extents from physical to
logical when creating a mirror using a percentage that is based on
Physical Extents.  Otherwise a command like 'lvcreate -m3 -l80%FREE'
can never leave any free space.

This brings the behaviour closer to that of lvresize.
(A further patch is needed to cover all the raid types.)
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |   37 ++++++++++++++++++++++++++++++-------
 2 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e0741a9..abe4641 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Fix lvcreate extent percentage calculation for mirrors.
   Don't reinstate still-missing devices when correcting inconsistent metadata.
   Properly handle subshell return codes in fsadm.
   Disallow cachepool creation with policy cleaner and mode writeback.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index f775290..dddf8ad 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -251,6 +251,7 @@ static int _update_extents_params(struct volume_group *vg,
 	uint32_t size_rest;
 	uint32_t stripesize_extents;
 	uint32_t extents;
+	uint32_t base_calc_extents;
 
 	if (lcp->size &&
 	    !(lp->extents = extents_from_size(vg->cmd, lcp->size,
@@ -275,17 +276,17 @@ static int _update_extents_params(struct volume_group *vg,
 
 	switch (lcp->percent) {
 		case PERCENT_VG:
-			extents = percent_of_extents(lp->extents, vg->extent_count, 0);
+			extents = percent_of_extents(lp->extents, base_calc_extents = vg->extent_count, 0);
 			break;
 		case PERCENT_FREE:
-			extents = percent_of_extents(lp->extents, vg->free_count, 0);
+			extents = percent_of_extents(lp->extents, base_calc_extents = vg->free_count, 0);
 			break;
 		case PERCENT_PVS:
 			if (lcp->pv_count) {
 				pv_extent_count = pv_list_extents_free(lp->pvh);
-				extents = percent_of_extents(lp->extents, pv_extent_count, 0);
+				extents = percent_of_extents(lp->extents, base_calc_extents = pv_extent_count, 0);
 			} else
-				extents = percent_of_extents(lp->extents, vg->extent_count, 0);
+				extents = percent_of_extents(lp->extents, base_calc_extents = vg->extent_count, 0);
 			break;
 		case PERCENT_LV:
 			log_error("Please express size as %%FREE%s, %%PVS or %%VG.",
@@ -304,7 +305,7 @@ static int _update_extents_params(struct volume_group *vg,
 			}
 			/* Add whole metadata size estimation */
 			extents = cow_max_extents(origin_lv, lp->chunk_size) - origin_lv->le_count +
-				percent_of_extents(lp->extents, origin_lv->le_count, 1);
+				percent_of_extents(lp->extents, base_calc_extents = origin_lv->le_count, 1);
 			break;
 		case PERCENT_NONE:
 			extents = lp->extents;
@@ -314,10 +315,27 @@ static int _update_extents_params(struct volume_group *vg,
 			return 0;
 	}
 
-	if (lcp->percent) {
+	if (lcp->percent != PERCENT_NONE) {
 		/* FIXME Don't do the adjustment for parallel allocation with PERCENT_ORIGIN! */
 		lp->approx_alloc = 1;
-		log_verbose("Converted %" PRIu32 "%%%s into %" PRIu32 " extents.", lp->extents, get_percent_string(lcp->percent), extents);
+		if (!extents) {
+			log_error("Calculated size of logical volume is 0 extents. Needs to be larger.");
+			return 0;
+		}
+
+		/* For mirrors and raid with percentages based on physical extents, convert the total number of PEs 
+		 * into the number of logical extents per image (minimum 1) */
+		/* FIXME Handle all the supported raid layouts here based on already-known segtype. */
+		if ((lcp->percent != PERCENT_ORIGIN) && lp->mirrors) {
+			extents /= lp->mirrors;
+			if (!extents)
+				extents = 1;
+		}
+
+		log_verbose("Converted %" PRIu32 "%% of %s (%" PRIu32 ") extents into %" PRIu32 " (with mimages %" PRIu32 " and stripes %" PRIu32
+			    " for segtype %s).", lp->extents, get_percent_string(lcp->percent), base_calc_extents,
+			    extents, lp->mirrors, lp->stripes, lp->segtype->name);
+
 		lp->extents = extents;
 	}
 
@@ -389,6 +407,11 @@ static int _update_extents_params(struct volume_group *vg,
 		}
 	}
 
+	if (!lp->extents) {
+		log_error("Adjusted size of logical volume is 0 extents. Needs to be larger.");
+		return 0;
+	}
+
 	return 1;
 }
 


