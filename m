From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:34:39 -0400
Subject: master - coverity: add missing error check for str_list_add
Message-ID: <201803172234.w2HMYd9e011153@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fd6661dfcf7568d32a127e63b0d6c95c010688fb
Commit:        fd6661dfcf7568d32a127e63b0d6c95c010688fb
Parent:        d7273822757d6ccc7d4178f01c96fc3be52702a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 14:15:11 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:33:58 2018 +0100

coverity: add missing error check for str_list_add

Validate success.
---
 tools/toollib.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index eab6223..3f27a7a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3088,7 +3088,11 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (lvargs_supplied && str_list_match_item(arg_lvnames, lvl->lv->name)) {
 			/* Remove LV from list of unprocessed LV names */
 			str_list_del(arg_lvnames, lvl->lv->name);
-			str_list_add(cmd->mem, &found_arg_lvnames, lvl->lv->name);
+			if (!str_list_add(cmd->mem, &found_arg_lvnames, lvl->lv->name)) {
+				log_error("strlist allocation failed.");
+				ret_max = ECMD_FAILED;
+				goto out;
+			}
 			process_lv = 1;
 		}
 


