From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 13 Sep 2020 22:16:42 +0000 (GMT)
Subject: master - cache: simplier signal handling
Message-ID: <20200913221642.CCF6739518AA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b2978efbff3a0700254f8f206e662312c21a03d3
Commit:        b2978efbff3a0700254f8f206e662312c21a03d3
Parent:        c285bf2f3794629161e55111f9a076cb9852dd26
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 13 11:33:39 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 00:15:14 2020 +0200

cache: simplier signal handling

Use just single sigint_allow()/restore() within flushing loop
and void one extra signal manipulation.
---
 lib/metadata/cache_manip.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index a786e8bac..2c4cc92fb 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -480,7 +480,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	const struct logical_volume *lock_lv = lv_lock_holder(cache_lv);
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct lv_status_cache *status;
-	int cleaner_policy, writeback;
+	int cleaner_policy = 0, writeback;
 	uint64_t dirty_blocks;
 
 	*is_clean = 0;
@@ -488,6 +488,9 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	//FIXME: use polling to do this...
 	for (;;) {
 		sigint_allow();
+		if (cleaner_policy)
+			/* TODO: Use centralized place */
+			usleep(500000);
 		sigint_restore();
 		if (sigint_caught()) {
 			sigint_clear();
@@ -523,13 +526,8 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 		log_print_unless_silent("Flushing " FMTu64 " blocks for cache %s.",
 					dirty_blocks, display_lvname(cache_lv));
 
-		if (cleaner_policy) {
-			/* TODO: Use centralized place */
-			sigint_allow();
-			usleep(500000);
-			sigint_restore();
+		if (cleaner_policy)
 			continue;
-		}
 
 		if (!(cache_lv->status & LVM_WRITE)) {
 			log_warn("WARNING: Dirty blocks found on read-only cache volume %s.",


