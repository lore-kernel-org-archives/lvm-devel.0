From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 26 May 2010 10:02:14 -0400
Subject: [PATCH 12/18] Add --metadataignore to pvchange, allowing for ignoring of metadata areas.
In-Reply-To: <1274882540-6181-12-git-send-email-dwysocha@redhat.com>
References: <1274882540-6181-1-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-2-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-3-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-4-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-5-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-6-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-7-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-8-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-9-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-10-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-11-git-send-email-dwysocha@redhat.com>
	<1274882540-6181-12-git-send-email-dwysocha@redhat.com>
Message-ID: <1274882540-6181-13-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch just modifies pvchange to call the underlying ignore
functions for mdas.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/args.h     |    1 +
 tools/commands.h |    3 ++-
 tools/pvchange.c |   30 +++++++++++++++++++++++++++++-
 3 files changed, 32 insertions(+), 2 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 76146ee..d343689 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -25,6 +25,7 @@ arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
+arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
 arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
 arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index e33cadc..6d8d2c0 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -455,6 +455,7 @@ xx(pvchange,
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
    "\t[-x|--allocatable y|n]\n"
+   "\t[--metadataignore y|n]\n"
    "\t[-v|--verbose]\n"
    "\t[--addtag Tag]\n"
    "\t[--deltag Tag]\n"
@@ -462,7 +463,7 @@ xx(pvchange,
    "\t[PhysicalVolumePath...]\n",
 
    all_ARG, allocatable_ARG, allocation_ARG, autobackup_ARG, deltag_ARG,
-   addtag_ARG, test_ARG, uuid_ARG)
+   addtag_ARG, metadataignore_ARG, test_ARG, uuid_ARG)
 
 xx(pvresize,
    "Resize physical volume(s)",
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 5486b73..2203b65 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -34,6 +34,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	int allocatable = 0;
 	int tagarg = 0;
 	int r = 0;
+	int mda_ignore = 0;
 
 	if (arg_count(cmd, addtag_ARG))
 		tagarg = addtag_ARG;
@@ -43,6 +44,9 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	if (arg_count(cmd, allocatable_ARG))
 		allocatable = !strcmp(arg_str_value(cmd, allocatable_ARG, "n"),
 				      "y");
+	if (arg_count(cmd, metadataignore_ARG))
+		mda_ignore = !strcmp(arg_str_value(cmd, metadataignore_ARG, "n"),
+				      "y");
 	else if (tagarg && !(tag = arg_str_value(cmd, tagarg, NULL))) {
 		log_error("Failed to get tag");
 		return 0;
@@ -117,6 +121,29 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 				goto out;
 			}
 		}
+	} else if (arg_count(cmd, metadataignore_ARG)) {
+		if (mda_ignore && pv_mda_is_ignored(pv)) {
+			log_error("Physical volume \"%s\" metadata already "
+				  "ignored", pv_name);
+			r = 1;
+			goto out;
+		}
+		if (!mda_ignore && !pv_mda_is_ignored(pv)) {
+			log_error("Physical volume \"%s\" metadata already "
+				  "not ignored", pv_name);
+			r = 1;
+			goto out;
+		}
+		if (mda_ignore) {
+			log_verbose("Setting physical volume \"%s\" "
+				    "metadata ignored", pv_name);
+		} else {
+			log_verbose("Setting physical volume \"%s\" "
+				    "metadata not ignored", pv_name);
+		}
+		if (!pv_mda_set_ignored(pv, mda_ignore)) {
+			goto out;
+		}
 	} else {
 		/* --uuid: Change PV ID randomly */
 		if (!id_create(&pv->id)) {
@@ -187,7 +214,8 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	struct str_list *sll;
 
 	if (arg_count(cmd, allocatable_ARG) + arg_count(cmd, addtag_ARG) +
-	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) != 1) {
+	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
+	    arg_count(cmd, metadataignore_ARG) != 1) {
 		log_error("Please give exactly one option of -x, -uuid, "
 			  "--addtag or --deltag");
 		return EINVALID_CMD_LINE;
-- 
1.6.0.6


