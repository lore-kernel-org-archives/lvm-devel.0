From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 11 Feb 2016 17:39:50 +0000 (UTC)
Subject: master - cleanup: stripes_extents
Message-ID: <20160211173950.5A36560365@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=acf7815acaceb32133bcdf8160260622c2df2f82
Commit:        acf7815acaceb32133bcdf8160260622c2df2f82
Parent:        740d27f9fea2596d0f4bcf32c07cd72bad798537
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 22 16:11:29 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 11 18:35:06 2016 +0100

cleanup: stripes_extents

Simplify calculation of extents rounding needed for
segment size.

Segment size has to divisible by 'extent count' needed to contain
whole stripe. LVM currently does not support stripes across segment.

In case the stripe size is bigger then extent size,
require bigger rounding.
---
 lib/metadata/lv_manip.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 1e1d1b4..6c6a03c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4822,7 +4822,7 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 	uint32_t seg_logical_extents;
 	uint32_t seg_physical_extents;
 	uint32_t area_multiple;
-	uint32_t stripesize_extents;
+	uint32_t stripes_extents;
 	uint32_t size_rest;
 	uint32_t existing_logical_extents = lv->le_count;
 	uint32_t existing_physical_extents, saved_existing_physical_extents;
@@ -5053,22 +5053,24 @@ static int _lvresize_adjust_extents(struct cmd_context *cmd, struct logical_volu
 			return 0;
 		}
 
-		if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
-			stripesize_extents = 1;
+		/* Segment size in extents must be divisible by stripes */
+		stripes_extents = lp->stripes;
+		if (lp->stripe_size > vg->extent_size)
+			/* Strip size is bigger then extent size needs more extents */
+			stripes_extents *= (lp->stripe_size / vg->extent_size);
 
-		size_rest = seg_size % (lp->stripes * stripesize_extents);
+		size_rest = seg_size % stripes_extents;
 		/* Round toward the original size. */
 		if (size_rest &&
 		    ((lp->extents < existing_logical_extents) ||
 		     !lp->percent ||
 		     (vg->free_count >= (lp->extents - existing_logical_extents - size_rest +
-					 (lp->stripes * stripesize_extents))))) {
+					 stripes_extents)))) {
 			log_print_unless_silent("Rounding size (%d extents) up to stripe "
 						"boundary size for segment (%d extents)",
-						lp->extents, lp->extents - size_rest +
-						(lp->stripes * stripesize_extents));
-			lp->extents = lp->extents - size_rest +
-				      (lp->stripes * stripesize_extents);
+						lp->extents,
+						lp->extents - size_rest + stripes_extents);
+			lp->extents = lp->extents - size_rest + stripes_extents;
 		} else if (size_rest) {
 			log_print_unless_silent("Rounding size (%d extents) down to stripe "
 						"boundary size for segment (%d extents)",


