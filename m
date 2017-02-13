From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:13 +0000 (UTC)
Subject: master - toollib: find VG name in option values when needed
Message-ID: <20170213181013.F41746039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95e38607ecf44fece40dd4a1b078582554c93da1
Commit:        95e38607ecf44fece40dd4a1b078582554c93da1
Parent:        0e3e611a137a264a343335d18d500fce7af8e0f7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Dec 9 13:30:42 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

toollib: find VG name in option values when needed

---
 tools/commands.h  |    2 +-
 tools/lvconvert.c |    2 +
 tools/toollib.c   |  158 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 tools/tools.h     |    2 +
 4 files changed, 162 insertions(+), 2 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index c663207..4739479 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -47,7 +47,7 @@ xx(lvchange,
 
 xx(lvconvert,
    "Change logical volume layout",
-   0)
+   GET_VGNAME_FROM_OPTIONS)
 
 xx(lvcreate,
    "Create a logical volume",
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 979d94d..da70cbd 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5386,6 +5386,8 @@ int lvconvert(struct cmd_context * cmd, int argc, char **argv)
 	};
 	struct processing_handle *handle = init_processing_handle(cmd, NULL);
 
+	cmd->command->flags &= ~GET_VGNAME_FROM_OPTIONS;
+
 	if (!handle) {
 		log_error("Failed to initialize processing handle.");
 		return ECMD_FAILED;
diff --git a/tools/toollib.c b/tools/toollib.c
index 6f9e294..36599e0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3364,6 +3364,157 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 	return ret_max;
 }
 
