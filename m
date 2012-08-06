From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  6 Aug 2012 16:10:20 +0000 (UTC)
Subject: master - args: increase major:minor limit to 4095:1048575
Message-ID: <20120806161020.F3F20325E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e55201144be3bcf82b6aafe7e9f7430318719d0
Commit:        6e55201144be3bcf82b6aafe7e9f7430318719d0
Parent:        3843f54974ea7c3bbe51fcd681a55fc23f4e7736
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 6 18:01:01 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 6 18:01:01 2012 +0200

args: increase major:minor limit to 4095:1048575

Remove the limit for major and minor number arguments used while specifying
persistent numbers via -My --major <major> --minor <minor> option which
was set to 255 before. Follow the kernel limit instead which is 12 bits
for major and 20 bits for minor number (kernel >= 2.6 and LVM formats
that does not have FMT_RESTRICTED_LVIDS - so still keep the old limit
of 255 for lvm1 format).
---
 WHATS_NEW          |    1 +
 tools/args.h       |    4 +-
 tools/lvchange.c   |   11 +++++++-
 tools/lvcreate.c   |    7 ++++-
 tools/lvmcmdline.c |   61 ++++++++++++++++++++++++---------------------------
 tools/tools.h      |    2 +
 6 files changed, 48 insertions(+), 38 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 92dd0dc..eab7e99 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.97 - 
 ===============================
+  Increase limit for major:minor to 4095:1048575 when using -My option.
   Add make install_systemd_generators.
   Add generator for lvm2 activation systemd units.
   Add lvm_config_find_bool lvm2app fn to retrieve bool value from config tree.
diff --git a/tools/args.h b/tools/args.h
index 4909f9e..b195303 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -44,7 +44,7 @@ arg(addtag_ARG, '\0', "addtag", tag_arg, ARG_GROUPABLE)
 arg(deltag_ARG, '\0', "deltag", tag_arg, ARG_GROUPABLE)
 arg(refresh_ARG, '\0', "refresh", NULL, 0)
 arg(mknodes_ARG, '\0', "mknodes", NULL, 0)
-arg(minor_ARG, '\0', "minor", minor_arg, ARG_GROUPABLE)
+arg(minor_ARG, '\0', "minor", int_arg, ARG_GROUPABLE)
 arg(type_ARG, '\0', "type", segtype_arg, 0)
 arg(alloc_ARG, '\0', "alloc", alloc_arg, 0)
 arg(separator_ARG, '\0', "separator", string_arg, 0)
@@ -117,7 +117,7 @@ arg(size_ARG, 'L', "size", size_mb_arg, 0)
 arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0)
 arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0)
 arg(merge_ARG, '\0', "merge", NULL, 0)
-arg(major_ARG, 'j', "major", major_arg, ARG_GROUPABLE)
+arg(major_ARG, 'j', "major", int_arg, ARG_GROUPABLE)
 arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign, 0)
 arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg, 0)
 arg(maps_ARG, 'm', "maps", NULL, 0)
