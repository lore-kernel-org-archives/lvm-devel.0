From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:34 +0000 (GMT)
Subject: main - toolib: move sigint_caught
Message-ID: <20210302215834.C8C4A3851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=56620b903955e245d4a257847f5825bb44d6db1e
Commit:        56620b903955e245d4a257847f5825bb44d6db1e
Parent:        2a9a3346e74c1327eafb03c44f2579eb6119943f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 27 19:22:11 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

toolib: move sigint_caught

Move the check for catched signal to the loop front.
Currently not much usable - but we can improve it later.
---
 tools/toollib.c | 44 +++++++++++++++++++++++---------------------
 1 file changed, 23 insertions(+), 21 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 9c026d9e5..67422e3b4 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1407,6 +1407,12 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 
 	if (argc) {
 		for (; opt < argc; opt++) {
+			if (sigint_caught()) {
+				log_error("Interrupted.");
+				ret_max = ECMD_FAILED;
+				goto out;
+			}
+
 			if (!(dev = dev_cache_get(cmd, argv[opt], cmd->filter))) {
 				log_error("Failed to find device "
 					  "\"%s\".", argv[opt]);
@@ -1436,12 +1442,14 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 				ret_max = ret;
 
 			log_set_report_object_name_and_id(NULL, NULL);
-
-			if (sigint_caught())
-				break;
 		}
 
 		dm_list_iterate_items(devl, &process_duplicates) {
+			if (sigint_caught()) {
+				log_error("Interrupted.");
+				ret_max = ECMD_FAILED;
+				goto out;
+			}
 			/* 
 			 * remove the existing dev for this pvid from lvmcache
 			 * so that the duplicate dev can replace it.
@@ -1470,9 +1478,6 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 				ret_max = ret;
 
 			log_set_report_object_name_and_id(NULL, NULL);
-
-			if (sigint_caught())
-				break;
 		}
 
 		goto out;
@@ -1484,8 +1489,13 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 		goto out;
 	}
 
-	while ((dev = dev_iter_get(cmd, iter)))
-	{
+	while ((dev = dev_iter_get(cmd, iter)))	{
+		if (sigint_caught()) {
+			log_error("Interrupted.");
+			ret_max = ECMD_FAILED;
+			break;
+		}
+
 		if (!(label = lvmcache_get_dev_label(dev)))
 			continue;
 
@@ -1498,9 +1508,6 @@ int process_each_label(struct cmd_context *cmd, int argc, char **argv,
 			ret_max = ret;
 
 		log_set_report_object_name_and_id(NULL, NULL);
-
-		if (sigint_caught())
-			break;
 	}
 
 	dev_iter_destroy(iter);
@@ -3064,11 +3071,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 		process_lv = process_lv && select_match_lv(cmd, handle, vg, lvl->lv) && _select_matches(handle);
 
-		if (sigint_caught()) {
-			ret_max = ECMD_FAILED;
-			goto_out;
-		}
-
 		if (!process_lv)
 			continue;
 
@@ -3174,6 +3176,11 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 			log_set_report_object_name_and_id(glvl->glv->historical->name, lv_uuid);
 
+			if (sigint_caught()) {
+				ret_max = ECMD_FAILED;
+				goto_out;
+			}
+
 			process_lv = process_all;
 
 			if (lvargs_supplied &&
@@ -3185,11 +3192,6 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 
 			process_lv = process_lv && select_match_lv(cmd, handle, vg, lvl->lv) && _select_matches(handle);
 
-			if (sigint_caught()) {
-				ret_max = ECMD_FAILED;
-				goto_out;
-			}
-
 			if (!process_lv)
 				continue;
 


