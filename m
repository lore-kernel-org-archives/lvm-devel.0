From: David Teigland <teigland@sourceware.org>
Date: Fri,  5 Nov 2021 17:45:37 +0000 (GMT)
Subject: main - vgchange -aay: optimize device list using pvs_online files
Message-ID: <20211105174537.1EB283858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=62533ae3fad9fece6f27e3fae7b56e40c66438fa
Commit:        62533ae3fad9fece6f27e3fae7b56e40c66438fa
Parent:        5f7cb977438891a073227d75029f61970b1710bd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 5 12:19:35 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 5 12:19:35 2021 -0500

vgchange -aay: optimize device list using pvs_online files

Port another optimization from pvscan -aay to vgchange -aay:
  "pvscan: only add device args to dev cache"

This optimization avoids doing a full dev_cache_scan, and
instead populates dev-cache with only the devices in the
VG being activated.

This involves shifting the use of pvs_online files from
the hints interface up to the higher level label_scan
interface.  This specialized label_scan is structured
around creating a list of devices from the pvs_online
files.  Previously, a list of all devices was created
first, and then reduced based on the pvs_online files.
The initial step of listing all devices was slow when
thousands of devices are present on the system.

This optimization extends the previous optimization that
used pvs_online files to limit the devices that were
actually scanned (i.e. reading to identify the device):
  "vgchange -aay: optimize device scan using pvs_online files"
---
 lib/cache/lvmcache.c               |  10 ++
 lib/cache/lvmcache.h               |   2 +
 lib/commands/toolcontext.h         |   1 -
 lib/device/dev-cache.c             |   6 +-
 lib/device/dev-cache.h             |   3 +-
 lib/device/online.c                | 116 ++++++++++++++++++++++-
 lib/device/online.h                |  11 +++
 lib/label/hints.c                  | 129 ++------------------------
 lib/label/hints.h                  |   3 +
 lib/label/label.c                  | 182 +++++++++++++++++++++++++++++++++++++
 lib/label/label.h                  |   1 +
 test/shell/udev-pvscan-vgchange.sh |   3 +
 tools/lvmcmdline.c                 |   2 -
 tools/pvscan.c                     |   2 +-
 tools/vgchange.c                   |  21 ++++-
 15 files changed, 357 insertions(+), 135 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index bee63ebb4..81b9b0ec9 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -572,6 +572,16 @@ static const char *_get_pvsummary_device_id(const char *pvid_arg, const char **d
 	return NULL;
 }
 
+int lvmcache_pvsummary_count(const char *vgname)
+{
+	struct lvmcache_vginfo *vginfo;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, NULL)))
+		return_0;
+
+	return dm_list_size(&vginfo->pvsummaries);
+}
+
 /*
  * Check if any PVs in vg->pvs have the same PVID as any
  * entries in _unused_duplicates.
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 9511bb9e9..4c4903136 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -229,4 +229,6 @@ void lvmcache_extra_md_component_checks(struct cmd_context *cmd);
 
 unsigned int lvmcache_vg_info_count(void);
 
+int lvmcache_pvsummary_count(const char *vgname);
+
 #endif
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index b3de65702..fb7182db6 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -183,7 +183,6 @@ struct cmd_context {
 	unsigned enable_hints:1;		/* hints are enabled for cmds in general */
 	unsigned use_hints:1;			/* if hints are enabled this cmd can use them */
 	unsigned pvscan_recreate_hints:1;	/* enable special case hint handling for pvscan --cache */
-	unsigned hints_pvs_online:1;		/* hints="pvs_online" */
 	unsigned scan_lvs:1;
 	unsigned wipe_outdated_pvs:1;
 	unsigned enable_devices_list:1;		/* command is using --devices option */
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 33b75a9a9..ce82a9303 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -2056,12 +2056,12 @@ int setup_device(struct cmd_context *cmd, const char *devname)
 }
 
 /*
- * pvscan --cache is specialized/optimized to look only at command args,
+ * autoactivation is specialized/optimized to look only at command args,
  * so this just sets up the devices file, then individual devices are
- * added to dev-cache and matched with device_ids later in pvscan.
+ * added to dev-cache and matched with device_ids.
  */
 
