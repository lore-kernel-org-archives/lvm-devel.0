From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:29 -0500
Subject: master - lvresize: check external origin with new size
Message-ID: <201802282022.w1SKMTQh009805@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=052f28746d1d90883f63e9fb1ef86efb03133fe7
Commit:        052f28746d1d90883f63e9fb1ef86efb03133fe7
Parent:        b09ea3b6f764f6a853b816da65aeb3d0d351f77c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 28 17:04:26 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:15:55 2018 +0100

lvresize: check external origin with new size

Instead of checking with existing size of external origin LV,
use correctly the new 'wanted' size of this LV whether it fits
the limitiation requirements for older thin-pool target.

Otherwise code started to the the resize, updates metadata and
just fails during 'resize' in case the LV was active. For
inactive LV operation could have actually passed.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 6a0a0dc..46f66b0 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Fix compatibility size test of extended external origin.
   Add external_origin visiting in for_each_sub_lv().
   Ensure cluster commands drop their device cache before locking VG.
   Do not report LV as remotely active when it's locally exclusive in cluster.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 12f444b..28f00ab 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5334,7 +5334,7 @@ static int _lvresize_check_type(const struct logical_volume *lv,
 
 		/* Validate thin target supports bigger size of thin volume then external origin */
 		if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv &&
-		    (lv->size > first_seg(lv)->external_lv->size) &&
+		    (lp->extents > first_seg(lv)->external_lv->le_count) &&
 		    !thin_pool_feature_supported(first_seg(lv)->pool_lv, THIN_FEATURE_EXTERNAL_ORIGIN_EXTEND)) {
 			log_error("Thin target does not support external origin smaller then thin volume.");
 			return 0;


