From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 16 Nov 2011 14:22:50 +0100
Subject: [PATCH 03/12] Code reorder
In-Reply-To: <cover.1321449480.git.zkabelac@redhat.com>
References: <cover.1321449480.git.zkabelac@redhat.com>
Message-ID: <9d38d78f6803b053005f04bc0e496cbb37c6dcca.1321449480.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Boolean algebra changes:

1st.
Drop process_lv variable since it's not needed.

2nd.
process_lv was always initilized to 0 - so condition was always true.
It the condition (!tags_supplied && !lvargs_supplied) evaluates to
true, process_all is already set to 1, so skip vg tags evaluation.

3rd.
Move check for matching lv name in front of lv tags check
since this check can't be skipped for lvargs_matched counter.
If this filter evaluates to true, skip lv tags evaluation.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/toollib.c |   30 ++++++++----------------------
 1 files changed, 8 insertions(+), 22 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 1e13961..8030f8e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -93,7 +93,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 	unsigned process_all = 0;
-	unsigned process_lv = 0;
 	unsigned tags_supplied = 0;
 	unsigned lvargs_supplied = 0;
 	unsigned lvargs_matched = 0;
@@ -112,12 +111,10 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 	/* Process all LVs in this VG if no restrictions given */
 	if (!tags_supplied && !lvargs_supplied)
 		process_all = 1;
-
 	/* Or if VG tags match */
-	if (!process_lv && tags_supplied &&
-	    str_list_match_list(tags, &vg->tags, NULL)) {
+	else if (tags_supplied &&
+		 str_list_match_list(tags, &vg->tags, NULL))
 		process_all = 1;
-	}
 
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (lvl->lv->status & SNAPSHOT)
@@ -139,26 +136,15 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 		if (!lvargs_supplied && !lv_is_visible(lvl->lv) && !arg_count(cmd, all_ARG))
 			continue;
 
-		/* Should we process this LV? */
-		if (process_all)
-			process_lv = 1;
-		else
-			process_lv = 0;
-
-		/* LV tag match? */
-		if (!process_lv && tags_supplied &&
-		    str_list_match_list(tags, &lvl->lv->tags, NULL)) {
-			process_lv = 1;
-		}
-
 		/* LV name match? */
 		if (lvargs_supplied &&
-		    str_list_match_item(arg_lvnames, lvl->lv->name)) {
-			process_lv = 1;
+		    str_list_match_item(arg_lvnames, lvl->lv->name))
+			/* Check even when process_all for counter */
 			lvargs_matched++;
-		}
-
-		if (!process_lv)
+		/* LV tag match?   skip test, when process_all */
+		else if (!process_all &&
+			 (!tags_supplied ||
+			  !str_list_match_list(tags, &lvl->lv->tags, NULL)))
 			continue;
 
 		lvl->lv->vg->cmd_missing_vgs = 0;
-- 
1.7.7.3


