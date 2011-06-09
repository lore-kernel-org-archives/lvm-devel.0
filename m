From: Milan Broz <mbroz@redhat.com>
Date: Thu,  9 Jun 2011 16:30:30 +0200
Subject: [PATCH 3/4] Fix mirrored stripe reduction.
In-Reply-To: <1307629831-13816-1-git-send-email-mbroz@redhat.com>
References: <1307629831-13816-1-git-send-email-mbroz@redhat.com>
Message-ID: <1307629831-13816-3-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch adds check for stripe not only in direct
LV segment but also in mirror image segment.

This prevents bugs like:

# lvcreate -i2 -l10 -n lv vg_test
# lvconvert -m1 -i1 vg_test/lv

# lvreduce -f -l1 vg_test/lv
  WARNING: Reducing active logical volume to 4.00 MiB
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
  Reducing logical volume lv to 4.00 MiB
  Segment extent reduction 9 not divisible by #stripes 2
  Logical volume lv successfully resized

# lvremove -f vg_test
  Segment extent reduction 1 not divisible by #stripes 2
  LV segment lv:0-4294967295 is incorrectly listed as being used by LV lv_mimage_0
  Internal error: LV segments corrupted in lv_mimage_0.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 test/t-lvconvert-mirror.sh |    8 ++++++++
 tools/lvresize.c           |   34 ++++++++++++++++++++++++++++++----
 2 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/test/t-lvconvert-mirror.sh b/test/t-lvconvert-mirror.sh
index 129a4d4..64c407b 100644
--- a/test/t-lvconvert-mirror.sh
+++ b/test/t-lvconvert-mirror.sh
@@ -240,3 +240,11 @@ lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 $dev4 $dev3:0
 check mirror $vg $lv1 $dev3
 check mirror_no_temporaries $vg $lv1
 check mirror_legs $vg $lv1 3
+
+# simple mirrored stripe
+aux prepare_vg 5
+lvcreate -i2 -l10 -n $lv1 $vg
+lvconvert -m1 -i1 $vg/$lv1
+lvreduce -f -l1 $vg/$lv1
+lvextend -f -l10 $vg/$lv1
+lvremove -ff $vg/$lv1
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 30e0bf0..02f1f32 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -305,6 +305,34 @@ static int _adjust_policy_params(struct cmd_context *cmd,
 	return 1;
 }
 
+static uint32_t lvseg_get_stripes(struct lv_segment *seg, uint32_t *stripesize)
+{
+	uint32_t s;
+	struct lv_segment *seg_mirr;
+
+	/* If segment mirrored, check if images are striped */
+	if (seg_is_mirrored(seg))
+		for (s = 0; s < seg->area_count; s++) {
+			if (seg_type(seg, s) != AREA_LV)
+				continue;
+			seg_mirr = first_seg(seg_lv(seg, s));
+
+			if (seg_is_striped(seg_mirr)) {
+				seg = seg_mirr;
+				break;
+			}
+		}
+
+
+	if (seg_is_striped(seg)) {
+		*stripesize = seg->stripe_size;
+		return seg->area_count;
+	}
+
+	*stripesize = 0;
+	return 0;
+}
+
 static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvresize_params *lp)
 {
@@ -548,10 +576,8 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		dm_list_iterate_items(seg, &lv->segments) {
 			seg_extents = seg->len;
 
-			if (seg_is_striped(seg)) {
-				seg_stripesize = seg->stripe_size;
-				seg_stripes = seg->area_count;
-			}
+			/* Check for underlying stripe sizes */
+			seg_stripes = lvseg_get_stripes(seg, &seg_stripesize);
 
 			if (seg_is_mirrored(seg))
 				seg_mirrors = lv_mirror_count(seg->lv);
-- 
1.7.5.3


