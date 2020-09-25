From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Sep 2020 21:07:03 +0000 (GMT)
Subject: master - thin: enhance lvcreate error paths
Message-ID: <20200925210703.C40D23947C02@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef59c83f2df61b0f0263b0e32dac66eb0cb75488
Commit:        ef59c83f2df61b0f0263b0e32dac66eb0cb75488
Parent:        e2eb1dc501aca4b11997b31978c9ce62916a7c98
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 25 22:43:57 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 25 22:56:40 2020 +0200

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
index 267914382..d50ba762a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Enhance reporting and error handling when creating thin volumes.
   Enable vgsplit for VDO volumes.
   Lvextend of vdo pool volumes ensure at least 1 new VDO slab is added.
   Use revert_lv() on reload error path after vg_revert().
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ff86a7ab3..ce532ab92 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7973,6 +7973,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	struct lv_segment *seg, *pool_seg;
 	int thin_pool_was_active = -1; /* not scanned, inactive, active */
 	int historical;
+	uint64_t transaction_id;
+	int ret;
 
 	if (new_lv_name && lv_name_is_used_in_vg(vg, new_lv_name, &historical)) {
 		log_error("%sLogical Volume \"%s\" already exists in "
@@ -8441,15 +8443,38 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
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