-int setup_devices_for_pvscan_cache(struct cmd_context *cmd)
+int setup_devices_for_online_autoactivation(struct cmd_context *cmd)
 {
 	if (cmd->enable_devices_list) {
 		if (!_setup_devices_list(cmd))
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 143848d6d..175c0a3e3 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -79,8 +79,7 @@ int setup_devices_file(struct cmd_context *cmd);
 int setup_devices(struct cmd_context *cmd);
 int setup_device(struct cmd_context *cmd, const char *devname);
 
-/* Normal device setup functions are split up for pvscan optimization. */
-int setup_devices_for_pvscan_cache(struct cmd_context *cmd);
+int setup_devices_for_online_autoactivation(struct cmd_context *cmd);
 int setup_devname_in_dev_cache(struct cmd_context *cmd, const char *devname);
 int setup_devno_in_dev_cache(struct cmd_context *cmd, dev_t devno);
 
diff --git a/lib/device/online.c b/lib/device/online.c
index 28e97d9fe..cd89d72e3 100644
--- a/lib/device/online.c
+++ b/lib/device/online.c
@@ -81,6 +81,64 @@ int online_pvid_file_read(char *path, int *major, int *minor, char *vgname)
 	return 1;
 }
 
+void free_po_list(struct dm_list *list)
+{
+	struct pv_online *po, *po2;
+
+	dm_list_iterate_items_safe(po, po2, list) {
+		dm_list_del(&po->list);
+		free(po);
+	}
+}
+
+int get_pvs_online(struct dm_list *pvs_online, const char *vgname)
+{
+	char path[PATH_MAX];
+	char file_vgname[NAME_LEN];
+	DIR *dir;
+	struct dirent *de;
+	struct pv_online *po;
+	int file_major = 0, file_minor = 0;
+
+	if (!(dir = opendir(PVS_ONLINE_DIR)))
+		return 0;
+
+	while ((de = readdir(dir))) {
+		if (de->d_name[0] == '.')
+			continue;
+
+		if (strlen(de->d_name) != ID_LEN)
+			continue;
+
+		memset(path, 0, sizeof(path));
+		snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, de->d_name);
+
+		file_major = 0;
+		file_minor = 0;
+		memset(file_vgname, 0, sizeof(file_vgname));
+
+		if (!online_pvid_file_read(path, &file_major, &file_minor, file_vgname))
+			continue;
+
+		if (vgname && strcmp(file_vgname, vgname))
+			continue;
+
+		if (!(po = zalloc(sizeof(*po))))
+			continue;
+
+		memcpy(po->pvid, de->d_name, ID_LEN);
+		if (file_major || file_minor)
+			po->devno = MKDEV(file_major, file_minor);
+		if (file_vgname[0])
+			strncpy(po->vgname, file_vgname, NAME_LEN-1);
+
+		dm_list_add(pvs_online, &po->list);
+	}
+	if (closedir(dir))
+		log_sys_debug("closedir", PVS_ONLINE_DIR);
+	return 1;
+}
+
 /*
  * When a PV goes offline, remove the vg online file for that VG
  * (even if other PVs for the VG are still online).  This means
@@ -250,6 +308,62 @@ int online_pvid_file_exists(const char *pvid)
 	return 0;
 }
 
+int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
+{
+	char lookup_path[PATH_MAX] = { 0 };
+	char path[PATH_MAX] = { 0 };
+	char line[64];
+	char pvid[ID_LEN + 1] __attribute__((aligned(8))) = { 0 };
+	char file_vgname[NAME_LEN];
+	struct pv_online *po;
+	int file_major = 0, file_minor = 0;
+	FILE *fp;
+
+	if (dm_snprintf(lookup_path, sizeof(path), "%s/%s", PVS_LOOKUP_DIR, vgname) < 0)
+		return_0;
+
+	if (!(fp = fopen(lookup_path, "r")))
+		return_0;
+
+	while (fgets(line, sizeof(line), fp)) {
+		memcpy(pvid, line, ID_LEN);
+		if (strlen(pvid) != ID_LEN)
+			goto_bad;
+
+		memset(path, 0, sizeof(path));
+		snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, pvid);
+
+		file_major = 0;
+		file_minor = 0;
+		memset(file_vgname, 0, sizeof(file_vgname));
+
+		if (!online_pvid_file_read(path, &file_major, &file_minor, file_vgname))
+			goto_bad;
+
+		if (vgname && strcmp(file_vgname, vgname))
+			goto_bad;
+
+		if (!(po = zalloc(sizeof(*po))))
+			goto_bad;
+
+		memcpy(po->pvid, pvid, ID_LEN);
+		if (file_major || file_minor)
+			po->devno = MKDEV(file_major, file_minor);
+		if (file_vgname[0])
+			strncpy(po->vgname, file_vgname, NAME_LEN-1);
+
+		dm_list_add(pvs_online, &po->list);
+	}
+
+	fclose(fp);
+	return 1;
+
+bad:
+	free_po_list(pvs_online);
+	fclose(fp);
+	return 0;
+}
+
 void online_dir_setup(struct cmd_context *cmd)
 {
 	struct stat st;
@@ -301,6 +415,4 @@ do_lookup:
 
 	if ((rv < 0) && stat(PVS_LOOKUP_DIR, &st))
 		log_error_pvscan(cmd, "Failed to create %s %d", PVS_LOOKUP_DIR, errno);
-
-
 }
diff --git a/lib/device/online.h b/lib/device/online.h
index 0a5076f7d..25a176854 100644
--- a/lib/device/online.h
+++ b/lib/device/online.h
@@ -15,6 +15,14 @@
 #ifndef _ONLINE_H
 #define _ONLINE_H
 
+struct pv_online {
+	struct dm_list list;
+	struct device *dev;
+	dev_t devno;
+	char pvid[ID_LEN + 1];
+	char vgname[NAME_LEN];
+};
+
 /*
  * Avoid a duplicate pvscan[%d] prefix when logging to the journal.
  * FIXME: this should probably replace if (udevoutput) with
@@ -42,5 +50,8 @@ void online_vg_file_remove(const char *vgname);
 int online_pvid_file_create(struct cmd_context *cmd, struct device *dev, const char *vgname);
 int online_pvid_file_exists(const char *pvid);
 void online_dir_setup(struct cmd_context *cmd);
+int get_pvs_online(struct dm_list *pvs_online, const char *vgname);
+int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname);
+void free_po_list(struct dm_list *list);
 
 #endif
diff --git a/lib/label/hints.c b/lib/label/hints.c
index 85e5ab1cb..9a7c280eb 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -1214,8 +1214,8 @@ void invalidate_hints(struct cmd_context *cmd)
  * probably want to exclude that command from attempting this optimization,
  * because it would be difficult to know what VG that command wanted to use.
  */
