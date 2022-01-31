From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 31 Jan 2022 13:57:30 +0000 (GMT)
Subject: main - activation: use lv_is_active
Message-ID: <20220131135730.43BBB3858C20@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b36fce26a29cece9f3e11f081e9ac44c90a0ab0c
Commit:        b36fce26a29cece9f3e11f081e9ac44c90a0ab0c
Parent:        f8d12913e78e25120ca41d8d6938ec3a423274f5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 30 15:30:48 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 31 14:56:11 2022 +0100

activation: use lv_is_active

Use existing lv_is_active
---
 tools/lvchange.c  | 4 +---
 tools/lvconvert.c | 8 +++-----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 879999766..d9c1bc688 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -171,9 +171,7 @@ static int _lvchange_monitoring(struct cmd_context *cmd,
 static int _lvchange_background_polling(struct cmd_context *cmd,
 					struct logical_volume *lv)
 {
-	struct lvinfo info;
-
-	if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists) {
+	if (!lv_is_active(lv)) {
 		log_error("Logical volume %s is not active.", display_lvname(lv));
 		return 0;
 	}
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 34b82ea02..a3eb60b20 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2231,7 +2231,7 @@ static int _lvconvert_merge_old_snapshot(struct cmd_context *cmd,
 			/* Race during table reload prevented merging */
 			merge_on_activate = 1;
 
-		} else if (!lv_info(cmd, origin, 0, &info, 0, 0) || !info.exists) {
+		} else if (!lv_is_active(origin)) {
 			log_print_unless_silent("Conversion starts after activation.");
 			merge_on_activate = 1;
 		} else {
@@ -3687,7 +3687,6 @@ static int _lvconvert_repair_pvs_mirror(struct cmd_context *cmd, struct logical_
 	struct lvconvert_result *lr = (struct lvconvert_result *) handle->custom_handle;
 	struct lvconvert_params lp = { 0 };
 	struct convert_poll_id_list *idl;
-	struct lvinfo info;
 	int ret;
 
 	/*
@@ -3721,7 +3720,7 @@ static int _lvconvert_repair_pvs_mirror(struct cmd_context *cmd, struct logical_
 	ret = _lvconvert_mirrors_repair(cmd, lv, &lp, use_pvh);
 
 	if (lp.need_polling) {
-		if (!lv_info(cmd, lv, 0, &info, 0, 0) || !info.exists)
+		if (!lv_is_active(lv))
 			log_print_unless_silent("Conversion starts after activation.");
 		else {
 			if (!(idl = _convert_poll_id_list_create(cmd, lv)))
@@ -5061,7 +5060,6 @@ static int _lvconvert_raid_types_single(struct cmd_context *cmd, struct logical_
 	struct lvconvert_params *lp = (struct lvconvert_params *) handle->custom_handle;
 	struct dm_list *use_pvh;
 	struct convert_poll_id_list *idl;
-	struct lvinfo info;
 	int ret;
 
 	if (cmd->position_argc > 1) {
@@ -5083,7 +5081,7 @@ static int _lvconvert_raid_types_single(struct cmd_context *cmd, struct logical_
 
 	if (lp->need_polling) {
 		/* _lvconvert() call may alter the reference in lp->lv_to_poll */
-		if (!lv_info(cmd, lp->lv_to_poll, 0, &info, 0, 0) || !info.exists)
+		if (!lv_is_active(lp->lv_to_poll))
 			log_print_unless_silent("Conversion starts after activation.");
 		else {
 			if (!(idl = _convert_poll_id_list_create(cmd, lp->lv_to_poll)))


