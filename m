From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 23 Jul 2013 15:14:07 +0000 (UTC)
Subject: master - lvconvert: add more checks for lvconvert --type
Message-ID: <20130723151407.6443E6167D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=31de670318c9794690601468def392cd7e4eb0fc
Commit:        31de670318c9794690601468def392cd7e4eb0fc
Parent:        373f95a921223c1e4d36ae975ac685227369cf5b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jul 23 17:04:43 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 23 17:13:54 2013 +0200

lvconvert: add more checks for lvconvert --type

The --type mirror requires -m/--mirrrors:

  lvconvert --type mirror vg/lvol0
    --type mirror requires -m/--mirrors
    Run `lvconvert --help' for more information.

The --type raid* is allowed (the checks already existed):

  lvconvert --type raid10 vg/lvol0
    Converting the segment type for vg/lvol0 from linear to raid10 is not yet supported.

The --type snapshot is a synonym to -s/--snapshot:

  lvconvert -s vg/lvol0 vg/lvol1
    Logical volume lvol1 converted to snapshot.

  lvconvert --type snapshot vg/lvol0 vg/lvol1
    Logical volume lvol1 converted to snapshot.

All the other segment types are not supported, e.g.:

  lvconvert --type zero vg/lvol0
    Conversion using --type zero is not supported.
    Run `lvconvert --help' for more information.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |   66 ++++++++++++++++++++++++++++++++++++++++-------------
 2 files changed, 51 insertions(+), 16 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0269839..36d9f93 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Issue an error msg if lvconvert --type used incorrectly with other options.
   Use LOG_DEBUG/ERR msg severity instead default for lvm2-activation-generator.
   Support ARG_GROUPABLE with merge_synonym (for --raidwritemostly).
   Fix segfault when reporting raid_syncaction for older kernels.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index ce28947..62334d8 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -177,6 +177,35 @@ static int _lvconvert_name_params(struct lvconvert_params *lp,
 	return 1;
 }
 
+static int _check_conversion_type(struct cmd_context *cmd, const char *type_str)
+{
+	if (!type_str || !*type_str)
+		return 1;
+
+	if (!strcmp(type_str, "mirror")) {
+		if (!arg_count(cmd, mirrors_ARG)) {
+			log_error("--type mirror requires -m/--mirrors");
+			return 0;
+		}
+		return 1;
+	}
+
+	/* FIXME: Check thin-pool and thin more thoroughly! */
+	if (!strcmp(type_str, "snapshot") || !strncmp(type_str, "raid", 4) ||
+	    !strcmp(type_str, "thin-pool") || !strcmp(type_str, "thin"))
+		return 1;
+
+	log_error("Conversion using --type %s is not supported.", type_str);
+	return 0;
+}
+
+/* -s/--snapshot and --type snapshot are synonyms */
+#define snapshot_type_requested(cmd,type_str) (arg_count(cmd, snapshot_ARG) || \
+					       !strcmp(type_str, "snapshot"))
+/* mirror/raid* (1,10,4,5,6 and their variants) reshape */
+#define mirror_or_raid_type_requested(cmd,type_str) (arg_count(cmd, mirrors_ARG) || \
+						     !strncmp(type_str, "raid", 4))
+
 static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			int argc, char **argv)
 {
@@ -185,40 +214,45 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	struct arg_value_group_list *group;
 	int region_size;
 	int pagesize = lvm_getpagesize();
+	const char *type_str = arg_str_value(cmd, type_ARG, "");
 
 	memset(lp, 0, sizeof(*lp));
 	lp->target_attr = ~0;
 
-	if ((arg_count(cmd, snapshot_ARG) || arg_count(cmd, merge_ARG)) &&
-	    (arg_count(cmd, mirrorlog_ARG) || arg_count(cmd, mirrors_ARG) ||
+	if (!_check_conversion_type(cmd, type_str))
+		return_0;
+
+	if ((snapshot_type_requested(cmd, type_str) || arg_count(cmd, merge_ARG)) &&
+	    (arg_count(cmd, mirrorlog_ARG) || mirror_or_raid_type_requested(cmd, type_str) ||
 	     arg_count(cmd, repair_ARG) || arg_count(cmd, thinpool_ARG))) {
-		log_error("--snapshot or --merge argument cannot be mixed "
-			  "with --mirrors, --mirrorlog, --repair "
-			  "or --thinpool.");
+		log_error("--snapshot/--type snapshot or --merge argument "
+			  "cannot be mixed with --mirrors/--type mirror/--type raid*, "
+			  "--mirrorlog, --repair or --thinpool.");
 		return 0;
 	}
 
 	if ((arg_count(cmd, stripes_long_ARG) || arg_count(cmd, stripesize_ARG)) &&
-	    !(arg_count(cmd, mirrors_ARG) || arg_count(cmd, repair_ARG) ||
-	      arg_count(cmd, thinpool_ARG) || arg_count(cmd, type_ARG))) {
+	    !(mirror_or_raid_type_requested(cmd, type_str) ||
+	      arg_count(cmd, repair_ARG) ||
+	      arg_count(cmd, thinpool_ARG))) {
 		log_error("--stripes or --stripesize argument is only valid "
-			  "with --mirrors, --repair, --thinpool or --type");
+			  "with --mirrors/--type mirror/--type raid*, --repair and --thinpool");
 		return 0;
 	}
 
 	if (!arg_count(cmd, background_ARG))
 		lp->wait_completion = 1;
 
-	if (arg_count(cmd, snapshot_ARG))
+	if (snapshot_type_requested(cmd, type_str))
 		lp->snapshot = 1;
 
-	if (arg_count(cmd, snapshot_ARG) && arg_count(cmd, merge_ARG)) {
+	if (snapshot_type_requested(cmd, type_str) && arg_count(cmd, merge_ARG)) {
 		log_error("--snapshot and --merge are mutually exclusive");
 		return 0;
 	}
 
-	if (arg_count(cmd, splitmirrors_ARG) && arg_count(cmd, mirrors_ARG)) {
-		log_error("--mirrors and --splitmirrors are "
+	if (arg_count(cmd, splitmirrors_ARG) && mirror_or_raid_type_requested(cmd, type_str)) {
+		log_error("--mirrors/--type mirror/--type raid* and --splitmirrors are "
 			  "mutually exclusive");
 		return 0;
 	}
@@ -231,16 +265,16 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 			log_error("--thinpool and --merge are mutually exlusive.");
 			return 0;
 		}
-		if (arg_count(cmd, mirrors_ARG)) {
-			log_error("--thinpool and --mirrors are mutually exlusive.");
+		if (mirror_or_raid_type_requested(cmd, type_str)) {
+			log_error("--thinpool and --mirrors/--type mirror/--type raid* are mutually exlusive.");
 			return 0;
 		}
 		if (arg_count(cmd, repair_ARG)) {
 			log_error("--thinpool and --repair are mutually exlusive.");
 			return 0;
 		}
-		if (arg_count(cmd, snapshot_ARG)) {
-			log_error("--thinpool and --snapshot are mutually exlusive.");
+		if (snapshot_type_requested(cmd, type_str)) {
+			log_error("--thinpool and --snapshot/--type snapshot are mutually exlusive.");
 			return 0;
 		}
 		if (arg_count(cmd, splitmirrors_ARG)) {


