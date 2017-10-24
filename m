From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 24 Oct 2017 10:17:41 -0400
Subject: master - lvconvert: fixing extraction of vgname
Message-ID: <201710241417.v9OEHf2X025798@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ea63a38f5a883238bfdabdb3f4af5d08f4499424
Commit:        ea63a38f5a883238bfdabdb3f4af5d08f4499424
Parent:        dcc8f90c587be5e60f45847d7c8ffc945e78d41c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 24 14:56:42 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 24 16:16:08 2017 +0200

lvconvert: fixing extraction of vgname

Correction to function for extracting vgname out of lvconvert
parameters.

Avoid repeating some checks.

Add code to handle generic options which may provide vgname in its argument
and compare them all so they match to a single vgname (otherwise it's a
error).

Extract default (envvar) vgname only when no position nor optional vgname is
found.

Fixing regression instroduce with patchset started with commit:
1e2420bca85da9a37570871cd70192e9ae831786   (2.02.169)
---
 WHATS_NEW       |    1 +
 tools/toollib.c |  107 +++++++++++++++++++-----------------------------------
 2 files changed, 39 insertions(+), 69 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d91900b..3ba8e30 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.176 -
 ===================================
+  Fix regression in more advanced vgname extraction in lvconvert (2.02.169).
   Allow lvcreate to be used for caching of _tdata LV.
   Avoid internal error when resizing cache type _tdata LV (not yet supported).
   Show original converted names when lvconverting LV to pool volume.
diff --git a/tools/toollib.c b/tools/toollib.c
index 79829f4..7eb0bed 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3386,18 +3386,17 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 }
 
 /*
- * This is a non-standard way of finding vgname/lvname to process.  It exists
- * because an earlier form of lvconvert did not follow the standard form, and
- * came up with its own inconsistent approach.
+ * Finding vgname/lvname to process.
  *
- * In this case, when the position arg is a single name, it is treated as an LV
- * name (not a VG name).  This leaves the VG unknown.  So, other option values,
- * or env var, must be searched for a VG name.  If one of the option values
- * contains a vgname/lvname value, then the VG name is extracted and used for
- * the LV position arg.  Or, if the env var has the VG name, that is used.
+ * When the position arg is a single name without any '/'
+ * it is treated as an LV name (leaving the VG unknown).
+ * Other option values, or env var, must be searched for a VG name.
+ * If one of the option values contains a vgname/lvname value,
+ * then the VG name is extracted and used for the LV position arg.
+ * Or, if the env var has the VG name, that is used.
  *
  * Other option values that are searched for a VG name are:
- * --thinpool, --cachepool.
+ * --thinpool, --cachepool, --poolmetadata.
  *
  *  . command vg/lv1
  *  . add vg to arg_vgnames
@@ -3422,22 +3421,23 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
  *  . add vg to arg_vgnames
  *  . add vg/lv2 to arg_lvnames
  */
