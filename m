From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 17 Jun 2011 14:39:39 +0200
Subject: [PATCH] dmsetup: add option to enable udev fallback code only when needed
Message-ID: <4DFB4B0B.4040802@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The same as the patch for lvm2, but for dmsetup now...

Peter
---
 tools/dmsetup.c |   34 +++++++++++++++++++---------------
 1 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 2a8e5a6..00a682a 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -135,6 +135,7 @@ enum {
 	UDEVCOOKIE_ARG,
 	NOUDEVRULES_ARG,
 	NOUDEVSYNC_ARG,
+	UDEVFALLBACK_ARG,
 	OPTIONS_ARG,
 	READAHEAD_ARG,
 	ROWS_ARG,
@@ -648,11 +649,11 @@ static int _create(CMD_ARGS)
 	if (!_set_task_add_node(dmt))
                 goto out;
 
-	if (_udev_cookie) {
+	if (_udev_cookie)
 		cookie = _udev_cookie;
-		if (_udev_only)
-			udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
-	}
+
+	if (_udev_only)
+		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
 	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
 	    !dm_task_run(dmt))
@@ -702,11 +703,11 @@ static int _rename(CMD_ARGS)
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
-	if (_udev_cookie) {
+	if (_udev_cookie)
 		cookie = _udev_cookie;
-		if (_udev_only)
-			udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
-	}
+
+	if (_udev_only)
+		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
 	if (!dm_task_set_cookie(dmt, &cookie, udev_flags) ||
 	    !dm_task_run(dmt))
@@ -1006,7 +1007,7 @@ static int _set_up_udev_support(const char *dev_dir)
 	else
 		dirs_diff = strcmp(dev_dir, udev_dev_dir);
 
-	_udev_only = _udev_cookie && !dirs_diff;
+	_udev_only = !dirs_diff && (_udev_cookie || !_switches[UDEVFALLBACK_ARG]);
 
 	if (dirs_diff) {
 		log_debug("The path %s used for creating device nodes that is "
@@ -1225,11 +1226,11 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
-	if (_udev_cookie) {
+	if (_udev_cookie)
 		cookie = _udev_cookie;
-		if (_udev_only)
-			udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
-	}
+
+	if (_udev_only)
+		udev_flags |= DM_UDEV_DISABLE_LIBRARY_FALLBACK;
 
 	if (udev_wait_flag && !dm_task_set_cookie(dmt, &cookie, udev_flags))
 		goto out;
@@ -2744,8 +2745,8 @@ static void _usage(FILE *out)
 	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
 		"        [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
-		"        [--udevcookie] [--noudevrules] [--noudevsync] [-y|--yes]\n"
-		"        [--readahead [+]<sectors>|auto|none]\n"
+		"        [--udevcookie] [--noudevrules] [--noudevsync] [--udevfallback]\n"
+		"        [-y|--yes] [--readahead [+]<sectors>|auto|none]\n"
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [--nameprefixes] [--noheadings] [--separator <separator>]\n\n");
 	for (i = 0; _commands[i].name; i++)
@@ -3115,6 +3116,7 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 		{"udevcookie", 1, &ind, UDEVCOOKIE_ARG},
 		{"noudevrules", 0, &ind, NOUDEVRULES_ARG},
 		{"noudevsync", 0, &ind, NOUDEVSYNC_ARG},
+		{"udevfallback", 0, &ind, UDEVFALLBACK_ARG},
 		{"options", 1, &ind, OPTIONS_ARG},
 		{"readahead", 1, &ind, READAHEAD_ARG},
 		{"rows", 0, &ind, ROWS_ARG},
@@ -3243,6 +3245,8 @@ static int _process_switches(int *argc, char ***argv, const char *dev_dir)
 			_switches[NOUDEVRULES_ARG]++;
 		if (ind == NOUDEVSYNC_ARG)
 			_switches[NOUDEVSYNC_ARG]++;
+		if (ind == UDEVFALLBACK_ARG)
+			_switches[UDEVFALLBACK_ARG]++;
 		if (c == 'G' || ind == GID_ARG) {
 			_switches[GID_ARG]++;
 			_int_args[GID_ARG] = atoi(optarg);