diff --git a/tools/lvchange.c b/tools/lvchange.c
index a24d26c..c5cbe08 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -516,6 +516,7 @@ static int lvchange_persistent(struct cmd_context *cmd,
 {
 	struct lvinfo info;
 	int active = 0;
+	int32_t major, minor;
 
 	if (!strcmp(arg_str_value(cmd, persistent_ARG, "n"), "n")) {
 		if (!(lv->status & FIXED_MINOR)) {
@@ -547,6 +548,12 @@ static int lvchange_persistent(struct cmd_context *cmd,
 		}
 		if (lv_info(cmd, lv, 0, &info, 0, 0) && info.exists)
 			active = 1;
+
+		major = arg_int_value(cmd, major_ARG, lv->major);
+		minor = arg_int_value(cmd, minor_ARG, lv->minor);
+		if (!major_minor_valid(cmd, lv->vg->fid->fmt, major, minor))
+			return 0;
+
 		if (active && !arg_count(cmd, force_ARG) &&
 		    yes_no_prompt("Logical volume %s will be "
 				  "deactivated temporarily. "
@@ -565,8 +572,8 @@ static int lvchange_persistent(struct cmd_context *cmd,
 			return 0;
 		}
 		lv->status |= FIXED_MINOR;
-		lv->minor = arg_int_value(cmd, minor_ARG, lv->minor);
-		lv->major = arg_int_value(cmd, major_ARG, lv->major);
+		lv->minor = minor;
+		lv->major = major;
 		log_verbose("Setting persistent device number to (%d, %d) "
 			    "for \"%s\"", lv->major, lv->minor, lv->name);
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index ab217cf..48977d7 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -555,7 +555,8 @@ static int _read_raid_params(struct lvcreate_params *lp,
 	return 1;
 }
 
-static int _read_activation_params(struct lvcreate_params *lp, struct cmd_context *cmd)
+static int _read_activation_params(struct lvcreate_params *lp, struct cmd_context *cmd,
+				   struct volume_group *vg)
 {
 	unsigned pagesize;
 
@@ -637,6 +638,8 @@ static int _read_activation_params(struct lvcreate_params *lp, struct cmd_contex
 					  "--major when using -My");
 				return 0;
 			}
+			if (!major_minor_valid(cmd, vg->fid->fmt, lp->major, lp->minor))
+				return 0;
 		} else {
 			if ((lp->minor != -1) || (lp->major != -1)) {
 				log_error("--major and --minor incompatible "
@@ -1032,7 +1035,7 @@ int lvcreate(struct cmd_context *cmd, int argc, char **argv)
 	 * Check activation parameters to support inactive thin snapshot creation
 	 * FIXME: anything else needs to be moved past _determine_snapshot_type()?
 	 */
-	if (!_read_activation_params(&lp, cmd)) {
+	if (!_read_activation_params(&lp, cmd, vg)) {
 		r = ECMD_FAILED;
 		goto_out;
 	}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0e6a51c..50a2ac1 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -407,38 +407,6 @@ int int_arg_with_sign_and_percent(struct cmd_context *cmd __attribute__((unused)
 	return 1;
 }
 
-int minor_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
-{
-	char *ptr;
-
-	if (!_get_int_arg(av, &ptr) || (*ptr) || (av->sign == SIGN_MINUS))
-		return 0;
-
-	if (av->i_value > 255) {
-		log_error("Minor number outside range 0-255");
-		return 0;
-	}
-
-	return 1;
-}
-
-int major_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
-{
-	char *ptr;
-
-	if (!_get_int_arg(av, &ptr) || (*ptr) || (av->sign == SIGN_MINUS))
-		return 0;
-
-	if (av->i_value > 255) {
-		log_error("Major number outside range 0-255");
-		return 0;
-	}
-
-	/* FIXME Also Check against /proc/devices */
-
-	return 1;
-}
-
 int string_arg(struct cmd_context *cmd __attribute__((unused)),
 	       struct arg_values *av __attribute__((unused)))
 {
@@ -540,6 +508,35 @@ int metadatacopies_arg(struct cmd_context *cmd, struct arg_values *av)
 	return int_arg(cmd, av);
 }
 
+int major_minor_valid(const struct cmd_context *cmd, const struct format_type *fmt,
+		      int32_t major, int32_t minor)
+{
+	if (!strncmp(cmd->kernel_vsn, "2.4.", 4) ||
+	    (fmt->features & FMT_RESTRICTED_LVIDS)) {
+		if (major < 0 || major > 255) {
+			log_error("Major number outside range 0-255");
+			return 0;
+		}
+		if (minor < 0 || minor > 255) {
+			log_error("Minor number outside range 0-255");
+			return 0;
+		}
+	} else {
+		/* 12 bits for major number */
+		if (major < 0 || major > 4095) {
+			log_error("Major number outside range 0-4095");
+			return 0;
+		}
+		/* 20 bits for minor number */
+		if (minor < 0 || minor > 1048575) {
+			log_error("Minor number outside range 0-1048575");
+			return 0;
+		}
+	}
+
+	return 1;
+}
+
 static void __alloc(int size)
 {
 	if (!(_cmdline.commands = dm_realloc(_cmdline.commands, sizeof(*_cmdline.commands) * size))) {
diff --git a/tools/tools.h b/tools/tools.h
index f92abd5..4d2f5b0 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -156,6 +156,8 @@ int segtype_arg(struct cmd_context *cmd, struct arg_values *av);
 int alloc_arg(struct cmd_context *cmd, struct arg_values *av);
 int readahead_arg(struct cmd_context *cmd, struct arg_values *av);
 int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int major_minor_valid(const struct cmd_context * cmd, const struct format_type *fmt,
+		      int32_t major, int32_t minor);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);