+/*
+ * This is a non-standard way of finding vgname/lvname to process.  It exists
+ * because an earlier form of lvconvert did not follow the standard form, and
+ * came up with its own inconsistent approach.
+ *
+ * In this case, when the position arg is a single name, it is treated as an LV
+ * name (not a VG name).  This leaves the VG unknown.  So, other option values
+ * must be searched for a VG name.  If one of those option values contains a
+ * vgname/lvname value, then the VG name is extracted and used for the LV
+ * position arg.
+ *
+ * Other option values that are searched for a VG name are:
+ * --thinpool, --cachepool.
+ *
+ *  . command vg/lv1
+ *  . add vg to arg_vgnames
+ *  . add vg/lv1 to arg_lvnames
+ *
+ *  command lv1
+ *  . error: no vg name
+ *
+ *  command --option vg/lv1 vg/lv2
+ *  . verify both vg names match
+ *  . add vg to arg_vgnames
+ *  . add vg/lv2 to arg_lvnames
+ *
+ *  command --option lv1 lv2
+ *  . error: no vg name
+ *
+ *  command --option vg/lv1 lv2
+ *  . add vg to arg_vgnames
+ *  . add vg/lv2 to arg_lvnames
+ *
+ *  command --option lv1 vg/lv2
+ *  . add vg to arg_vgnames
+ *  . add vg/lv2 to arg_lvnames
+ */
+
+static int _get_arg_lvnames_using_options(struct cmd_context *cmd,
+			    		  int argc, char **argv,
+					  struct dm_list *arg_vgnames,
+					  struct dm_list *arg_lvnames,
+					  struct dm_list *arg_tags)
+{
+	const char *pos_name = NULL;
+	const char *arg_name = NULL;
+	const char *pos_vgname = NULL;
+	const char *opt_vgname = NULL;
+	const char *pos_lvname = NULL;
+	const char *use_vgname = NULL;
+	char *tmp_name;
+	char *split;
+	char *vglv;
+	size_t vglv_sz;
+
+	if (argc != 1) {
+		log_error("One LV position arg is required.");
+		return ECMD_FAILED;
+	}
+
+	if (!(pos_name = dm_pool_strdup(cmd->mem, argv[0]))) {
+		log_error("string alloc failed.");
+		return ECMD_FAILED;
+	}
+
+	if (*pos_name == '@') {
+		if (!validate_tag(pos_name + 1)) {
+			log_error("Skipping invalid tag %s.", pos_name);
+			return ECMD_FAILED;
+		}
+		if (!str_list_add(cmd->mem, arg_tags,
+				  dm_pool_strdup(cmd->mem, pos_name + 1))) {
+			log_error("strlist allocation failed.");
+			return ECMD_FAILED;
+		}
+		return ECMD_PROCESSED;
+	}
+
+	if ((split = strchr(pos_name, '/'))) {
+		pos_vgname = pos_name;
+		pos_lvname = split + 1;
+		*split = '\0';
+	} else {
+		pos_lvname = pos_name;
+		pos_vgname = NULL;
+	}
+
+	if (arg_is_set(cmd, thinpool_ARG))
+		arg_name = arg_str_value(cmd, thinpool_ARG, NULL);
+	else if (arg_is_set(cmd, cachepool_ARG))
+		arg_name = arg_str_value(cmd, cachepool_ARG, NULL);
+
+	if (!pos_vgname && !arg_name) {
+		log_error("Cannot find VG name for LV %s.", pos_lvname);
+		return ECMD_FAILED;
+	}
+
+	if (arg_name && (split = strchr(arg_name, '/'))) {
+		/* combined VG/LV */
+
+		if (!(tmp_name = dm_pool_strdup(cmd->mem, arg_name))) {
+			log_error("string alloc failed.");
+			return ECMD_FAILED;
+		}
+
+		if (!(split = strchr(tmp_name, '/')))
+			return ECMD_FAILED;
+
+		opt_vgname = tmp_name;
+		/* Don't care about opt lvname. */
+		/* opt_lvname = split + 1; */
+		*split = '\0';
+	} else {
+		/* Don't care about opt lvname. */
+		/* opt_lvname = arg_name; */
+		opt_vgname = NULL;
+	}
+
+	if (!pos_vgname && !opt_vgname) {
+		log_error("Cannot find VG name for LV %s.", pos_lvname);
+		return ECMD_FAILED;
+	}
+
+	if (pos_vgname && opt_vgname && strcmp(pos_vgname, opt_vgname)) {
+		log_error("VG name mismatch from position arg (%s) and option arg (%s).",
+			  pos_vgname, opt_vgname);
+		return ECMD_FAILED; 
+	}
+
+	use_vgname = pos_vgname ? pos_vgname : opt_vgname;
+
+	if (!str_list_add(cmd->mem, arg_vgnames, dm_pool_strdup(cmd->mem, use_vgname))) {
+		log_error("strlist allocation failed.");
+		return ECMD_FAILED;
+	}
+
+	vglv_sz = strlen(use_vgname) + strlen(pos_lvname) + 2;
+
+	if (!(vglv = dm_pool_alloc(cmd->mem, vglv_sz)) ||
+	    dm_snprintf(vglv, vglv_sz, "%s/%s", use_vgname, pos_lvname) < 0) {
+		log_error("vg/lv string alloc failed.");
+		return ECMD_FAILED;
+	}
+	if (!str_list_add(cmd->mem, arg_lvnames, vglv)) {
+		log_error("strlist allocation failed.");
+		return ECMD_FAILED;
+	}
+
+	return ECMD_PROCESSED;
+}
+
 static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 				     struct dm_list *vgnameids_to_process,
 				     struct dm_list *arg_vgnames,
@@ -3523,7 +3674,12 @@ int process_each_lv(struct cmd_context *cmd,
 	/*
 	 * Find any LVs, VGs or tags explicitly provided on the command line.
 	 */
-	if ((ret = _get_arg_lvnames(cmd, argc, argv, one_vgname, one_lvname, &arg_vgnames, &arg_lvnames, &arg_tags) != ECMD_PROCESSED)) {
+	if (cmd->command->flags & GET_VGNAME_FROM_OPTIONS)
+		ret = _get_arg_lvnames_using_options(cmd, argc, argv, &arg_vgnames, &arg_lvnames, &arg_tags);
+	else
+		ret = _get_arg_lvnames(cmd, argc, argv, one_vgname, one_lvname, &arg_vgnames, &arg_lvnames, &arg_tags);
+
+	if (ret != ECMD_PROCESSED) {
 		ret_max = ret;
 		goto_out;
 	}
diff --git a/tools/tools.h b/tools/tools.h
index f310570..2deded9 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -162,6 +162,8 @@ struct lv_types {
 #define ENABLE_DUPLICATE_DEVS    0x00000400
 /* Command does not accept tags as args. */
 #define DISALLOW_TAG_ARGS        0x00000800
+/* Command may need to find VG name in an option value. */
+#define GET_VGNAME_FROM_OPTIONS  0x00001000
 
 void usage(const char *name);
 