-static void _get_single_vgname_cmd_arg(struct cmd_context *cmd,
-				       struct dm_list *hints, char **vgname)
+void get_single_vgname_cmd_arg(struct cmd_context *cmd,
+			       struct dm_list *hints, char **vgname)
 {
 	struct hint *hint;
 	char namebuf[NAME_LEN];
@@ -1264,6 +1264,11 @@ static void _get_single_vgname_cmd_arg(struct cmd_context *cmd,
 		return;
 
 check:
+	if (!hints) {
+		*vgname = name;
+		return;
+	}
+
 	/*
 	 * Only use this vgname hint if there are hints that contain this
 	 * vgname.  This might happen if we aren't able to properly extract the
@@ -1280,109 +1285,6 @@ check:
 	free(name);
 }
 
-static int _get_hints_from_pvs_online(struct cmd_context *cmd, struct dm_list *hints_out,
-				      struct dm_list *devs_in, struct dm_list *devs_out)
-{
-	char path[PATH_MAX];
-	char file_vgname[NAME_LEN];
-	struct dm_list hints_list;
-	struct hint file_hint;
-	struct hint *alloc_hint;
-	struct hint *hint, *hint2;
-	struct device_list *devl, *devl2;
-	int file_major, file_minor;
-	int found = 0;
-	DIR *dir;
-	struct dirent *de;
-	char *vgname = NULL;
-	char *pvid;
-
-	dm_list_init(&hints_list);
-
-	if (!(dir = opendir(PVS_ONLINE_DIR)))
-		return 0;
-
-	while ((de = readdir(dir))) {
-		if (de->d_name[0] == '.')
-			continue;
-
-		pvid = de->d_name;
-
-		if (strlen(pvid) != ID_LEN) /* 32 */
-			continue;
-
-		memset(path, 0, sizeof(path));
-		snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, pvid);
-
-		memset(&file_hint, 0, sizeof(file_hint));
-		memset(file_vgname, 0, sizeof(file_vgname));
-		file_major = 0;
-		file_minor = 0;
-
-		if (!online_pvid_file_read(path, &file_major, &file_minor, file_vgname))
-			continue;
-
-		if (!dm_strncpy(file_hint.pvid, pvid, sizeof(file_hint.pvid)))
-			continue;
-
-		file_hint.devt = makedev(file_major, file_minor);
-
-		if (file_vgname[0] && validate_name(file_vgname)) {
-			if (!dm_strncpy(file_hint.vgname, file_vgname, sizeof(file_hint.vgname)))
-				continue;
-		}
-
-		if (!(alloc_hint = malloc(sizeof(struct hint))))
-			continue;
-
-		memcpy(alloc_hint, &file_hint, sizeof(struct hint));
-
-		log_debug("add hint %s %d:%d %s from pvs_online", file_hint.pvid, file_major, file_minor, file_vgname);
-		dm_list_add(&hints_list, &alloc_hint->list);
-		found++;
-	}
-
-	if (closedir(dir))
-		stack;
-
-	log_debug("accept hints found %d from pvs_online", found);
-
-	_get_single_vgname_cmd_arg(cmd, &hints_list, &vgname);
-
-	/*
-	 * apply_hints equivalent, move devs from devs_in to devs_out if
-	 * their devno matches the devno of a hint (and if the hint matches
-	 * the vgname when a vgname is present.)
-	 */
-	dm_list_iterate_items_safe(devl, devl2, devs_in) {
-		dm_list_iterate_items_safe(hint, hint2, &hints_list) {
-			if ((MAJOR(devl->dev->dev) == MAJOR(hint->devt)) &&
-			    (MINOR(devl->dev->dev) == MINOR(hint->devt))) {
-
-				if (vgname && hint->vgname[0] && strcmp(vgname, hint->vgname))
-					goto next_dev;
-
-				snprintf(hint->name, sizeof(hint->name), "%s", dev_name(devl->dev));
-				hint->chosen = 1;
-
-				dm_list_del(&devl->list);
-				dm_list_add(devs_out, &devl->list);
-			}
-		}
- next_dev:
-		;
-	}
-
-	log_debug("applied hints using %d other %d vgname %s from pvs_online",
-		  dm_list_size(devs_out), dm_list_size(devs_in), vgname ?: "");
-
-	dm_list_splice(hints_out, &hints_list);
-
-	free(vgname);
-
-	return 1;
-}
-
 /*
  * Returns 0: no hints are used.
  *  . newhints is set if this command should create new hints after scan
@@ -1404,7 +1306,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	*newhints = NEWHINTS_NONE;
 
 	/* No commands are using hints. */
