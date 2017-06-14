From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Wed, 14 Jun 2017 09:37:35 -0400
Subject: master - lvconvert: linear -> raid1 upconvert should cause "recover" not "resync"
Message-ID: <201706141337.v5EDbZmO012171@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c87907dcd5385337ba96c79b4bee8e3d2f2ea129
Commit:        c87907dcd5385337ba96c79b4bee8e3d2f2ea129
Parent:        14d563accc7692dfd827a4db91912c9ab498ca1f
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 14 08:33:42 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 14 08:35:22 2017 -0500

lvconvert:  linear -> raid1 upconvert should cause "recover" not "resync"

Two of the sync actions performed by the kernel (aka MD runtime) are
"resync" and "recover".  The "resync" refers to when an entirely new array
is going through the process of initializing (or resynchronizing after an
unexpected shutdown).  The "recover" is the process of initializing a new
member device to the array.  So, a brand new array with all new devices
will undergo "resync".  An array with replaced or added sub-LVs will undergo
"recover".

These two states are treated very differently when failures happen.  If any
device is lost or replaced while "resync", there are no worries.  This is
because any writes created from the inception of the array have occurred to
all the devices and can be safely recovered.  Even though non-initialized
portions will still be resync'ed with uninitialized data, it is ok.  However,
if a pre-existing device is lost (aka, the original linear device in a
linear -> raid1 convert) during a "recover", data loss can be the result.
Thus, writes are errored by the kernel and recovery is halted.  The failed
device must be restored or removed.  This is the correct behavior.

Unfortunately, we were treating an up-convert from linear as a "resync"
when we should have been treating it as a "recover".  This patch
removes the special case for linear upconvert.  It allows each new image
sub-LV to be marked with a rebuild flag and treats the array as 'in-sync'.
This has the correct effect of causing the upconvert to be treated as a
"recover" rather than a "resync".  There is no need to flag these two states
differently in LVM metadata, because they are already considered differently
by the kernel RAID metadata.  (Any activation/deactivation will properly
resume the "recover" process and not a "resync" process.)

We make this behavior change based on the presense of dm-raid target
version 1.9.0+.
---
 WHATS_NEW                         |    1 +
 lib/metadata/raid_manip.c         |   35 +++++++++++++++++++++++++++++++++--
 lib/metadata/segtype.h            |   18 ++++++++++++++++++
 lib/raid/raid.c                   |    1 +
 test/shell/lvcreate-large-raid.sh |   10 +++++++++-
 5 files changed, 62 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cdd401e..c7f8903 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.172 - 
 ===============================
