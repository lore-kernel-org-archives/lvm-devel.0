From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 15 Feb 2017 21:31:14 +0000 (UTC)
Subject: master - commands: use existing vg/lv name parsing functions
Message-ID: <20170215213114.DD41760727@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6a5c9ba34902193ac9d03fe30976d259391905b3
Commit:        6a5c9ba34902193ac9d03fe30976d259391905b3
Parent:        2556498ee191cc9eaa505c611c5570937ff32315
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 15 15:06:52 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 15 15:28:54 2017 -0600

commands: use existing vg/lv name parsing functions

inside the new lv arg parsing function.

This includes getting the VG name from the env var,
and some added checks on the format of the vg/lv string.
---
 tools/toollib.c |   45 +++++++++++++++++++++++++++++----------------
 1 files changed, 29 insertions(+), 16 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 6e0a4f1..842f67c 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3362,10 +3362,10 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
  * came up with its own inconsistent approach.
  *
  * In this case, when the position arg is a single name, it is treated as an LV
- * name (not a VG name).  This leaves the VG unknown.  So, other option values
- * must be searched for a VG name.  If one of those option values contains a
- * vgname/lvname value, then the VG name is extracted and used for the LV
- * position arg.
+ * name (not a VG name).  This leaves the VG unknown.  So, other option values,
+ * or env var, must be searched for a VG name.  If one of the option values
+ * contains a vgname/lvname value, then the VG name is extracted and used for
+ * the LV position arg.  Or, if the env var has the VG name, that is used.
  *
  * Other option values that are searched for a VG name are:
  * --thinpool, --cachepool.
@@ -3375,21 +3375,21 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
  *  . add vg/lv1 to arg_lvnames
  *
  *  command lv1
- *  . error: no vg name
+ *  . error: no vg name (unless LVM_VG_NAME)
  *
- *  command --option vg/lv1 vg/lv2
+ *  command --option=vg/lv1 vg/lv2
  *  . verify both vg names match
  *  . add vg to arg_vgnames
  *  . add vg/lv2 to arg_lvnames
  *
- *  command --option lv1 lv2
- *  . error: no vg name
+ *  command --option=lv1 lv2
+ *  . error: no vg name (unless LVM_VG_NAME)
  *
- *  command --option vg/lv1 lv2
+ *  command --option=vg/lv1 lv2
  *  . add vg to arg_vgnames
  *  . add vg/lv2 to arg_lvnames
  *
- *  command --option lv1 vg/lv2
+ *  command --option=lv1 vg/lv2
  *  . add vg to arg_vgnames
  *  . add vg/lv2 to arg_lvnames
  */
@@ -3405,6 +3405,7 @@ static int _get_arg_lvnames_using_options(struct cmd_context *cmd,
 	const char *pos_vgname = NULL;
 	const char *opt_vgname = NULL;
 	const char *pos_lvname = NULL;
+	const char *env_vgname = NULL;
 	const char *use_vgname = NULL;
 	char *tmp_name;
 	char *split;
@@ -3440,9 +3441,12 @@ static int _get_arg_lvnames_using_options(struct cmd_context *cmd,
 	}
 
 	if ((split = strchr(pos_name, '/'))) {
-		pos_vgname = pos_name;
-		pos_lvname = split + 1;
-		*split = '\0';
+		/*
+		 * This splits pos_name 'x/y' into pos_vgname 'x' and pos_lvname 'y'
+		 * It skips repeated '/', e.g. x//y
+		 * It also checks and fails for extra '/', e.g. x/y/z
+		 */
+		pos_vgname = _extract_vgname(cmd, pos_name, &pos_lvname);
 	} else {
 		pos_lvname = pos_name;
 		pos_vgname = NULL;
@@ -3453,7 +3457,9 @@ static int _get_arg_lvnames_using_options(struct cmd_context *cmd,
 	else if (arg_is_set(cmd, cachepool_ARG))
 		arg_name = arg_str_value(cmd, cachepool_ARG, NULL);
 
-	if (!pos_vgname && !arg_name) {
+	env_vgname = _default_vgname(cmd);
+
+	if (!pos_vgname && !arg_name && !env_vgname) {
 		log_error("Cannot find VG name for LV %s.", pos_lvname);
 		return ECMD_FAILED;
 	}
@@ -3479,7 +3485,7 @@ static int _get_arg_lvnames_using_options(struct cmd_context *cmd,
 		opt_vgname = NULL;
 	}
 
-	if (!pos_vgname && !opt_vgname) {
+	if (!pos_vgname && !opt_vgname && !env_vgname) {
 		log_error("Cannot find VG name for LV %s.", pos_lvname);
 		return ECMD_FAILED;
 	}
@@ -3490,7 +3496,14 @@ static int _get_arg_lvnames_using_options(struct cmd_context *cmd,
 		return ECMD_FAILED; 
 	}
 
-	use_vgname = pos_vgname ? pos_vgname : opt_vgname;
+	if (pos_vgname)
+		use_vgname = pos_vgname;
+	else if (opt_vgname)
+		use_vgname = opt_vgname;
+	else if (env_vgname)
+		use_vgname = env_vgname;
+	else
+		return_ECMD_FAILED; 
 
 	if (!str_list_add(cmd->mem, arg_vgnames, dm_pool_strdup(cmd->mem, use_vgname))) {
 		log_error("strlist allocation failed.");