-	if (!cmd->enable_hints && !cmd->hints_pvs_online)
+	if (!cmd->enable_hints)
 		return 0;
 
 	/*
@@ -1424,19 +1326,6 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	if (!cmd->use_hints)
 		return 0;
 
-	/*
-	 * enable_hints is 0 for the special hints=pvs_online
-	 * and by lvm.conf hints="none" does not disable hints=pvs_online.
-	 * hints=pvs_online can be disabled with --nohints.
-	 */
-	if (cmd->hints_pvs_online) {
-		if (!_get_hints_from_pvs_online(cmd, &hints_list, devs_in, devs_out)) {
-			log_debug("get_hints: pvs_online failed");
-			return 0;
-		}
-		return 1;
-	}
-
 	/*
 	 * Check if another command created the nohints file to prevent us from
 	 * using hints.
@@ -1541,7 +1430,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	 * us which devs are PVs. We might want to enable this optimization
 	 * separately.)
 	 */
-	_get_single_vgname_cmd_arg(cmd, &hints_list, &vgname);
+	get_single_vgname_cmd_arg(cmd, &hints_list, &vgname);
 
 	_apply_hints(cmd, &hints_list, vgname, devs_in, devs_out);
 
diff --git a/lib/label/hints.h b/lib/label/hints.h
index e8cfd6a7e..2bf7e7724 100644
--- a/lib/label/hints.h
+++ b/lib/label/hints.h
@@ -41,5 +41,8 @@ void hints_exit(struct cmd_context *cmd);
 
 void pvscan_recreate_hints_begin(struct cmd_context *cmd);
 
