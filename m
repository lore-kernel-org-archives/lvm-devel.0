From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 9 Jun 2017 16:23:18 -0400
Subject: master - raid: add reshape segtype flag support
Message-ID: <201706092023.v59KNI4j014089@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c916ec5ffd37cfb7be2101b93a2dc91aa2ef7f0
Commit:        1c916ec5ffd37cfb7be2101b93a2dc91aa2ef7f0
Parent:        305513178474d15adcba4785871c3f0321576fbe
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jun 9 21:31:09 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jun 9 22:23:04 2017 +0200

raid: add reshape segtype flag support

Prohibit activation of reshaping RaidLVs on incompatible
lvm2 runtime by storing e.g. 'raid5+RESHAPE' segment type
strings in the lvm2 metadata.  Incompatible runtime not
supporting reshaping won't be able to activate those thus
avoiding potential data corruption.

Any new non-reshaping lvconvert command will reset the
segment type string from 'raid5+RESHAPE' to 'raid5'.

See commits
0299a7af1ec1eeb11388ed15c4c78f224fee76b2 and
4141409eb09e78aef030346995f1722fb40956d8
for segtype flag support.
---
 lib/format_text/flags.c          |    1 +
 lib/metadata/metadata-exported.h |    5 ++++-
 lib/metadata/raid_manip.c        |   17 ++++++++++++++++-
 3 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index d86ceb7..a9548e0 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -62,6 +62,7 @@ static const struct flag _lv_flags[] = {
 	{LOCKED, "LOCKED", STATUS_FLAG},
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
+	{LV_RESHAPE, "RESHAPE", SEGTYPE_FLAG},
 	{LV_RESHAPE_DELTA_DISKS_PLUS, "RESHAPE_DELTA_DISKS_PLUS", STATUS_FLAG},
 	{LV_RESHAPE_DELTA_DISKS_MINUS, "RESHAPE_DELTA_DISKS_MINUS", STATUS_FLAG},
 	{LV_REMOVE_AFTER_RESHAPE, "REMOVE_AFTER_RESHAPE", STATUS_FLAG},
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 8b4310b..c4bebd0 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -142,7 +142,10 @@
 
 #define LV_REMOVE_AFTER_RESHAPE	UINT64_C(0x0400000000000000)	/* LV needs to be removed after a shrinking reshape */
 #define LV_METADATA_FORMAT	UINT64_C(0x0800000000000000)    /* LV has segments with metadata format */
-/* Next unused flag:		UINT64_C(0x1000000000000000)    */
+
+#define LV_RESHAPE		UINT64_C(0x1000000000000000)    /* Ongoing reshape (number of stripes, stripesize or raid algorithm change):
+								   used as SEGTYPE_FLAG to prevent activation on old runtime */
+/* Next unused flag:		UINT64_C(0x2000000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 5db4a8e..fd51964 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1637,6 +1637,8 @@ static int _lv_free_reshape_space_with_status(struct logical_volume *lv, enum al
 	} else if (where_it_was)
 		*where_it_was = alloc_none;
 
+	lv->status &= ~LV_RESHAPE;
+
 	return 1;
 }
 
@@ -1844,6 +1846,9 @@ static int _raid_reshape_add_images(struct logical_volume *lv,
 
 	seg->stripe_size = new_stripe_size;
 
+	/* Define image adding reshape (used as SEGTYPE_FLAG to avoid incompatible activations on old runtime) */
+	lv->status |= LV_RESHAPE;
+
 	return 1;
 }
 
@@ -1943,6 +1948,8 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 		if (seg_is_any_raid5(seg) && new_image_count == 2)
 			seg->data_copies = 2;
 
+		/* Define image removing reshape (used as SEGTYPE_FLAG to avoid incompatible activations on old runtime) */
+		lv ->status |= LV_RESHAPE;
 		break;
 
 	case 1:
@@ -1981,7 +1988,6 @@ static int _raid_reshape_remove_images(struct logical_volume *lv,
 			return 0;
 
 		seg->area_count = new_image_count;
-
 		break;
 
 	default:
@@ -2054,6 +2060,9 @@ static int _raid_reshape_keep_images(struct logical_volume *lv,
 
 	seg->segtype = new_segtype;
 
+	/* Define stripesize/raid algorithm reshape (used as SEGTYPE_FLAG to avoid incompatible activations on old runtime) */
+	lv->status |= LV_RESHAPE;
+
 	return 1;
 }
 
@@ -2237,6 +2246,8 @@ static int _raid_reshape(struct logical_volume *lv,
 		return 0;
 	}
 
+	lv->status &= ~LV_RESHAPE; /* Reset any reshaping segtype flag */
+
 	dm_list_init(&removal_lvs);
 
 	/* No change in layout requested ? */
@@ -6040,6 +6051,8 @@ static int _region_size_change_requested(struct logical_volume *lv, int yes, con
 		return 0;
 	}
 
+	lv->status &= ~LV_RESHAPE;
+
 	if (!lv_update_and_reload_origin(lv))
 		return_0;
 
@@ -6291,6 +6304,8 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
+	lv->status &= ~LV_RESHAPE;
+
 	return takeover_fn(lv, new_segtype, yes, force, new_image_count, 0, new_stripes, stripe_size,
 			   region_size, allocate_pvs);
 }


