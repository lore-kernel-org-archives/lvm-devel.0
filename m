From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 19:39:51 +0000 (GMT)
Subject: main - lvremove: correct return code
Message-ID: <20210308193951.AB0423950423@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=843ee943ab4ff9d05817c6b59bd778cc4182ccc2
Commit:        843ee943ab4ff9d05817c6b59bd778cc4182ccc2
Parent:        3cbb751815ed545df905d49716444314beb5996c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 8 20:24:04 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 20:24:04 2021 +0100

lvremove: correct return code

Need to return ECMD_FAILED from toollib code.
Add missing stack traces.
---
 lib/metadata/lv_manip.c | 4 ++--
 tools/toollib.c         | 5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5573e6f43..f580e5835 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6610,7 +6610,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 			    !lv_is_pending_delete(lv) &&
 			    lv_is_visible(lv)) {
 				if (vg->needs_write_and_commit && (!vg_write(vg) || !vg_commit(vg)))
-					return 0;
+					return_0;
 				if (yes_no_prompt("Do you really want to remove%s active "
 						  "%slogical volume %s? [y/n]: ",
 						  ask_discard ? " and DISCARD" : "",
@@ -6651,7 +6651,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!lv_is_historical(lv) && (force == PROMPT) && ask_discard) {
 		/* try to store on disks already confirmed removals */
 		if (vg->needs_write_and_commit && (!vg_write(vg) || !vg_commit(vg)))
-			return 0;
+			return_0;
 		if (yes_no_prompt("Do you really want to remove and DISCARD "
 				  "logical volume %s? [y/n]: ",
 				  display_lvname(lv)) == 'n') {
diff --git a/tools/toollib.c b/tools/toollib.c
index 41e722c5c..28bfb8398 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3218,9 +3218,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (vg->needs_write_and_commit && (ret_max == ECMD_PROCESSED) &&
 	    (!vg_write(vg) || !vg_commit(vg)))
-		return_0;
-
-	if (vg->needs_backup)
+		ret_max = ECMD_FAILED;
+	else if (vg->needs_backup)
 		backup(vg);
 
 	if (lvargs_supplied) {


