From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 15:50:26 -0400
Subject: master - snapshot: fix reporting for merged old snapshot
Message-ID: <201706091950.v59JoQNa010262@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e7db7d85de7285eaee1867c73c10ee212c00631
Commit:        5e7db7d85de7285eaee1867c73c10ee212c00631
Parent:        b6945b85106620cb79730070e9a38ed93e7fc35a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 9 21:00:05 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 21:03:20 2017 +0200

snapshot: fix reporting for merged old snapshot

When old snapshot is merged, lvm2 still can report some data about
merged 'snapshot' - i.e. it occupied space in VG.

This patch fixes regression from commit:
6fd20be629b6dceb96702c5f875a2e612e6f465d

and resolved RHBZ: 1460161
---
 lib/activate/activate.c |    1 -
 tools/reporter.c        |    4 ++--
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a3978ad..282dd4f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -835,7 +835,6 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 				 * When merge is in progress, query merging origin LV instead.
 				 * COW volume is already mapped as error target in this case.
 				 */
-				status->lv = olv;
 				return 1;
 			}
 
diff --git a/tools/reporter.c b/tools/reporter.c
index 980f39c..912d3ab 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -172,7 +172,7 @@ static int _do_lvs_with_info_and_status_single(struct cmd_context *cmd,
 	if (lv_is_merging_origin(lv)) {
 		if (!_check_merging_origin(lv, &status, &merged))
 		      goto_out;
-		if (merged)
+		if (merged && lv_is_thin_volume(lv->snapshot->lv))
 			lv = lv->snapshot->lv;
 	}
 
@@ -234,7 +234,7 @@ static int _do_segs_with_info_and_status_single(struct cmd_context *cmd,
 	if (lv_is_merging_origin(seg->lv)) {
 		if (!_check_merging_origin(seg->lv, &status, &merged))
 			goto_out;
-		if (merged)
+		if (merged && lv_is_thin_volume(seg->lv->snapshot->lv))
 			seg = seg->lv->snapshot;
 	}
 


