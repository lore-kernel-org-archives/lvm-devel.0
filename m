From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 09:44:12 -0500
Subject: master - lv_manip: better work with PERCENT_VG modifier with lvresize
Message-ID: <201901211444.x0LEiC7v020552@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=105a8edea1c4a77cc3681a7cc46a6a5c02656c5c
Commit:        105a8edea1c4a77cc3681a7cc46a6a5c02656c5c
Parent:        e689bfb5d5a9983205efbccf1e554fde52a0376a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 21 15:37:51 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 15:39:24 2019 +0100

lv_manip: better work with PERCENT_VG modifier with lvresize

Fixing recent commit 022ebb0cfebee4ac8fdbe4e0c61e85db1038a115
Resize already has size that needs to be counted with,
otherwise upsizing operation could turn into size reduction one.
---
 lib/metadata/lv_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8c9a933..00039ef 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5053,8 +5053,8 @@ static int _lvresize_extents_from_percent(const struct logical_volume *lv,
 		case PERCENT_VG:
 			lp->extents = percent_of_extents(lp->extents, vg->extent_count,
 							 (lp->sign != SIGN_MINUS));
-			if (lp->sign == SIGN_NONE && lp->extents > vg->free_count) {
-				lp->extents = vg->free_count;
+			if ((lp->sign == SIGN_NONE) && (lp->extents > (lv->le_count + vg->free_count))) {
+				lp->extents = lv->le_count + vg->free_count;
 				log_print_unless_silent("Reducing %u%%VG to remaining free space %s in VG.",
 							old_extents,
 							display_size(vg->cmd, (uint64_t)vg->extent_size * lp->extents));


