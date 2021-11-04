From: David Teigland <teigland@sourceware.org>
Date: Thu,  4 Nov 2021 16:37:10 +0000 (GMT)
Subject: main - add hints interface to the pvs_online file information
Message-ID: <20211104163710.B87EC385840F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=726dd25969e9e6a3de285a22cea45e9f5f53520f
Commit:        726dd25969e9e6a3de285a22cea45e9f5f53520f
Parent:        6ea8d975b23758e6e099bf51cf7334f27f9fd096
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 15 16:33:50 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 4 10:58:16 2021 -0500

add hints interface to the pvs_online file information

The information in /run/lvm/pvs_online/<pvid> files can
be used to build a list of devices for a given VG.

The pvscan -aay command has long used this information to
activate a VG while scanning only devices in that VG, which
is an important optimization for autoactivation.

This patch implements the same thing through the existing
device hints interface, so that the optimization can be
applied elsewhere.  A future patch will take advantage of
this optimization in vgchange -aay, which is now used in
place of pvscan -aay for event activation.
---
 lib/commands/toolcontext.h |   1 +
 lib/config/defaults.h      |   4 ++
 lib/label/hints.c          | 121 ++++++++++++++++++++++++++++++++++++++++++++-
 lib/label/label.c          |   3 ++
 tools/lvmcmdline.c         |   2 +
 tools/pvscan.c             |  12 +++--
 6 files changed, 137 insertions(+), 6 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 356c79f8a..e864932f2 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -183,6 +183,7 @@ struct cmd_context {
 	unsigned enable_hints:1;		/* hints are enabled for cmds in general */
 	unsigned use_hints:1;			/* if hints are enabled this cmd can use them */
 	unsigned pvscan_recreate_hints:1;	/* enable special case hint handling for pvscan --cache */
+	unsigned hints_pvs_online:1;		/* hints="pvs_online" */
 	unsigned scan_lvs:1;
 	unsigned wipe_outdated_pvs:1;
 	unsigned enable_devices_list:1;		/* command is using --devices option */
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 1b1568a7b..3308b1ea6 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -328,4 +328,8 @@
 
 #define DEFAULT_WWIDS_FILE "/etc/multipath/wwids"
 
+#define PVS_ONLINE_DIR DEFAULT_RUN_DIR "/pvs_online"
+#define VGS_ONLINE_DIR DEFAULT_RUN_DIR "/vgs_online"
+#define PVS_LOOKUP_DIR DEFAULT_RUN_DIR "/pvs_lookup"
+
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/label/hints.c b/lib/label/hints.c
index e444a0c82..c84bd1f1c 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -150,11 +150,14 @@
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <unistd.h>
+#include <dirent.h>
 #include <time.h>
 #include <sys/types.h>
 #include <sys/file.h>
 #include <sys/sysmacros.h>
 
+int online_pvid_file_read(char *path, int *major, int *minor, char *vgname);
+
 static const char *_hints_file = DEFAULT_RUN_DIR "/hints";
 static const char *_nohints_file = DEFAULT_RUN_DIR "/nohints";
 static const char *_newhints_file = DEFAULT_RUN_DIR "/newhints";
@@ -1278,6 +1281,109 @@ check:
 	free(name);
 }
 
+static int _get_hints_from_pvs_online(struct cmd_context *cmd, struct dm_list *hints_out,
+				      struct dm_list *devs_in, struct dm_list *devs_out)
+{
+	char path[PATH_MAX];
+	char file_vgname[NAME_LEN];
+	struct dm_list hints_list;
+	struct hint file_hint;
+	struct hint *alloc_hint;
+	struct hint *hint, *hint2;
+	struct device_list *devl, *devl2;
+	int file_major, file_minor;
+	int found = 0;
+	DIR *dir;
+	struct dirent *de;
+	char *vgname = NULL;
+	char *pvid;
+
+	dm_list_init(&hints_list);
+
+	if (!(dir = opendir(PVS_ONLINE_DIR)))
+		return 0;
+
+	while ((de = readdir(dir))) {
+		if (de->d_name[0] == '.')
+			continue;
+
+		pvid = de->d_name;
+
+		if (strlen(pvid) != ID_LEN) /* 32 */
+			continue;
+
+		memset(path, 0, sizeof(path));
+		snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, pvid);
+
+		memset(&file_hint, 0, sizeof(file_hint));
+		memset(file_vgname, 0, sizeof(file_vgname));
+		file_major = 0;
+		file_minor = 0;
+
+		if (!online_pvid_file_read(path, &file_major, &file_minor, file_vgname))
+			continue;
+
+		if (!dm_strncpy(file_hint.pvid, pvid, sizeof(file_hint.pvid)))
+			continue;
+
+		file_hint.devt = makedev(file_major, file_minor);
+
+		if (file_vgname[0] && validate_name(file_vgname)) {
+			if (!dm_strncpy(file_hint.vgname, file_vgname, sizeof(file_hint.vgname)))
+				continue;
+		}
+
+		if (!(alloc_hint = malloc(sizeof(struct hint))))
+			continue;
+
+		memcpy(alloc_hint, &file_hint, sizeof(struct hint));
+
+		log_debug("add hint %s %d:%d %s from pvs_online", file_hint.pvid, file_major, file_minor, file_vgname);
+		dm_list_add(&hints_list, &alloc_hint->list);
+		found++;
+	}
+
+	if (closedir(dir))
+		stack;
+
+	log_debug("accept hints found %d from pvs_online", found);
+
+	_get_single_vgname_cmd_arg(cmd, &hints_list, &vgname);
+
+	/*
+	 * apply_hints equivalent, move devs from devs_in to devs_out if
+	 * their devno matches the devno of a hint (and if the hint matches
+	 * the vgname when a vgname is present.)
+	 */
+	dm_list_iterate_items_safe(devl, devl2, devs_in) {
+		dm_list_iterate_items_safe(hint, hint2, &hints_list) {
+			if ((MAJOR(devl->dev->dev) == MAJOR(hint->devt)) &&
+			    (MINOR(devl->dev->dev) == MINOR(hint->devt))) {
+
+				if (vgname && hint->vgname[0] && strcmp(vgname, hint->vgname))
+					goto next_dev;
+
+				snprintf(hint->name, sizeof(hint->name), "%s", dev_name(devl->dev));
+				hint->chosen = 1;
+
+				dm_list_del(&devl->list);
+				dm_list_add(devs_out, &devl->list);
+			}
+		}
+ next_dev:
+		;
+	}
+
+	log_debug("applied hints using %d other %d vgname %s from pvs_online",
+		  dm_list_size(devs_out), dm_list_size(devs_in), vgname ?: "");
+
+	dm_list_splice(hints_out, &hints_list);
+
+	free(vgname);
+
+	return 1;
+}
+
 /*
  * Returns 0: no hints are used.
  *  . newhints is set if this command should create new hints after scan
@@ -1299,7 +1405,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	*newhints = NEWHINTS_NONE;
 
 	/* No commands are using hints. */
