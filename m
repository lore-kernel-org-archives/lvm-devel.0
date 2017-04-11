From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 11 Apr 2017 19:29:16 -0400
Subject: master - lvconvert: add segment type raid10_near
Message-ID: <201704112329.v3BNTGAM026127@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=01b5820d03c41516222675eb458ce6eb3dff53a7
Commit:        01b5820d03c41516222675eb458ce6eb3dff53a7
Parent:        7bc85177b08c7a6f4f0c3384c8d05b9089267c14
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Apr 12 01:28:22 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Apr 12 01:28:22 2017 +0200

lvconvert: add segment type raid10_near

Introducing this alias for "raid10", avoid allocating
reshape space when converting between them.

Resolves: rhbz1441347
---
 lib/metadata/raid_manip.c |   27 +++++++++++++++++++++++----
 lib/metadata/segtype.h    |   10 ++++++----
 lib/raid/raid.c           |    1 +
 libdm/libdm-deptree.c     |    1 +
 4 files changed, 31 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4662736..f99788f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1976,6 +1976,7 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
  * Reshape: keep images in RAID @lv but change stripe size or data copies
  *
  */
+static const char *_get_segtype_alias(const struct segment_type *segtype);
 static int _raid_reshape_keep_images(struct logical_volume *lv,
 				     const struct segment_type *new_segtype,
 				     int yes, int force, int *force_repair,
@@ -1995,8 +1996,6 @@ static int _raid_reshape_keep_images(struct logical_volume *lv,
 			return 0;
 	}
 
-	seg->stripe_size = new_stripe_size;
-
 	/*
 	 * Reshape layout alogorithm or chunksize:
 	 *
@@ -2010,8 +2009,22 @@ static int _raid_reshape_keep_images(struct logical_volume *lv,
 	 * The dm-raid target is able to use the space whereever it
 	 * is found by appropriately selecting forward or backward reshape.
 	 */
-	if (seg->area_count != 2 &&
-	    alloc_reshape_space &&
+	if (seg->segtype != new_segtype) {
+		const char *alias = _get_segtype_alias(seg->segtype);
+
+		if (!strcmp(alias, new_segtype->name))
+			alloc_reshape_space = 0;
+	}
+
+	if (seg->stripe_size != new_stripe_size)
+		alloc_reshape_space = 1;
+
+	seg->stripe_size = new_stripe_size;
+
+	if (seg->area_count == 2)
+		alloc_reshape_space = 0;
+
+	if (alloc_reshape_space &&
 	    !_lv_alloc_reshape_space(lv, where, NULL, allocate_pvs))
 		return 0;
 
@@ -4411,6 +4424,12 @@ static const char *_get_segtype_alias(const struct segment_type *segtype)
 	if (!strcmp(segtype->name, SEG_TYPE_NAME_RAID6_ZR))
 		return SEG_TYPE_NAME_RAID6;
 
+	if (!strcmp(segtype->name, SEG_TYPE_NAME_RAID10))
+		return SEG_TYPE_NAME_RAID10_NEAR;
+
+	if (!strcmp(segtype->name, SEG_TYPE_NAME_RAID10_NEAR))
+		return SEG_TYPE_NAME_RAID10;
+
 	return "";
 }
 
diff --git a/lib/metadata/segtype.h b/lib/metadata/segtype.h
index 0eea6e6..93132c3 100644
--- a/lib/metadata/segtype.h
+++ b/lib/metadata/segtype.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -89,6 +89,7 @@ struct dev_manager;
 #define SEG_TYPE_NAME_RAID0_META	"raid0_meta"
 #define SEG_TYPE_NAME_RAID1		"raid1"
 #define SEG_TYPE_NAME_RAID10		"raid10"
+#define SEG_TYPE_NAME_RAID10_NEAR	"raid10_near"
 #define SEG_TYPE_NAME_RAID4		"raid4"
 #define SEG_TYPE_NAME_RAID5		"raid5"
 #define SEG_TYPE_NAME_RAID5_N		"raid5_n"
@@ -137,11 +138,12 @@ struct dev_manager;
 #define segtype_is_raid6_rs_6(segtype)	((segtype)->flags & SEG_RAID6_RS_6 ? 1 : 0)
 #define segtype_is_raid6_la_6(segtype)	((segtype)->flags & SEG_RAID6_LA_6 ? 1 : 0)
 #define segtype_is_raid6_ra_6(segtype)	((segtype)->flags & SEG_RAID6_RA_6 ? 1 : 0)
-#define segtype_is_any_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
 #define segtype_is_raid10(segtype)	((segtype)->flags & SEG_RAID10 ? 1 : 0)
-#define segtype_is_raid10_near(segtype)	segtype_is_raid10(segtype)
-/* FIXME: once raid10_offset supported */
+#define segtype_is_raid10_near(segtype)	((segtype)->flags & SEG_RAID10_NEAR ? 1 : 0)
+/* FIXME: once raid10_{far,offset} supported */
+#define segtype_is_raid10_far(segtype)		0 /* FIXME ((segtype)->flags & SEG_RAID10_FAR ? 1 : 0 */
 #define segtype_is_raid10_offset(segtype)	0 /* FIXME ((segtype)->flags & SEG_RAID10_OFFSET ? 1 : 0 */
+#define segtype_is_any_raid10(segtype)	(segtype_is_raid10(segtype) || segtype_is_raid10_near(segtype) || segtype_is_raid10_far(segtype) || segtype_is_raid10_offset(segtype))
 #define segtype_is_raid_with_meta(segtype)	(segtype_is_raid(segtype) && !segtype_is_raid0(segtype))
 #define segtype_is_striped_raid(segtype)        (segtype_is_raid(segtype) && !segtype_is_raid1(segtype))
 #define segtype_is_reshapable_raid(segtype)     ((segtype_is_striped_raid(segtype) && !segtype_is_any_raid0(segtype)) || segtype_is_raid10_near(segtype) || segtype_is_raid10_offset(segtype))
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index df9796d..25009f6 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -599,6 +599,7 @@ static const struct raid_type {
 	{ SEG_TYPE_NAME_RAID0_META, 0, SEG_RAID0_META | SEG_AREAS_STRIPED },
 	{ SEG_TYPE_NAME_RAID1,      0, SEG_RAID1 | SEG_AREAS_MIRRORED },
 	{ SEG_TYPE_NAME_RAID10,     0, SEG_RAID10 | SEG_AREAS_MIRRORED },
+	{ SEG_TYPE_NAME_RAID10_NEAR,0, SEG_RAID10_NEAR | SEG_AREAS_MIRRORED },
 	{ SEG_TYPE_NAME_RAID4,      1, SEG_RAID4 },
 	{ SEG_TYPE_NAME_RAID5,      1, SEG_RAID5 },
 	{ SEG_TYPE_NAME_RAID5_N,    1, SEG_RAID5_N },
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index a25d4c3..80bfc1b 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -108,6 +108,7 @@ static const struct {
 	 */
 	{ SEG_RAID5_LS, "raid5"}, /* same as "raid5_ls" (default for MD also) */
 	{ SEG_RAID6_ZR, "raid6"}, /* same as "raid6_zr" */
+	{ SEG_RAID10, "raid10_near"}, /* same as "raid10" */
 };
 
 /* Some segment types have a list of areas of other devices attached */


