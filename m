From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:09 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063209.27B3560AA7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d39b4d5e7c38438b294469f74d437bdbb9a2632
Commit:        7d39b4d5e7c38438b294469f74d437bdbb9a2632
Parent:        92691e345d12515d61e6e7748e5b9ddc4eff49c0
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 02:05:36 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces more local infrastructure to raid_manip.c
used by followup patches.

Changes:
- add function providing state of a reshaped RaidLV
- add function to adjust the size of a RaidLV was
  reshaped to add/remove stripes

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |   96 +++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 96 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b2a5572..b82ec90 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1447,6 +1447,102 @@ static int _lv_free_reshape_space(struct logical_volume *lv)
 	return _lv_free_reshape_space_with_status(lv, NULL);
 }
 
+/*
+ * HM
+ *
+ * Compares current raid disk count of active RAID set @lv to
+ * requested @dev_count returning number of disks as of healths
+ * string in @devs_health and synced disks in @devs_in_sync
+ *
+ * Returns:
+ *
+ * 	0: error
+ * 	1: kernel dev count = @dev_count
+ * 	2: kernel dev count < @dev_count
+ * 	3: kernel dev count > @dev_count
+ *
+ */
+__attribute__ ((__unused__))
+static int _reshaped_state(struct logical_volume *lv, const unsigned dev_count,
+			   unsigned *devs_health, unsigned *devs_in_sync)
+{
+	uint32_t kernel_devs;
+
+	if (!devs_health || !devs_in_sync)
+		return_0;
+
+	if (!_get_dev_health(lv, &kernel_devs, devs_health, devs_in_sync, NULL))
+		return 0;
+
+	if (kernel_devs == dev_count)
+		return 1;
+
+	return kernel_devs < dev_count ? 2 : 3;
+}
+
+/*
+ * Return new length for @lv based on @old_image_count and @new_image_count in @*len
+ *
+ * Subtracts any reshape space and provide data length only!
+ */
+static int _lv_reshape_get_new_len(struct logical_volume *lv,
+				   uint32_t old_image_count, uint32_t new_image_count,
+				   uint32_t *len)
+{
+	struct lv_segment *seg = first_seg(lv);
+	uint32_t di_old = _data_rimages_count(seg, old_image_count);
+	uint32_t di_new = _data_rimages_count(seg, new_image_count);
+	uint32_t old_lv_reshape_len, new_lv_reshape_len;
+	uint64_t r;
+
+	if (!di_old || !di_new)
+		return_0;
+
+	old_lv_reshape_len = di_old * _reshape_len_per_dev(seg);
+	new_lv_reshape_len = di_new * _reshape_len_per_dev(seg);
+
+	r = (uint64_t) lv->le_count;
+	r -= old_lv_reshape_len;
+	if ((r = new_lv_reshape_len + r * di_new / di_old) > UINT_MAX) {
+		log_error("No proper new segment length for %s!", display_lvname(lv));
+		return 0;
+	}
+
+	*len = (uint32_t) r;
+
+	return 1;
+}
+
+/*
+ * Extend/reduce size of @lv and it's first segment during reshape to @extents
+ */
+__attribute__ ((__unused__))
+static int _reshape_adjust_to_size(struct logical_volume *lv,
+				   uint32_t old_image_count, uint32_t new_image_count)
+{
+	struct lv_segment *seg = first_seg(lv);
+	uint32_t new_le_count;
+
+	if (!_lv_reshape_get_new_len(lv, old_image_count, new_image_count, &new_le_count))
+		return 0;
+
+	/* Externally visible LV size w/o reshape space */
+	lv->le_count = seg->len = new_le_count;
+	lv->size = (lv->le_count - new_image_count * _reshape_len_per_dev(seg)) * lv->vg->extent_size;
+	/* seg->area_len does not change */
+
+	if (old_image_count < new_image_count) {
+		/* Extend from raid1 mapping */
+		if (old_image_count == 2 &&
+		    !seg->stripe_size)
+			seg->stripe_size = DEFAULT_STRIPESIZE;
+
+	/* Reduce to raid1 mapping */
+	} else if (new_image_count == 2)
+		seg->stripe_size = 0;
+
+	return 1;
+}
 
 /*
  * _alloc_rmeta_for_lv


