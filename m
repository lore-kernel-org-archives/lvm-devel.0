From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:19 +0000 (GMT)
Subject: main - debug: update message
Message-ID: <20210315101419.7E77B3857C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f69ff4b84a559a5795479489cf834fc0c3999e8d
Commit:        f69ff4b84a559a5795479489cf834fc0c3999e8d
Parent:        6e9ccf7b6f58cd3e31a79c35d3a312560809e85a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 14 13:15:50 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 15 11:13:24 2021 +0100

debug: update message

---
 lib/metadata/lv_manip.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6fc7afbac..12b1505df 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6799,7 +6799,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (!suppress_remove_message && (visible || historical)) {
 		(void) dm_snprintf(msg, sizeof(msg),
-				   "%sogical volume \"%s\" successfully removed",
+				   "%sogical volume \"%s\" successfully removed.",
 				   historical ? "Historical l" : "L",
 				   historical ? lv->this_glv->historical->name : lv->name);
 		if (!vg->needs_write_and_commit)
@@ -6820,11 +6820,11 @@ static int _lv_remove_segs_using_this_lv(struct cmd_context *cmd, struct logical
 	struct seg_list *sl;
 
 	if ((force == PROMPT) &&
-	    yes_no_prompt("Removing %s \"%s\" will remove %u dependent volume(s). "
-			  "Proceed? [y/n]: ", lv_type, lv->name,
+	    yes_no_prompt("Removing %s %s will remove %u dependent volume(s). "
+			  "Proceed? [y/n]: ", lv_type, display_lvname(lv),
 			  dm_list_size(&lv->segs_using_this_lv)) == 'n') {
 		lv->to_remove = 0;
-		log_error("Logical volume \"%s\" not removed.", lv->name);
+		log_error("Logical volume %s not removed.", display_lvname(lv));
 		return 0;
 	}
 


