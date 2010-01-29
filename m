From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 29 Jan 2010 16:38:00 -0500
Subject: [PATCH 10/12] Add --metadatadisable to pvchange, allowing for disabling of metadata areas.
In-Reply-To: <1264801082-28132-10-git-send-email-dwysocha@redhat.com>
References: <1264801082-28132-1-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-2-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-3-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-4-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-5-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-6-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-7-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-8-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-9-git-send-email-dwysocha@redhat.com>
	<1264801082-28132-10-git-send-email-dwysocha@redhat.com>
Message-ID: <1264801082-28132-11-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch just modifies pvchange to call the underlying enable/disable
functions for mdas.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/args.h     |    1 +
 tools/commands.h |    3 ++-
 tools/pvchange.c |   28 +++++++++++++++++++++++++++-
 3 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 981f45f..f41fbf5 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -26,6 +26,7 @@ arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
+arg(metadatadisable_ARG, '\0', "metadatadisable", yes_no_arg, 0)
 arg(restorefile_ARG, '\0', "restorefile", string_arg, 0)
 arg(labelsector_ARG, '\0', "labelsector", int_arg, 0)
 arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 72898a9..2842937 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -448,6 +448,7 @@ xx(pvchange,
    "\t[-t|--test]\n"
    "\t[-u|--uuid]\n"
    "\t[-x|--allocatable y|n]\n"
+   "\t[--metadatadisable y|n]\n"
    "\t[-v|--verbose]\n"
    "\t[--addtag Tag]\n"
    "\t[--deltag Tag]\n"
@@ -455,7 +456,7 @@ xx(pvchange,
    "\t[PhysicalVolumePath...]\n",
 
    all_ARG, allocatable_ARG, allocation_ARG, autobackup_ARG, deltag_ARG,
-   addtag_ARG, test_ARG, uuid_ARG)
+   addtag_ARG, metadatadisable_ARG, test_ARG, uuid_ARG)
 
 xx(pvresize,
    "Resize physical volume(s)",
diff --git a/tools/pvchange.c b/tools/pvchange.c
index cba9dd2..6e87ac2 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -37,6 +37,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 	int allocatable = 0;
 	int tagarg = 0;
 	int r = 0;
+	int mda_disable = 0;
 
 	if (arg_count(cmd, addtag_ARG))
 		tagarg = addtag_ARG;
@@ -46,6 +47,9 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 	if (arg_count(cmd, allocatable_ARG))
 		allocatable = !strcmp(arg_str_value(cmd, allocatable_ARG, "n"),
 				      "y");
+	if (arg_count(cmd, metadatadisable_ARG))
+		mda_disable = !strcmp(arg_str_value(cmd, metadatadisable_ARG, "n"),
+				      "y");
 	else if (tagarg && !(tag = arg_str_value(cmd, tagarg, NULL))) {
 		log_error("Failed to get tag");
 		return 0;
@@ -149,6 +153,27 @@ static int _pvchange_single(struct cmd_context *cmd, struct physical_volume *pv,
 				goto out;
 			}
 		}
+	} else if (arg_count(cmd, metadatadisable_ARG)) {
+		if (mda_disable && pv_mda_is_disabled(pv)) {
+			log_error("Physical volume \"%s\" mdas already "
+				  "disabled", pv_name);
+			r = 1;
+			goto out;
+		}
+		if (!mda_disable && !pv_mda_is_disabled(pv)) {
+			log_error("Physical volume \"%s\" mdas already "
+				  "enabled", pv_name);
+			r = 1;
+			goto out;
+		}
+		if (mda_disable) {
+			log_verbose("Setting physical volume \"%s\" "
+				    "metadata disable", pv_name);
+		} else {
+			log_verbose("Setting physical volume \"%s\" NOT "
+				    "metadata enable", pv_name);
+		}
+		pv_mda_set_disabled(pv, mda_disable);
 	} else {
 		/* --uuid: Change PV ID randomly */
 		if (!id_create(&pv->id)) {
@@ -220,7 +245,8 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 	struct dm_list mdas;
 
 	if (arg_count(cmd, allocatable_ARG) + arg_count(cmd, addtag_ARG) +
-	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) != 1) {
+	    arg_count(cmd, deltag_ARG) + arg_count(cmd, uuid_ARG) +
+	    arg_count(cmd, metadatadisable_ARG) != 1) {
 		log_error("Please give exactly one option of -x, -uuid, "
 			  "--addtag or --deltag");
 		return EINVALID_CMD_LINE;
-- 
1.6.0.6


