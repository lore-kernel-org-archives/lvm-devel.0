From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:47 +0000 (UTC)
Subject: master - cleanup: lvconvert reoder repair check
Message-ID: <20140711113447.B19F360E3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f703d35a0ac4f74934ff8c7dc9e5610986caff6
Commit:        9f703d35a0ac4f74934ff8c7dc9e5610986caff6
Parent:        4bbfac359c5e7e82a0600fa3d41bf7ea308e485f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jul 10 20:59:39 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 13:32:23 2014 +0200

cleanup: lvconvert reoder repair check

---
 tools/lvconvert.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 9710134..ff32f76 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3163,20 +3163,20 @@ static int _lvconvert_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (lp->splitsnapshot)
 		return _lvconvert_splitsnapshot(cmd, lv, lp);
 
-	if (arg_count(cmd, repair_ARG) && lv_is_pool(lv)) {
-		if (!_lvconvert_pool_repair(cmd, lv, lp))
-			return_ECMD_FAILED;
-		return ECMD_PROCESSED;
-	}
-
-	if (arg_count(cmd, repair_ARG) &&
-	    !(lv->status & MIRRORED) && !(lv->status & RAID)) {
-		if (arg_count(cmd, use_policies_ARG))
-			return ECMD_PROCESSED; /* nothing to be done here */
-		log_error("Can't repair LV \"%s\" of segtype %s.",
-			  lv->name,
-			  first_seg(lv)->segtype->ops->name(first_seg(lv)));
-		return ECMD_FAILED;
+	if (arg_count(cmd, repair_ARG)) {
+		if (lv_is_pool(lv)) {
+			if (!_lvconvert_pool_repair(cmd, lv, lp))
+				return_ECMD_FAILED;
+			return ECMD_PROCESSED;
+		}
+		if (!lv_is_mirrored(lv) && !lv_is_raid(lv)) {
+			if (arg_count(cmd, use_policies_ARG))
+				return ECMD_PROCESSED; /* nothing to be done here */
+			log_error("Can't repair LV \"%s\" of segtype %s.",
+				  lv->name,
+				  first_seg(lv)->segtype->ops->name(first_seg(lv)));
+			return ECMD_FAILED;
+		}
 	}
 
 	if (!lp->segtype) {