+  Linear to RAID1 upconverts now use "recover" sync action, not "resync".
   Improve lvcreate --cachepool arg validation.
   Limit maximal size of thin-pool for specific chunk size.
   Print a warning about in-use PVs with no VG using them.
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a19a7e9..425abbb 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -57,6 +57,25 @@ static int _reshape_is_supported(struct cmd_context *cmd, const struct segment_t
 }
 
 /*
+ * Check if rebuild CTR args are allowed when other images exist in the array
+ * with empty metadata areas for this kernel.
+ */
+static int _rebuild_with_emptymeta_is_supported(struct cmd_context *cmd,
+						const struct segment_type *segtype)
+{
+	unsigned attrs;
+
+	if (!segtype->ops->target_present ||
+            !segtype->ops->target_present(cmd, NULL, &attrs) ||
+            !(attrs & RAID_FEATURE_NEW_DEVICES_ACCEPT_REBUILD)) {
+		log_verbose("RAID module does not support rebuild+emptymeta.");
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
  * Ensure region size exceeds the minimum for @lv because
  * MD's bitmap is limited to tracking 2^21 regions.
  *
@@ -2550,6 +2569,7 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 	struct dm_list meta_lvs, data_lvs;
 	struct lv_list *lvl;
 	struct lv_segment_area *new_areas;
+	struct segment_type *segtype;
 
 	if (lv_is_not_synced(lv)) {
 		log_error("Can't add image to out-of-sync RAID LV:"
@@ -2581,8 +2601,19 @@ static int _raid_add_images_without_commit(struct logical_volume *lv,
 	 * LV to accompany it.
 	 */
 	if (seg_is_linear(seg)) {
-		/* A complete resync will be done, no need to mark each sub-lv */
-		status_mask = ~(LV_REBUILD);
+		/*
+		 * As of dm-raid version 1.9.0, it is possible to specify
+		 * RAID table lines with the 'rebuild' parameters necessary
+		 * to force a "recover" instead of a "resync" on upconvert.
+		 *
+		 * LVM's interaction with older kernels should be as before -
+		 * performing a complete resync rather than a set of rebuilds.
+		 */
+		if (!(segtype = get_segtype_from_string(lv->vg->cmd, SEG_TYPE_NAME_RAID1)))
+			return_0;
+
+		if (!_rebuild_with_emptymeta_is_supported(lv->vg->cmd, segtype))
+			status_mask = ~(LV_REBUILD);
 
 		/* FIXME: allow setting region size on upconvert from linear */
 		seg->region_size = get_default_region_size(lv->vg->cmd);
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 93132c3..2acb894 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -290,6 +290,24 @@ struct segment_type *init_unknown_segtype(struct cmd_context *cmd,
 #define RAID_FEATURE_RAID4			(1U << 3) /* ! version 1.8 or 1.9.0 */
 #define RAID_FEATURE_SHRINK			(1U << 4) /* version 1.9.0 */
 #define RAID_FEATURE_RESHAPE			(1U << 5) /* version 1.10.1 */
+/*
+ * RAID_FEATURE_NEW_DEVICES_ACCEPT_REBUILD
+ * This signifies a behavioral change in dm-raid.  Prior to upstream kernel
+ * commit 33e53f068, the kernel would refuse to allow 'rebuild' CTR args to
+ * be submitted when other devices in the array had uninitialized superblocks.
+ * After the commit, these parameters were allowed.
+ *
+ * The most obvious useful case of this new behavior is up-converting a
+ * linear device to RAID1.  A new superblock is allocated for the linear dev
+ * and it will be uninitialized, while all the new images are specified for
+ * 'rebuild'.  This valid scenario would not have been allowed prior to
+ * commit 33e53f068.
+ *
+ * Commit 33e53f068 did not bump the dm-raid version number.  So it exists
+ * in some, but not all 1.8.1 versions of dm-raid.  The only way to be
+ * certain the new behavior exists is to check for version 1.9.0.
+ */
+#define RAID_FEATURE_NEW_DEVICES_ACCEPT_REBUILD	(1U << 6) /* version 1.9.0 */
 
 #ifdef RAID_INTERNAL
 int init_raid_segtypes(struct cmd_context *cmd, struct segtype_library *seglib);
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 25009f6..8a53d7e 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -474,6 +474,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 		{ 1, 3, 0, RAID_FEATURE_RAID10, SEG_TYPE_NAME_RAID10 },
 		{ 1, 7, 0, RAID_FEATURE_RAID0, SEG_TYPE_NAME_RAID0 },
 		{ 1, 9, 0, RAID_FEATURE_SHRINK, "shrinking" },
+		{ 1, 9, 0, RAID_FEATURE_NEW_DEVICES_ACCEPT_REBUILD, "rebuild+emptymeta" },
 		{ 1, 10, 1, RAID_FEATURE_RESHAPE, "reshaping" },
 	};
 
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index ca3f715..7ec140b 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -101,7 +101,15 @@ lvremove -ff $vg1
 lvcreate -aey -L 200T -n $lv1 $vg1
 lvconvert -y --type raid1 -m 1 $vg1/$lv1
 check lv_field $vg1/$lv1 size "200.00t"
-check raid_leg_status $vg1 $lv1 "aa"
+if aux have_raid 1 9 0; then
+	# The 1.9.0 version of dm-raid is capable of performing
+	# linear -> RAID1 upconverts as "recover" not "resync"
+	# The LVM code now checks the dm-raid version when
+	# upconverting and if 1.9.0+ is found, it uses "recover"
+	check raid_leg_status $vg1 $lv1 "Aa"
+else
+	check raid_leg_status $vg1 $lv1 "aa"
+fi
 lvremove -ff $vg1
 
 # bz837927 END


