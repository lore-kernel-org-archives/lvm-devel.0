From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 29 Oct 2013 12:34:46 +0000 (UTC)
Subject: master - lvconvert: use LV_TEMPORARY when necessary during lvconvert to thin pool
Message-ID: <20131029123446.2FB74613AE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f1a42aa8ec4c6d693b57832a8575ee68b9e71b12
Commit:        f1a42aa8ec4c6d693b57832a8575ee68b9e71b12
Parent:        9d0621267d644d21d3c1ad3a5268af0ef3d7eb9a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Oct 29 13:18:14 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Oct 29 13:33:35 2013 +0100

lvconvert: use LV_TEMPORARY when necessary during lvconvert to thin pool

This is an addition to original patch for lvcreate - commit 039bdad.
The same principle applies to lvconvert where there are several steps
during which we need to wipe the existing LV that's being converted
to thin pool, making sure there's no other interference from outside (udev).
---
 tools/lvconvert.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a6c1187..92a2022 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2435,14 +2435,8 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 			goto mda_write;
 		}
 
-		metadata_lv->status |= LV_NOSCAN;
-		if (!lv_is_active(metadata_lv) &&
-		    !activate_lv_local(cmd, metadata_lv)) {
-			log_error("Aborting. Failed to activate thin metadata lv.");
-			return 0;
-		}
-		if (!set_lv(cmd, metadata_lv, UINT64_C(0), 0)) {
-			log_error("Aborting. Failed to wipe thin metadata lv.");
+		if (!deactivate_lv(cmd, metadata_lv)) {
+			log_error("Aborting. Failed to deactivate thin metadata lv.");
 			return 0;
 		}
 
@@ -2462,6 +2456,16 @@ static int _lvconvert_thinpool(struct cmd_context *cmd,
 					&lp->thin_chunk_size_calc_policy, &lp->chunk_size,
 					&lp->discards, &lp->poolmetadata_size, &lp->zero))
 			return_0;
+
+		metadata_lv->status |= LV_TEMPORARY;
+		if (!activate_lv_local(cmd, metadata_lv)) {
+			log_error("Aborting. Failed to activate thin metadata lv.");
+			return 0;
+		}
+		if (!set_lv(cmd, metadata_lv, UINT64_C(0), 0)) {
+			log_error("Aborting. Failed to wipe thin metadata lv.");
+			return 0;
+		}
 	}
 
 	if (!deactivate_lv(cmd, metadata_lv)) {


