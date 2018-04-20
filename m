From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 20 Apr 2018 07:02:05 -0400
Subject: master - mirror: validate region_size for mirrors
Message-ID: <201804201102.w3KB25X5031259@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=79d214032b21074709cd24669f53b5e24c5c377d
Commit:        79d214032b21074709cd24669f53b5e24c5c377d
Parent:        1693fef529e7e1536d91956cfc4256c98cae58ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 19 17:38:04 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 20 12:16:13 2018 +0200

mirror: validate region_size for mirrors

Check for region size properties of mirror segments.
---
 WHATS_NEW            |    1 +
 lib/metadata/merge.c |    8 ++++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 434f4a0..2d085a1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Extend validation of region_size for mirror segment.
   Reload whole device stack when reinitilizing mirror log.
   Mirrors without monitoring are WARNING and not blocking on error.
   Detect too big region_size with clustered mirrors.
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index f0da2fe..90b40e2 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -391,6 +391,14 @@ static void _check_lv_segment(struct logical_volume *lv, struct lv_segment *seg,
 			if (!(seg2 = first_seg(seg->log_lv)) || (find_mirror_seg(seg2) != seg))
 				seg_error("log LV does not point back to mirror segment");
 		}
+		if (seg_is_mirror(seg)) {
+			if (!seg->region_size)
+				seg_error("region size is zero");
+			else if (seg->region_size > seg->lv->size)
+				seg_error("region size is bigger then LV itself");
+			else if (!is_power_of_2(seg->region_size))
+				seg_error("region size is non power of 2");
+		}
 	} else { /* !mirrored */
 		if (seg->log_lv) {
 			if (lv_is_raid_image(lv))


