From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 16 Jun 2017 10:01:15 -0400
Subject: master - Revert "lvconvert: reject changing number of stripes on single core
Message-ID: <201706161401.v5GE1F0X000497@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ddf2a1d6564800f6d7f87e91cb8a7dfaa0edac1f
Commit:        ddf2a1d6564800f6d7f87e91cb8a7dfaa0edac1f
Parent:        3592243afb4bd1b54926b7d8bfef3a0213ca4908
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jun 16 15:43:23 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jun 16 15:43:23 2017 +0200

Revert "lvconvert: reject changing number of stripes on single core

This reverts commit 3719f4bc5441cb5f29ad4beb91ccaa6b234ea8e1
to allow for single core testing on kernels with deadlock
fixes relative to rhbz1443999."
---
 lib/metadata/raid_manip.c |   12 ------------
 1 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ade27e6..214aa19 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2346,12 +2346,6 @@ static int _raid_reshape(struct logical_volume *lv,
 
 	/* Handle disk addition reshaping */
 	if (old_image_count < new_image_count) {
-		/* FIXME: remove once MD kernel rhbz1443999 got fixed. */
-		if (sysconf(_SC_NPROCESSORS_ONLN) < 2) {
-			log_error("Can't add stripes to LV %s on single core.", display_lvname(lv));
-			return 0;
-		}
-
 		if (!_raid_reshape_add_images(lv, new_segtype, yes,
 					      old_image_count, new_image_count,
 					      new_stripes, new_stripe_size, allocate_pvs))
@@ -2359,12 +2353,6 @@ static int _raid_reshape(struct logical_volume *lv,
 
 	/* Handle disk removal reshaping */
 	} else if (old_image_count > new_image_count) {
-		/* FIXME: remove once MD kernel rhbz1443999 got fixed. */
-		if (sysconf(_SC_NPROCESSORS_ONLN) < 2) {
-			log_error("Can't remove stripes from LV %s on single core.", display_lvname(lv));
-			return 0;
-		}
-
 		if (!_raid_reshape_remove_images(lv, new_segtype, yes, force,
 						 old_image_count, new_image_count,
 						 new_stripes, new_stripe_size,


