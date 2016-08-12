From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 12 Aug 2016 17:14:53 +0000 (UTC)
Subject: master - lvcreate/lvconvert: fix validation of maximum mirrors/stripes
Message-ID: <20160812171453.D5D05610C2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a185a2bea27db7cbd8b19df1bb85307fc5c246eb
Commit:        a185a2bea27db7cbd8b19df1bb85307fc5c246eb
Parent:        93b61c07eb14f6185c708bd74f7e471b50cf251b
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Aug 12 19:14:28 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Aug 12 19:14:28 2016 +0200

lvcreate/lvconvert: fix validation of maximum mirrors/stripes

Enforce mirror/raid0/1/10/4/5/6 type specific maximum images when
creating LVs or converting them from mirror <-> raid1.

Document those maxima in the lvcreate/lvconvert man pages.

- resolves rhbz1366060
---
 lib/config/defaults.h |    9 +++++++--
 lib/metadata/merge.c  |   13 ++++++++++---
 man/lvconvert.8.in    |    2 ++
 man/lvcreate.8.in     |   11 +++++++++--
 tools/lvconvert.c     |    5 +++++
 tools/lvcreate.c      |   32 ++++++++++++++++++++++++++++----
 6 files changed, 61 insertions(+), 11 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index f1f1700..c6efcdc 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -66,8 +66,13 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
-// FIXME Increase this to 64
-#define DEFAULT_RAID_MAX_IMAGES 8 /* limited by kernel failed devices bitfield in superblock (raid4/5/6 max 253) */
+/* Limited by kernel failed devices bitfield in superblock (raid4/5/6 MD max 253) */
+/*
+ * FIXME: Increase these to 64 and further to the MD maximum
+ *	  once the SubLVs split and name shift got enhanced
+ */
+#define DEFAULT_RAID1_MAX_IMAGES 10
+#define DEFAULT_RAID_MAX_IMAGES 64
 #define DEFAULT_ALLOCATION_STRIPE_ALL_DEVICES 0 /* Don't stripe across all devices if not -i/--stripes given */
 
 #define DEFAULT_RAID_FAULT_POLICY "warn"
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index ce33e28..bf0d2c0 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -261,10 +261,17 @@ static void _check_raid_seg(struct lv_segment *seg, int *error_count)
 	if (seg->extents_copied > seg->area_len)
 		raid_seg_error_val("extents_copied too large", seg->extents_copied);
 
-	/* Default still 8, change! */
-	if (seg->area_count > DEFAULT_RAID_MAX_IMAGES) {
+	/* Default < 10, change once raid1 split shift and rename SubLVs works! */
+	if (seg_is_raid1(seg)) {
+		if (seg->area_count > DEFAULT_RAID1_MAX_IMAGES) {
+			log_error("LV %s invalid: maximum supported areas %u (is %u) for %s segment",
+			  	seg->lv->name, DEFAULT_RAID1_MAX_IMAGES, seg->area_count, lvseg_name(seg));
+				if ((*error_count)++ > ERROR_MAX)
+					return;
+		}
+	} else if (seg->area_count > DEFAULT_RAID_MAX_IMAGES) {
 		log_error("LV %s invalid: maximum supported areas %u (is %u) for %s segment",
-			  seg->lv->name, DEFAULT_RAID_MAX_IMAGES, seg->area_count, lvseg_name(seg));
+		  	seg->lv->name, DEFAULT_RAID_MAX_IMAGES, seg->area_count, lvseg_name(seg));
 			if ((*error_count)++ > ERROR_MAX)
 				return;
 	}
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 641e850..4f4d05e 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -338,6 +338,8 @@ VG/RaidLV
 \[bu]
 Change the number of images in raid1 RaidLV.
 
