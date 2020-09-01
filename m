From: David Teigland <teigland@sourceware.org>
Date: Tue,  1 Sep 2020 22:14:27 +0000 (GMT)
Subject: master - integrity: always default to journal mode
Message-ID: <20200901221427.57ABA385E005@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2c1de783cd1afc522b65f5deb45567c6cb2ffbf
Commit:        f2c1de783cd1afc522b65f5deb45567c6cb2ffbf
Parent:        9a06700017bd2d97ff96854f7acbe4b1c74c2ab3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 1 12:53:00 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 1 17:12:28 2020 -0500

integrity: always default to journal mode

lvconvert was defaulting to bitmap mode,
and lvcreate was defaulting to journal mode.
---
 lib/metadata/integrity_manip.c   | 15 +++++++++++++++
 lib/metadata/metadata-exported.h |  1 +
 tools/toollib.c                  | 14 --------------
 tools/tools.h                    |  2 --
 4 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index 3322a2101..290b7a863 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -303,6 +303,21 @@ int lv_remove_integrity_from_raid(struct logical_volume *lv)
 	return 1;
 }
 
+int integrity_mode_set(const char *mode, struct integrity_settings *settings)
+{
+	if (!mode)
+		settings->mode[0] = DEFAULT_MODE;
+	else if (!strcmp(mode, "bitmap") || !strcmp(mode, "B"))
+		settings->mode[0] = 'B';
+	else if (!strcmp(mode, "journal") || !strcmp(mode, "J"))
+		settings->mode[0] = 'J';
+	else {
+		log_error("Invalid raid integrity mode (use \"bitmap\" or \"journal\")");
+		return 0;
+	}
+	return 1;
+}
+
 static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_volume *lv, int is_active,
 				     struct integrity_settings *settings,
 				     int lbs_4k, int lbs_512, int pbs_4k, int pbs_512)
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index db41ca36c..e5c8e4305 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1414,5 +1414,6 @@ int lv_has_integrity_recalculate_metadata(struct logical_volume *lv);
 int lv_raid_has_integrity(struct logical_volume *lv);
 int lv_extend_integrity_in_raid(struct logical_volume *lv, struct dm_list *pvh);
 int lv_get_raid_integrity_settings(struct logical_volume *lv, struct integrity_settings **isettings);
+int integrity_mode_set(const char *mode, struct integrity_settings *settings);
 
 #endif
diff --git a/tools/toollib.c b/tools/toollib.c
index eb0de5501..019346ce9 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -718,20 +718,6 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 	return 1;
 }
 
-int integrity_mode_set(const char *mode, struct integrity_settings *settings)
-{
-	if (!mode || !strcmp(mode, "bitmap") || !strcmp(mode, "B"))
-		settings->mode[0] = 'B';
-	else if (!strcmp(mode, "journal") || !strcmp(mode, "J"))
-		settings->mode[0] = 'J';
-	else {
-		/* FIXME: the kernel has other modes, should we allow any of those? */
-		log_error("Invalid raid integrity mode (use \"bitmap\" or \"journal\")");
-		return 0;
-	}
-	return 1;
-}
-
 /* Shared code for changing activation state for vgchange/lvchange */
 int lv_change_activate(struct cmd_context *cmd, struct logical_volume *lv,
 		       activation_change_t activate)
diff --git a/tools/tools.h b/tools/tools.h
index befff5708..a0be4bedb 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -212,8 +212,6 @@ unsigned grouped_arg_is_set(const struct arg_values *av, int a);
 const char *grouped_arg_str_value(const struct arg_values *av, int a, const char *def);
 int32_t grouped_arg_int_value(const struct arg_values *av, int a, const int32_t def); 
 
-int integrity_mode_set(const char *mode, struct integrity_settings *settings);
-
 const char *command_name(struct cmd_context *cmd);
 
 int pvmove_poll(struct cmd_context *cmd, const char *pv_name, const char *uuid,


