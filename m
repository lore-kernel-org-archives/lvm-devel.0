From: David Teigland <teigland@sourceware.org>
Date: Wed, 12 Oct 2022 15:05:45 +0000 (GMT)
Subject: main - lvreduce: change error message about --fs options
Message-ID: <20221012150545.ACE5C3851164@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=04097d9f620b5e22ae8fe2884110249116f3dab5
Commit:        04097d9f620b5e22ae8fe2884110249116f3dab5
Parent:        4f4554164b6fec7a92c21d1230b0abb6316db1b5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 12 10:05:14 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 12 10:05:14 2022 -0500

lvreduce: change error message about --fs options

---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index db97a019c..4cdbc19a0 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6874,7 +6874,7 @@ int lv_resize(struct cmd_context *cmd, struct logical_volume *lv,
 
 	if (is_reduce && !is_active && !strcmp(lp->fsopt, "checksize")) {
 		if (!lp->user_set_fs) {
-			log_error("The LV must be active to safely reduce, or use --fs checksize.");
+			log_error("The LV must be active to safely reduce (see --fs options.)");
 			goto out;
 		}
 		lv_top->status |= LV_TEMPORARY;

