From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:13:07 +0000 (UTC)
Subject: master - pvchange: use processing_handle when processing items for pvchange
Message-ID: <20150210151307.BAAE2600E1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d6c8f0de280653d0d15f491f776046b09d7dc635
Commit:        d6c8f0de280653d0d15f491f776046b09d7dc635
Parent:        56846d787381e5dc90f3a3adbcc3de58154a4ed3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 3 10:02:13 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:07:01 2015 +0100

pvchange: use processing_handle when processing items for pvchange

pvchange is an exception that does not use toollib yet for iterating
over the list of PVs (process_each_pv) so intialize the
processing_handle and use just like it's used in toollib.
---
 tools/pvchange.c |   45 +++++++++++++++++++++++++++++++++++----------
 1 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index 76db917..f0342a6 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -145,7 +145,9 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	int opt = 0;
 	int done = 0;
 	int total = 0;
+	int selected;
 
+	struct processing_handle *handle = NULL;
 	struct volume_group *vg;
 	const char *vg_name;
 	char *pv_name;
@@ -154,22 +156,36 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	struct dm_list *vgnames;
 	struct dm_str_list *sll;
 
+	int r = ECMD_PROCESSED;
+
 	if (!(arg_count(cmd, allocatable_ARG) + arg_is_set(cmd, addtag_ARG) +
 	    arg_is_set(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
 	    arg_count(cmd, metadataignore_ARG))) {
 		log_error("Please give one or more of -x, -uuid, "
 			  "--addtag, --deltag or --metadataignore");
-		return EINVALID_CMD_LINE;
+		r = EINVALID_CMD_LINE;
+		goto out;
+	}
+
+	/* FIXME: use process_each_pv for pvchange. */
+
+	if (!(handle = init_processing_handle(cmd)) ||
+	    (handle->internal_report_for_select && !init_selection_handle(cmd, handle))) {
+		log_error("Failed to initialize processing handle.");
+		r = ECMD_FAILED;
+		goto out;
 	}
 
-	if (!(arg_count(cmd, all_ARG)) && !argc) {
+	if (!(arg_count(cmd, all_ARG)) && !argc && !handle->internal_report_for_select) {
 		log_error("Please give a physical volume path");
-		return EINVALID_CMD_LINE;
+		r = EINVALID_CMD_LINE;
+		goto out;
 	}
 
 	if (arg_count(cmd, all_ARG) && argc) {
 		log_error("Option --all and PhysicalVolumePath are exclusive.");
-		return EINVALID_CMD_LINE;
+		r = EINVALID_CMD_LINE;
+		goto out;
 	}
 
 	if (argc) {
@@ -213,7 +229,8 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		 */
 		if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
 			log_error("Unable to obtain global lock.");
-			return ECMD_FAILED;
+			r = ECMD_FAILED;
+			goto out;
 		}
 
 		/* populate lvmcache */
@@ -230,10 +247,13 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 					continue;
 				}
 				dm_list_iterate_items(pvl, &vg->pvs) {
-					total++;
-					done += _pvchange_single(cmd, vg,
-								 pvl->pv,
-								 NULL);
+					if (select_match_pv(cmd, handle, vg, pvl->pv,
+							    &selected) && selected) {
+						total++;
+						done += _pvchange_single(cmd, vg,
+									 pvl->pv,
+									 NULL);
+					}
 				}
 				unlock_and_release_vg(cmd, vg, sll->str);
 			}
@@ -246,5 +266,10 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 				done, done == 1 ? "" : "s",
 				total - done, (total - done) == 1 ? "" : "s");
 
-	return (total == done) ? ECMD_PROCESSED : ECMD_FAILED;
+out:
+	destroy_processing_handle(cmd, handle, 1);
+	if (r == ECMD_PROCESSED)
+		return (total == done) ? ECMD_PROCESSED : ECMD_FAILED;
+	else
+		return r;
 }