+void get_single_vgname_cmd_arg(struct cmd_context *cmd,
+                               struct dm_list *hints, char **vgname);
+
 #endif
 
diff --git a/lib/label/label.c b/lib/label/label.c
index f9ab9a1f1..709ae8fc1 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -26,6 +26,7 @@
 #include "lib/metadata/metadata.h"
 #include "lib/format_text/layout.h"
 #include "lib/device/device_id.h"
+#include "lib/device/online.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -1020,6 +1021,187 @@ int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev
 	return ret;
 }
 
+/*
+ * Use files under /run/lvm/, created by pvscan --cache autoactivation,
+ * to optimize device setup/scanning for a command that is run for a
+ * specific vg name.  autoactivation happens during system startup
+ * when the hints file is not useful, so this uses the online files as
+ * an alternative.
+ */ 
+
+int label_scan_vg_online(struct cmd_context *cmd, const char *vgname)
+{
+	struct dm_list pvs_online;
+	struct dm_list devs;
+	struct pv_online *po;
+	struct device_list *devl, *devl2;
+	int relax_deviceid_filter = 0;
+	int metadata_pv_count;
+
+	dm_list_init(&pvs_online);
+	dm_list_init(&devs);
+
+	/* reads devices file, does not populate dev-cache */
+	if (!setup_devices_for_online_autoactivation(cmd))
+		return 0;
+
+	/*
+	 * First attempt to use /run/lvm/pvs_lookup/vgname which should be
+	 * used in cases where all PVs in a VG do not contain metadata.
+	 * When the pvs_lookup file does not exist, then simply use all
+	 * /run/lvm/pvs_online/pvid files that contain a matching vgname.
+	 * The list of po structs represents the PVs in the VG, and the
+	 * info from the online files tell us which devices those PVs are
+	 * located on.
+	 */
+	if (!get_pvs_lookup(&pvs_online, vgname)) {
+		if (!get_pvs_online(&pvs_online, vgname))
+			goto bad;
+	}
+
+	/* for each po devno add a struct dev to dev-cache */
+
+	dm_list_iterate_items(po, &pvs_online) {
+		if (!setup_devno_in_dev_cache(cmd, po->devno)) {
+			log_error("No device set up for %d:%d PVID %s",
+				  (int)MAJOR(po->devno), (int)MINOR(po->devno), po->pvid);
+			goto bad;
+		}
+
+		if (!(po->dev = dev_cache_get_by_devt(cmd, po->devno, NULL, NULL))) {
+			log_error("No device found for %d:%d PVID %s",
+				  (int)MAJOR(po->devno), (int)MINOR(po->devno), po->pvid);
+			goto bad;
+		}
+
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			goto_bad;
+
+		devl->dev = po->dev;
+		dm_list_add(&devs, &devl->list);
+	}
+
+	/*
+	 * factor code common to pvscan_cache_args
+	 */
+
+	if (cmd->enable_devices_file) {
+		dm_list_iterate_items(devl, &devs)
+			device_ids_match_dev(cmd, devl->dev);
+	}
+
+	if (cmd->enable_devices_list)
+		device_ids_match_device_list(cmd);
+
+	if (cmd->enable_devices_file && device_ids_use_devname(cmd)) {
+		relax_deviceid_filter = 1;
+		cmd->filter_deviceid_skip = 1;
+	}
+
+	cmd->filter_nodata_only = 1;
+
+	dm_list_iterate_items_safe(devl, devl2, &devs) {
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
+			log_print("%s excluded by filters: %s.",
+				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
+			dm_list_del(&devl->list);
+		}
+	}
+
+	cmd->filter_nodata_only = 0;
+
+	/*
+	 * Clear the results of nodata filters that were saved by the
+	 * persistent filter so that the complete set of filters will
+	 * be checked by passes_filter below.
+	 */
+	dm_list_iterate_items(devl, &devs)
+		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
+
+	/*
+	 * Read header from each dev.
+	 * Eliminate non-lvm devs.
+	 * Apply all filters.
+	 */
+
+	log_debug("label_scan_vg_online: read and filter devs");
+
+	label_scan_setup_bcache();
+
+	dm_list_iterate_items_safe(devl, devl2, &devs) {
+		int has_pvid;
+
+		if (!label_read_pvid(devl->dev, &has_pvid)) {
+			log_print("%s cannot read label.", dev_name(devl->dev));
+			dm_list_del(&devl->list);
+			continue;
+		}
+
+		if (!has_pvid) {
+			/* Not an lvm device */
+			log_print("%s not an lvm device.", dev_name(devl->dev));
+			dm_list_del(&devl->list);
+			continue;
+		}
+
+		/*
+		 * filter-deviceid is not being used because of unstable devnames,
+		 * so in place of that check if the pvid is in the devices file.
+		 */
+		if (relax_deviceid_filter) {
+			if (!get_du_for_pvid(cmd, devl->dev->pvid)) {
+				log_print("%s excluded by devices file (checking PVID).",
+					  dev_name(devl->dev));
+				dm_list_del(&devl->list);
+				continue;
+			}
+		}
+
+		/* Applies all filters, including those that need data from dev. */
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
+			log_print("%s excluded by filters: %s.",
+				  dev_name(devl->dev), dev_filtered_reason(devl->dev));
+			dm_list_del(&devl->list);
+		}
+	}
+
+	if (relax_deviceid_filter)
+		cmd->filter_deviceid_skip = 0;
+
+	free_po_list(&pvs_online);
+
+	if (dm_list_empty(&devs))
+		return 1;
+
+	/*
+	 * Scan devs to populate lvmcache info, which includes the mda info that's
+	 * needed to read vg metadata.
+	 * bcache data from label_read_pvid above is not invalidated so it can
+	 * be reused (more data may need to be read depending on how much of the
+	 * metadata was covered when reading the pvid.)
+	 */
+	_scan_list(cmd, NULL, &devs, 0, NULL);
+
+	/*
+	 * Check if all PVs from the VG were found after scanning the devs
+	 * produced from the online files.  The online files are effectively
+	 * hints that usually work, but are not definitive, so we need to
+	 * be able to fall back to a standard label scan if the online hints
+	 * gave fewer PVs than listed in VG metadata.
+	 */
+	metadata_pv_count = lvmcache_pvsummary_count(vgname);
+	if (metadata_pv_count != dm_list_size(&devs)) {
+		log_debug("Incorrect PV list from online files %d metadata %d.",
+			   dm_list_size(&devs), metadata_pv_count);
+		return 0;
+	}
+
+	return 1;
+bad:
+	free_po_list(&pvs_online);
+	return 0;
+}
+
 /*
  * Scan devices on the system to discover which are LVM devices.
  * Info about the LVM devices (PVs) is saved in lvmcache in a
diff --git a/lib/label/label.h b/lib/label/label.h
index 34563efd0..55ebfde45 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -118,6 +118,7 @@ int label_scan_open_excl(struct device *dev);
 int label_scan_open_rw(struct device *dev);
 int label_scan_reopen_rw(struct device *dev);
 int label_read_pvid(struct device *dev, int *has_pvid);
+int label_scan_vg_online(struct cmd_context *cmd, const char *vgname);
 
 int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev_out);
 
diff --git a/test/shell/udev-pvscan-vgchange.sh b/test/shell/udev-pvscan-vgchange.sh
index c81acf0ce..f0d637562 100644
--- a/test/shell/udev-pvscan-vgchange.sh
+++ b/test/shell/udev-pvscan-vgchange.sh
@@ -219,6 +219,8 @@ udevadm trigger -c add /sys/block/$BDEV3
 aux udev_wait
 wait_lvm_activate $vg4
 
+ls "$RUNDIR/lvm/pvs_lookup/"
+cat "$RUNDIR/lvm/pvs_lookup/$vg4" || true
 ls "$RUNDIR/lvm/pvs_online/$PVID1"
 ls "$RUNDIR/lvm/pvs_online/$PVID2"
 ls "$RUNDIR/lvm/pvs_online/$PVID3"
@@ -375,6 +377,7 @@ touch $DF
 mdadm --create --metadata=1.0 "$mddev" --level 1 --chunk=64 --raid-devices=2 "$dev1" "$dev2"
 wait_md_create "$mddev"
 vgcreate $vg9 "$mddev"
+lvmdevices --adddev "$mddev" || true
 
 PVIDMD=`pvs $mddev --noheading -o uuid | tr -d - | awk '{print $1}'`
 BDEVMD=$(basename "$mddev")
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0f2c832ae..a28d98ecf 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2542,8 +2542,6 @@ static int _get_current_settings(struct cmd_context *cmd)
 		if (!strcmp(hint_mode, "none")) {
 			cmd->enable_hints = 0;
 			cmd->use_hints = 0;
-		} else if (!strcmp(hint_mode, "pvs_online")) {
-			cmd->hints_pvs_online = 1;
 		}
 	}
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index c1f7fbe6d..6fd86e486 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1378,7 +1378,7 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	 * Does not do dev_cache_scan (adds nothing to dev-cache), and
 	 * does not do any device id matching.
 	 */
