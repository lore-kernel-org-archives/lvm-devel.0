From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 12:43:32 +0000 (UTC)
Subject: master - cleanup: improve tag processing
Message-ID: <20131212124332.A0EF96024C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe21b02fabe1dddeb45c4cfd0be475846dd0f906
Commit:        fe21b02fabe1dddeb45c4cfd0be475846dd0f906
Parent:        1c2cc2f794f540c0efead257bb8f8f1d909a053c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 8 23:29:40 2011 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:29:20 2013 +0100

cleanup: improve tag processing

Boolean algebra changes for process_each_lv_in_vg().

1st.
Drop process_lv variable since it's not needed.

2nd.
process_lv was always initilized to 0 - so the condition was always true.
It the condition (!tags_supplied && !lvargs_supplied) evaluates as "true",
process_all is already set to 1, so skip vg tags evaluation.

3rd.
Move check for matching lv name in the front of lv tags check
since this check can't be skipped for lvargs_matched counter.
If this filter evaluates to true, skip lv tags evaluation.
---
 WHATS_NEW       |    1 +
 tools/toollib.c |   30 ++++++++----------------------
 2 files changed, 9 insertions(+), 22 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0d6a9df..4b469d4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Improve process_each_lv_in_vg() tag processing.
   Reodered and simplified logging code.
   Fix SYSTEMD_READY assignment for foreign devices in lvmetad udev rules.
   Disable online thin pool metadata resize for 1.9 kernel thin target.
diff --git a/tools/toollib.c b/tools/toollib.c
index 65a7089..0429eb9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -192,7 +192,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	unsigned process_all = 0;
-	unsigned process_lv = 0;
 	unsigned tags_supplied = 0;
 	unsigned lvargs_supplied = 0;
 	unsigned lvargs_matched = 0;
@@ -211,12 +210,10 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
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
 
 	/*
 	 * FIXME: In case of remove it goes through deleted entries,
@@ -242,26 +239,15 @@ int process_each_lv_in_vg(struct cmd_context *cmd,
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
 
 		if (sigint_caught())