+Note the current maximum is 9 providing 10 raid1 legs.
+
 .B lvconvert \-\-splitmirrors
 Number
 VG/RaidLV
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 2873e72..bf3c33f 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -399,6 +399,9 @@ to configure default mirror segment type.
 The options
 \fB\-\-mirrorlog\fP and \fB\-\-corelog\fP apply
 to the legacy "\fImirror\fP" segment type only.
+
+Note the current maxima for mirrors are 7 for "mirror" providing
+8 mirror legs and 9 for "raid1" providing 10 legs.
 .
 .HP
 .BR \-\-mirrorlog
@@ -633,8 +636,12 @@ section of \fBlvm.conf (5)\fP or add
 \fB\-\-config allocation/raid_stripe_all_devices=1\fP
 .br
 to the command.
-.br
-Note the current limitation of 8 stripes total in any RaidLV including parity devices.
+
+Note the current maxima for stripes depend on the created RAID type.
+For raid10, the maximum of stripes is 32,
+for raid0, it is 64,
+for raid4/5, it is 63
+and for raid6 it is 62.
 
 See the \fB\-\-nosync\fP option to optionally avoid initial syncrhonization of RaidLVs.
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 72b4931..23e3cd5 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1910,6 +1910,11 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	if (lp->mirrors_supplied) {
 		if (!*lp->type_str || !strcmp(lp->type_str, SEG_TYPE_NAME_RAID1) || !strcmp(lp->type_str, SEG_TYPE_NAME_LINEAR) ||
 		    (!strcmp(lp->type_str, SEG_TYPE_NAME_STRIPED) && image_count == 1)) {
+			if (image_count > DEFAULT_RAID1_MAX_IMAGES) {
+				log_error("Only up to %u mirrors in %s LV %s supported currently.",
+					  DEFAULT_RAID1_MAX_IMAGES, lp->segtype->name, display_lvname(lv));
+				return 0;
+			}
 			if (!lv_raid_change_image_count(lv, image_count, lp->pvh))
 				return_0;
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 28d8c92..ccd07f0 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -527,8 +527,21 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 					struct lvcreate_params *lp)
 {
 	int pagesize = lvm_getpagesize();
-	unsigned max_images = segtype_is_raid(lp->segtype) ? DEFAULT_RAID_MAX_IMAGES :
-							     DEFAULT_MIRROR_MAX_IMAGES;
+	unsigned max_images;
+
+	if (seg_is_raid(lp)) {
+		if (seg_is_raid1(lp))
+			max_images = DEFAULT_RAID1_MAX_IMAGES;
+		else {
+			max_images = DEFAULT_RAID_MAX_IMAGES;
+			if (seg_is_raid4(lp) ||
+			    seg_is_any_raid5(lp))
+				max_images--;
+			else if (seg_is_any_raid6(lp))
+				max_images -= 2;
+		}
+	} else
+		max_images = DEFAULT_MIRROR_MAX_IMAGES;
 
 	/* Common mirror and raid params */
 	if (arg_is_set(cmd, mirrors_ARG)) {
@@ -556,8 +569,19 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 		/* Default to 2 mirrored areas if '--type mirror|raid1|raid10' */
 		lp->mirrors = seg_is_mirrored(lp) ? 2 : 1;
 
-	if (max(lp->mirrors, lp->stripes) > max_images) {
-		log_error("Only up to %u images in %s supported currently.",
+	/* FIMXE: raid10 check has to change once we support data copies and odd numbers of stripes */
+	if (seg_is_raid10(lp) && lp->mirrors * lp->stripes > max_images) {
+		log_error("Only up to %u stripes in %s supported currently.",
+			  max_images, lp->segtype->name);
+		return 0;
+	} else if (seg_is_mirrored(lp)) {
+		if (lp->mirrors > max_images) {
+			log_error("Only up to %u mirrors in %s supported currently.",
+				  max_images, lp->segtype->name);
+			return 0;
+		}
+	} else if (lp->stripes > max_images) {
+		log_error("Only up to %u stripes in %s supported currently.",
 			  max_images, lp->segtype->name);
 		return 0;
 	}