-	if (!setup_devices_for_pvscan_cache(cmd)) {
+	if (!setup_devices_for_online_autoactivation(cmd)) {
 		log_error_pvscan(cmd, "Failed to set up devices.");
 		return 0;
 	}
diff --git a/tools/vgchange.c b/tools/vgchange.c
index ee06c498c..e20026e4d 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -15,6 +15,7 @@
 
 #include "tools.h"
 #include "lib/device/device_id.h"
+#include "lib/label/hints.h"
 
 struct vgchange_params {
 	int lock_start_count;
@@ -755,10 +756,7 @@ static int _check_autoactivation(struct cmd_context *cmd, struct vgchange_params
 
 	vp->vg_complete_to_activate = 1;
 
-	if (!arg_is_set(cmd, nohints_ARG))
-		cmd->hints_pvs_online = 1;
-	else
-		cmd->use_hints = 0;
+	cmd->use_hints = 0;
 
 	return 1;
 }
@@ -767,6 +765,7 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
 	struct vgchange_params vp = { 0 };
 	struct processing_handle *handle;
+	char *vgname = NULL;
 	uint32_t flags = 0;
 	int ret;
 
@@ -885,6 +884,20 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 			return ECMD_FAILED;
 		if (skip_command)
 			return ECMD_PROCESSED;
+
+		/*
+		 * Special label scan optimized for autoactivation
+		 * that is based on info read from /run/lvm/ files
+		 * created by pvscan --cache during autoactivation.
+		 * (Add an option to disable this optimization?)
+		 */
+		get_single_vgname_cmd_arg(cmd, NULL, &vgname);
+		if (vgname) {
+			if (!label_scan_vg_online(cmd, vgname))
+				log_debug("Standard label_scan required in place of online scan.");
+			else
+				flags |= PROCESS_SKIP_SCAN;
+		}
 	}
 
 	if (update)


