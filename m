From: David Teigland <teigland@sourceware.org>
Date: Tue, 27 Sep 2022 18:01:13 +0000 (GMT)
Subject: main - lvreduce: use temporary flag when activating lv to check for fs
Message-ID: <20220927180113.DA5CD3858C52@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3ca44e13beb8532d19828c71540af0d0307fd017
Commit:        3ca44e13beb8532d19828c71540af0d0307fd017
Parent:        c1ab9fb37faee56cee278ccd94cb958d30d61b94
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 27 12:59:17 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 27 12:59:17 2022 -0500

lvreduce: use temporary flag when activating lv to check for fs

This flag is meant to suppress udev processing of the LV.
---
 lib/metadata/lv_manip.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 71aee7fb7..f2ec5d99c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6856,10 +6856,12 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 	is_active = lv_is_active(lv_top);
 
 	if (is_reduce && !is_active && !strcmp(lp->fsopt, "checksize")) {
+		lv_top->status |= LV_TEMPORARY;
 		if (!activate_lv(cmd, lv_top)) {
 			log_error("Failed to activate %s to check for fs.", display_lvname(lv_top));
 			goto out;
 		}
+		lv_top->status &= ~LV_TEMPORARY;
 		if (!sync_local_dev_names(cmd))
 			stack;
 		activated_checksize = 1;

