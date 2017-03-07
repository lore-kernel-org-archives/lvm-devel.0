From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 7 Mar 2017 15:36:21 -0500
Subject: master - lvconvert: adjust --stripes on raid10 convert
Message-ID: <201703072036.v27KaL0a003841@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=05aceaffbd184c6b5d892d92a6c4d9db182da8f8
Commit:        05aceaffbd184c6b5d892d92a6c4d9db182da8f8
Parent:        f4b30b0daef3bac7f775dff29c21ac47fe5d82a7
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 7 21:36:03 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 7 21:36:03 2017 +0100

lvconvert: adjust --stripes on raid10 convert

For the time being raid10 is limited to even number of total stripes
as is and 2 data copies.  The number of stripes provided on creation
of a raid10(_near) LV with -i/--stripes gets doubled to define
that even total number of stripes (i.e. images).

Apply the same on disk adding conversions (reshapes) with
"lvconvert --stripes RaidLV" (e.g. 2 stripes = 4 images
total converted to 3 stripes = 6 images total).

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 6cc1c12..1a4a860 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5878,7 +5878,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		    struct dm_list *allocate_pvs)
 {
 	struct lv_segment *seg = first_seg(lv);
-	uint32_t stripes, stripe_size;
+	uint32_t stripes = new_stripes, stripe_size;
 	uint32_t new_image_count = seg->area_count;
 	uint32_t region_size = new_region_size;
 	uint32_t data_copies = seg->data_copies;
@@ -5890,7 +5890,10 @@ int lv_raid_convert(struct logical_volume *lv,
 		return 0;
 	}
 
-	stripes = new_stripes ? : _data_rimages_count(seg, seg->area_count);
+	if (seg_is_raid10(seg))
+		stripes *= 2;
+
+	stripes = stripes ? : _data_rimages_count(seg, seg->area_count);
 
 	/* FIXME Ensure caller does *not* set wrong default value! */
 	/* Define new stripe size if not passed in */


