From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Sep 2020 21:46:49 +0000 (GMT)
Subject: master - vdo: enhance vdo pool extension
Message-ID: <20200922214649.55A1C385780B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a3307c0d8029f545a31d305a23a0dec2ece65f2
Commit:        3a3307c0d8029f545a31d305a23a0dec2ece65f2
Parent:        f38b7afd62533041ec68b10349169efb70c37d82
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 22 23:25:58 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 22 23:28:43 2020 +0200

vdo: enhance vdo pool extension

When user tries to extend vdo pool - he needs to go always
at least by 1 full VDO slab  (defined as  vdo_slab_size_mb).

To avoid all trouble around find 'workable' size - lvm2 automatically
increases the passed (or by --use-policies calculated) extension size
(and informs a user about sometimes possibly large increase as slab
size can go upto 32GiB)

With VDO users need to always 'think-big' anyway and expect such
operation to be in GiB domain range.
---
 WHATS_NEW               |  1 +
 lib/metadata/lv_manip.c | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4be9b8bad..ad3cbde6a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Lvextend of vdo pool volumes ensure at least 1 new VDO slab is added.
   Use revert_lv() on reload error path after vg_revert().
   Configure --with-integrity enabled.
   Restore lost signal blocking while VG lock is held.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index fc0acd6ee..9f15e9f21 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5465,6 +5465,27 @@ static int _lvresize_adjust_extents(struct logical_volume *lv,
 		else
 			seg_size = lp->extents - existing_extents;
 
+		if (lv_is_vdo_pool_data(lv)) {
+			if (!(seg = get_only_segment_using_this_lv(lv)))
+				return_0;
+			/* Min growth is defined this way:  max(1 slab, 128M + 128K (recovery journal + slab summary)) */
+			new_extents = max(seg->vdo_params.slab_size_mb * 1024, UINT32_C(128 * 1024 + 128));
+			new_extents *= (1024 >> SECTOR_SHIFT); /* minimal growth (~128MiB..32GiB) in sectors */
+
+			if (new_extents > vg->extent_size) {
+				/* Minimal growth in extent size units */
+				new_extents = (new_extents + vg->extent_size - 1) / vg->extent_size;
+
+				if (new_extents > seg_size) {
+					/* Notify user about extra increase of extension */
+					log_print_unless_silent("Increasing incremention size from %s to %s to fit new VDO slab.",
+								display_size(cmd, (uint64_t)seg_size * vg->extent_size),
+								display_size(cmd, (uint64_t)new_extents * vg->extent_size));
+					seg_size = new_extents;
+				}
+			}
+		}
+
 		/* Convert PEs to LEs */
 		if (lp->extents_are_pes && !seg_is_striped(seg_last) && !seg_is_virtual(seg_last)) {
 			area_multiple = _calc_area_multiple(seg_last->segtype, seg_last->area_count, 0);


