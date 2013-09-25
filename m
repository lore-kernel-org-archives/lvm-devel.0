From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 25 Sep 2013 14:08:31 +0000 (UTC)
Subject: master - thin: calculate thin pool chunk size based on device IO hints
Message-ID: <20130925140831.B976860F43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=78cba8eb3fa262c2c4e1a5c5a3db3e4e0d7e6900
Commit:        78cba8eb3fa262c2c4e1a5c5a3db3e4e0d7e6900
Parent:        cc9e65c391f9070c4b06a94a0ffdb9c61cf89c13
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Sep 25 16:01:47 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Sep 25 16:06:38 2013 +0200

thin: calculate thin pool chunk size based on device IO hints

If "default" thin pool chunk size calculation method is selected,
use minimum_io_size, otherwise optimal_io_size for "performance"
device hint exposed in sysfs. If there appear to be PVs with
different hints presented, use their least common multiple.

If the hint is less than the default value defined for the
calculation method, use the default value instead.
---
 lib/metadata/lv_manip.c |   69 ++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 68 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d1ec4cd..f945b79 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5510,6 +5510,72 @@ int lv_activation_skip(struct logical_volume *lv, activation_change_t activate,
 	return (lv->status & LV_ACTIVATION_SKIP) ? 1 : 0;
 }
 
+/* Greatest common divisor */
+static unsigned long _gcd(unsigned long n1, unsigned long n2)
+{
+	unsigned long remainder;
+
+	do {
+		remainder = n1 % n2;
+		n1 = n2;
+		n2 = remainder;
+	} while (n2);
+
+	return n1;
+}
+
+/* Least common multiple */
+static unsigned long _lcm(unsigned long n1, unsigned long n2)
+{
+	if (!n1 || !n2)
+		return 0;
+	return (n1 * n2) / _gcd(n1, n2);
+}
+
+static int _recalculate_thin_pool_chunk_size_with_dev_hints(struct lvcreate_params *lp,
+							    struct logical_volume *pool_lv)
+{
+	struct logical_volume *pool_data_lv;
+	struct lv_segment *seg;
+	struct physical_volume *pv;
+	struct cmd_context *cmd = pool_lv->vg->cmd;
+	unsigned long previous_hint = 0, hint;
+	uint32_t chunk_size = lp->chunk_size;
+	uint32_t default_chunk_size = lp->thin_chunk_size_calc_method == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE ?
+					DEFAULT_THIN_POOL_CHUNK_SIZE_PERFORMANCE*2 : DEFAULT_THIN_POOL_CHUNK_SIZE*2;
+
+	if (lp->passed_args & PASS_ARG_CHUNK_SIZE ||
+	    find_config_tree_int(cmd, allocation_thin_pool_chunk_size_CFG, NULL))
+		goto out;
+
+	pool_data_lv = seg_lv(first_seg(pool_lv), 0);
+
+	dm_list_iterate_items(seg, &pool_data_lv->segments) {
+		pv = seg_pv(seg, 0);
+		if (lp->thin_chunk_size_calc_method == THIN_CHUNK_SIZE_CALC_METHOD_PERFORMANCE)
+			hint = dev_optimal_io_size(cmd->dev_types, pv_dev(pv));
+		else
+			hint = dev_minimum_io_size(cmd->dev_types, pv_dev(pv));
+
+		if (!hint)
+			continue;
+		if (previous_hint)
+			hint = _lcm(previous_hint, hint);
+		previous_hint = hint;
+	}
+
+	if (hint < DM_THIN_MIN_DATA_BLOCK_SIZE ||
+	    hint > DM_THIN_MAX_DATA_BLOCK_SIZE) {
+		log_debug_alloc("Calculated value of %ld sectors for thin pool "
+				"chunk size is out of allowed range (%d-%d).",
+				hint, DM_THIN_MIN_DATA_BLOCK_SIZE, DM_THIN_MAX_DATA_BLOCK_SIZE);
+	} else
+		chunk_size = hint >= default_chunk_size ? hint : default_chunk_size;
+out:
+	first_seg(pool_lv)->chunk_size = chunk_size;
+	return 1;
+}
+
 /* Thin notes:
  * If lp->thin OR lp->activate is AY*, activate the pool if not already active.
  * If lp->thin, create thin LV within the pool - as a snapshot if lp->snapshot.
@@ -5808,8 +5874,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		return_NULL;
 
 	if (seg_is_thin_pool(lp)) {
+		if (!_recalculate_thin_pool_chunk_size_with_dev_hints(lp, lv))
+			return_NULL;
 		first_seg(lv)->zero_new_blocks = lp->zero ? 1 : 0;
-		first_seg(lv)->chunk_size = lp->chunk_size;
 		first_seg(lv)->discards = lp->discards;
 		/* FIXME: use lowwatermark  via lvm.conf global for all thinpools ? */
 		first_seg(lv)->low_water_mark = 0;


