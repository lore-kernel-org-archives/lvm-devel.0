From: Iustin Pop <iustin@google.com>
Date: Tue, 7 Jul 2009 10:00:26 +0200
Subject: [PATCH] Change lvextend to round up for stripped volumes
Message-ID: <20090707080026.GC6490@google.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Currently lvresize, when growing stripped volumes, rounds down if the
extents delta doesn't match exactly the full stripe size. This is
counterintuitive (we're requesting growth by X amount, and instead we
could get less than X, even though the operation succeded), and also
doesn't match the current behaviour in lvcreate (rounds up) and lvextend
for non-stripped volumes (which also rounds up).

Signed-off-by: Iustin Pop <iustin@google.com>
---
 Note: I've tested this in a two-stripe scenario, and it seems to work as
 intended; however, I'm not familiar with the code so I might have
 misunderstood things. Thanks in advance! iustin

 Also this is a resend, it seems the first time it didn't go through.

 tools/lvresize.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/tools/lvresize.c b/tools/lvresize.c
index 1c0f570..69239dc 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -283,6 +283,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	uint32_t seg_mirrors = 0;
 	uint32_t extents_used = 0;
 	uint32_t size_rest;
+        uint32_t full_stripe_size;
 	uint32_t pv_extent_count = 0;
 	alloc_policy_t alloc;
 	struct logical_volume *lock_lv;
@@ -517,12 +518,13 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 	if ((lp->stripes > 1)) {
 		if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
 			stripesize_extents = 1;
+                full_stripe_size = lp->stripes * stripesize_extents;
 
-		if ((size_rest = seg_size % (lp->stripes * stripesize_extents))) {
-			log_print("Rounding size (%d extents) down to stripe "
+		if ((size_rest = seg_size % full_stripe_size)) {
+			log_print("Rounding size (%d extents) up to stripe "
 				  "boundary size for segment (%d extents)",
-				  lp->extents, lp->extents - size_rest);
-			lp->extents = lp->extents - size_rest;
+				  lp->extents, lp->extents - size_rest + full_stripe_size);
+			lp->extents = lp->extents - size_rest + full_stripe_size;
 		}
 
 		if (lp->stripe_size < STRIPE_SIZE_MIN) {
-- 
1.6.3.3