-	if (!cmd->enable_hints)
+	if (!cmd->enable_hints && !cmd->hints_pvs_online)
 		return 0;
 
 	/*
@@ -1319,6 +1425,19 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	if (!cmd->use_hints)
 		return 0;
 
+	/*
+	 * enable_hints is 0 for the special hints=pvs_online
+	 * and by lvm.conf hints="none" does not disable hints=pvs_online.
+	 * hints=pvs_online can be disabled with --nohints.
+	 */
+	if (cmd->hints_pvs_online) {
+		if (!_get_hints_from_pvs_online(cmd, &hints_list, devs_in, devs_out)) {
+			log_debug("get_hints: pvs_online failed");
+			return 0;
+		}
+		return 1;
+	}
+
 	/*
 	 * Check if another command created the nohints file to prevent us from
 	 * using hints.
diff --git a/lib/label/label.c b/lib/label/label.c
index 9fac3e464..f9ab9a1f1 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -1130,6 +1130,9 @@ int label_scan(struct cmd_context *cmd)
 			}
 		}
 	}
+
+	log_debug_devs("Filtering devices to scan done (nodata)");
+
 	cmd->filter_nodata_only = 0;
 
 	dm_list_iterate_items(devl, &all_devs)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 1e12bedca..9cbeab91d 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2540,6 +2540,8 @@ static int _get_current_settings(struct cmd_context *cmd)
 		if (!strcmp(hint_mode, "none")) {
 			cmd->enable_hints = 0;
 			cmd->use_hints = 0;
+		} else if (!strcmp(hint_mode, "pvs_online")) {
+			cmd->hints_pvs_online = 1;
 		}
 	}
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 7d84e45d4..01f57af0c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -21,6 +21,8 @@
 
 #include <dirent.h>
 
+int online_pvid_file_read(char *path, int *major, int *minor, char *vgname);
+
 struct pvscan_params {
 	int new_pvs_found;
 	int pvs_found;
@@ -225,7 +227,7 @@ static char *_vgname_in_pvid_file_buf(char *buf)
 
 #define MAX_PVID_FILE_SIZE 512
 
-static int _online_pvid_file_read(char *path, int *major, int *minor, char *vgname)
+int online_pvid_file_read(char *path, int *major, int *minor, char *vgname)
 {
 	char buf[MAX_PVID_FILE_SIZE] = { 0 };
 	char *name;
@@ -328,7 +330,7 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 		file_minor = 0;
 		memset(file_vgname, 0, sizeof(file_vgname));
 
-		_online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
+		online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
 
 		if ((file_major == major) && (file_minor == minor)) {
 			log_debug("Unlink pv online %s", path);
@@ -447,7 +449,7 @@ check_duplicate:
 
 	memset(file_vgname, 0, sizeof(file_vgname));
 
-	_online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
+	online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
 
 	if ((file_major == major) && (file_minor == minor)) {
 		log_debug("Existing online file for %d:%d", major, minor);
@@ -847,7 +849,7 @@ static int _get_devs_from_saved_vg(struct cmd_context *cmd, const char *vgname,
 		file_minor = 0;
 		memset(file_vgname, 0, sizeof(file_vgname));
 
-		_online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
+		online_pvid_file_read(path, &file_major, &file_minor, file_vgname);
 
 		if (file_vgname[0] && strcmp(vgname, file_vgname)) {
 			log_error_pvscan(cmd, "Wrong VG found for %d:%d PVID %s: %s vs %s",
@@ -1254,7 +1256,7 @@ static void _set_pv_devices_online(struct cmd_context *cmd, struct volume_group
 		minor = 0;
 		file_vgname[0] = '\0';
 
-		_online_pvid_file_read(path, &major, &minor, file_vgname);
+		online_pvid_file_read(path, &major, &minor, file_vgname);
 
 		if (file_vgname[0] && strcmp(vg->name, file_vgname)) {
 			log_warn("WARNING: VG %s PV %s wrong vgname in online file %s",


