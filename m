From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 Apr 2019 07:31:12 -0400
Subject: stable-2.02 - lv_manip: better work with PERCENT_VG modifier
Message-ID: <201904301131.x3UBVCKS020501@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e79e092f8bd41d3d589be0a10ac5addeaa8a3126
Commit:        e79e092f8bd41d3d589be0a10ac5addeaa8a3126
Parent:        4729b4af0bee2e742ed4f765dd6dc8d72f808521
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 18 22:27:02 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 30 12:24:53 2019 +0200

lv_manip: better work with PERCENT_VG modifier

When using 'lvcreate -l100%VG' and there is big disproportion between
real available space and requested setting - automatically fallback
to 100%FREE.

Difference can be seen when VG is big and already most space was
allocated, so the requestion 100%VG can end (and by spec for % modifier
it's correct) as LV with size of 1%VG.  Usually this is not a big
problem - buit in some cases - like cache-pool allocation, this
can result a big difference for chunksize selection.

With this patch it's more closely match common-sense logic without
the need of reitteration of too big changes in lvm2 core ATM.

TODO: in the future there should be allocator solving all allocations
in a single call.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    6 ++++++
 tools/lvcreate.c        |    6 ++++++
 3 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dc2c4af..4b73ccc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.185 - 
 ==================================
+  Improve -lXXX%VG modifier which improves cache segment estimation.
   Add synchronization with udev before removing cached devices.
   Fix missing growth of _pmsmare volume when extending _tmeta volume.
   Automatically grow thin metadata, when thin data gets too big.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f960fad..9e7eff9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4925,6 +4925,12 @@ static int _lvresize_extents_from_percent(const struct logical_volume *lv,
 		case PERCENT_VG:
 			lp->extents = percent_of_extents(lp->extents, vg->extent_count,
 							 (lp->sign != SIGN_MINUS));
+			if ((lp->sign == SIGN_NONE) && (lp->extents > (lv->le_count + vg->free_count))) {
+				lp->extents = lv->le_count + vg->free_count;
+				log_print_unless_silent("Reducing %u%%VG to remaining free space %s in VG.",
+							old_extents,
+							display_size(vg->cmd, (uint64_t)vg->extent_size * lp->extents));
+			}
 			break;
 		case PERCENT_FREE:
 			lp->extents = percent_of_extents(lp->extents, vg->free_count,
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 867cde1..6e8cc90 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -277,6 +277,12 @@ static int _update_extents_params(struct volume_group *vg,
 	switch (lcp->percent) {
 		case PERCENT_VG:
 			extents = percent_of_extents(lp->extents, base_calc_extents = vg->extent_count, 0);
+			if (extents > vg->free_count) {
+				extents = vg->free_count;
+				log_print_unless_silent("Reducing %u%%VG to remaining free space %s in VG.",
+							lp->extents,
+							display_size(vg->cmd, (uint64_t)vg->extent_size * extents));
+			}
 			break;
 		case PERCENT_FREE:
 			extents = percent_of_extents(lp->extents, base_calc_extents = vg->free_count, 0);


