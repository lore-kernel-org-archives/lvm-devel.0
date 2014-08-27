From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 27 Aug 2014 23:44:46 +0000 (UTC)
Subject: master - lvextend: Reinstate --nosync logic for mirrors.
Message-ID: <20140827234446.12F6D60A3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2faf416e0ed639b453c4ccf0d7f6f0217b644d5d
Commit:        2faf416e0ed639b453c4ccf0d7f6f0217b644d5d
Parent:        3003a9a7be35dc8a6f87ceddd5cdc9bf6b021bfa
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Aug 28 00:40:09 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Aug 28 00:40:09 2014 +0100

lvextend: Reinstate --nosync logic for mirrors.

Reinstate the logic for syncing extensions of mirrors created with
--nosync.  (Inadvertently disabled by the approximate allocation
changes.)
---
 WHATS_NEW               |    3 ++-
 lib/metadata/lv_manip.c |   12 ++++++++----
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 02ee1b0..79e32e7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,6 +1,7 @@
 Version 2.02.111 - 
 ===================================
-  Fix regression in cache pool allocation (2.02.110).
+  Reinstate nosync logic when extending mirror. (2.02.110)
+  Fix total area extent calculation when allocating cache pool. (2.02.110)
 
 Version 2.02.110 - 26th August 2014
 ===================================
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index baf431f..fcf9975 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3670,6 +3670,8 @@ int lv_extend(struct logical_volume *lv,
 	int log_count = 0;
 	struct alloc_handle *ah;
 	uint32_t sub_lv_count;
+	uint32_t old_extents;
+	uint32_t new_extents;	/* Total logical size after extension. */
 
 	log_very_verbose("Adding segment of type %s to LV %s.", segtype->name, lv->name);
 
@@ -3695,9 +3697,9 @@ int lv_extend(struct logical_volume *lv,
 				    allocatable_pvs, alloc, approx_alloc, NULL)))
 		return_0;
 
-	extents = ah->new_extents;
+	new_extents = ah->new_extents;
 	if (segtype_is_raid(segtype))
-		extents -= ah->log_len * ah->area_multiple;
+		new_extents -= ah->log_len * ah->area_multiple;
 
 	if (segtype_is_thin_pool(segtype) || segtype_is_cache_pool(segtype)) {
 		if (lv->le_count) {
@@ -3723,6 +3725,8 @@ int lv_extend(struct logical_volume *lv,
 		else
 			sub_lv_count = mirrors;
 
+		old_extents = lv->le_count;
+
 		if (!lv->le_count &&
 		    !(r = _lv_insert_empty_sublvs(lv, segtype, stripe_size,
 						  region_size, sub_lv_count))) {
@@ -3730,7 +3734,7 @@ int lv_extend(struct logical_volume *lv,
 			goto out;
 		}
 
-		if (!(r = _lv_extend_layered_lv(ah, lv, extents - lv->le_count, 0,
+		if (!(r = _lv_extend_layered_lv(ah, lv, new_extents - lv->le_count, 0,
 						stripes, stripe_size)))
 			goto_out;
 
@@ -3739,7 +3743,7 @@ int lv_extend(struct logical_volume *lv,
 		 * resync of the extension if the LV is currently in-sync
 		 * and the LV has the LV_NOTSYNCED flag set.
 		 */
-		if ((lv->le_count != extents) &&
+		if (old_extents &&
 		    segtype_is_mirrored(segtype) &&
 		    (lv->status & LV_NOTSYNCED)) {
 			dm_percent_t sync_percent = DM_PERCENT_INVALID;


