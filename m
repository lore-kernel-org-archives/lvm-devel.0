From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Jun 2013 12:08:57 +0000 (UTC)
Subject: master - snapshots: check for active state
Message-ID: <20130611120857.A89E761498@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=272f5ae208d20dc56599e61b37e74afac05a1140
Commit:        272f5ae208d20dc56599e61b37e74afac05a1140
Parent:        1cdb6ca2b246bf5dc680abde3b0a2ea0192f1aaf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 11 13:07:13 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 11 13:57:18 2013 +0200

snapshots: check for active state

Fix testing if the snapshot could be resized and use lv_is_active()
to get correct answer in cluster.
---
 WHATS_NEW        |    1 +
 tools/lvresize.c |    3 +--
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fe42b81..57aab93 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Fix test for active snapshot in cluster before resizing it.
   Report backtrace from dump filter error path.
   Do not use persistent filter with lvmetad.
   Composable persistent filter functionality for global filter.
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 558dff0..f552992 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -362,7 +362,6 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 		     struct lvresize_params *lp)
 {
 	struct logical_volume *lv;
-	struct lvinfo info;
 	uint32_t stripesize_extents;
 	uint32_t seg_stripes = 0, seg_stripesize = 0, seg_size;
 	uint32_t seg_mirrors = 0;
@@ -762,7 +761,7 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			return ECMD_FAILED;
 		}
 
-		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists) {
+		if (lv_is_active(lv)) {
 			log_error("Snapshot origin volumes can be resized "
 				  "only while inactive: try lvchange -an");
 			return ECMD_FAILED;


