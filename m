From: Milan Broz <mbroz@redhat.com>
Date: Thu,  9 Jun 2011 16:30:28 +0200
Subject: [PATCH 1/4] Fix extent rounding for striped segments.
Message-ID: <1307629831-13816-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We should never remove more extents than requested by user,
so round up to next stripe boundary during lvreduce.

Also this fixes round to zero sized LV bug:

# lvcreate -i2 -I 64k -l10 -n lvs vg_test
# lvreduce -f -l1 vg_test/lvs
  Rounding size (1 extents) down to stripe boundary size for segment (0 extents)
  WARNING: Reducing active logical volume to 0
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
  Reducing logical volume lvs to 0
  Failed to suspend lvs

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 test/t-lvextend-percent-extents.sh |    5 +++++
 tools/lvresize.c                   |   10 ++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/test/t-lvextend-percent-extents.sh b/test/t-lvextend-percent-extents.sh
index 24fac60..ecd5a1b 100755
--- a/test/t-lvextend-percent-extents.sh
+++ b/test/t-lvextend-percent-extents.sh
@@ -99,3 +99,8 @@ check lv_field $vg/$lv seg_count 2
 lvreduce -f -l -$(( $pe_count * 1 )) $vg/$lv
 check lv_field $vg/$lv seg_count 1
 
+# do not reduce to 0 extents
+lvremove -f $vg/$lv
+lvcreate -i2 -I 64k -l10 -n $lv $vg
+lvreduce -f -l1 $vg/$lv
+check lv_field $vg/$lv lv_size "8.00m"
diff --git a/tools/lvresize.c b/tools/lvresize.c
index b9084e6..30e0bf0 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -575,11 +575,17 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		return EINVALID_CMD_LINE;
 	}
 
-	if ((lp->stripes > 1)) {
+	if (lp->stripes > 1) {
 		if (!(stripesize_extents = lp->stripe_size / vg->extent_size))
 			stripesize_extents = 1;
 
-		if ((size_rest = seg_size % (lp->stripes * stripesize_extents))) {
+		size_rest = seg_size % (lp->stripes * stripesize_extents);
+		if (size_rest && lp->resize == LV_REDUCE) {
+			log_print("Rounding size (%d extents) up to stripe "
+				  "boundary size for segment (%d extents)",
+				  lp->extents, lp->extents + size_rest);
+			lp->extents = lp->extents + size_rest;
+		} else if (size_rest) {
 			log_print("Rounding size (%d extents) down to stripe "
 				  "boundary size for segment (%d extents)",
 				  lp->extents, lp->extents - size_rest);
-- 
1.7.5.3


