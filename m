From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:48 +0000 (GMT)
Subject: stable-2.02 - thin: enhance lvcreate error paths
Message-ID: <20201016191148.949A4396EC45@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=22b256a09ae6a7def0228a18a940b3f6876c3211
Commit:        22b256a09ae6a7def0228a18a940b3f6876c3211
Parent:        9e8016ffa96490f040cab35b83c18ef92409b7b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 22:43:57 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

thin: enhance lvcreate error paths

Improve error response and reporting, when creating thin snapshots.
If the thin pool kernel metadata already have device with ID lvm2
tries to create, give more meanigful error message and also properly
restore transaction id to the value known to thin-pool in this case.

Before it's been possible to divert by one from kernel TID value,
and lvm2 stacked delete message for such thin device.
---
 WHATS_NEW               |  1 +
 lib/metadata/lv_manip.c | 39 ++++++++++++++++++++++++++++++++-------
 2 files changed, 33 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8b6f8965c..fe1093201 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.188 - 
 ==================================
+  Enhance reporting and error handling when creating thin volumes.
   Use revert_lv() on reload error path after vg_revert().
   Improve estimation of needed extents when creating thin-pool.
   Use extra 1% when resizing thin-pool metadata LV with --use-policy.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1bed4f525..dbfb306de 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7522,6 +7522,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	struct lv_segment *seg, *pool_seg;
 	int thin_pool_was_active = -1; /* not scanned, inactive, active */
 	int historical;
+	uint64_t transaction_id;
+	int ret;
 
 	if (new_lv_name && lv_name_is_used_in_vg(vg, new_lv_name, &historical)) {
 		log_error("%sLogical Volume \"%s\" already exists in "
@@ -7976,15 +7978,38 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		log_very_verbose("Cache pool is prepared.");
 	} else if (lv_is_thin_volume(lv)) {
 		/* For snapshot, suspend active thin origin first */
-		if (origin_lv && lv_is_active(origin_lv) && lv_is_thin_volume(origin_lv)) {
-			if (!suspend_lv_origin(cmd, origin_lv)) {
-				log_error("Failed to suspend thin snapshot origin %s/%s.",
-					  origin_lv->vg->name, origin_lv->name);
-				goto revert_new_lv;
+		if (origin_lv && lv_is_thin_volume(origin_lv) && lv_is_active(origin_lv)) {
+			if (!(ret = suspend_lv_origin(cmd, origin_lv))) {
+				log_error("Failed to suspend thin snapshot origin %s.",
+					  display_lvname(origin_lv));
 			}
+			/* Note: always proceed with resume_lv() to leave critical_section */
 			if (!resume_lv_origin(cmd, origin_lv)) { /* deptree updates thin-pool */
-				log_error("Failed to resume thin snapshot origin %s/%s.",
-					  origin_lv->vg->name, origin_lv->name);
+				log_error("Failed to resume thin snapshot origin %s.",
+					  display_lvname(origin_lv));
+				if (ret)
+					/* suspend with message was OK, only resume failed */
+					goto revert_new_lv; /* hard to fix things here */
+			}
+			if (!ret) {
+				/* Pool transaction_id has been incremented for this canceled transaction
+				 * and needs to be restored to the state from this canceled segment.
+				 * TODO: there is low chance actual suspend has failed
+				 */
+				if (!lv_thin_pool_transaction_id(pool_lv, &transaction_id)) {
+					log_error("Aborting. Failed to read transaction_id from thin pool %s.",
+						  display_lvname(pool_lv)); /* Can't even get thin pool transaction id ??? */
+				} else if (transaction_id != first_seg(pool_lv)->transaction_id) {
+					if (transaction_id == seg->transaction_id)
+						log_debug_metadata("Reverting back transaction_id " FMTu64 " for thin pool %s.",
+								   seg->transaction_id, display_lvname(pool_lv));
+					else
+						log_warn("WARNING: Metadata for thin pool %s have transaction_id " FMTu64
+							 ", but active pool has " FMTu64 ".",
+							 display_lvname(pool_lv), seg->transaction_id, transaction_id);
+					first_seg(pool_lv)->transaction_id = seg->transaction_id;
+					first_seg(lv)->device_id = 0; /* no delete of never existing thin device */
+				}
 				goto revert_new_lv;
 			}
 			/* At this point remove pool messages, snapshot is active */


