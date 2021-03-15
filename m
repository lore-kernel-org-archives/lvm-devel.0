From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:00 +0000 (GMT)
Subject: main - thinpool: correct condition
Message-ID: <20210315101400.199583858039@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bbac843268ab353bb80a7f09841ff467bdcdeb04
Commit:        bbac843268ab353bb80a7f09841ff467bdcdeb04
Parent:        262008f1ceb050a9eed64f2fa50b1bc9366b9e75
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 11 13:33:24 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 12 12:59:55 2021 +0100

thinpool: correct condition

Actually we do want to flush thin-pool message for particular LV first.
Existing condition evaluated to noop.
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 4114e7d5c..2c77bacc2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6707,7 +6707,7 @@ int lv_remove_single(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* Clear thin pool stacked messages */
-	if (pool_lv && !pool_has_message(first_seg(pool_lv), lv, 0) &&
+	if (pool_lv && pool_has_message(first_seg(pool_lv), lv, 0) &&
 	    !update_pool_lv(pool_lv, 1)) {
 		if (force < DONT_PROMPT_OVERRIDE) {
 			log_error("Failed to update pool %s.", display_lvname(pool_lv));


