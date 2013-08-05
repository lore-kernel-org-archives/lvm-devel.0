From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon,  5 Aug 2013 15:03:15 -0500
Subject: [PATCH 4/6] Thin: Make 'lv_is_on_pv(s)' and 'get_pv_list_for_lv' work with thin types
In-Reply-To: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
References: <1375732997-23644-1-git-send-email-jbrassow@redhat.com>
Message-ID: <1375732997-23644-5-git-send-email-jbrassow@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The pool metadata LV must be accounted for when determining what PVs
are in a thin-pool.  The pool LV must also be accounted for when
checking thin volumes.

This is a prerequisite for pvmove working with thin types.
---
 lib/metadata/lv_manip.c |   39 +++++++++++++++++++++++++++++++++++----
 1 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index be40c30..b94fef6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -86,10 +86,13 @@ struct lv_names {
  * (or its metadata device) is on the PV, 1 would be returned for the
  * top-level LV.
  * If you wish to check the images themselves, you should pass them.
- *
- * FIXME:  This should be made more generic, possibly use 'for_each_sub_lv'.
- * 'for_each_sub_lv' does not yet allow us to short-circuit execution or
- * pass back the values we need yet though...
+ * Currently handles:
+ *  - linear
+ *  - stripe
+ *  - RAID
+ *  - mirror
+ *  - thin-pool
+ *  - thin
  *
  * Returns: 1 if LV (or part of LV) is on PV, 0 otherwise
  */
@@ -110,6 +113,20 @@ int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
 	if (lv_is_on_pv(seg->log_lv, pv))
 		return 1;
 
+	/* Check thin-pool metadata area */
+	if (lv_is_on_pv(seg->metadata_lv, pv))
+		return 1;
+
+	/* Check thin volume's pool LV */
+	if (lv_is_on_pv(seg->pool_lv, pv))
+		return 1;
+
+	/*
+	 * Do _not_ check 'external_lv.  We wouldn't count an origin's
+	 * PVs as part of a snapshot, so we don't count external_origin's
+	 * PVs as part of a thin-snap/LV
+	 */
+
 	/* Check stack of LVs */
 	dm_list_iterate_items(seg, &lv->segments) {
 		for (s = 0; s < seg->area_count; s++) {
@@ -143,6 +160,8 @@ int lv_is_on_pv(struct logical_volume *lv, struct physical_volume *pv)
  * @lv
  * @pvs
  *
+ * Handles the segment types listed by 'lv_is_on_pv'.
+ *
  * Returns 1 if the LV (or part of the LV) is on any of the pvs
  * in the list, 0 otherwise.
  */
@@ -176,6 +195,8 @@ int lv_is_on_pvs(struct logical_volume *lv, struct dm_list *pvs)
  *  - stripe
  *  - raid
  *  - mirror
+ *  - thin-pool
+ *  - thin (which is essentially the same as thin-pool)
  * It is up to the caller to free the pv_list when they are finished
  * with it.
  *
@@ -197,6 +218,16 @@ int get_pv_list_for_lv(struct dm_pool *mem,
 		    !get_pv_list_for_lv(mem, seg->log_lv, pvs))
 			return_0;
 
+		if (seg->metadata_lv && /* Thin-pool metadata area */
+		    !get_pv_list_for_lv(mem, seg->metadata_lv, pvs))
+			return_0;
+
+		if (seg->pool_lv && /* Check thin volume's pool LV */
+		    !get_pv_list_for_lv(mem, seg->pool_lv, pvs))
+			return_0;
+
+		/* An external origin's PVs do not count */
+
 		for (s = 0; s < seg->area_count; s++) {
 			dup_found = 0;
 
-- 
1.7.7.6


