From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 14 Jul 2017 09:53:58 -0400
Subject: master - raid: add data_offset incompatibility segment type flag
Message-ID: <201707141353.v6EDrw30025151@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=34504855a70772e1de3f117a9a610860ead80981
Commit:        34504855a70772e1de3f117a9a610860ead80981
Parent:        1d69fc7c5e8ed301817253f6c8a9f8e806015a03
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jul 14 15:52:18 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jul 14 15:53:23 2017 +0200

raid: add data_offset incompatibility segment type flag

In order to reject out of place reshaping with segment data_offset
field on old runtime, add a respective segment type incompatibility
flag causing "+RESHAPE_DATA_OFFSET" to be suffixed to the segment
type name.
---
 lib/format_text/flags.c          |    1 +
 lib/metadata/metadata-exported.h |    3 ++-
 lib/metadata/raid_manip.c        |    5 +++++
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 88fb091..156d542 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -63,6 +63,7 @@ static const struct flag _lv_flags[] = {
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
 	{LV_RESHAPE, "RESHAPE", SEGTYPE_FLAG},
+	{LV_RESHAPE_DATA_OFFSET, "RESHAPE_DATA_OFFSET", SEGTYPE_FLAG},
 	{LV_RESHAPE_DELTA_DISKS_PLUS, "RESHAPE_DELTA_DISKS_PLUS", SEGTYPE_FLAG},
 	{LV_RESHAPE_DELTA_DISKS_MINUS, "RESHAPE_DELTA_DISKS_MINUS", SEGTYPE_FLAG},
 	{LV_REMOVE_AFTER_RESHAPE, "REMOVE_AFTER_RESHAPE", SEGTYPE_FLAG},
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 6c3d8d7..4e198d1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -145,7 +145,8 @@
 
 #define LV_RESHAPE		UINT64_C(0x1000000000000000)    /* Ongoing reshape (number of stripes, stripesize or raid algorithm change):
 								   used as SEGTYPE_FLAG to prevent activation on old runtime */
-/* Next unused flag:		UINT64_C(0x2000000000000000)    */
+#define LV_RESHAPE_DATA_OFFSET	UINT64_C(0x2000000000000000)    /* LV reshape flag data offset (out of place reshaping) */
+/* Next unused flag:		UINT64_C(0x4000000000000000)    */
 
 /* Format features flags */
 #define FMT_SEGMENTS		0x00000001U	/* Arbitrary segment params? */
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index e35b999..c207970 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1636,6 +1636,9 @@ static int _lv_alloc_reshape_space(struct logical_volume *lv,
 		/* Update and reload mapping for proper size of data SubLVs in the cluster */
 		if (!lv_update_and_reload(lv))
 			return_0;
+
+		/* Define out of place reshape (used as SEGTYPE_FLAG to avoid incompatible activations on old runtime) */
+		lv->status |= LV_RESHAPE_DATA_OFFSET;
 	}
 
 	/* Preset data offset in case we fail relocating reshape space below */
@@ -1729,6 +1732,8 @@ static int _lv_free_reshape_space_with_status(struct logical_volume *lv, enum al
 		if (!_lv_set_reshape_len(lv, 0))
 			return_0;
 
+		lv->status &= ~LV_RESHAPE_DATA_OFFSET;
+
 	} else if (where_it_was)
 		*where_it_was = alloc_none;
 


