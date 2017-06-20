From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Jun 2017 12:25:43 -0400
Subject: master - activation: fix usage of origin_only
Message-ID: <201706201625.v5KGPhfR006790@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ea41b6d486cc34bf55e51eaac60f2cadfc866c3
Commit:        1ea41b6d486cc34bf55e51eaac60f2cadfc866c3
Parent:        5e611c700ba1032ffb71bf0cdd33e062e5e16439
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 20 17:11:42 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 20 18:23:24 2017 +0200

activation: fix usage of origin_only

When lock-holding LV differs from actually request locked LV,
we drop  origin_only flag as it has no use - it'd be applied
on completely different LV.

Example of problem:

Raid is  thin-pool _tdata LV.
Raid run  origin_only locking on stacked device.
As lock holder is discovered thinLV.
Whole origin_only operation is then applied only on thinLV
changing the meaning of whole operation.

NOTE: this patch does not change anything for LV that are
already top-level lock holding LVs (i.e. thinLVs, snahoshots/origins).
---
 lib/metadata/lv_manip.c   |    6 ++++++
 lib/metadata/raid_manip.c |   15 +++++++++++++--
 2 files changed, 19 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8f38839..9e98ee3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6368,6 +6368,12 @@ static int _lv_update_and_reload(struct logical_volume *lv, int origin_only)
 	if (!vg_write(vg))
 		return_0;
 
+	if (lock_lv != lv) {
+		log_debug_activation("Dropping origin_only for %s as lock holds %s",
+				     display_lvname(lv), display_lvname(lock_lv));
+		origin_only = 0;
+	}
+
 	if (!(origin_only ? suspend_lv_origin(vg->cmd, lock_lv) : suspend_lv(vg->cmd, lock_lv))) {
 		log_error("Failed to lock logical volume %s.",
 			  display_lvname(lock_lv));
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 93895fe..6d3a509 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -551,10 +551,21 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 	fn_on_lv_t fn_pre_on_lv = NULL, fn_post_on_lv;
 	void *fn_pre_data, *fn_post_data = NULL;
 	struct dm_list *removal_lvs;
+	const struct logical_volume *lock_lv = lv_lock_holder(lv);
 
 	va_start(ap, origin_only);
 	removal_lvs = va_arg(ap, struct dm_list *);
 
+	if (lock_lv != lv) {
+		log_debug_activation("Dropping origin_only for %s as lock holds %s",
+				     display_lvname(lv), display_lvname(lock_lv));
+		origin_only = 0;
+	}
+	origin_only = 0;
+
+	/* TODO/FIXME:  this function should be simplified to just call
+	 * lv_update_and_reload() and cleanup of remained LVs */
+
 	/* Retrieve post/pre functions and post/pre data reference from variable arguments, if any */
 	if ((fn_post_on_lv = va_arg(ap, fn_on_lv_t))) {
 		fn_post_data = va_arg(ap, void *);
@@ -576,8 +587,8 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 		 * Returning 2 from pre function -> lv is suspended and
 		 * metadata got updated, don't need to do it again
 		 */
-		if (!(r = (origin_only ? resume_lv_origin(lv->vg->cmd, lv_lock_holder(lv)) :
-					 resume_lv(lv->vg->cmd, lv_lock_holder(lv))))) {
+		if (!(r = (origin_only ? resume_lv_origin(lv->vg->cmd, lock_lv) :
+					 resume_lv(lv->vg->cmd, lock_lv)))) {
 			log_error("Failed to resume %s.", display_lvname(lv));
 			return 0;
 		}


