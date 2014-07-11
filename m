From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 11 Jul 2014 11:34:13 +0000 (UTC)
Subject: master - lvconvert: snapshot prompts to confirm conversion
Message-ID: <20140711113413.999B06022E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=56c5ad7b194f5b991ae3835abca1c951450f34df
Commit:        56c5ad7b194f5b991ae3835abca1c951450f34df
Parent:        64828d877edbf1907557d76e44eb86d00f7a1f3a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 7 22:33:31 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jul 11 12:49:55 2014 +0200

lvconvert: snapshot prompts to confirm conversion

Since the type passed LV is changed and content of data detroyed,
query user with prompt to confirm this operation.
Also add a proper wiping of header.

Using '--yes' will skip this prompt:

lvconvert -s --yes vg/lv vg/lvcow
---
 WHATS_NEW                        |    1 +
 test/shell/lvconvert-snapshot.sh |    4 +++-
 tools/lvconvert.c                |   30 +++++++++++++++++++++++++-----
 3 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dcaaf23..7891d76 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.108 -
 =================================
+  Prompt for confirmation before change LV into a snapshot exception store.
   Return proper error codes for some failing lvconvert funtions.
   Add initial code to use cache tools (cache_check|dump|repair|restore).
   Add "degraded" activation mode and make it the default.
diff --git a/test/shell/lvconvert-snapshot.sh b/test/shell/lvconvert-snapshot.sh
index f59bb7b..3d81573 100644
--- a/test/shell/lvconvert-snapshot.sh
+++ b/test/shell/lvconvert-snapshot.sh
@@ -25,6 +25,7 @@ lvcreate -L1 -s -n $lv3 $vg/$lv2
 
 lvcreate -l1 -n $lv4 $vg
 lvcreate -L1 -n $lv5 $vg
+lvcreate -L1 -n $lv6 $vg
 
 not lvconvert -s $vg/$lv1 $vg/not_exist
 
@@ -52,6 +53,7 @@ not lvconvert -s $vg/$lv2 $vg/$lv4 2>&1 | tee err
 grep "smaller" err
 
 # This should pass
-lvconvert -s $vg/$lv2 $vg/$lv5
+lvconvert --yes -s $vg/$lv2 $vg/$lv5
+lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv6
 
 vgremove -f $vg
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 62a9d4e..264b86c 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2063,11 +2063,14 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (!lp->zero || !(lv->status & LVM_WRITE))
-		log_warn("WARNING: \"%s\" not zeroed", lv->name);
-	else if (!wipe_lv(lv, (struct wipe_params) { .do_zero = 1 })) {
-		log_error("Aborting. Failed to wipe snapshot "
-			  "exception store.");
+	log_warn("WARNING: Converting logical volume %s to snapshot exception store.",
+		 display_lvname(lv));
+	log_warn("THIS WILL DESTROY CONTENT OF LOGICAL VOLUME (filesystem etc.)");
+
+	if (!lp->yes &&
+	    yes_no_prompt("Do you really want to convert %s? [y/n]: ",
+			  display_lvname(lv)) == 'n') {
+		log_error("Conversion aborted.");
 		return 0;
 	}
 
@@ -2076,6 +2079,23 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!lp->zero || !(lv->status & LVM_WRITE))
+		log_warn("WARNING: \"%s\" not zeroed", lv->name);
+	else {
+		lv->status |= LV_TEMPORARY;
+		if (!activate_lv_local(cmd, lv) ||
+		    !wipe_lv(lv, (struct wipe_params) { .do_zero = 1 })) {
+			log_error("Aborting. Failed to wipe snapshot exception store.");
+			return 0;
+		}
+		lv->status &= ~LV_TEMPORARY;
+		/* Deactivates cleared metadata LV */
+		if (!deactivate_lv_local(lv->vg->cmd, lv)) {
+			log_error("Failed to deactivate zeroed snapshot exception store.");
+			return 0;
+		}
+	}
+
 	if (!archive(lv->vg))
 		return_0;
 


