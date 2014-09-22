From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:57 +0000 (UTC)
Subject: dev-dct-process-latest - toollib: improve error message in process_each_lv_in_vg
Message-ID: <20140922153957.1B1DE60228@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bb21649a4700b5a19251def33a3a3418b5d0830d
Commit:        bb21649a4700b5a19251def33a3a3418b5d0830d
Parent:        2f1bf1978e6d3986be5a44648e8ac59ef7aaa4e2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 29 16:42:49 2013 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 22 10:32:23 2014 -0500

toollib: improve error message in process_each_lv_in_vg

Include in the error message the lv name args that were not found.
---
 tools/toollib.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 0f9e241..31e2fcf 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1698,8 +1698,8 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 	unsigned process_lv = 0;
 	unsigned tags_supplied = 0;
 	unsigned lvargs_supplied = 0;
-	unsigned lvargs_matched = 0;
 	struct lv_list *lvl;
+	struct dm_str_list *sl;
 
 	if (!vg_check_status(vg, EXPORTED_VG))
 		return_ECMD_FAILED;
@@ -1760,7 +1760,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (lvargs_supplied &&
 		    str_list_match_item(arg_lvnames, lvl->lv->name)) {
 			process_lv = 1;
-			lvargs_matched++;
+			str_list_del(arg_lvnames, lvl->lv->name);
 		}
 
 		if (!process_lv)
@@ -1769,20 +1769,25 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (sigint_caught())
 			return_ECMD_FAILED;
 
+		log_very_verbose("Processing LV %s in VG %s", lvl->lv->name, vg->name);
+
 		ret = process_single_lv(cmd, lvl->lv, handle);
 
 		if (ret > ret_max)
 			ret_max = ret;
 	}
 
-	if (lvargs_supplied && lvargs_matched != dm_list_size(arg_lvnames)) {
+	if (lvargs_supplied) {
 		/*
 		 * FIXME: lvm supports removal of LV with all its dependencies
 		 * this leads to miscalculation that depends on the order of args.
 		 */
-		log_error("One or more specified logical volume(s) not found.");
-		if (ret_max < ECMD_FAILED)
-			ret_max = ECMD_FAILED;
+		dm_list_iterate_items(sl, arg_lvnames) {
+			log_error("Failed to find logical volume \"%s/%s\"",
+				  vg->name, sl->str);
+			if (ret_max < ECMD_FAILED)
+				ret_max = ECMD_FAILED;
+		}
 	}
 
 	return ret_max;