-
 static int _get_arg_lvnames_using_options(struct cmd_context *cmd,
 			    		  int argc, char **argv,
 					  struct dm_list *arg_vgnames,
 					  struct dm_list *arg_lvnames,
 					  struct dm_list *arg_tags)
 {
+	/* Array with args which may provide vgname */
+	static const unsigned _opts_with_vgname[] = {
+		cachepool_ARG, poolmetadata_ARG, thinpool_ARG
+	};
+	unsigned i;
 	const char *pos_name = NULL;
 	const char *arg_name = NULL;
 	const char *pos_vgname = NULL;
 	const char *opt_vgname = NULL;
 	const char *pos_lvname = NULL;
-	const char *env_vgname = NULL;
 	const char *use_vgname = NULL;
-	char *tmp_name;
-	char *split;
 	char *vglv;
 	size_t vglv_sz;
 
@@ -3464,76 +3464,45 @@ static int _get_arg_lvnames_using_options(struct cmd_context *cmd,
 		return ECMD_PROCESSED;
 	}
 
-	if (*pos_name == '/') {
-		if (!(pos_name = skip_dev_dir(cmd, pos_name, NULL)))
-			return ECMD_FAILED;
-	}
-
-	if ((split = strchr(pos_name, '/'))) {
+	if (strchr(pos_name, '/')) {
 		/*
 		 * This splits pos_name 'x/y' into pos_vgname 'x' and pos_lvname 'y'
 		 * It skips repeated '/', e.g. x//y
 		 * It also checks and fails for extra '/', e.g. x/y/z
 		 */
-		pos_vgname = _extract_vgname(cmd, pos_name, &pos_lvname);
-	} else {
+		if (!(pos_vgname = _extract_vgname(cmd, pos_name, &pos_lvname)))
+			return_0;
+		use_vgname = pos_vgname;
+	} else
 		pos_lvname = pos_name;
-		pos_vgname = NULL;
-	}
-
-	if (arg_is_set(cmd, thinpool_ARG))
-		arg_name = arg_str_value(cmd, thinpool_ARG, NULL);
-	else if (arg_is_set(cmd, cachepool_ARG))
-		arg_name = arg_str_value(cmd, cachepool_ARG, NULL);
 
-	env_vgname = _default_vgname(cmd);
-
-	if (!pos_vgname && !arg_name && !env_vgname) {
-		log_error("Cannot find VG name for LV %s.", pos_lvname);
-		return ECMD_FAILED;
-	}
-
-	if (arg_name && (split = strchr(arg_name, '/'))) {
-		/* combined VG/LV */
-
-		if (!(tmp_name = dm_pool_strdup(cmd->mem, arg_name))) {
-			log_error("string alloc failed.");
-			return ECMD_FAILED;
+	/* Go through the list of options which can provide vgname */
+	for (i = 0; i < DM_ARRAY_SIZE(_opts_with_vgname); ++i) {
+		if ((arg_name = arg_str_value(cmd, _opts_with_vgname[i], NULL)) &&
+		    strchr(arg_name, '/')) {
+			/* Combined VG/LV */
+			/* Don't care about opt lvname, only extract vgname. */
+			if (!(opt_vgname = _extract_vgname(cmd, arg_name, NULL)))
+				return_0;
+			/* Compare with already known vgname */
+			if (use_vgname) {
+				if (strcmp(use_vgname, opt_vgname)) {
+					log_error("VG name mismatch from %s arg (%s) and option arg (%s).",
+						  pos_vgname ? "position" : "option",
+						  use_vgname, opt_vgname);
+					return ECMD_FAILED;
+				}
+			} else
+				use_vgname = opt_vgname;
 		}
-
-		if (!(split = strchr(tmp_name, '/')))
-			return ECMD_FAILED;
-
-		opt_vgname = tmp_name;
-		/* Don't care about opt lvname. */
-		/* opt_lvname = split + 1; */
-		*split = '\0';
-	} else {
-		/* Don't care about opt lvname. */
-		/* opt_lvname = arg_name; */
-		opt_vgname = NULL;
 	}
 
-	if (!pos_vgname && !opt_vgname && !env_vgname) {
+	/* VG not specified as position nor as optional arg, so check for default VG */
+	if (!use_vgname && !(use_vgname = _default_vgname(cmd)))  {
 		log_error("Cannot find VG name for LV %s.", pos_lvname);
 		return ECMD_FAILED;
 	}
 
-	if (pos_vgname && opt_vgname && strcmp(pos_vgname, opt_vgname)) {
-		log_error("VG name mismatch from position arg (%s) and option arg (%s).",
-			  pos_vgname, opt_vgname);
-		return ECMD_FAILED; 
-	}
-
-	if (pos_vgname)
-		use_vgname = pos_vgname;
-	else if (opt_vgname)
-		use_vgname = opt_vgname;
-	else if (env_vgname)
-		use_vgname = env_vgname;
-	else
-		return_ECMD_FAILED; 
-
 	if (!str_list_add(cmd->mem, arg_vgnames, dm_pool_strdup(cmd->mem, use_vgname))) {
 		log_error("strlist allocation failed.");
 		return ECMD_FAILED;


