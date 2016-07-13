From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Jul 2016 19:56:15 +0000 (UTC)
Subject: master - cleanup: add some dots to messages
Message-ID: <20160713195615.05DEB60370@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=deb6f6a06c2fa25b1c9aa4c6eeb9529ce7c5c4c3
Commit:        deb6f6a06c2fa25b1c9aa4c6eeb9529ce7c5c4c3
Parent:        e1112227d19cc252e1404eb4bf44d03e3867e463
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 12 22:25:21 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 13 21:52:14 2016 +0200

cleanup: add some dots to messages

---
 lib/metadata/lv_manip.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 022bb1f..a47bd16 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4989,14 +4989,14 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 	/* At this point, lp->extents should hold the correct NEW logical size required. */
 
 	if (!lp->extents) {
-		log_error("New size of 0 not permitted");
+		log_error("New size of 0 not permitted.");
 		return 0;
 	}
 
 	if (lp->extents == existing_logical_extents) {
 		if (!lp->resizefs) {
-			log_error("New size (%d extents) matches existing size "
-				  "(%d extents)", lp->extents, existing_logical_extents);
+			log_error("New size (%d extents) matches existing size (%d extents).",
+				  lp->extents, existing_logical_extents);
 			return 0;
 		}
 		lp->resize = LV_EXTEND; /* lets pretend zero size extension */
@@ -5005,7 +5005,7 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 	/* Perform any rounding to produce complete stripes. */
 	if (lp->stripes > 1) {
 		if (lp->stripe_size < STRIPE_SIZE_MIN) {
-			log_error("Invalid stripe size %s",
+			log_error("Invalid stripe size %s.",
 				  display_size(cmd, (uint64_t) lp->stripe_size));
 			return 0;
 		}
@@ -5024,7 +5024,7 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 		     (vg->free_count >= (lp->extents - existing_logical_extents - size_rest +
 					 stripes_extents)))) {
 			log_print_unless_silent("Rounding size (%d extents) up to stripe "
-						"boundary size for segment (%d extents)",
+						"boundary size for segment (%d extents).",
 						lp->extents,
 						lp->extents - size_rest + stripes_extents);
 			lp->extents = lp->extents - size_rest + stripes_extents;
@@ -5088,7 +5088,7 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 
 		if (lv_is_active(lv)) {
 			log_error("Snapshot origin volumes can be resized "
-				  "only while inactive: try lvchange -an");
+				  "only while inactive: try lvchange -an.");
 			return 0;
 		}
 	}


