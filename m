From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri, 24 Feb 2017 06:32:21 +0000 (UTC)
Subject: master - lvconvert: add infrastructure for RaidLV reshaping support
Message-ID: <20170224063221.D049460AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d74de3f05d44b2ac5f651e49d29878731a114a1
Commit:        2d74de3f05d44b2ac5f651e49d29878731a114a1
Parent:        34a8d3c2fdc9da2bb1974781070d01f901862b9a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 24 03:46:14 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 24 05:20:58 2017 +0100

lvconvert: add infrastructure for RaidLV reshaping support

In order to support striped raid5/6/10 LV reshaping (change
of LV type, stripesize or number of legs), this patch
introduces more local infrastructure to raid_manip.c
used by followup patches.

Change:
- enhance _clear_meta_lvs() to support raid0 allowing
  raid0_meta -> raid10 conversions to succeed by clearing
  the raid0 rmeta images or the kernel will fail because
  of discovering reordered raid devices

Related: rhbz834579
Related: rhbz1191935
Related: rhbz1191978
---
 lib/metadata/raid_manip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 2b5559a..fc02d3d 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4579,6 +4579,7 @@ static int _raid1_to_mirrored_wrapper(TAKEOVER_FN_ARGS)
  * order to wipe them then reattach and set back to raid0_meta.
  *
  * Same applies to raid4 <-> raid5.
+ * Same applies to raid10 -> raid0_meta.
  */
 static int _clear_meta_lvs(struct logical_volume *lv)
 {
@@ -4588,11 +4589,11 @@ static int _clear_meta_lvs(struct logical_volume *lv)
 	const struct segment_type *tmp_segtype;
 	struct dm_list meta_lvs;
 	struct lv_list *lvl_array, *lvl;
-	int is_raid4_or_5N = seg_is_raid4(seg) || seg_is_raid5_n(seg);
+	int is_raid45n10 = seg_is_raid4(seg) || seg_is_raid5_n(seg) || seg_is_raid10(seg);
 
 	/* Reject non-raid0_meta/raid4/raid5_n segment types cautiously */
 	if (!seg->meta_areas ||
-	    (!seg_is_raid0_meta(seg) && !is_raid4_or_5N))
+	    (!seg_is_raid0_meta(seg) && !is_raid45n10))
 		return_0;
 
 	if (!(lvl_array = dm_pool_alloc(lv->vg->vgmem, seg->area_count * sizeof(*lvl_array))))


