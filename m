From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:26 +0000 (GMT)
Subject: stable-2.02 - cache: simplier signal handling
Message-ID: <20201016191126.F087F396EC72@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0881ba9e9f32144d5a538b9920367c494513d23a
Commit:        0881ba9e9f32144d5a538b9920367c494513d23a
Parent:        de17c273de8e3b139cd694d76f9bde9154cc3aa2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 13 11:33:39 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

cache: simplier signal handling

Use just single sigint_allow()/restore() within flushing loop
and void one extra signal manipulation.
---
 lib/metadata/cache_manip.c | 12 +++++-------
 1 file changed, 5 insertions(+), 7 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 8376bfbf0..05a6efdf1 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -425,7 +425,7 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	const struct logical_volume *lock_lv = lv_lock_holder(cache_lv);
 	struct lv_segment *cache_seg = first_seg(cache_lv);
 	struct lv_status_cache *status;
-	int cleaner_policy, writeback;
+	int cleaner_policy = 0, writeback;
 	uint64_t dirty_blocks;
 
 	*is_clean = 0;
@@ -433,6 +433,9 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
 	//FIXME: use polling to do this...
 	for (;;) {
 		sigint_allow();
+		if (cleaner_policy)
+			/* TODO: Use centralized place */
+			usleep(500000);
 		sigint_restore();
 		if (sigint_caught()) {
 			sigint_clear();
@@ -468,13 +471,8 @@ int lv_cache_wait_for_clean(struct logical_volume *cache_lv, int *is_clean)
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


