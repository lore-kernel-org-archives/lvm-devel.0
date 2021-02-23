From: David Teigland <teigland@sourceware.org>
Date: Tue, 23 Feb 2021 22:48:48 +0000 (GMT)
Subject: main - device usage based on devices file
Message-ID: <20210223224848.BCBF9382E804@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83fe6e720f42711ff183a66909b690b726702f58
Commit:        83fe6e720f42711ff183a66909b690b726702f58
Parent:        f7d9542aed2615c2a3737ec055a15b79877ac7fc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 23 13:25:41 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 23 16:43:32 2021 -0600

device usage based on devices file

The LVM devices file lists devices that lvm can use.  The default
file is /etc/lvm/devices/system.devices, and the lvmdevices(8)
command is used to add or remove device entries.  If the file
does not exist, or if lvm.conf includes use_devicesfile=0, then
lvm will not use a devices file.  When the devices file is in use,
the regex filter is not used, and the filter settings in lvm.conf
or on the command line are ignored.

LVM records devices in the devices file using hardware-specific
IDs, such as the WWID, and attempts to use subsystem-specific
IDs for virtual device types.  These device IDs are also written
in the VG metadata.  When no hardware or virtual ID is available,
lvm falls back using the unstable device name as the device ID.
When devnames are used, lvm performs extra scanning to find
devices if their devname changes, e.g. after reboot.

When proper device IDs are used, an lvm command will not look
at devices outside the devices file, but when devnames are used
as a fallback, lvm will scan devices outside the devices file
to locate PVs on renamed devices.  A config setting
search_for_devnames can be used to control the scanning for
renamed devname entries.

Related to the devices file, the new command option
--devices <devnames> allows a list of devices to be specified for
the command to use, overriding the devices file.  The listed
devices act as a sort of devices file in terms of limiting which
devices lvm will see and use.  Devices that are not listed will
appear to be missing to the lvm command.

Multiple devices files can be kept in /etc/lvm/devices, which
allows lvm to be used with different sets of devices, e.g.
system devices do not need to be exposed to a specific application,
and the application can use lvm on its own set of devices that are
not exposed to the system.  The option --devicesfile <filename> is
used to select the devices file to use with the command.  Without
the option set, the default system devices file is used.

Setting --devicesfile "" causes lvm to not use a devices file.

An existing, empty devices file means lvm will see no devices.

The new command vgimportdevices adds PVs from a VG to the devices
file and updates the VG metadata to include the device IDs.
vgimportdevices -a will import all VGs into the system devices file.

LVM commands run by dmeventd not use a devices file by default,
and will look at all devices on the system.  A devices file can
be created for dmeventd (/etc/lvm/devices/dmeventd.devices)  If
this file exists, lvm commands run by dmeventd will use it.

Internal implementaion:

- device_ids_read - read the devices file
  . add struct dev_use (du) to cmd->use_devices for each devices file entry
- dev_cache_scan - get /dev entries
  . add struct device (dev) to dev_cache for each device on the system
- device_ids_match - match devices file entries to /dev entries
  . match each du on cmd->use_devices to a dev in dev_cache, using device ID
  . on match, set du->dev, dev->id, dev->flags MATCHED_USE_ID
- label_scan - read lvm headers and metadata from devices
  . filters are applied, those that do not need data from the device
  . filter-deviceid skips devs without MATCHED_USE_ID, i.e.
    skips /dev entries that are not listed in the devices file
  . read lvm label from dev
  . filters are applied, those that use data from the device
  . read lvm metadata from dev
  . add info/vginfo structs for PVs/VGs (info is "lvmcache")
- device_ids_find_renamed_devs - handle devices with unstable devname ID
  where devname changed
  . this step only needed when devs do not have proper device IDs,
    and their dev names change, e.g. after reboot sdb becomes sdc.
  . detect incorrect match because PVID in the devices file entry
    does not match the PVID found when the device was read above
  . undo incorrect match between du and dev above
  . search system devices for new location of PVID
  . update devices file with new devnames for PVIDs on renamed devices
  . label_scan the renamed devs
- continue with command processing
---
 daemons/lvmpolld/lvmpolld-cmd-utils.c  |    6 +
 daemons/lvmpolld/lvmpolld-core.c       |    8 +-
 daemons/lvmpolld/lvmpolld-data-utils.c |    7 +-
 daemons/lvmpolld/lvmpolld-data-utils.h |    4 +-
 daemons/lvmpolld/lvmpolld-protocol.h   |    1 +
 lib/Makefile.in                        |    2 +
 lib/cache/lvmcache.c                   |   88 +-
 lib/cache/lvmcache.h                   |    2 +
 lib/commands/toolcontext.c             |   20 +-
 lib/commands/toolcontext.h             |   14 +
 lib/config/config_settings.h           |   26 +
 lib/config/defaults.h                  |    5 +
 lib/device/dev-cache.c                 |  353 ++++-
 lib/device/dev-cache.h                 |    7 +-
 lib/device/dev-type.c                  |   39 +
 lib/device/dev-type.h                  |    1 +
 lib/device/device.h                    |   44 +
 lib/device/device_id.c                 | 2320 ++++++++++++++++++++++++++++++++
 lib/device/device_id.h                 |   55 +
 lib/filters/filter-deviceid.c          |   69 +
 lib/filters/filter-regex.c             |    7 +
 lib/filters/filter.h                   |    3 +
 lib/format_text/export.c               |    9 +
 lib/format_text/import_vsn1.c          |   34 +-
 lib/label/hints.c                      |   57 +-
 lib/label/label.c                      |   61 +-
 lib/label/label.h                      |    1 -
 lib/lvmpolld/lvmpolld-client.c         |    7 +
 lib/lvmpolld/polldaemon.h              |    1 +
 lib/metadata/pv.c                      |   14 +
 lib/metadata/pv.h                      |    4 +
 lib/report/columns.h                   |    2 +
 lib/report/properties.c                |    4 +
 lib/report/report.c                    |   36 +
 man/Makefile.in                        |    2 +-
 man/lvm.8_main                         |    6 +
 man/lvmdevices.8_des                   |   62 +
 man/lvmdevices.8_end                   |    0
 man/see_also.end                       |    2 +
 man/vgimportdevices.8_des              |   11 +
 man/vgimportdevices.8_end              |    0
 spec/packages.inc                      |    4 +
 tools/Makefile.in                      |    2 +
 tools/args.h                           |   30 +
 tools/command-lines.in                 |   46 +-
 tools/commands.h                       |    8 +
 tools/lvmcmdline.c                     |   71 +-
 tools/lvmdevices.c                     |  465 +++++++
 tools/polldaemon.c                     |    9 +
 tools/pvchange.c                       |   17 +
 tools/pvck.c                           |   42 +-
 tools/pvcreate.c                       |    2 +
 tools/pvscan.c                         |   48 +-
 tools/toollib.c                        |   29 +-
 tools/tools.h                          |    1 +
 tools/vgcreate.c                       |    4 +
 tools/vgextend.c                       |    4 +
 tools/vgimportclone.c                  |  420 ++++--
 tools/vgimportdevices.c                |  207 +++
 59 files changed, 4614 insertions(+), 189 deletions(-)

diff --git a/daemons/lvmpolld/lvmpolld-cmd-utils.c b/daemons/lvmpolld/lvmpolld-cmd-utils.c
index 865b47ec9..2c3a77fac 100644
--- a/daemons/lvmpolld/lvmpolld-cmd-utils.c
+++ b/daemons/lvmpolld/lvmpolld-cmd-utils.c
@@ -92,6 +92,12 @@ const char **cmdargv_ctr(const struct lvmpolld_lv *pdlv, const char *lvm_binary,
 	if (!add_to_cmd_arr(&cmd_argv, "-An", &i))
 		goto err;
 
+	if (pdlv->devicesfile) {
+		if (!add_to_cmd_arr(&cmd_argv, "--devicesfile", &i) ||
+		    !add_to_cmd_arr(&cmd_argv, pdlv->devicesfile, &i))
+			goto err;
+	}
+
 	/* terminating NULL */
 	if (!add_to_cmd_arr(&cmd_argv, NULL, &i))
 		goto err;
diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index af98843c9..f7381eb35 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -555,14 +555,15 @@ static struct lvmpolld_lv *construct_pdlv(request req, struct lvmpolld_state *ls
 				     const char *interval, const char *id,
 				     const char *vgname, const char *lvname,
 				     const char *sysdir, enum poll_type type,
-				     unsigned abort_polling, unsigned uinterval)
+				     unsigned abort_polling, unsigned uinterval,
+				     const char *devicesfile)
 {
 	const char **cmdargv, **cmdenvp;
 	struct lvmpolld_lv *pdlv;
 	unsigned handle_missing_pvs = daemon_request_int(req, LVMPD_PARM_HANDLE_MISSING_PVS, 0);
 
 	pdlv = pdlv_create(ls, id, vgname, lvname, sysdir, type,
-			   interval, uinterval, pdst);
+			   interval, uinterval, pdst, devicesfile);
 
 	if (!pdlv) {
 		ERROR(ls, "%s: %s", PD_LOG_PREFIX, "failed to create internal LV data structure.");
@@ -621,6 +622,7 @@ static response poll_init(client_handle h, struct lvmpolld_state *ls, request re
 	const char *lvname = daemon_request_str(req, LVMPD_PARM_LVNAME, NULL);
 	const char *vgname = daemon_request_str(req, LVMPD_PARM_VGNAME, NULL);
 	const char *sysdir = daemon_request_str(req, LVMPD_PARM_SYSDIR, NULL);
+	const char *devicesfile = daemon_request_str(req, LVMPD_PARM_DEVICESFILE, NULL);
 	unsigned abort_polling = daemon_request_int(req, LVMPD_PARM_ABORT, 0);
 
 	assert(type < POLL_TYPE_MAX);
@@ -680,7 +682,7 @@ static response poll_init(client_handle h, struct lvmpolld_state *ls, request re
 		pdlv->init_rq_count++; /* safe. protected by store lock */
 	} else {
 		pdlv = construct_pdlv(req, ls, pdst, interval, id, vgname,
-				      lvname, sysdir, type, abort_polling, 2 * uinterval);
+				      lvname, sysdir, type, abort_polling, 2 * uinterval, devicesfile);
 		if (!pdlv) {
 			pdst_unlock(pdst);
 			free(id);
diff --git a/daemons/lvmpolld/lvmpolld-data-utils.c b/daemons/lvmpolld/lvmpolld-data-utils.c
index 23e316a96..6b66f1b67 100644
--- a/daemons/lvmpolld/lvmpolld-data-utils.c
+++ b/daemons/lvmpolld/lvmpolld-data-utils.c
@@ -93,11 +93,13 @@ struct lvmpolld_lv *pdlv_create(struct lvmpolld_state *ls, const char *id,
 			   const char *vgname, const char *lvname,
 			   const char *sysdir, enum poll_type type,
 			   const char *sinterval, unsigned pdtimeout,
-			   struct lvmpolld_store *pdst)
+			   struct lvmpolld_store *pdst,
+			   const char *devicesfile)
 {
 	char *lvmpolld_id = strdup(id), /* copy */
 	     *full_lvname = _construct_full_lvname(vgname, lvname), /* copy */
 	     *lvm_system_dir_env = _construct_lvm_system_dir_env(sysdir); /* copy */
+	char *devicesfile_dup = devicesfile ? strdup(devicesfile) : NULL;
 
 	struct lvmpolld_lv tmp = {
 		.ls = ls,
@@ -105,6 +107,7 @@ struct lvmpolld_lv *pdlv_create(struct lvmpolld_state *ls, const char *id,
 		.lvmpolld_id = lvmpolld_id,
 		.lvid = _get_lvid(lvmpolld_id, sysdir),
 		.lvname = full_lvname,
+		.devicesfile = devicesfile_dup,
 		.lvm_system_dir_env = lvm_system_dir_env,
 		.sinterval = strdup(sinterval), /* copy */
 		.pdtimeout = pdtimeout < MIN_POLLING_TIMEOUT ? MIN_POLLING_TIMEOUT : pdtimeout,
@@ -124,6 +127,7 @@ struct lvmpolld_lv *pdlv_create(struct lvmpolld_state *ls, const char *id,
 	return pdlv;
 
 err:
+	free((void *)devicesfile_dup);
 	free((void *)full_lvname);
 	free((void *)lvmpolld_id);
 	free((void *)lvm_system_dir_env);
@@ -136,6 +140,7 @@ err:
 void pdlv_destroy(struct lvmpolld_lv *pdlv)
 {
 	free((void *)pdlv->lvmpolld_id);
+	free((void *)pdlv->devicesfile);
 	free((void *)pdlv->lvname);
 	free((void *)pdlv->sinterval);
 	free((void *)pdlv->lvm_system_dir_env);
diff --git a/daemons/lvmpolld/lvmpolld-data-utils.h b/daemons/lvmpolld/lvmpolld-data-utils.h
index 5bb5c863d..96a27f1c8 100644
--- a/daemons/lvmpolld/lvmpolld-data-utils.h
+++ b/daemons/lvmpolld/lvmpolld-data-utils.h
@@ -49,6 +49,7 @@ struct lvmpolld_lv {
 	const enum poll_type type;
 	const char *const lvid;
 	const char *const lvmpolld_id;
+	const char *const devicesfile;
 	const char *const lvname; /* full vg/lv name */
 	const unsigned pdtimeout; /* in seconds */
 	const char *const sinterval;
@@ -101,7 +102,8 @@ struct lvmpolld_lv *pdlv_create(struct lvmpolld_state *ls, const char *id,
 			   const char *vgname, const char *lvname,
 			   const char *sysdir, enum poll_type type,
 			   const char *sinterval, unsigned pdtimeout,
-			   struct lvmpolld_store *pdst);
+			   struct lvmpolld_store *pdst,
+			   const char *devicesfile);
 
 /* only call with appropriate struct lvmpolld_store lock held */
 void pdlv_destroy(struct lvmpolld_lv *pdlv);
diff --git a/daemons/lvmpolld/lvmpolld-protocol.h b/daemons/lvmpolld/lvmpolld-protocol.h
index 9b9890d7b..18c7de85a 100644
--- a/daemons/lvmpolld/lvmpolld-protocol.h
+++ b/daemons/lvmpolld/lvmpolld-protocol.h
@@ -35,6 +35,7 @@
 #define LVMPD_PARM_SYSDIR		"sysdir"
 #define LVMPD_PARM_VALUE		"value" /* either retcode or signal value */
 #define LVMPD_PARM_VGNAME		"vgname"
+#define LVMPD_PARM_DEVICESFILE		"devicesfile"
 
 #define LVMPD_RESP_FAILED	"failed"
 #define LVMPD_RESP_FINISHED	"finished"
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 8e50ec45c..3409cbd8c 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -29,6 +29,7 @@ SOURCES =\
 	device/bcache.c \
 	device/bcache-utils.c \
 	device/dev-cache.c \
+	device/device_id.c \
 	device/dev-ext.c \
 	device/dev-io.c \
 	device/dev-md.c \
@@ -52,6 +53,7 @@ SOURCES =\
 	filters/filter-usable.c \
 	filters/filter-internal.c \
 	filters/filter-signature.c \
+	filters/filter-deviceid.c \
 	format_text/archive.c \
 	format_text/archiver.c \
 	format_text/export.c \
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index e05530a53..172c10f30 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -18,6 +18,7 @@
 #include "lib/cache/lvmcache.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/device/dev-cache.h"
+#include "lib/device/device_id.h"
 #include "lib/locking/locking.h"
 #include "lib/metadata/metadata.h"
 #include "lib/mm/memlock.h"
@@ -125,6 +126,19 @@ void lvmcache_unlock_vgname(const char *vgname)
 	}
 }
 
+unsigned int lvmcache_vg_info_count(void)
+{
+	struct lvmcache_vginfo *vginfo;
+	unsigned int count = 0;
+
+	dm_list_iterate_items(vginfo, &_vginfos) {
+		if (is_orphan_vg(vginfo->vgname))
+			continue;
+		count++;
+	}
+	return count;
+}
+
 int lvmcache_found_duplicate_vgnames(void)
 {
 	return _found_duplicate_vgnames;
@@ -507,6 +521,25 @@ static const char *_get_pvsummary_device_hint(char *pvid)
 	return NULL;
 }
 
+static const char *_get_pvsummary_device_id(char *pvid, const char **device_id_type)
+{
+	char pvid_s[ID_LEN + 1] __attribute__((aligned(8)));
+	struct lvmcache_vginfo *vginfo;
+	struct pv_list *pvl;
+
+	dm_list_iterate_items(vginfo, &_vginfos) {
+		dm_list_iterate_items(pvl, &vginfo->pvsummaries) {
+			(void) dm_strncpy(pvid_s, (char *) &pvl->pv->id, sizeof(pvid_s));
+			if (!strcmp(pvid_s, pvid)) {
+				*device_id_type = pvl->pv->device_id_type;
+				return pvl->pv->device_id;
+			}
+		}
+	}
+
+	return NULL;
+}
+
 /*
  * Check if any PVs in vg->pvs have the same PVID as any
  * entries in _unused_duplicates.
@@ -612,6 +645,8 @@ static void _choose_duplicates(struct cmd_context *cmd,
 	struct device_list *devl, *devl_safe, *devl_add, *devl_del;
 	struct lvmcache_info *info;
 	struct device *dev1, *dev2;
+	const char *device_id = NULL, *device_id_type = NULL;
+	const char *idname1 = NULL, *idname2 = NULL;
 	uint32_t dev1_major, dev1_minor, dev2_major, dev2_minor;
 	uint64_t dev1_size, dev2_size, pvsummary_size;
 	int in_subsys1, in_subsys2;
@@ -620,6 +655,7 @@ static void _choose_duplicates(struct cmd_context *cmd,
 	int has_lv1, has_lv2;
 	int same_size1, same_size2;
 	int same_name1 = 0, same_name2 = 0;
+	int same_id1 = 0, same_id2 = 0;
 	int prev_unchosen1, prev_unchosen2;
 	int change;
 
@@ -750,6 +786,19 @@ next:
 			same_name2 = !strcmp(device_hint, dev_name(dev2));
 		}
 
+		if ((device_id = _get_pvsummary_device_id(devl->dev->pvid, &device_id_type))) {
+			uint16_t idtype = idtype_from_str(device_id_type);
+
+			if (idtype) {
+				idname1 = device_id_system_read(cmd, dev1, idtype);
+				idname2 = device_id_system_read(cmd, dev2, idtype);
+			}
+			if (idname1)
+				same_id1 = !strcmp(idname1, device_id);
+			if (idname2)
+				same_id2 = !strcmp(idname2, device_id);
+		}
+
 		has_lv1 = (dev1->flags & DEV_USED_FOR_LV) ? 1 : 0;
 		has_lv2 = (dev2->flags & DEV_USED_FOR_LV) ? 1 : 0;
 
@@ -768,6 +817,12 @@ next:
 				dev_name(dev2), dev2_major, dev2_minor,
 				device_hint ?: "none");
 
+		log_debug_cache("PV %s: device_id %s. %s is %s. %s is %s.",
+				devl->dev->pvid,
+				device_id ?: ".",
+				dev_name(dev1), idname1 ?: ".",
+				dev_name(dev2), idname2 ?: ".");
+
 		log_debug_cache("PV %s: size %llu. %s is %llu. %s is %llu.",
 				devl->dev->pvid,
 				(unsigned long long)pvsummary_size,
@@ -808,6 +863,13 @@ next:
 		} else if (prev_unchosen2 && !prev_unchosen1) {
 			/* keep 1 (NB when unchosen is set we unprefer) */
 			reason = "of previous preference";
+		} else if (same_id1 && !same_id2) {
+			/* keep 1 */
+			reason = "device id";
+		} else if (same_id2 && !same_id1) {
+			/* change to 2 */
+			change = 1;
+			reason = "device id";
 		} else if (has_lv1 && !has_lv2) {
 			/* keep 1 */
 			reason = "device is used by LV";
@@ -1177,9 +1239,12 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 {
 	struct dm_list del_cache_devs;
 	struct dm_list add_cache_devs;
+	struct dm_list renamed_devs;
 	struct lvmcache_info *info;
 	struct device_list *devl;
 
+	dm_list_init(&renamed_devs);
+
 	log_debug_cache("lvmcache label scan begin");
 
 	/*
@@ -1192,13 +1257,24 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	 * Do the actual scanning.  This populates lvmcache
 	 * with infos/vginfos based on reading headers from
 	 * each device, and a vg summary from each mda.
-	 *
-	 * Note that this will *skip* scanning a device if
-	 * an info struct already exists in lvmcache for
-	 * the device.
 	 */
 	label_scan(cmd);
 
+	/*
+	 * When devnames are used as device ids (which is dispreferred),
+	 * changing/unstable devnames can lead to entries in the devices file
+	 * not being matched to a dev even if the PV is present on the system.
+	 * Or, a devices file entry may have been matched to the wrong device
+	 * (with the previous name) that does not have the PVID specified in
+	 * the entry.  This function detects that problem, scans labels on all
+	 * devs on the system to find the missing PVIDs, and corrects the
+	 * devices file.  We then need to run label scan on these correct
+	 * devices.
+	 */
+	device_ids_find_renamed_devs(cmd, &renamed_devs, NULL, 0);
+	if (!dm_list_empty(&renamed_devs))
+		label_scan_devs(cmd, cmd->filter, &renamed_devs);
+
 	/*
 	 * _choose_duplicates() returns:
 	 *
@@ -2830,6 +2906,10 @@ const char *dev_filtered_reason(struct device *dev)
 		return "device is too small (pv_min_size)";
 	if (dev->filtered_flags & DEV_FILTERED_UNUSABLE)
 		return "device is not in a usable state";
+	if (dev->filtered_flags & DEV_FILTERED_DEVICES_FILE)
+		return "device is not in devices file";
+	if (dev->filtered_flags & DEV_FILTERED_DEVICES_LIST)
+		return "device is not in devices list";
 
 	/* flag has not been added here */
 	if (dev->filtered_flags)
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index d00bba575..76429fc5b 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -224,4 +224,6 @@ struct metadata_area *lvmcache_get_dev_mda(struct device *dev, int mda_num);
 
 void lvmcache_extra_md_component_checks(struct cmd_context *cmd);
 
+unsigned int lvmcache_vg_info_count(void);
+
 #endif
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 63b6811e5..c3de18d7f 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -32,6 +32,7 @@
 #include "lib/cache/lvmcache.h"
 #include "lib/format_text/archiver.h"
 #include "lib/lvmpolld/lvmpolld-client.h"
+#include "lib/device/device_id.h"
 
 #include <locale.h>
 #include <sys/stat.h>
@@ -1066,7 +1067,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	return 1;
 }
 
-#define MAX_FILTERS 10
+#define MAX_FILTERS 11
 
 static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 {
@@ -1085,6 +1086,9 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 	 * sysfs filter. Only available on 2.6 kernels.  Non-critical.
 	 * Listed first because it's very efficient at eliminating
 	 * unavailable devices.
+	 *
+	 * TODO: I suspect that using the lvm_type and device_id
+	 * filters before this one may be more efficient.
 	 */
 	if (find_config_tree_bool(cmd, devices_sysfs_scan_CFG, NULL)) {
 		if ((filters[nr_filt] = sysfs_filter_create()))
@@ -1123,6 +1127,13 @@ static struct dev_filter *_init_filter_chain(struct cmd_context *cmd)
 	}
 	nr_filt++;
 
+	/* filter based on the device_ids saved in the devices file */
+	if (!(filters[nr_filt] = deviceid_filter_create(cmd))) {
+		log_error("Failed to create deviceid device filter");
+		goto bad;
+	}
+	nr_filt++;
+
 	/* usable device filter. Required. */
 	if (!(filters[nr_filt] = usable_filter_create(cmd, cmd->dev_types, FILTER_MODE_NO_LVMETAD))) {
 		log_error("Failed to create usabled device filter");
@@ -1485,6 +1496,7 @@ int init_run_by_dmeventd(struct cmd_context *cmd)
 	init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
 	init_ignore_suspended_devices(1);
 	init_disable_dmeventd_monitoring(1); /* Lock settings */
+	cmd->run_by_dmeventd = 1;
 
 	return 0;
 }
@@ -1717,6 +1729,8 @@ struct cmd_context *create_toolcontext(unsigned is_clvmd,
 	if (!_init_dev_cache(cmd))
 		goto_out;
 
+	devices_file_init(cmd);
+
 	memlock_init(cmd);
 
 	if (!_init_formats(cmd))
@@ -1842,6 +1856,7 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	_destroy_segtypes(&cmd->segtypes);
 	_destroy_formats(cmd, &cmd->formats);
 
+	devices_file_exit(cmd);
 	if (!dev_cache_exit())
 		stack;
 	_destroy_dev_types(cmd);
@@ -1921,6 +1936,8 @@ int refresh_toolcontext(struct cmd_context *cmd)
 	if (!_init_dev_cache(cmd))
 		return_0;
 
+	devices_file_init(cmd);
+
 	if (!_init_formats(cmd))
 		return_0;
 
@@ -1970,6 +1987,7 @@ void destroy_toolcontext(struct cmd_context *cmd)
 	_destroy_filters(cmd);
 	if (cmd->mem)
 		dm_pool_destroy(cmd->mem);
+	devices_file_exit(cmd);
 	dev_cache_exit();
 	_destroy_dev_types(cmd);
 	_destroy_tags(cmd);
diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index d20768ad0..977b31412 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -182,14 +182,27 @@ struct cmd_context {
 	unsigned pvscan_recreate_hints:1;	/* enable special case hint handling for pvscan --cache */
 	unsigned scan_lvs:1;
 	unsigned wipe_outdated_pvs:1;
+	unsigned enable_devices_list:1;		/* command is using --devices option */
+	unsigned enable_devices_file:1;		/* command is using devices file */
+	unsigned pending_devices_file:1;	/* command may create and enable devices file */
+	unsigned create_edit_devices_file:1;	/* command expects to create and/or edit devices file */
+	unsigned edit_devices_file:1;		/* command expects to edit devices file */
+	unsigned filter_deviceid_skip:1;	/* don't use filter-deviceid */
+	unsigned filter_regex_with_devices_file:1; /* use filter-regex even when devices file is enabled */
 	unsigned filter_nodata_only:1;          /* only use filters that do not require data from the dev */
+	unsigned run_by_dmeventd:1;		/* command is being run by dmeventd */
+	unsigned sysinit:1;			/* --sysinit is used */
 
 	/*
 	 * Devices and filtering.
 	 */
 	struct dev_filter *filter;
 	struct dm_list hints;
+	struct dm_list use_devices;		/* struct dev_use for each entry in devices file */
 	const char *md_component_checks;
+	const char *search_for_devnames;	/* config file setting */
+	const char *devicesfile;                /* from --devicesfile option */
+	struct dm_list deviceslist;             /* from --devices option, struct dm_str_list */
 
 	/*
 	 * Configuration.
@@ -221,6 +234,7 @@ struct cmd_context {
 	char system_dir[PATH_MAX];
 	char dev_dir[PATH_MAX];
 	char proc_dir[PATH_MAX];
+	char devices_file_path[PATH_MAX];
 
 	/*
 	 * Reporting.
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index d61b707e9..ee5d97721 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -288,6 +288,32 @@ cfg_array(devices_preferred_names_CFG, "preferred_names", devices_CFG_SECTION, C
 	"preferred_names = [ \"^/dev/mpath/\", \"^/dev/mapper/mpath\", \"^/dev/[hs]d\" ]\n"
 	"#\n")
 
+cfg(devices_use_devicesfile_CFG, "use_devicesfile", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_USE_DEVICES_FILE, vsn(2, 3, 12), NULL, 0, NULL,
+	"Enable or disable the use of a devices file.\n"
+	"When enabled, lvm will only use devices that\n"
+	"are lised in the devices file. A devices file will\n"
+	"be used, regardless of this setting, when the --devicesfile\n"
+	"option is set to a specific file name.\n")
+
+cfg(devices_devicesfile_CFG, "devicesfile", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_DEVICES_FILE, vsn(2, 3, 12), NULL, 0, NULL,
+	"The name of the system devices file, listing devices that LVM should use.\n"
+	"This should not be used to select a non-system devices file.\n"
+	"The --devicesfile option is intended for alternative devices files.\n")
+
+cfg(devices_search_for_devnames_CFG, "search_for_devnames", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, DEFAULT_SEARCH_FOR_DEVNAMES, vsn(2, 3, 12), NULL, 0, NULL,
+	"Look outside of the devices file for missing devname entries.\n"
+	"A devname entry is used for a device that does not have a stable\n"
+	"device id, e.g. wwid, so the unstable device name is used as\n"
+	"the device id. After reboot, or if the device is reattached,\n"
+	"the device name may change, in which case lvm will not find\n"
+	"the expected PV on the device listed in the devices file.\n"
+	"This setting controls whether lvm will search other devices,\n"
+	"outside the devices file, to look for the missing PV on a\n"
+	"renamed device. If \"none\", lvm will not look at other devices,\n"
+	"and the PV may appear to be missing. If \"auto\", lvm will look\n"
+	"at other devices, but only those that are likely to have the PV.\n"
+	"If \"all\", lvm will look at all devices on the system.\n")
+
 cfg_array(devices_filter_CFG, "filter", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, "#Sa|.*|", vsn(1, 0, 0), NULL, 0, NULL,
 	"Limit the block devices that are used by LVM commands.\n"
 	"This is a list of regular expressions used to accept or reject block\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index bcc20cc97..2870dee12 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -323,4 +323,9 @@
 
 #define DEFAULT_MD_COMPONENT_CHECKS "auto"
 
+#define DEFAULT_USE_DEVICES_FILE 0
+#define DEFAULT_DEVICES_FILE "system.devices"
+
+#define DEFAULT_SEARCH_FOR_DEVNAMES "auto"
+
 #endif				/* _LVM_DEFAULTS_H */
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 67e1386d3..8dd069c79 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -16,6 +16,7 @@
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/device/dev-type.h"
+#include "lib/device/device_id.h"
 #include "lib/datastruct/btree.h"
 #include "lib/config/config.h"
 #include "lib/commands/toolcontext.h"
@@ -68,11 +69,13 @@ static void _dev_init(struct device *dev)
 	dev->bcache_fd = -1;
 	dev->bcache_di = -1;
 	dev->read_ahead = -1;
+	dev->part = -1;
 
 	dev->ext.enabled = 0;
 	dev->ext.src = DEV_EXT_NONE;
 
 	dm_list_init(&dev->aliases);
+	dm_list_init(&dev->ids);
 }
 
 void dev_destroy_file(struct device *dev)
@@ -376,7 +379,7 @@ out:
 	return 1;
 }
 
-static int _get_sysfs_value(const char *path, char *buf, size_t buf_size, int error_if_no_value)
+int get_sysfs_value(const char *path, char *buf, size_t buf_size, int error_if_no_value)
 {
 	FILE *fp;
 	size_t len;
@@ -417,7 +420,7 @@ static int _get_dm_uuid_from_sysfs(char *buf, size_t buf_size, int major, int mi
 		return 0;
 	}
 
-	return _get_sysfs_value(path, buf, buf_size, 0);
+	return get_sysfs_value(path, buf, buf_size, 0);
 }
 
 static struct dm_list *_get_or_add_list_by_index_key(struct dm_hash_table *idx, const char *key)
@@ -491,7 +494,7 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 		return NULL;
 	}
 
-	if (!_get_sysfs_value(path, buf, sizeof(buf), 1))
+	if (!get_sysfs_value(path, buf, sizeof(buf), 1))
 		return_NULL;
 
 	if (sscanf(buf, "%d:%d", &major, &minor) != 2) {
@@ -935,7 +938,7 @@ static int _dev_cache_iterate_sysfs_for_index(const char *path)
 	return r;
 }
 
-int dev_cache_index_devs(void)
+static int dev_cache_index_devs(void)
 {
 	static int sysfs_has_dev_block = -1;
 	char path[PATH_MAX];
@@ -1284,12 +1287,20 @@ int dev_cache_check_for_open_devices(void)
 
 int dev_cache_exit(void)
 {
+	struct device *dev;
+	struct dm_hash_node *n;
 	int num_open = 0;
 
-	if (_cache.names)
+	if (_cache.names) {
 		if ((num_open = _check_for_open_devices(1)) > 0)
 			log_error(INTERNAL_ERROR "%d device(s) were left open and have been closed.", num_open);
 
+		dm_hash_iterate(n, _cache.names) {
+			dev = (struct device *) dm_hash_get_data(_cache.names, n);
+			free_dids(&dev->ids);
+		}
+	}
+
 	if (_cache.mem)
 		dm_pool_destroy(_cache.mem);
 
@@ -1703,3 +1714,335 @@ bool dev_cache_has_md_with_end_superblock(struct dev_types *dt)
 
 	return false;
 }
+
+static int _setup_devices_list(struct cmd_context *cmd)
+{
+	struct dm_str_list *strl;
+	struct dev_use *du;
+
+	/*
+	 * For each --devices arg, add a du to cmd->use_devices.
+	 * The du has devname is the devices arg value.
+	 */
+
+	dm_list_iterate_items(strl, &cmd->deviceslist) {
+		if (!(du = zalloc(sizeof(struct dev_use))))
+			return_0;
+
+		if (!(du->devname = strdup(strl->str)))
+			return_0;
+
+		dm_list_add(&cmd->use_devices, &du->list);
+	}
+
+	return 1;
+}
+
+static int _setup_devices_file_dmeventd(struct cmd_context *cmd)
+{
+	char path[PATH_MAX];
+	struct stat st;
+
+	/*
+	 * When command is run by dmeventd there is no --devicesfile
+	 * option that can enable/disable the use of a devices file.
+	 */
+	if (!find_config_tree_bool(cmd, devices_use_devicesfile_CFG, NULL)) {
+		cmd->enable_devices_file = 0;
+		return 1;
+	}
+
+	/*
+	 * If /etc/lvm/devices/dmeventd.devices exists, then use that.
+	 * The optional dmeventd.devices allows the user to control
+	 * which devices dmeventd will look at and use.
+	 * Otherwise, disable the devices file because dmeventd should
+	 * be able to manage LVs in any VG (i.e. LVs in a non-system
+	 * devices file.)
+	 */
+	if (dm_snprintf(path, sizeof(path), "%s/devices/dmeventd.devices", cmd->system_dir) < 0) {
+		log_warn("Failed to copy devices path");
+		cmd->enable_devices_file = 0;
+		return 1;
+	}
+
+	if (stat(path, &st)) {
+		/* No dmeventd.devices, so do not use a devices file. */
+		cmd->enable_devices_file = 0;
+		return 1;
+	}
+
+	cmd->enable_devices_file = 1;
+	(void) dm_strncpy(cmd->devices_file_path, path, sizeof(cmd->devices_file_path));
+	return 1;
+}
+	
+int setup_devices_file(struct cmd_context *cmd)
+{
+	char dirpath[PATH_MAX];
+	const char *filename = NULL;
+	struct stat st;
+	int rv;
+
+	if (cmd->run_by_dmeventd)
+		return _setup_devices_file_dmeventd(cmd);
+
+	if (cmd->devicesfile) {
+		/* --devicesfile <filename> or "" has been set which overrides
+		   lvm.conf settings use_devicesfile and devicesfile. */
+		if (!strlen(cmd->devicesfile))
+			cmd->enable_devices_file = 0;
+		else {
+			cmd->enable_devices_file = 1;
+			filename = cmd->devicesfile;
+		}
+		/* TODO: print a warning if --devicesfile system.devices
+		   while lvm.conf use_devicesfile=0. */
+	} else {
+		if (!find_config_tree_bool(cmd, devices_use_devicesfile_CFG, NULL))
+			cmd->enable_devices_file = 0;
+		else {
+			cmd->enable_devices_file = 1;
+			filename = find_config_tree_str(cmd, devices_devicesfile_CFG, NULL);
+			if (!validate_name(filename)) {
+				log_error("Invalid devices file name from config setting \"%s\".", filename);
+				return 0;
+			}
+		}
+	}
+
+	if (!cmd->enable_devices_file)
+		return 1;
+
+	if (dm_snprintf(dirpath, sizeof(dirpath), "%s/devices", cmd->system_dir) < 0) {
+		log_error("Failed to copy devices dir path");
+		return 0;
+	}
+
+	if (stat(dirpath, &st)) {
+		log_debug("Creating %s.", dirpath);
+		dm_prepare_selinux_context(dirpath, S_IFDIR);
+		rv = mkdir(dirpath, 0755);
+		dm_prepare_selinux_context(NULL, 0);
+
+		if ((rv < 0) && stat(dirpath, &st)) {
+			log_error("Failed to create %s %d", dirpath, errno);
+			return 0;
+		}
+	}
+	
+	if (dm_snprintf(cmd->devices_file_path, sizeof(cmd->devices_file_path),
+			"%s/devices/%s", cmd->system_dir, filename) < 0) {
+		log_error("Failed to copy devices file path");
+		return 0;
+	}
+	return 1;
+}
+
+/*
+ * Add all system devices to dev-cache, and attempt to
+ * match all devices_file entries to dev-cache entries.
+ */
+int setup_devices(struct cmd_context *cmd)
+{
+	int file_exists;
+	int lock_mode = 0;
+
+	if (cmd->enable_devices_list) {
+		if (!_setup_devices_list(cmd))
+			return_0;
+		goto scan;
+	}
+
+	if (!setup_devices_file(cmd))
+		return_0;
+
+	if (!cmd->enable_devices_file)
+		goto scan;
+
+	file_exists = devices_file_exists(cmd);
+
+	/*
+	 * Removing the devices file is another way of disabling the use of
+	 * a devices file, unless the command creates the devices file.
+	 */
+	if (!file_exists && !cmd->create_edit_devices_file) {
+		log_debug("Devices file not found, ignoring.");
+		cmd->enable_devices_file = 0;
+		goto scan;
+	}
+
+	/*
+	 * Don't let pvcreate or vgcreate create a new system devices file
+	 * unless it's specified explicitly with --devicesfile.  This avoids
+	 * a problem where a system is running with existing PVs, and is
+	 * not using a devices file based on the fact that the system
+	 * devices file doesn't exist.  If the user simply uses pvcreate
+	 * to create a new PV, they almost certainly do not want that to
+	 * create a new system devices file containing the new PV and none
+	 * of the existing PVs that the system is already using.
+	 * However, if they use the vgimportdevices or lvmdevices command
+	 * then they are clearly intending to use the devices file, so we
+	 * can create it.  Or, if they specify a non-system devices file
+	 * with pvcreate/vgcreate, then they clearly want to use a devices
+	 * file and we can create it (and creating a non-system devices file 
+	 * would not cause existing PVs to disappear from the main system.)
+	 *
+	 * An exception is if pvcreate/vgcreate get to device_id_write and
+	 * did not see any existing VGs during label scan.  In that case
+	 * they will create a new system devices file, since there will be
+	 * no VGs that the new file would hide.
+	 */
+	if (cmd->create_edit_devices_file && !cmd->devicesfile && !file_exists &&
+	    (!strncmp(cmd->name, "pvcreate", 8) || !strncmp(cmd->name, "vgcreate", 8))) {
+		/* The command will decide in device_ids_write whether to create
+		   a new system devices file. */
+		cmd->enable_devices_file = 0;
+		cmd->pending_devices_file = 1;
+		goto scan;
+	}
+
+	if (!file_exists && cmd->sysinit) {
+		cmd->enable_devices_file = 0;
+		goto scan;
+	}
+
+	if (!file_exists) {
+		/*
+		 * pvcreate/vgcreate/vgimportdevices/lvmdevices-add create
+		 * a new devices file here if it doesn't exist.
+		 * They have the create_edit_devices_file flag set.
+		 * First they create/lock-ex the devices file lockfile.
+		 * Other commands will not use a devices file if none exists.
+		 */
+		lock_mode = LOCK_EX;
+
+		if (!lock_devices_file(cmd, lock_mode)) {
+			log_error("Failed to lock the devices file to create.");
+			return 0;
+		}
+
+		/* The file will be created in device_ids_write() */
+		if (!devices_file_exists(cmd))
+			goto scan;
+	} else {
+		/*
+		 * Commands that intend to edit the devices file have
+		 * edit_devices_file or create_edit_devices_file set (create if
+		 * they can also create a new devices file) and lock it ex
+		 * here prior to reading.  Other commands that intend to just
+		 * read the devices file lock sh.
+		 */
+		lock_mode = (cmd->create_edit_devices_file || cmd->edit_devices_file) ? LOCK_EX : LOCK_SH;
+
+		if (!lock_devices_file(cmd, lock_mode)) {
+			log_error("Failed to lock the devices file.");
+			return 0;
+		}
+	}
+
+	/*
+	 * Read the list of device ids that lvm can use.
+	 * Adds a struct dev_id to cmd->use_devices for each one.
+	 */
+	if (!device_ids_read(cmd)) {
+		log_error("Failed to read the devices file.");
+		unlock_devices_file(cmd);
+		return 0;
+	}
+
+	/*
+	 * When the command is editing the devices file, it acquires
+	 * the ex lock above, will later call device_ids_write(), and
+	 * then unlock the lock after writing the file.
+	 * When the command is just reading the devices file, it's
+	 * locked sh above just before reading the file, and unlocked
+	 * here after reading.
+	 */
+	if (lock_mode == LOCK_SH)
+		unlock_devices_file(cmd);
+
+ scan:
+	/*
+	 * Add a 'struct device' to dev-cache for each device available on the system.
+	 * This will not open or read any devices, but may look at sysfs properties.
+	 * This list of devs comes from looking /dev entries, or from asking libudev.
+	 */
+	dev_cache_scan();
+
+	/*
+	 * Match entries from cmd->use_devices with device structs in dev-cache.
+	 */
+	device_ids_match(cmd);
+
+	return 1;
+}
+
+/*
+ * The alternative to setup_devices() when the command is interested
+ * in using only one PV.
+ *
+ * Add one system device to dev-cache, and attempt to
+ * match its dev-cache entry to a devices_file entry.
+ */
+int setup_device(struct cmd_context *cmd, const char *devname)
+{
+	struct stat buf;
+	struct device *dev;
+
+	if (cmd->enable_devices_list) {
+		if (!_setup_devices_list(cmd))
+			return_0;
+		goto scan;
+	}
+
+	if (!setup_devices_file(cmd))
+		return_0;
+
+	if (!cmd->enable_devices_file)
+		goto scan;
+
+	if (!devices_file_exists(cmd)) {
+		log_debug("Devices file not found, ignoring.");
+		cmd->enable_devices_file = 0;
+		goto scan;
+	}
+
+	if (!lock_devices_file(cmd, LOCK_SH)) {
+		log_error("Failed to lock the devices file to read.");
+		return 0;
+	}
+
+	if (!device_ids_read(cmd)) {
+		log_error("Failed to read the devices file.");
+		unlock_devices_file(cmd);
+		return 0;
+	}
+
+	unlock_devices_file(cmd);
+
+ scan:
+	if (stat(devname, &buf) < 0) {
+		log_error("Cannot access device %s.", devname);
+		return 0;
+	}
+
+	if (!S_ISBLK(buf.st_mode)) {
+		log_error("Invaild device type %s.", devname);
+		return 0;
+	}
+
+	if (!_insert_dev(devname, buf.st_rdev))
+		return_0;
+
+	if (!(dev = (struct device *) dm_hash_lookup(_cache.names, devname)))
+		return_0;
+
+	/* Match this device to an entry in devices_file so it will not
+	   be rejected by filter-deviceid. */
+	if (cmd->enable_devices_file)
+		device_ids_match_dev(cmd, dev);
+
+	return 1;
+}
+
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index 7285bc3a7..9b7e39d33 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -34,7 +34,6 @@ struct dev_filter {
 	const char *name;
 };
 
-int dev_cache_index_devs(void);
 struct dm_list *dev_cache_get_dev_list_for_vgid(const char *vgid);
 struct dm_list *dev_cache_get_dev_list_for_lvid(const char *lvid);
 
@@ -75,4 +74,10 @@ void dev_cache_failed_path(struct device *dev, const char *path);
 
 bool dev_cache_has_md_with_end_superblock(struct dev_types *dt);
 
+int get_sysfs_value(const char *path, char *buf, size_t buf_size, int error_if_no_value);
+
+int setup_devices_file(struct cmd_context *cmd);
+int setup_devices(struct cmd_context *cmd);
+int setup_device(struct cmd_context *cmd, const char *devname);
+
 #endif
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 0411572fa..40c2a748e 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -363,6 +363,45 @@ static int _loop_is_with_partscan(struct device *dev)
 	return partscan;
 }
 
+int dev_get_partition_number(struct device *dev, int *num)
+{
+	char path[PATH_MAX];
+	char buf[8] = { 0 };
+	dev_t devt = dev->dev;
+	struct stat sb;
+
+	if (dev->part != -1) {
+		*num = dev->part;
+		return 1;
+	}
+
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/partition",
+			dm_sysfs_dir(), (int)MAJOR(devt), (int)MINOR(devt)) < 0) {
+		log_error("Failed to create sysfs path for %s", dev_name(dev));
+		return 0;
+	}
+
+	if (stat(path, &sb)) {
+		dev->part = 0;
+		*num = 0;
+		return 1;
+	}
+
+	if (!get_sysfs_value(path, buf, sizeof(buf), 0)) {
+		log_error("Failed to read sysfs path for %s", dev_name(dev));
+		return 0;
+	}
+
+	if (!buf[0]) {
+		log_error("Failed to read sysfs partition value for %s", dev_name(dev));
+		return 0;
+	}
+
+	dev->part = atoi(buf);
+	*num = dev->part;
+	return 1;
+}
+
 /* See linux/genhd.h and fs/partitions/msdos */
 #define PART_MAGIC 0xAA55
 #define PART_MAGIC_OFFSET UINT64_C(0x1FE)
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index f96b67ca3..45377c144 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -83,6 +83,7 @@ int dev_is_md_with_end_superblock(struct dev_types *dt, struct device *dev);
 int major_max_partitions(struct dev_types *dt, int major);
 int dev_is_partitioned(struct dev_types *dt, struct device *dev);
 int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result);
+int dev_get_partition_number(struct device *dev, int *num);
 
 /* Various device properties */
 unsigned long dev_alignment_offset(struct dev_types *dt, struct device *dev);
diff --git a/lib/device/device.h b/lib/device/device.h
index 816db3166..aed1a0342 100644
--- a/lib/device/device.h
+++ b/lib/device/device.h
@@ -39,6 +39,7 @@
 #define DEV_IS_MD_COMPONENT	0x00020000	/* device is an md component */
 #define DEV_UDEV_INFO_MISSING   0x00040000	/* we have no udev info for this device */
 #define DEV_IS_NVME		0x00080000	/* set if dev is nvme */
+#define DEV_MATCHED_USE_ID	0x00100000	/* matched an entry from cmd->use_devices */
 
 /*
  * Support for external device info.
@@ -57,12 +58,54 @@ struct dev_ext {
 	void *handle;
 };
 
+#define DEV_ID_TYPE_SYS_WWID   0x0001
+#define DEV_ID_TYPE_SYS_SERIAL 0x0002
+#define DEV_ID_TYPE_MPATH_UUID 0x0003
+#define DEV_ID_TYPE_MD_UUID    0x0004
+#define DEV_ID_TYPE_LOOP_FILE  0x0005
+#define DEV_ID_TYPE_CRYPT_UUID 0x0006
+#define DEV_ID_TYPE_LVMLV_UUID 0x0007
+#define DEV_ID_TYPE_DEVNAME    0x0008
+
+/*
+ * A device ID of a certain type for a device.
+ * A struct device may have multiple dev_id structs on dev->ids.
+ * One of them will be the one that's used, pointed to by dev->id.
+ */
+
+struct dev_id {
+	struct dm_list list;
+	struct device *dev;
+	uint16_t idtype;	/* DEV_ID_TYPE_ */
+	char *idname;		/* id string determined by idtype */
+};
+
+/*
+ * A device listed in devices file that lvm should use.
+ * Each entry in the devices file is represented by a struct dev_use.
+ * The structs are kept on cmd->use_devices.
+ * idtype/idname/pvid/part are set when reading the devices file.
+ * du->dev is set when a struct dev_use is matched to a struct device.
+ */
+
+struct dev_use {
+	struct dm_list list;
+	struct device *dev;
+	int part;
+	uint16_t idtype;
+	char *idname;
+	char *devname;
+	char *pvid;
+};
+
 /*
  * All devices in LVM will be represented by one of these.
  * pointer comparisons are valid.
  */
 struct device {
 	struct dm_list aliases;	/* struct dm_str_list */
+	struct dm_list ids; /* struct dev_id, different entries for different idtypes */
+	struct dev_id *id; /* points to the the ids entry being used for this dev */
 	dev_t dev;
 
 	/* private */
@@ -73,6 +116,7 @@ struct device {
 	int read_ahead;
 	int bcache_fd;
 	int bcache_di;
+	int part;		/* partition number */
 	uint32_t flags;
 	uint32_t filtered_flags;
 	unsigned size_seqno;
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
new file mode 100644
index 000000000..698942bb1
--- /dev/null
+++ b/lib/device/device_id.c
@@ -0,0 +1,2320 @@
+/*
+ * Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "base/memory/zalloc.h"
+#include "lib/misc/lib.h"
+#include "lib/commands/toolcontext.h"
+#include "lib/device/device.h"
+#include "lib/device/device_id.h"
+#include "lib/device/dev-type.h"
+#include "lib/device/device-types.h"
+#include "lib/label/label.h"
+#include "lib/metadata/metadata.h"
+#include "lib/format_text/layout.h"
+#include "lib/cache/lvmcache.h"
+
+#include <sys/stat.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <time.h>
+#include <sys/types.h>
+#include <sys/file.h>
+#include <sys/sysmacros.h>
+
+#define DEVICES_FILE_MAJOR 1
+#define DEVICES_FILE_MINOR 1
+#define VERSION_LINE_MAX 256
+
+static int _devices_fd = -1;
+static int _using_devices_file;
+static int _devices_file_locked;
+static char _devices_lockfile[PATH_MAX];
+static char _devices_file_systemid[PATH_MAX];
+static char _devices_file_version[VERSION_LINE_MAX];
+static const char *_searched_file = DEFAULT_RUN_DIR "/searched_devnames";
+
+char *devices_file_version(void)
+{
+	return _devices_file_version;
+}
+
+/*
+ * cmd->devicesfile is set when using a non-system devices file,
+ * and at least for now, the searched_devnames optimization
+ * only applies to the system devices file.
+ */
+
+static void _touch_searched_devnames(struct cmd_context *cmd)
+{
+	FILE *fp;
+
+	if (cmd->devicesfile)
+		return;
+
+	if (!(fp = fopen(_searched_file, "w")))
+		return;
+	if (fclose(fp))
+		stack;
+}
+
+void unlink_searched_devnames(struct cmd_context *cmd)
+{
+	if (cmd->devicesfile)
+		return;
+
+	if (unlink(_searched_file))
+		log_debug("unlink %s errno %d", _searched_file, errno);
+}
+
+static int _searched_devnames_exists(struct cmd_context *cmd)
+{
+	struct stat buf;
+
+	if (cmd->devicesfile)
+		return 0;
+
+	if (!stat(_searched_file, &buf))
+		return 1;
+
+	if (errno != ENOENT)
+		log_debug("stat %s errno %d", _searched_file, errno);
+
+	return 0;
+}
+
+/*
+ * How the devices file and device IDs are used by an ordinary command:
+ *
+ * 1. device_ids_read() reads the devices file, and adds a 'struct dev_use'
+ *    to cmd->use_devices for each entry.  These are the devices lvm
+ *    can use, but we do not yet know which devnames they correspond to.
+ * 2. dev_cache_scan() gets a list of all devices (devnames) on the system,
+ *    and adds a 'struct device' to dev-cache for each.
+ * 3. device_ids_match() matches du entries from the devices file
+ *    with devices from dev-cache.  With this complete, we know the
+ *    devnames to use for each of the entries in the devices file.
+ * 4. label_scan (or equivalent) iterates through all devices in
+ *    dev-cache, checks each one with filters, which excludes many,
+ *    and reads lvm headers and metadata from the devs that pass the
+ *    filters.  lvmcache is populated with summary info about each PV
+ *    during this phase.
+ * 5. device_ids_validate() checks if the PVIDs saved in the devices
+ *    file are correct based on the PVIDs read from disk in the 
+ *    previous step.  If not it updates the devices file.
+ *
+ * cmd->use_devices reflect the entries in the devices file.
+ * When reading the devices file, a 'du' struct is added to use_devices
+ * for each entry.
+ * When adding devices to the devices file, a new du struct is added
+ * to use_devices, and then a new file entry is written for each du.
+ *
+ * After reading the devices file, we want to match each du from
+ * the file to an actual device on the system.  We look at struct device's
+ * in dev-cache to find one that matches each du, based on the device_id.
+ * When a match is made, du->dev is set, and DEV_MATCHED_USE_ID is set
+ * in the dev.
+ *
+ * After the use_devices entries are matched to system devices,
+ * label_scan can be called to filter and scan devices.  After
+ * label_scan, device_ids_validate() is called to check if the
+ * PVID read from each device matches the PVID recorded in the
+ * devices file for the device.
+ *
+ * A device can have multiple device IDs, e.g. a dev could have
+ * both a wwid and a serial number, but only one of these IDs is
+ * used as the device ID in the devices file, e.g. the wwid is
+ * preferred so that would be used in the devices file.
+ * Each of the different types of device IDs can be saved in
+ * dev->ids list (struct dev_id).  So, one dev may have multiple
+ * entries in dev->ids, e.g. one for wwid and one for serial.
+ * The dev_id struct that is actually being used for the device
+ * is set in dev->id.
+ * The reason for saving multiple IDs in dev->ids is because
+ * the process of matching devs to devices file entries can
+ * involve repeatedly checking other dev_id types for a given
+ * device, so we save each type as it is read to avoid rereading
+ * the same id type many times.
+ */
+
+void free_du(struct dev_use *du)
+{
+	if (du->idname)
+		free(du->idname);
+	if (du->devname)
+		free(du->devname);
+	if (du->pvid)
+		free(du->pvid);
+	free(du);
+}
+
+void free_dus(struct dm_list *dus)
+{
+	struct dev_use *du, *safe;
+
+	dm_list_iterate_items_safe(du, safe, dus) {
+		dm_list_del(&du->list);
+		free_du(du);
+	}
+}
+
+void free_did(struct dev_id *id)
+{
+	if (id->idname)
+		free(id->idname);
+	free(id);
+}
+
+void free_dids(struct dm_list *ids)
+{
+	struct dev_id *id, *safe;
+
+	dm_list_iterate_items_safe(id, safe, ids) {
+		dm_list_del(&id->list);
+		free_did(id);
+	}
+}
+
+static int _read_sys_block(struct cmd_context *cmd, struct device *dev, const char *suffix, char *sysbuf, int sysbufsize)
+{
+	char path[PATH_MAX];
+	dev_t devt = dev->dev;
+	dev_t prim = 0;
+	int ret;
+
+ retry:
+	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/%s",
+			dm_sysfs_dir(), (int)MAJOR(devt), (int)MINOR(devt), suffix) < 0) {
+		log_error("Failed to create sysfs path for %s", dev_name(dev));
+		return 0;
+	}
+
+	get_sysfs_value(path, sysbuf, sysbufsize, 0);
+
+	if (sysbuf[0]) {
+		if (prim)
+			log_debug("Using primary device_id for partition %s.", dev_name(dev));
+		sysbuf[sysbufsize - 1] = '\0';
+		return 1;
+	}
+
+	if (prim)
+		goto fail;
+
+	/* in case it failed because dev is a partition... */
+
+	ret = dev_get_primary_dev(cmd->dev_types, dev, &prim);
+	if (ret == 2) {
+		devt = prim;
+		goto retry;
+	}
+
+ fail:
+	return 0;
+}
+
+static int _dm_uuid_has_prefix(char *sysbuf, const char *prefix)
+{
+	if (!strncmp(sysbuf, prefix, strlen(prefix)))
+		return 1;
+
+	/*
+	 * If it's a kpartx partitioned dm device the dm uuid will
+	 * be part%d-<prefix>...  e.g. part1-mpath-abc...
+	 * Check for the prefix after the part%-
+	 */
+	if (!strncmp(sysbuf, "part", 4)) {
+		const char *dash = strchr(sysbuf, '-');
+
+		if (!dash)
+			return 0;
+
+		if (!strncmp(dash + 1, prefix, strlen(prefix)))
+			return 1;
+	}
+	return 0;
+}
+
+/* the dm uuid uses the wwid of the underlying dev */
+static int _dev_has_mpath_uuid(struct cmd_context *cmd, struct device *dev, const char **idname_out)
+{
+	char sysbuf[PATH_MAX] = { 0 };
+	const char *idname;
+
+	if (!_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
+		return 0;
+
+	if (!_dm_uuid_has_prefix(sysbuf, "mpath-"))
+		return 0;
+
+	if (!idname_out)
+		return 1;
+	if (!(idname = strdup(sysbuf)))
+		return_0;
+	*idname_out = idname;
+	return 1;
+}
+
+static int _dev_has_crypt_uuid(struct cmd_context *cmd, struct device *dev, const char **idname_out)
+{
+	char sysbuf[PATH_MAX] = { 0 };
+	const char *idname;
+
+	if (!_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
+		return 0;
+
+	if (!_dm_uuid_has_prefix(sysbuf, "CRYPT-"))
+		return 0;
+
+	if (!idname_out)
+		return 1;
+	if (!(idname = strdup(sysbuf)))
+		return_0;
+	*idname_out = idname;
+	return 1;
+}
+
+static int _dev_has_lvmlv_uuid(struct cmd_context *cmd, struct device *dev, const char **idname_out)
+{
+	char sysbuf[PATH_MAX] = { 0 };
+	const char *idname;
+
+	if (!_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
+		return 0;
+
+	if (!_dm_uuid_has_prefix(sysbuf, "LVM-"))
+		return 0;
+
+	if (!idname_out)
+		return 1;
+	if (!(idname = strdup(sysbuf)))
+		return_0;
+	*idname_out = idname;
+	return 1;
+}
+
+const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, uint16_t idtype)
+{
+	char sysbuf[PATH_MAX] = { 0 };
+	const char *idname = NULL;
+
+	if (idtype == DEV_ID_TYPE_SYS_WWID) {
+		_read_sys_block(cmd, dev, "device/wwid", sysbuf, sizeof(sysbuf));
+
+		if (!sysbuf[0])
+			_read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf));
+	}
+
+	else if (idtype == DEV_ID_TYPE_SYS_SERIAL)
+		_read_sys_block(cmd, dev, "device/serial", sysbuf, sizeof(sysbuf));
+
+	else if (idtype == DEV_ID_TYPE_MPATH_UUID)
+		_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
+
+	else if (idtype == DEV_ID_TYPE_CRYPT_UUID)
+		_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
+
+	else if (idtype == DEV_ID_TYPE_LVMLV_UUID)
+		_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf));
+
+	else if (idtype == DEV_ID_TYPE_MD_UUID)
+		_read_sys_block(cmd, dev, "md/uuid", sysbuf, sizeof(sysbuf));
+
+	else if (idtype == DEV_ID_TYPE_LOOP_FILE)
+		_read_sys_block(cmd, dev, "loop/backing_file", sysbuf, sizeof(sysbuf));
+
+	else if (idtype == DEV_ID_TYPE_DEVNAME) {
+		if (!(idname = strdup(dev_name(dev))))
+			goto_bad;
+		return idname;
+	}
+
+	if (!sysbuf[0])
+		goto_bad;
+
+	if (!(idname = strdup(sysbuf)))
+		goto_bad;
+
+	return idname;
+ bad:
+	log_debug("No idtype %s for %s", idtype_to_str(idtype), dev_name(dev));
+	return NULL;
+}
+
+/*
+ * Check if this dev would use a stable idtype or if it
+ * would use DEV_ID_TYPE_DEVNAME.
+ */
+static int _dev_has_stable_id(struct cmd_context *cmd, struct device *dev)
+{
+	char sysbuf[PATH_MAX] = { 0 };
+	struct dev_id *id;
+
+	dm_list_iterate_items(id, &dev->ids) {
+		if (id->idtype != DEV_ID_TYPE_DEVNAME)
+			return 1;
+	}
+
+	if (_read_sys_block(cmd, dev, "device/wwid", sysbuf, sizeof(sysbuf)))
+		return 1;
+
+	if (_read_sys_block(cmd, dev, "wwid", sysbuf, sizeof(sysbuf)))
+		return 1;
+
+	if (_read_sys_block(cmd, dev, "device/serial", sysbuf, sizeof(sysbuf)))
+		return 1;
+
+	if ((MAJOR(dev->dev) == cmd->dev_types->device_mapper_major)) {
+		if (!_read_sys_block(cmd, dev, "dm/uuid", sysbuf, sizeof(sysbuf)))
+			goto_out;
+
+		if (_dm_uuid_has_prefix(sysbuf, "mpath-"))
+			return 1;
+		if (_dm_uuid_has_prefix(sysbuf, "CRYPT-"))
+			return 1;
+		if (_dm_uuid_has_prefix(sysbuf, "LVM-"))
+			return 1;
+	}
+
+	if ((MAJOR(dev->dev) == cmd->dev_types->md_major) &&
+	    _read_sys_block(cmd, dev, "md/uuid", sysbuf, sizeof(sysbuf)))
+		return 1;
+
+	if ((MAJOR(dev->dev) == cmd->dev_types->loop_major) &&
+	    _read_sys_block(cmd, dev, "loop/backing_file", sysbuf, sizeof(sysbuf)))
+		return 1;
+ out:
+	/* DEV_ID_TYPE_DEVNAME would be used for this dev. */
+	return 0;
+}
+
+const char *idtype_to_str(uint16_t idtype)
+{
+	if (idtype == DEV_ID_TYPE_SYS_WWID)
+		return "sys_wwid";
+	if (idtype == DEV_ID_TYPE_SYS_SERIAL)
+		return "sys_serial";
+	if (idtype == DEV_ID_TYPE_DEVNAME)
+		return "devname";
+	if (idtype == DEV_ID_TYPE_MPATH_UUID)
+		return "mpath_uuid";
+	if (idtype == DEV_ID_TYPE_CRYPT_UUID)
+		return "crypt_uuid";
+	if (idtype == DEV_ID_TYPE_LVMLV_UUID)
+		return "lvmlv_uuid";
+	if (idtype == DEV_ID_TYPE_MD_UUID)
+		return "md_uuid";
+	if (idtype == DEV_ID_TYPE_LOOP_FILE)
+		return "loop_file";
+	return "unknown";
+}
+
+uint16_t idtype_from_str(const char *str)
+{
+	if (!strcmp(str, "sys_wwid"))
+		return DEV_ID_TYPE_SYS_WWID;
+	if (!strcmp(str, "sys_serial"))
+		return DEV_ID_TYPE_SYS_SERIAL;
+	if (!strcmp(str, "devname"))
+		return DEV_ID_TYPE_DEVNAME;
+	if (!strcmp(str, "mpath_uuid"))
+		return DEV_ID_TYPE_MPATH_UUID;
+	if (!strcmp(str, "crypt_uuid"))
+		return DEV_ID_TYPE_CRYPT_UUID;
+	if (!strcmp(str, "lvmlv_uuid"))
+		return DEV_ID_TYPE_LVMLV_UUID;
+	if (!strcmp(str, "md_uuid"))
+		return DEV_ID_TYPE_MD_UUID;
+	if (!strcmp(str, "loop_file"))
+		return DEV_ID_TYPE_LOOP_FILE;
+	return 0;
+}
+
+const char *dev_idtype_for_metadata(struct cmd_context *cmd, struct device *dev)
+{
+	const char *str;
+
+	if (!cmd->enable_devices_file)
+		return NULL;
+
+	if (!dev || !dev->id || !dev->id->idtype || (dev->id->idtype == DEV_ID_TYPE_DEVNAME))
+		return NULL;
+
+	str = idtype_to_str(dev->id->idtype);
+	if (!strcmp(str, "unknown"))
+		return NULL;
+
+	return str;
+}
+
+const char *dev_idname_for_metadata(struct cmd_context *cmd, struct device *dev)
+{
+	if (!cmd->enable_devices_file)
+		return NULL;
+
+	if (!dev || !dev->id || !dev->id->idtype || (dev->id->idtype == DEV_ID_TYPE_DEVNAME))
+		return NULL;
+
+	return dev->id->idname;
+}
+
+static void _copy_idline_str(char *src, char *dst, int len)
+{
+	char *s, *d = dst;
+
+	memset(dst, 0, len);
+
+	if (!(s = strchr(src, '=')))
+		return;
+	s++;
+	while ((*s == ' ') && (s < src + len))
+		s++;
+	while ((*s != ' ') && (*s != '\0') && (*s != '\n') && (s < src + len)) {
+		*d = *s;
+		s++;
+		d++;
+	}
+
+	dst[len-1] = '\0';
+}
+
+int device_ids_read(struct cmd_context *cmd)
+{
+	char line[PATH_MAX];
+	char buf[PATH_MAX];
+	char *idtype, *idname, *devname, *pvid, *part;
+	struct dev_use *du;
+	FILE *fp;
+	int line_error;
+	int ret = 1;
+
+	if (!cmd->enable_devices_file)
+		return 1;
+
+	/*
+	 * The use_devices list should rarely if ever be non-empty at this
+	 * point, it means device_ids_read has been called twice.
+	 * If we wanted to redo reading the file, we'd need to
+	 * free_dus(&cmd->use_devices) and clear the MATCHED_USE_ID flag in all
+	 * dev->flags.
+	 */
+	if (!dm_list_empty(&cmd->use_devices)) {
+		log_debug("device_ids_read already done");
+		return 1;
+	}
+
+	log_debug("device_ids_read %s", cmd->devices_file_path);
+
+	if (!(fp = fopen(cmd->devices_file_path, "r"))) {
+		log_warn("Cannot open devices file to read.");
+		return 0;
+	}
+
+	while (fgets(line, sizeof(line), fp)) {
+		if (line[0] == '#')
+			continue;
+
+		if (!strncmp(line, "SYSTEMID", 8)) {
+			_copy_idline_str(line, _devices_file_systemid, sizeof(_devices_file_systemid));
+			log_debug("read devices file systemid %s", _devices_file_systemid);
+			if ((!cmd->system_id && _devices_file_systemid[0]) ||
+			    strcmp(cmd->system_id, _devices_file_systemid)) {
+				log_warn("WARNING: ignoring devices file with wrong system id %s vs local %s.",
+					  _devices_file_systemid[0] ? _devices_file_systemid : "none", cmd->system_id ?: "none");
+				free_dus(&cmd->use_devices);
+				ret = 0;
+				goto out;
+			}
+			continue;
+		}
+		if (!strncmp(line, "VERSION", 7)) {
+			_copy_idline_str(line, _devices_file_version, sizeof(_devices_file_version));
+			log_debug("read devices file version %s", _devices_file_version);
+			continue;
+		}
+
+		idtype = strstr(line, "IDTYPE");
+		idname = strstr(line, "IDNAME");
+		devname = strstr(line, "DEVNAME");
+		pvid = strstr(line, "PVID");
+		part = strstr(line, "PART");
+		line_error = 0;
+
+		/* These two are the minimum required. */
+		if (!idtype || !idname)
+			continue;
+
+		if (!(du = zalloc(sizeof(struct dev_use)))) {
+			log_warn("WARNING: failed to process devices file entry.");
+			continue;
+		}
+
+		_copy_idline_str(idtype, buf, PATH_MAX);
+		if (buf[0])
+			du->idtype = idtype_from_str(buf);
+
+		_copy_idline_str(idname, buf, PATH_MAX);
+		if (buf[0] && (buf[0] != '.')) {
+			if (!(du->idname = strdup(buf)))
+				line_error = 1;
+		}
+
+		if (devname) {
+			_copy_idline_str(devname, buf, PATH_MAX);
+			if (buf[0] && (buf[0] != '.')) {
+				if (!(du->devname = strdup(buf)))
+					line_error = 1;
+			}
+		}
+
+		if (pvid) {
+			_copy_idline_str(pvid, buf, PATH_MAX);
+			if (buf[0] && (buf[0] != '.')) {
+				if (!(du->pvid = strdup(buf)))
+					line_error = 1;
+			}
+		}
+
+		if (part) {
+			_copy_idline_str(part, buf, PATH_MAX);
+			if (buf[0] && (buf[0] != '.'))
+				du->part = atoi(buf);
+		}
+
+		if (line_error) {
+			log_warn("WARNING: failed to process devices file entry.");
+			free_du(du);
+			continue;
+		}
+
+		dm_list_add(&cmd->use_devices, &du->list);
+	}
+out:
+	if (fclose(fp))
+		stack;
+
+	return ret;
+}
+
+int device_ids_write(struct cmd_context *cmd)
+{
+	char dirpath[PATH_MAX];
+	char tmpfile[PATH_MAX];
+	char version_buf[VERSION_LINE_MAX] = {0};
+	FILE *fp;
+	int dir_fd;
+	time_t t;
+	struct dev_use *du;
+	const char *devname;
+	const char *pvid;
+	uint32_t df_major = 0, df_minor = 0, df_counter = 0;
+	int file_exists;
+	int ret = 1;
+
+	if (!cmd->enable_devices_file && !cmd->pending_devices_file)
+		return 1;
+
+	/*
+	 * pending_devices_file: setup_devices found no system devices file
+	 * exists and has not enabled the devices file, but may want to
+	 * create a new devices file here and enable it.
+	 *
+	 * If this is pvcreate/vgcreate with the system devices file,
+	 * and the devices file doesn't exist, then we may not want to
+	 * create one for the new PVs created.  This is because doing so
+	 * would cause existing PVs on the system to be left out and not
+	 * be visible.  So, if the pvcreate/vgcreate have seen existing PVs
+	 * during the label scan, then skip creating/writing a new system
+	 * devices file.  But, if they have not seen any other PVs, then
+	 * create a new system devices file here with the newly created PVs.
+	 * The idea is that pvcreate/vgcreate of the first PVs is probably
+	 * system installation, and we'd like to have a devices file created
+	 * automatically during installation.  (The installer could also touch
+	 * the devices file to create it, and that would cause
+	 * pvcreate/vgcreate to always populate it.)
+	 */
+	file_exists = devices_file_exists(cmd);
+
+	log_debug("device_ids_write create %d edit %d pending %d exists %d version %s devicesfile %s",
+		  cmd->create_edit_devices_file, cmd->edit_devices_file, cmd->pending_devices_file, file_exists,
+		  _devices_file_version[0] ? _devices_file_version : ".", cmd->devicesfile ?: ".");
+
+	if (cmd->pending_devices_file && cmd->create_edit_devices_file && !cmd->devicesfile && !file_exists &&
+	    (!strncmp(cmd->name, "pvcreate", 8) || !strncmp(cmd->name, "vgcreate", 8))) {
+		/* If any PVs were seen during scan then don't create a new devices file. */
+		if (lvmcache_vg_info_count()) {
+			log_warn("Not creating system devices file due to existing VGs.");
+			free_dus(&cmd->use_devices);
+			return 1;
+		}
+		log_warn("Creating devices file %s", cmd->devices_file_path);
+		cmd->enable_devices_file = 1;
+	}
+
+	if (_devices_file_version[0]) {
+		if (sscanf(_devices_file_version, "%u.%u.%u", &df_major, &df_minor, &df_counter) != 3) {
+			/* don't update a file we can't parse */
+			log_warn("WARNING: not updating devices file with unparsed version.");
+			return 0;
+		}
+		if (df_major > DEVICES_FILE_MAJOR) {
+			/* don't update a file with a newer major version */
+			log_warn("WARNING: not updating devices file with larger major version.");
+			return 0;
+		}
+	}
+
+	if (dm_snprintf(dirpath, sizeof(dirpath), "%s/devices", cmd->system_dir) < 0) {
+		ret = 0;
+		goto out;
+	}
+
+	if (dm_snprintf(tmpfile, sizeof(tmpfile), "%s_new", cmd->devices_file_path) < 0) {
+		ret = 0;
+		goto out;
+	}
+
+	unlink(tmpfile); /* in case a previous file was left */
+
+	if (!(fp = fopen(tmpfile, "w+"))) {
+		log_warn("Cannot open tmp devices_file to write.");
+		ret = 0;
+		goto out;
+	}
+
+	if ((dir_fd = open(dirpath, O_RDONLY)) < 0) {
+		fclose(fp);
+		ret = 0;
+		goto out;
+	}
+
+	t = time(NULL);
+
+	fprintf(fp, "# LVM uses devices listed in this file.\n");
+	fprintf(fp, "# Created by LVM command %s pid %d@%s", cmd->name, getpid(), ctime(&t));
+
+	/*
+	 * It's useful to ensure that this devices file is associated to a
+	 * single system because this file can be used to control access to
+	 * shared devices.  If this file is copied/cloned to another system,
+	 * that new system should not automatically gain access to the devices
+	 * that the original system is using.
+	 */
+	if (cmd->system_id)
+		fprintf(fp, "SYSTEMID=%s\n", cmd->system_id);
+
+	if (dm_snprintf(version_buf, VERSION_LINE_MAX, "VERSION=%u.%u.%u", DEVICES_FILE_MAJOR, DEVICES_FILE_MINOR, df_counter+1) < 0)
+		stack;
+	else
+		fprintf(fp, "%s\n", version_buf);
+
+	/* as if we had read this version in case we want to write again */
+	memset(_devices_file_version, 0, sizeof(_devices_file_version));
+	_copy_idline_str(version_buf, _devices_file_version, sizeof(_devices_file_version));
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		devname = du->dev ? dev_name(du->dev) : du->devname;
+		if (!devname || devname[0] != '/')
+			devname = ".";
+
+		if (!du->pvid || !du->pvid[0] || (du->pvid[0] == '.'))
+			pvid = ".";
+		else
+			pvid = du->pvid;
+
+		if (du->part) {
+			fprintf(fp, "IDTYPE=%s IDNAME=%s DEVNAME=%s PVID=%s PART=%d\n",
+				idtype_to_str(du->idtype) ?: ".",
+				du->idname ?: ".", devname, pvid, du->part);
+		} else {
+			fprintf(fp, "IDTYPE=%s IDNAME=%s DEVNAME=%s PVID=%s\n",
+				idtype_to_str(du->idtype) ?: ".",
+				du->idname ?: ".", devname, pvid);
+		}
+	}
+
+	if (fflush(fp))
+		stack;
+	if (fclose(fp))
+		stack;
+
+	if (rename(tmpfile, cmd->devices_file_path) < 0) {
+		log_error("Failed to replace devices file errno %d", errno);
+		ret = 0;
+	}
+
+	if (fsync(dir_fd) < 0)
+		stack;
+	if (close(dir_fd) < 0)
+		stack;
+
+	log_debug("Wrote devices file %s", version_buf);
+out:
+	return ret;
+}
+
+static void _device_ids_update_try(struct cmd_context *cmd)
+{
+	int held;
+
+	/* Defer updates to non-pvscan-cache commands. */
+	if (cmd->pvscan_cache_single) {
+		log_print("pvscan[%d] skip updating devices file.", getpid());
+		return;
+	}
+
+	/*
+	 * Use a non-blocking lock since it's not essential to
+	 * make this update, the next cmd will make these changes
+	 * if we skip it this update.
+	 * If this command already holds an ex lock on the
+	 * devices file, lock_devices_file ex succeeds and
+	 * held is set.
+	 * If we get the lock, only update the devices file if
+	 * it's not been changed since we read it.
+	 */
+	if (!lock_devices_file_try(cmd, LOCK_EX, &held)) {
+		log_debug("Skip devices file update (busy).");
+	} else {
+		if (device_ids_version_unchanged(cmd))
+			device_ids_write(cmd);
+		else
+			log_debug("Skip devices file update (changed).");
+	}
+	if (!held)
+		unlock_devices_file(cmd);
+}
+
+int device_ids_version_unchanged(struct cmd_context *cmd)
+{
+	char line[PATH_MAX];
+	char version_buf[VERSION_LINE_MAX];
+	FILE *fp;
+
+	if (!(fp = fopen(cmd->devices_file_path, "r"))) {
+		log_warn("WARNING: cannot open devices file to read.");
+		return 0;
+	}
+
+	while (fgets(line, sizeof(line), fp)) {
+		if (line[0] == '#')
+			continue;
+
+		if (!strncmp(line, "VERSION", 7)) {
+			if (fclose(fp))
+				stack;
+
+			_copy_idline_str(line, version_buf, sizeof(version_buf));
+
+			log_debug("check devices file version %s prev %s", version_buf, _devices_file_version);
+
+			if (!strcmp(version_buf, _devices_file_version))
+				return 1;
+			return 0;
+		}
+	}
+
+	if (fclose(fp))
+		stack;
+	return 0;
+}
+
+int device_ids_use_devname(struct cmd_context *cmd)
+{
+	struct dev_use *du;
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->idtype == DEV_ID_TYPE_DEVNAME)
+			return 1;
+	}
+	return 0;
+}
+
+struct dev_use *get_du_for_dev(struct cmd_context *cmd, struct device *dev)
+{
+	struct dev_use *du;
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->dev == dev)
+			return du;
+	}
+	return NULL;
+}
+
+struct dev_use *get_du_for_pvid(struct cmd_context *cmd, const char *pvid)
+{
+	struct dev_use *du;
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (!du->pvid)
+			continue;
+		if (!strcmp(du->pvid, pvid))
+			return du;
+	}
+	return NULL;
+}
+
+static struct dev_use *_get_du_for_devname(struct cmd_context *cmd, const char *devname)
+{
+	struct dev_use *du;
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (!du->devname)
+			continue;
+		if (!strcmp(du->devname, devname))
+			return du;
+	}
+	return NULL;
+}
+
+static struct dev_use *_get_du_for_device_id(struct cmd_context *cmd, uint16_t idtype, const char *idname)
+{
+	struct dev_use *du;
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->idname && (du->idtype == idtype) && !strcmp(du->idname, idname))
+			return du;
+	}
+	return NULL;
+}
+
+/*
+ * Add or update entry for this dev.
+ * . add an entry to dev->ids and point dev->id to it
+ * . add or update entry in cmd->use_devices
+ */
+int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid_arg,
+		  const char *idtype_arg, const char *id_arg)
+{
+	char pvid[ID_LEN+1] = { 0 };
+	uint16_t idtype = 0;
+	const char *idname = NULL;
+	const char *check_idname = NULL;
+	const char *update_matching_kind = NULL;
+	const char *update_matching_name = NULL;
+	struct dev_use *du, *update_du = NULL, *du_dev, *du_pvid, *du_devname, *du_devid;
+	struct dev_id *id;
+	int found_id = 0;
+
+	/*
+	 * When enable_devices_file=0 and pending_devices_file=1 we let
+	 * pvcreate/vgcreate add new du's to cmd->use_devices.  These du's may
+	 * be written to a new system devices file in device_ids_write, or they
+	 * may not, or devices_file_write may decide not to write a new system
+	 * devices file and devices file may remain disabled.
+	 */
+	if (!cmd->enable_devices_file && !cmd->pending_devices_file)
+		 return 1;
+
+	/*
+	 * The pvid_arg may be passed from a 'struct id' (pv->id) which
+	 * may not have a terminating \0.
+	 * Make a terminated copy to use as a string.
+	 */
+	memcpy(&pvid, pvid_arg, ID_LEN);
+
+	du_dev = get_du_for_dev(cmd, dev);
+	du_pvid = get_du_for_pvid(cmd, pvid);
+	du_devname = _get_du_for_devname(cmd, dev_name(dev));
+
+	/*
+	 * Choose the device_id type for the device being added.
+	 *
+	 * 1. use an idtype specific to a special/virtual device type
+	 *    e.g. loop, mpath, crypt, lvmlv, md, etc.
+	 * 2. use an idtype specified by user option.
+	 * 3. use sys_wwid, if it exists.
+	 * 4. use sys_serial, if it exists.
+	 * 5. use devname as the last resort.
+	 */
+
+	if (MAJOR(dev->dev) == cmd->dev_types->device_mapper_major) {
+		if (_dev_has_mpath_uuid(cmd, dev, &idname)) {
+			idtype = DEV_ID_TYPE_MPATH_UUID;
+			goto id_done;
+		}
+
+		if (_dev_has_crypt_uuid(cmd, dev, &idname)) {
+			idtype = DEV_ID_TYPE_CRYPT_UUID;
+			goto id_done;
+		}
+
+		if (_dev_has_lvmlv_uuid(cmd, dev, &idname)) {
+			idtype = DEV_ID_TYPE_LVMLV_UUID;
+			goto id_done;
+		}
+	}
+
+	/* TODO: kpartx partitions on loop devs. */
+	if (MAJOR(dev->dev) == cmd->dev_types->loop_major) {
+		idtype = DEV_ID_TYPE_LOOP_FILE;
+		goto id_name;
+	}
+
+	if (MAJOR(dev->dev) == cmd->dev_types->md_major) {
+		idtype = DEV_ID_TYPE_MD_UUID;
+		goto id_name;
+	}
+
+	if (MAJOR(dev->dev) == cmd->dev_types->drbd_major) {
+		/* TODO */
+		log_warn("Missing support for DRBD idtype");
+	}
+
+	if (idtype_arg) {
+		if (!(idtype = idtype_from_str(idtype_arg)))
+			log_warn("WARNING: ignoring unknown device_id type %s.", idtype_arg);
+		else {
+			if (id_arg) {
+				if (!(idname = strdup(id_arg)))
+					stack;
+				goto id_done;
+			}
+			goto id_name;
+		}
+	}
+
+	/*
+	 * No device-specific, existing, or user-specified idtypes,
+	 * so use first available of sys_wwid / sys_serial / devname.
+	 */
+	idtype = DEV_ID_TYPE_SYS_WWID;
+
+id_name:
+	if (!(idname = device_id_system_read(cmd, dev, idtype))) {
+		if (idtype == DEV_ID_TYPE_SYS_WWID) {
+			idtype = DEV_ID_TYPE_SYS_SERIAL;
+			goto id_name;
+		}
+		idtype = DEV_ID_TYPE_DEVNAME;
+		goto id_name;
+	}
+
+id_done:
+
+	/*
+	 * Create a dev_id struct for the new idtype on dev->ids.
+	 */
+	dm_list_iterate_items(id, &dev->ids) {
+		if (id->idtype == idtype) {
+			found_id = 1;
+			break;
+		}
+	}
+	if (found_id && !strcmp(id->idname, idname)) {
+		free((char *)idname);
+	} else if (found_id && strcmp(id->idname, idname)) {
+		dm_list_del(&id->list);
+		free_did(id);
+		found_id = 0;
+	}
+	if (!found_id) {
+		if (!(id = zalloc(sizeof(struct dev_id))))
+			return_0;
+		id->idtype = idtype;
+		id->idname = (char *)idname;
+		id->dev = dev;
+		dm_list_add(&dev->ids, &id->list);
+	}
+	dev->id = id;
+	dev->flags |= DEV_MATCHED_USE_ID;
+
+	idname = NULL;
+	idtype = 0;
+
+	/*
+	 * Update the cmd->use_devices list for the new device.  The
+	 * use_devices list will be used to update the devices file.
+	 *
+	 * The dev being added can potentially overlap existing entries
+	 * in various ways.  If one of the existing entries is truely for
+	 * this device being added, then we want to update that entry.
+	 * If some other existing entries are not for the same device, but
+	 * have some overlapping values, then we want to try to update
+	 * those other entries to fix any incorrect info.
+	 */
+
+	du_devid = _get_du_for_device_id(cmd, id->idtype, id->idname);
+
+	if (du_dev)
+		log_debug("device_id_add %s pvid %s matches du_dev %p dev %s",
+			  dev_name(dev), pvid, du_dev, dev_name(du_dev->dev));
+	if (du_pvid)
+		log_debug("device_id_add %s pvid %s matches du_pvid %p dev %s pvid %s",
+			  dev_name(dev), pvid, du_pvid, du_pvid->dev ? dev_name(du_pvid->dev) : ".",
+			  du_pvid->pvid);
+	if (du_devid)
+		log_debug("device_id_add %s pvid %s matches du_devid %p dev %s pvid %s",
+			  dev_name(dev), pvid, du_devid, du_devid->dev ? dev_name(du_devid->dev) : ".",
+			  du_devid->pvid);
+	if (du_devname)
+		log_debug("device_id_add %s pvid %s matches du_devname %p dev %s pvid %s",
+			  dev_name(dev), pvid, du_devname, du_devname->dev ? dev_name(du_devname->dev) : ".",
+			  du_devname->pvid);
+
+	/*
+	 * If one of the existing entries (du_dev, du_pvid, du_devid, du_devname)
+	 * is truely for the same device that is being added, then set update_du to
+	 * that existing entry to be updated.
+	 */
+
+	if (du_dev) {
+		update_du = du_dev;
+		dm_list_del(&update_du->list);
+		update_matching_kind = "device";
+		update_matching_name = dev_name(dev);
+
+		if (du_devid && (du_devid != du_dev)) {
+			log_warn("WARNING: device %s (%s) and %s (%s) have duplicate device ID.",
+				 dev_name(dev), id->idname,
+				 du_pvid->dev ? dev_name(du_pvid->dev) : "none", du_pvid->idname);
+		}
+
+		if (du_pvid && (du_pvid != du_dev)) {
+			log_warn("WARNING: device %s (%s) and %s (%s) have duplicate PVID %s",
+				 dev_name(dev), id->idname,
+				 du_pvid->dev ? dev_name(du_pvid->dev) : "none", du_pvid->idname,
+				 pvid);
+		}
+
+		if (du_devname && (du_devname != du_dev)) {
+			/* clear devname in another entry with our devname */
+			log_warn("Devices file PVID %s clearing wrong DEVNAME %s.",
+				 du_devname->pvid, du_devname->devname);
+			free(du_devname->devname);
+			du_devname->devname = NULL;
+		}
+
+	} else if (du_pvid) {
+		/*
+		 * If the device_id of the existing entry for PVID is the same
+		 * as the device_id of the device being added, then update the
+		 * existing entry.  If the device_ids differ, then the devices
+		 * have duplicate PVIDs, and the new device gets a new entry
+		 * (if we allow it to be added.)
+		 */
+		if (du_pvid->idtype == id->idtype)
+			check_idname = strdup(id->idname);
+		else
+			check_idname = device_id_system_read(cmd, dev, du_pvid->idtype);
+
+		if (check_idname && !strcmp(check_idname, du_pvid->idname)) {
+			update_du = du_pvid;
+			dm_list_del(&update_du->list);
+			update_matching_kind = "PVID";
+			update_matching_name = pvid;
+		} else {
+			log_warn("WARNING: device %s (%s) and %s (%s) have duplicate PVID %s",
+				 dev_name(dev), id->idname,
+				 du_pvid->dev ? dev_name(du_pvid->dev) : "none", du_pvid->idname,
+				 pvid);
+
+			if (yes_no_prompt("Add device with duplicate PV to devices file?") == 'n') {
+				log_print("Device not added.");
+				return 1;
+			}
+		}
+
+		if (du_devid && (du_devid != du_pvid)) {
+			/* warn about another entry using the same device_id */
+			log_warn("WARNING: duplicate device_id %s for PVIDs %s %s",
+				 du_devid->idname, du_devid->pvid, du_pvid->pvid);
+		}
+
+		if (du_devname && (du_devname != du_pvid)) {
+			/* clear devname in another entry with our devname */
+			log_warn("Devices file PVID %s clearing wrong DEVNAME %s.",
+				 du_devname->pvid, du_devname->devname);
+			free(du_devname->devname);
+			du_devname->devname = NULL;
+		}
+
+	} else if (du_devid) {
+		/*
+		 * Do we create a new du or update the existing du?
+		 * If it's the same device, update the existing du,
+		 * but if it's two devices with the same device_id, then
+		 * create a new du.
+		 *
+		 * We know that 'dev' has device_id 'id'.
+		 * Check if du_devid->dev is different from 'dev'
+		 * and that du_devid->idname matches id.
+		 * If so, then there are two different devices with
+		 * the same device_id (create a new du for dev.)
+		 * If not, then update the existing du_devid.
+		 */
+		
+		if (du_devid->dev != dev)
+			check_idname = device_id_system_read(cmd, du_devid->dev, id->idtype);
+
+		if (check_idname && !strcmp(check_idname, id->idname)) {
+			int ret1, ret2;
+			dev_t devt1, devt2;
+
+			/*
+			 * two different devices have the same device_id,
+			 * create a new du for the device being added
+			 */
+
+			/* dev_is_partitioned() the dev open to read it. */
+			if (!label_scan_open(du_devid->dev))
+				log_warn("Cannot open %s", dev_name(du_devid->dev));
+
+			if (dev_is_partitioned(cmd->dev_types, du_devid->dev)) {
+				/* Check if existing entry is whole device and new entry is a partition of it. */
+				ret1 = dev_get_primary_dev(cmd->dev_types, dev, &devt1);
+				if ((ret1 == 2) && (devt1 == du_devid->dev->dev))
+					log_warn("Remove partitioned device %s from devices file.", dev_name(du_devid->dev));
+			} else {
+				/* Check if both entries are partitions of the same device. */
+				ret1 = dev_get_primary_dev(cmd->dev_types, dev, &devt1);
+				ret2 = dev_get_primary_dev(cmd->dev_types, du_devid->dev, &devt2);
+
+				if ((ret1 == 2) && (ret2 == 2) && (devt1 == devt2)) {
+					log_warn("Partitions %s %s have same device_id %s",
+						 dev_name(dev), dev_name(du_devid->dev), id->idname);
+				} else {
+					log_warn("Duplicate device_id %s %s for %s and %s",
+						 idtype_to_str(id->idtype), check_idname,
+						 dev_name(dev), dev_name(du_devid->dev));
+				}
+			}
+		} else {
+			/* update the existing entry with matching devid */
+			update_du = du_devid;
+			dm_list_del(&update_du->list);
+			update_matching_kind = "device_id";
+			update_matching_name = id->idname;
+		}
+
+		if (du_devname && (du_devname != du_devid)) {
+			/* clear devname in another entry with our devname */
+			log_warn("Devices file PVID %s clearing wrong DEVNAME %s",
+				 du_devname->pvid, du_devname->devname);
+			free(du_devname->devname);
+			du_devname->devname = NULL;
+		}
+
+	} else if (du_devname) {
+		/* clear devname in another entry with our devname */
+		log_warn("Devices file PVID %s clearing wrong DEVNAME %s",
+			 du_devname->pvid, du_devname->devname);
+		free(du_devname->devname);
+		du_devname->devname = NULL;
+	}
+
+	if (check_idname)
+		free((void *)check_idname);
+
+	if (!update_du) {
+		log_debug("Adding new entry to devices file for %s PVID %s %s %s.",
+			  dev_name(dev), pvid, idtype_to_str(id->idtype), id->idname);
+		if (!(du = zalloc(sizeof(struct dev_use))))
+			return_0;
+	} else {
+		du = update_du;
+		log_debug("Updating existing entry in devices file for %s that matches %s %s.",
+			  dev_name(dev), update_matching_kind, update_matching_name);
+	}
+
+	if (du->idname)
+		free(du->idname);
+	if (du->devname)
+		free(du->devname);
+	if (du->pvid)
+		free(du->pvid);
+
+	du->idtype = id->idtype;
+	du->idname = strdup(id->idname);
+	du->devname = strdup(dev_name(dev));
+	du->dev = dev;
+	du->pvid = strdup(pvid);
+
+	dev_get_partition_number(dev, &du->part);
+
+	if (!du->idname || !du->devname || !du->pvid) {
+		free_du(du);
+		return_0;
+	}
+
+	dm_list_add(&cmd->use_devices, &du->list);
+
+	return 1;
+}
+
+/*
+ * Update entry for this dev.
+ * Set PVID=.
+ * update entry in cmd->use_devices
+ */
+void device_id_pvremove(struct cmd_context *cmd, struct device *dev)
+{
+	struct dev_use *du;
+
+	if (!cmd->enable_devices_file)
+		return;
+
+	if (!(du = get_du_for_dev(cmd, dev))) {
+		log_warn("WARNING: devices to use does not include %s", dev_name(dev));
+		return;
+	}
+
+	if (du->pvid) {
+		free(du->pvid);
+		du->pvid = NULL;
+	}
+}
+
+/*
+ * check for dev->ids entry with du->idtype, if found compare it,
+ * if not, system_read of this type and add entry to dev->ids, compare it.
+ * When a match is found, set up links among du/id/dev.
+ */
+
+static int _match_du_to_dev(struct cmd_context *cmd, struct dev_use *du, struct device *dev)
+{
+	struct dev_id *id;
+	const char *idname;
+	int part;
+
+	if (!du->idname || !du->idtype)
+		return 0;
+
+	if (!dev_get_partition_number(dev, &part)) {
+		log_debug("compare %s failed to get dev partition", dev_name(dev));
+		return 0;
+	}
+	if (part != du->part) {
+		/*
+		log_debug("compare mis %s %s part %d to %s part %d",
+			  idtype_to_str(du->idtype), du->idname ?: ".", du->part, dev_name(dev), part);
+		*/
+		return 0;
+	}
+
+	dm_list_iterate_items(id, &dev->ids) {
+		if (id->idtype == du->idtype) {
+			if (id->idname && !strcmp(id->idname, du->idname)) {
+				du->dev = dev;
+				dev->id = id;
+				dev->flags |= DEV_MATCHED_USE_ID;
+				log_debug("compare match %s %s to %s",
+					  idtype_to_str(du->idtype), du->idname, dev_name(dev));
+				return 1;
+			} else {
+				/*
+				log_debug("compare mis %s %s to %s %s",
+			  		  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev),
+					  ((id->idtype != DEV_ID_TYPE_DEVNAME) && id->idname) ? id->idname : "");
+				*/
+				return 0;
+			}
+		}
+	}
+
+	if (!(id = zalloc(sizeof(struct dev_id))))
+		return_0;
+
+	if (!(idname = device_id_system_read(cmd, dev, du->idtype))) {
+		/*
+		 * Save a new id in dev->ids for this type to indicate no match
+		 * to avoid repeated system_read, since this called many times.
+		 * Setting idtype and NULL idname means no id of this type.
+		 */
+		id->idtype = du->idtype;
+		id->dev = dev;
+		dm_list_add(&dev->ids, &id->list);
+		/*
+		log_debug("compare mis %s %s to %s no idtype",
+			  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev));
+		*/
+		return 0;
+	}
+
+	/*
+	 * Save this id for the device (so it can be quickly checked again), even
+	 * if it's not the idtype used to identify the dev in device_id_file.
+	 */
+	id->idtype = du->idtype;
+	id->idname = (char *)idname;
+	id->dev = dev;
+	dm_list_add(&dev->ids, &id->list);
+
+	if (!strcmp(idname, du->idname)) {
+		du->dev = dev;
+		dev->id = id;
+		dev->flags |= DEV_MATCHED_USE_ID;
+		log_debug("compare match %s %s to %s",
+			  idtype_to_str(du->idtype), du->idname, dev_name(dev));
+		return 1;
+	}
+
+	/*
+	log_debug("compare mis %s %s to %s %s",
+		  idtype_to_str(du->idtype), du->idname ?: ".", dev_name(dev),
+		  ((id->idtype != DEV_ID_TYPE_DEVNAME) && id->idname) ? id->idname : "");
+	*/
+	return 0;
+}
+
+int device_ids_match_dev(struct cmd_context *cmd, struct device *dev)
+{
+	struct dev_use *du;
+
+	/* First check the du entry with matching devname since it's likely correct. */
+	if ((du = _get_du_for_devname(cmd, dev_name(dev)))) {
+		if (_match_du_to_dev(cmd, du, dev))
+			return 1;
+	}
+
+	/* Check all du entries since the devname could have changed. */
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (!_match_du_to_dev(cmd, du, dev))
+			continue;
+		return 1;
+	}
+
+	return 0;
+}
+
+/*
+ * For each entry on cmd->use_devices (entries in the devices file),
+ * find a struct device from dev-cache.  They are paired based strictly
+ * on the device id.
+ *
+ * This must not open or read devices.  This function cannot use filters.
+ * filters are applied after this, and the filters may open devs in the first
+ * nodata filtering.  The second filtering, done after label_scan has read
+ * a device, is allowed to read a device to evaluate filters that need to see
+ * data from the dev.
+ *
+ * When a device id of a particular type is obtained for a dev, a id for that
+ * type is saved in dev->ids in case it needs to be checked again.
+ *
+ * When a device in dev-cache is matched to an entry in the devices file
+ * (a struct dev_use), then:
+ * . du->dev = dev;
+ * . dev->id = id;
+ * . dev->flags |= DEV_MATCHED_USE_ID;
+ *
+ * Later when filter-deviceid is run to exclude devices that are not
+ * included in the devices file, the filter checks if DEV_MATCHED_USE_ID
+ * is set which means that the dev matches a devices file entry and
+ * passes the filter.
+ */
+
+void device_ids_match(struct cmd_context *cmd)
+{
+	struct dev_iter *iter;
+	struct dev_use *du;
+	struct device *dev;
+
+	if (cmd->enable_devices_list) {
+		dm_list_iterate_items(du, &cmd->use_devices) {
+			if (du->dev)
+				continue;
+			if (!(du->dev = dev_cache_get(cmd, du->devname, NULL))) {
+				log_warn("Device not found for %s.", du->devname);
+			} else {
+				/* Should we set dev->id?  Which idtype?  Use --deviceidtype? */
+				du->dev->flags |= DEV_MATCHED_USE_ID;
+			}
+		}
+		return;
+	}
+
+	if (!cmd->enable_devices_file)
+		return;
+
+	log_debug("compare devices file entries to devices");
+
+	/*
+	 * We would set cmd->filter_deviceid_skip but we are disabling
+	 * all filters (dev_cache_get NULL arg) so it's not necessary.
+	 */
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		/* already matched */
+		if (du->dev) {
+			log_debug("devices idname %s previously matched %s",
+				  du->idname, dev_name(du->dev));
+			continue;
+		}
+
+		/*
+		 * du->devname from the devices file is the last known
+		 * device name.  It may be incorrect, but it's usually
+		 * correct, so it's an efficient place to check for a
+		 * match first.
+		 *
+		 * NULL filter is used because we are just setting up the
+		 * the du/dev pairs in preparation for using the filters.
+		 */
+		if (du->devname &&
+		    (dev = dev_cache_get(cmd, du->devname, NULL))) {
+			/* On successful match, du, dev, and id are linked. */
+			if (_match_du_to_dev(cmd, du, dev))
+				continue;
+			else {
+				/*
+				 * The device node may exist but the device is disconnected / zero size,
+				 * and likely has no sysfs entry to check for wwid.  Continue to look
+				 * for the device id on other devs.
+				 */
+				log_debug("devices entry %s %s devname found but not matched", du->devname, du->pvid ?: ".");
+			}
+		}
+
+		/*
+		 * Iterate through all devs and try to match du.
+		 *
+		 * If a match is made here it means the du->devname is wrong,
+		 * so the device_id file should be updated with a new devname.
+		 *
+		 * NULL filter is used because we are just setting up the
+		 * the du/dev pairs in preparation for using the filters.
+		 */
+		if (!(iter = dev_iter_create(NULL, 0)))
+			continue;
+		while ((dev = dev_iter_get(cmd, iter))) {
+			if (dev->flags & DEV_MATCHED_USE_ID)
+				continue;
+			if (_match_du_to_dev(cmd, du, dev))
+				break;
+		}
+		dev_iter_destroy(iter);
+	}
+
+	/*
+	 * Look for entries in devices file for which we found no device.
+	 */
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		/* Found a device for this entry. */
+		if (du->dev && (du->dev->flags & DEV_MATCHED_USE_ID))
+			continue;
+
+		/* This shouldn't be possible. */
+		if (du->dev && !(du->dev->flags & DEV_MATCHED_USE_ID)) {
+			log_error("Device %s not matched to device_id", dev_name(du->dev));
+			continue;
+		}
+
+		/* A detached device would get here which isn't uncommon. */
+
+		if ((du->idtype == DEV_ID_TYPE_DEVNAME) && du->devname)
+			log_warn("Devices file PVID %s last seen on %s not found.",
+				 du->pvid ?: "none",
+				 du->devname ?: "none");
+		else if (du->idtype == DEV_ID_TYPE_DEVNAME)
+			log_warn("Devices file PVID %s not found.",
+				 du->pvid ?: "none");
+		else if (du->devname)
+			log_warn("Devices file %s %s PVID %s last seen on %s not found.",
+				 idtype_to_str(du->idtype),
+				 du->idname ?: "none",
+				 du->pvid ?: "none",
+				 du->devname);
+		else
+			log_warn("Devices file %s %s PVID %s not found.",
+				 idtype_to_str(du->idtype),
+				 du->idname ?: "none",
+				 du->pvid ?: "none");
+	}
+}
+
+/*
+ * This is called after devices are scanned to compare what was found on disks
+ * vs what's in the devices file.  The devices file could be outdated and need
+ * correcting; the authoritative data is what's on disk.  Now that we have read
+ * the device labels and know the PVID's from disk we can check the PVID's in
+ * use_devices entries from the devices file.
+ */
+
+void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
+			 int *device_ids_invalid, int noupdate)
+{
+	struct dm_list wrong_devs;
+	struct device *dev;
+	struct device_list *devl;
+	struct dev_use *du;
+	char *tmpdup;
+	int checked = 0;
+	int update_file = 0;
+
+	dm_list_init(&wrong_devs);
+
+	if (!cmd->enable_devices_file)
+		return;
+
+	log_debug("validating devices file entries");
+
+	/*
+	 * Validate entries with proper device id types.
+	 * idname is the authority for pairing du and dev.
+	 */
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (!du->dev)
+			continue;
+
+		/* For this idtype the idname match is unreliable. */
+		if (du->idtype == DEV_ID_TYPE_DEVNAME)
+			continue;
+
+		dev = du->dev;
+
+		/*
+		 * scanned_devs are the devices that have been scanned,
+		 * so they are the only devs we can verify PVID for.
+		 */
+		if (scanned_devs && !dev_in_device_list(dev, scanned_devs))
+			continue;
+
+		/*
+		 * du and dev may have been matched, but the dev could still
+		 * have been excluded by other filters during label scan.
+		 * This shouldn't generally happen, but if it does the user
+		 * probably wants to do something about it.
+		 */
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "persistent")) {
+			log_warn("Devices file %s is excluded by filter: %s.",
+				 dev_name(dev), dev_filtered_reason(dev));
+			continue;
+		}
+
+		checked++;
+
+		/*
+		 * If the du pvid from the devices file does not match the
+		 * pvid read from disk, replace the du pvid with the pvid from
+		 * disk and update the pvid in the devices file entry.
+		 */
+		if (dev->pvid[0]) {
+			if (!du->pvid || memcmp(dev->pvid, du->pvid, ID_LEN)) {
+				log_warn("Device %s has PVID %s (devices file %s)",
+					 dev_name(dev), dev->pvid, du->pvid ?: "none");
+				if (!(tmpdup = strdup(dev->pvid)))
+					continue;
+				if (du->pvid)
+					free(du->pvid);
+				du->pvid = tmpdup;
+				update_file = 1;
+				*device_ids_invalid = 1;
+			}
+		} else {
+			if (du->pvid && (du->pvid[0] != '.')) {
+				log_warn("Device %s has no PVID (devices file %s)",
+					 dev_name(dev), du->pvid);
+				if (du->pvid)
+					free(du->pvid);
+				du->pvid = NULL;
+				update_file = 1;
+				*device_ids_invalid = 1;
+			}
+		}
+
+		if (!du->devname || strcmp(dev_name(du->dev), du->devname)) {
+			log_warn("Device %s has updated name (devices file %s)",
+				 dev_name(du->dev), du->devname ?: "none");
+			if (!(tmpdup = strdup(dev_name(du->dev))))
+				continue;
+			if (du->devname)
+				free(du->devname);
+			du->devname = tmpdup;
+			update_file = 1;
+			*device_ids_invalid = 1;
+		}
+	}
+
+	/*
+	 * Validate entries with unreliable devname id type.
+	 * pvid match overrides devname id match.
+	 */
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (!du->dev)
+			continue;
+
+		if (du->idtype != DEV_ID_TYPE_DEVNAME)
+			continue;
+
+		dev = du->dev;
+
+		/*
+		 * scanned_devs are the devices that have been scanned,
+		 * so they are the only devs we can verify PVID for.
+		 */
+		if (scanned_devs && !dev_in_device_list(dev, scanned_devs))
+			continue;
+
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "persistent")) {
+			log_warn("Devices file %s is excluded by filter: %s.",
+				 dev_name(dev), dev_filtered_reason(dev));
+			/* FIXME: what if this dev is wrongly matched and should be checked below? */
+			continue;
+		}
+
+		if (!du->pvid || du->pvid[0] == '.')
+			continue;
+
+		checked++;
+
+		/*
+		 * A good match based on pvid.
+		 */
+		if (dev->pvid[0] && !strcmp(dev->pvid, du->pvid)) {
+			const char *devname = dev_name(dev);
+
+			if (strcmp(devname, du->idname)) {
+				/* shouldn't happen since this was basis for match */
+				log_error("du for pvid %s unexpected idname %s mismatch dev %s",
+					  du->pvid, du->idname, devname);
+				*device_ids_invalid = 1;
+				continue;
+			}
+
+			if (!du->devname || strcmp(devname, du->devname)) {
+				log_warn("Device %s has updated name (devices file %s)",
+					 devname, du->devname ?: "none");
+				if (!(tmpdup = strdup(devname)))
+					continue;
+				if (du->devname)
+					free(du->devname);
+				du->devname = tmpdup;
+				update_file = 1;
+				*device_ids_invalid = 1;
+			}
+			continue;
+		}
+
+		/*
+		 * An incorrect match, the pvid read from dev does not match
+		 * du->pvid for the du dev was matched to.
+		 * du->idname is wrong, du->devname is probably wrong.
+		 * undo the incorrect match between du and dev
+		 */
+
+		if (dev->pvid[0])
+			log_warn("Devices file PVID %s not found on device %s (device PVID %s).",
+				 du->pvid, dev_name(dev), dev->pvid[0] ? dev->pvid : "none");
+		else
+			log_warn("Devices file PVID %s not found on device %s.",
+				 du->pvid, dev_name(dev));
+
+		if ((devl = dm_pool_zalloc(cmd->mem, sizeof(*devl)))) {
+			/* If this dev matches no du, drop it at the end. */
+			devl->dev = dev;
+			dm_list_add(&wrong_devs, &devl->list);
+		}
+
+		if (du->idname) {
+			free(du->idname);
+			du->idname = NULL;
+		}
+
+		/*
+		 * Keep the old devname hint in place to preserve some clue about
+		 * the previous location of the PV which may help the user understand
+		 * what happened.
+		 */
+		/*
+		if (du->devname) {
+			free(du->devname);
+			du->devname = NULL;
+		}
+		*/
+		dev->flags &= ~DEV_MATCHED_USE_ID;
+		dev->id = NULL;
+		du->dev = NULL;
+		update_file = 1;
+		*device_ids_invalid = 1;
+	}
+
+	/*
+	 * devs that were wrongly matched to a du and are not being
+	 * used in another correct du should be dropped.
+	 */
+	dm_list_iterate_items(devl, &wrong_devs) {
+		if (!get_du_for_dev(cmd, devl->dev)) {
+			log_debug("Drop incorrectly matched %s", dev_name(devl->dev));
+			cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
+			lvmcache_del_dev(devl->dev);
+		}
+	}
+
+	/*
+	 * Check for other problems for which we want to set *device_ids_invalid,
+	 * even if we don't have a way to fix them right here.  In particular,
+	 * issues that may be fixed shortly by device_ids_find_renamed_devs.
+	 *
+	 * The device_ids_invalid flag is only used to tell the caller not
+	 * to write hints, which could be based on invalid device info.
+	 * (There may be a better way to deal with that then returning
+	 * this flag.)
+	 */
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (*device_ids_invalid)
+			break;
+
+		if (!du->idname || (du->idname[0] == '.'))
+			*device_ids_invalid = 1;
+
+		if ((du->idtype == DEV_ID_TYPE_DEVNAME) && !du->dev && du->pvid)
+			*device_ids_invalid = 1;
+	}
+
+	/* FIXME: for wrong devname cases, wait to write new until device_ids_find_renamed_devs? */
+
+	/*
+	 * try lock and device_ids_write(), the update is not required and will
+	 * be done by a subsequent command if it's not done here.
+	 */
+	if (update_file && noupdate) {
+		log_debug("device ids validate checked %d update disabled.", checked);
+	} else if (update_file) {
+		log_debug("device ids validate checked %d trying to update devices file.", checked);
+		_device_ids_update_try(cmd);
+	} else {
+		log_debug("device ids validate checked %d found no update is needed.", checked);
+	}
+}
+
+/*
+ * Devices with IDNAME=devname that are mistakenly included by filter-deviceid
+ * due to a devname change are fully scanned and added to lvmcache.
+ * device_ids_validate() catches this by seeing that the pvid on the device
+ * doesn't match what's in the devices file, and then excludes the dev, and
+ * drops the lvmcache info for the dev.  It would be nicer to catch the issue
+ * earlier, before the dev is fully scanned (and populated in lvmcache).  This
+ * could be done by checking the devices file for the pvid right after the dev
+ * header is read and before scanning more metadata.  label_scan could read the
+ * pvid from the pv_header and check it prior to calling _text_read().
+ * Currently it's _text_read() that first gets the pvid from the dev, and
+ * passes it to lvmcache_add() which sets it in dev->pvid.
+ *
+ * This function searches devs for missing PVIDs, and for those found
+ * updates the du structs (devices file entries) and writes an updated
+ * devices file.
+ *
+ * TODO: should we disable find_renamed_devs entirely when the command
+ * is using a non-system devices file?
+ */
+
+void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_list,
+				  int *search_count, int noupdate)
+{
+	struct device *dev;
+	struct dev_use *du;
+	struct dev_id *id;
+	struct dev_iter *iter;
+	struct device_list *devl;           /* holds struct device */
+	struct device_id_list *dil, *dil2;  /* holds struct device + pvid */
+	struct dm_list search_pvids;        /* list of device_id_list */
+	struct dm_list search_devs ;        /* list of device_list */
+	const char *devname;
+	int update_file = 0;
+	int other_idtype = 0;
+	int other_pvid = 0;
+	int no_pvid = 0;
+	int found = 0;
+	int not_found = 0;
+	int search_none;
+	int search_auto;
+
+	dm_list_init(&search_pvids);
+	dm_list_init(&search_devs);
+
+	if (!cmd->enable_devices_file)
+		return;
+
+	search_none = !strcmp(cmd->search_for_devnames, "none");
+	search_auto = !strcmp(cmd->search_for_devnames, "auto");
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		if (du->dev)
+			continue;
+		if (!du->pvid)
+			continue;
+		if (du->idtype != DEV_ID_TYPE_DEVNAME)
+			continue;
+		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil))))
+			continue;
+
+		if (!search_none) {
+			memcpy(dil->pvid, du->pvid, ID_LEN);
+			dm_list_add(&search_pvids, &dil->list);
+		}
+		log_debug("Search for PVID %s.", du->pvid);
+		if (search_count)
+			(*search_count)++;
+	}
+
+	if (dm_list_empty(&search_pvids))
+		return;
+
+	/*
+	 * A previous command searched for devnames and found nothing, so it
+	 * created the searched file to tell us not to bother.  Without this, a
+	 * device that's permanently detached (and identified by devname) would
+	 * cause every command to search for it.  If the detached device is
+	 * later attached, it will generate a pvscan, and pvscan will unlink
+	 * the searched file, so a subsequent lvm command will do the search
+	 * again.  In future perhaps we could add a policy to automatically
+	 * remove a devices file entry that's not been found for some time.
+	 */
+	if (_searched_devnames_exists(cmd)) {
+		log_debug("Search for PVIDs skipped for %s", _searched_file);
+		return;
+	}
+
+	/*
+	 * Now we want to look at devs on the system that were previously
+	 * rejected by filter-deviceid (based on a devname device id) to check
+	 * if the missing PVID is on a device with a new name.
+	 */
+	log_debug("Search for PVIDs filtering.");
+
+	/*
+	 * Initial list of devs to search, eliminating any that have already
+	 * been matched, or don't pass filters that do not read dev.  We do not
+	 * want to modify the command's existing filter chain (the persistent
+	 * filter), in the process of doing this search outside the deviceid
+	 * filter.
+	 */
+	if (!(iter = dev_iter_create(NULL, 0)))
+		return;
+	while ((dev = dev_iter_get(cmd, iter))) {
+		if (dev->flags & DEV_MATCHED_USE_ID)
+			continue;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "sysfs"))
+			continue;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "type"))
+			continue;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "usable"))
+			continue;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "mpath"))
+			continue;
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			continue;
+		devl->dev = dev;
+		dm_list_add(&search_devs, &devl->list);
+	}
+	dev_iter_destroy(iter);
+
+	log_debug("Search for PVIDs reading labels on %d devs.", dm_list_size(&search_devs));
+
+	/*
+	 * Read the dev to get the pvid, and run the filters that will use the
+	 * data that has been read to get the pvid.  Like above, we do not want
+	 * to modify the command's existing filter chain or the persistent
+	 * filter values.
+	 */
+	dm_list_iterate_items(devl, &search_devs) {
+		dev = devl->dev;
+
+		/*
+		 * We only need to check devs that would use ID_TYPE_DEVNAME
+		 * themselves as alternatives to the missing ID_TYPE_DEVNAME
+		 * entry. i.e. a ID_TYPE_DEVNAME entry would not appear on a
+		 * device that has a wwid and would use ID_TYPE_SYS_WWID.  So,
+		 * if a dev in the search_devs list has a proper/stable device
+		 * id (e.g. wwid, serial, loop, mpath), then we don't need to
+		 * read it to check for missing PVIDs.
+		 * 
+		 * search_for_devnames="all" means we should search every
+		 * device, so we skip this optimization.
+		 *
+		 * TODO: in auto mode should we look in other non-system
+		 * devices files and skip any devs included in those?
+		 */
+		if (search_auto && _dev_has_stable_id(cmd, dev)) {
+			other_idtype++;
+			continue;
+		}
+
+		/*
+		 * Reads 4K from the start of the disk.
+		 * Looks for LVM header, and sets dev->pvid if the device is a PV.
+		 * Returns 0 if the dev has no lvm label or no PVID.
+		 * This loop may look at and skip many non-LVM devices.
+		 */
+		if (!label_read_pvid(dev)) {
+			no_pvid++;
+			continue;
+		}
+
+		/*
+		 * These filters will use the block of data from bcache that
+		 * was read label_read_pvid(), and may read other
+		 * data blocks beyond that.
+		 */
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "partitioned"))
+			goto next;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "signature"))
+			goto next;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "md"))
+			goto next;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, "fwraid"))
+			goto next;
+
+		/*
+		 * Check if the the PVID is one we are searching for.
+		 * Loop below looks at search_pvid entries that have dil->dev set.
+		 * This continues checking after all search_pvids entries have been
+		 * matched in order to check if the PVID is on duplicate devs.
+		 */
+		dm_list_iterate_items_safe(dil, dil2, &search_pvids) {
+			if (!memcmp(dil->pvid, dev->pvid, ID_LEN)) {
+				if (dil->dev) {
+					log_warn("WARNING: found PVID %s on multiple devices %s %s.",
+						 dil->pvid, dev_name(dil->dev), dev_name(dev));
+					log_warn("WARNING: duplicate PVIDs should be changed to be unique.");
+					log_warn("WARNING: use lvmdevices to select a device for PVID %s.", dil->pvid);
+					dm_list_del(&dil->list);
+				} else {
+					log_warn("Devices file PVID %s found on %s.", dil->pvid, dev_name(dev));
+					dil->dev = dev;
+				}
+			} else {
+				other_pvid++;
+			}
+		}
+         next:
+		label_scan_invalidate(dev);
+	}
+
+	log_debug("Search for PVIDs other_pvid %d no_pvid %d other_idtype %d.", other_pvid, no_pvid, other_idtype);
+
+	/*
+	 * The use_devices entries (repesenting the devices file) are
+	 * updated for the new devices on which the PVs reside.  The new
+	 * correct devs are set as dil->dev on search_pvids entries.
+	 *
+	 * The du/dev/id are set up and linked for the new devs.
+	 *
+	 * The command's full filter chain is updated for the new devs now that
+	 * filter-deviceid will pass.
+	 */
+	dm_list_iterate_items(dil, &search_pvids) {
+		char *dup_devname1, *dup_devname2, *dup_devname3;
+
+		if (!dil->dev) {
+			not_found++;
+			continue;
+		}
+		found++;
+
+		dev = dil->dev;
+		devname = dev_name(dev);
+
+		if (!(du = get_du_for_pvid(cmd, dil->pvid))) {
+			/* shouldn't happen */
+			continue;
+		}
+		if (du->idtype != DEV_ID_TYPE_DEVNAME) {
+			/* shouldn't happen */
+			continue;
+		}
+
+		dup_devname1 = strdup(devname);
+		dup_devname2 = strdup(devname);
+		dup_devname3 = strdup(devname);
+		id = zalloc(sizeof(struct dev_id));
+		if (!dup_devname1 || !dup_devname2 || !dup_devname3 || !id) {
+			if (dup_devname1)
+				free(dup_devname1);
+			if (dup_devname2)
+				free(dup_devname2);
+			if (dup_devname3)
+				free(dup_devname3);
+			if (id)
+				free(id);
+			stack;
+			continue;
+		}
+
+		log_warn("Devices file PVID %s updating IDNAME to %s.", dev->pvid, devname);
+
+		if (du->idname)
+			free(du->idname);
+		if (du->devname)
+			free(du->devname);
+		free_dids(&dev->ids);
+
+		du->idname = dup_devname1;
+		du->devname = dup_devname2;
+		id->idtype = DEV_ID_TYPE_DEVNAME;
+		id->idname = dup_devname3;
+		id->dev = dev;
+		du->dev = dev;
+		dev->id = id;
+		dev->flags |= DEV_MATCHED_USE_ID;
+		dm_list_add(&dev->ids, &id->list);
+		dev_get_partition_number(dev, &du->part);
+		update_file = 1;
+	}
+
+	dm_list_iterate_items(dil, &search_pvids) {
+		if (!dil->dev)
+			continue;
+		dev = dil->dev;
+
+		cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
+
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, NULL)) {
+			/* I don't think this would happen */
+			log_warn("WARNING: new device %s for PVID %s does not pass filter %s.",
+				 dev_name(dev), dil->pvid, dev_filtered_reason(dev));
+			du->dev = NULL;
+			dev->flags &= ~DEV_MATCHED_USE_ID;
+		}
+	}
+
+	/*
+	 * try lock and device_ids_write(), the update is not required and will
+	 * be done by a subsequent command if it's not done here.
+	 *
+	 * This command could have already done an earlier device_ids_update_try
+	 * (successfully or not) in device_ids_validate().
+	 */
+	if (update_file && noupdate) {
+		log_debug("Search for PVIDs update disabled");
+	} else if (update_file) {
+		log_debug("Search for PVIDs updating devices file");
+		_device_ids_update_try(cmd);
+	} else {
+		log_debug("Search for PVIDs found no updates");
+	}
+
+	/*
+	 * The entries in search_pvids with a dev set are the new devs found
+	 * for the PVIDs that we want to return to the caller in a device_list
+	 * format.
+	 */
+	dm_list_iterate_items(dil, &search_pvids) {
+		if (!dil->dev)
+			continue;
+		dev = dil->dev;
+
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			continue;
+		devl->dev = dev;
+		dm_list_add(dev_list, &devl->list);
+	}
+
+	/*
+	 * Prevent more devname searches by subsequent commands, in case the
+	 * pvids not found were from devices that are permanently detached.
+	 * If a new PV appears, pvscan will run and do unlink_searched_file.
+	 */
+	if (not_found && !found)
+		_touch_searched_devnames(cmd);
+}
+
+int devices_file_touch(struct cmd_context *cmd)
+{
+	struct stat buf;
+	char dirpath[PATH_MAX];
+	int fd;
+
+	if (dm_snprintf(dirpath, sizeof(dirpath), "%s/devices", cmd->system_dir) < 0) {
+		log_error("Failed to copy devices dir path");
+		return 0;
+	}
+
+	if (stat(dirpath, &buf)) {
+		log_error("Cannot create devices file, missing devices directory %s.", dirpath);
+		return 0;
+	}
+
+	fd = open(cmd->devices_file_path, O_CREAT, S_IRUSR | S_IWUSR);
+	if (fd < 0) {
+		log_debug("Failed to create %s %d", cmd->devices_file_path, errno);
+		return 0;
+	}
+	if (close(fd))
+		stack;
+	return 1;
+}
+
+int devices_file_exists(struct cmd_context *cmd)
+{
+	struct stat buf;
+
+	if (!cmd->devices_file_path[0])
+		return 0;
+
+	if (stat(cmd->devices_file_path, &buf))
+		return 0;
+
+	return 1;
+}
+
+/*
+ * If a command also uses the global lock, the global lock
+ * is acquired first, then the devices file is locked.
+ *
+ * There are three categories of commands in terms of
+ * reading/writing the devices file:
+ *
+ * 1. Commands that we know intend to modify the file,
+ *    lvmdevices --add|--del, vgimportdevices,
+ *    pvcreate/vgcreate/vgextend, pvchange --uuid,
+ *    vgimportclone.
+ *
+ * 2. Most other commands that do not modify the file.
+ *
+ * 3. Commands from 2 that find something to correct in
+ *    the devices file during device_ids_validate().
+ *    These corrections are not essential and can be
+ *    skipped, they will just be done by a subsequent
+ *    command if they are not done.
+ *
+ * Locking for each case:
+ *
+ * 1. lock ex, read file, write file, unlock
+ *
+ *    (In general, the command sets edit_devices_file or
+ *    create_edit_devices_file, then setup_devices() is called,
+ *    maybe directly, or by way of calling the traditional
+ *    process_each->label_scan->setup_devices.  setup_devices
+ *    sees {create}_edit_devices_file which causes it to do
+ *    lock_devices_file(EX) before creating/reading the file.)
+ *
+ * 2. lock sh, read file, unlock, (validate ok)
+ *
+ * 3. lock sh, read file, unlock, validate wants update,
+ *    lock ex (nonblocking - skip update if fails),
+ *    read file, check file is unchanged from prior read,
+ *    write file, unlock
+ */
+
+static int _lock_devices_file(struct cmd_context *cmd, int mode, int nonblock, int *held)
+{
+	const char *lock_dir;
+	const char *filename;
+	int fd;
+	int op = mode;
+	int ret;
+
+	if (!cmd->enable_devices_file || cmd->nolocking)
+		return 1;
+
+	_using_devices_file = 1;
+
+	if (_devices_file_locked == mode) {
+		/* can happen when a command holds an ex lock and does an update in device_ids_validate */
+		if (held)
+			*held = 1;
+		return 1;
+	}
+
+	if (_devices_file_locked) {
+		/* shouldn't happen */
+		log_warn("WARNING: devices file already locked %d", mode);
+		return 0;
+	}
+
+	if (!(lock_dir = find_config_tree_str(cmd, global_locking_dir_CFG, NULL)))
+		return_0;
+	if (!(filename = cmd->devicesfile ?: find_config_tree_str(cmd, devices_devicesfile_CFG, NULL)))
+		return_0;
+	if (dm_snprintf(_devices_lockfile, sizeof(_devices_lockfile), "%s/D_%s", lock_dir, filename) < 0)
+		return_0;
+
+	if (nonblock)
+		op |= LOCK_NB;
+
+	if (_devices_fd != -1) {
+		/* shouldn't happen */
+		log_warn("WARNING: devices file lock file already open %d", _devices_fd);
+		return 0;
+	}
+
+	fd = open(_devices_lockfile, O_CREAT|O_RDWR, S_IRUSR | S_IWUSR);
+	if (fd < 0) {
+		log_debug("lock_devices_file open errno %d", errno);
+		if (cmd->sysinit)
+			return 1;
+		return 0;
+	}
+
+	ret = flock(fd, op);
+	if (!ret) {
+		_devices_fd = fd;
+		_devices_file_locked = mode;
+		return 1;
+	}
+
+	log_debug("lock_devices_file flock errno %d", errno);
+
+	if (close(fd))
+		stack;
+	if (cmd->sysinit)
+		return 1;
+	return 0;
+}
+
+int lock_devices_file(struct cmd_context *cmd, int mode)
+{
+	return _lock_devices_file(cmd, mode, 0, NULL);
+}
+
+int lock_devices_file_try(struct cmd_context *cmd, int mode, int *held)
+{
+	return _lock_devices_file(cmd, mode, 1, held);
+}
+
+void unlock_devices_file(struct cmd_context *cmd)
+{
+	int ret;
+
+	if (!cmd->enable_devices_file || cmd->nolocking || !_using_devices_file)
+		return;
+
+	if (!_devices_file_locked && cmd->sysinit)
+		return;
+
+	if (_devices_fd == -1) {
+		/* shouldn't happen */
+		log_warn("WARNING: devices file unlock no fd");
+		return;
+	}
+
+	if (!_devices_file_locked)
+		log_warn("WARNING: devices file unlock not locked");
+
+	ret = flock(_devices_fd, LOCK_UN);
+	if (ret)
+		log_warn("WARNING: devices file unlock errno %d", errno);
+
+	_devices_file_locked = 0;
+
+	if (close(_devices_fd))
+		stack;
+	_devices_fd = -1;
+}
+
+void devices_file_init(struct cmd_context *cmd)
+{
+	dm_list_init(&cmd->use_devices);
+}
+
+void devices_file_exit(struct cmd_context *cmd)
+{
+	if (!cmd->enable_devices_file)
+		return;
+	free_dus(&cmd->use_devices);
+	if (_devices_fd == -1)
+		return;
+	unlock_devices_file(cmd);
+}
+
diff --git a/lib/device/device_id.h b/lib/device/device_id.h
new file mode 100644
index 000000000..1167373d9
--- /dev/null
+++ b/lib/device/device_id.h
@@ -0,0 +1,55 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#ifndef _LVM_DEVICE_ID_H
+#define _LVM_DEVICE_ID_H
+
+void free_du(struct dev_use *du);
+void free_dus(struct dm_list *list);
+void free_did(struct dev_id *did);
+void free_dids(struct dm_list *list);
+const char *idtype_to_str(uint16_t idtype);
+uint16_t idtype_from_str(const char *str);
+const char *dev_idtype_for_metadata(struct cmd_context *cmd, struct device *dev);
+const char *dev_idname_for_metadata(struct cmd_context *cmd, struct device *dev);
+int device_ids_use_devname(struct cmd_context *cmd);
+int device_ids_read(struct cmd_context *cmd);
+int device_ids_write(struct cmd_context *cmd);
+int device_id_add(struct cmd_context *cmd, struct device *dev, const char *pvid,
+                  const char *idtype_arg, const char *id_arg);
+void device_id_pvremove(struct cmd_context *cmd, struct device *dev);
+void device_ids_match(struct cmd_context *cmd);
+int device_ids_match_dev(struct cmd_context *cmd, struct device *dev);
+void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs, int *device_ids_invalid, int noupdate);
+int device_ids_version_unchanged(struct cmd_context *cmd);
+void device_ids_find_renamed_devs(struct cmd_context *cmd, struct dm_list *dev_list, int *search_count, int noupdate);
+const char *device_id_system_read(struct cmd_context *cmd, struct device *dev, uint16_t idtype);
+
+struct dev_use *get_du_for_dev(struct cmd_context *cmd, struct device *dev);
+struct dev_use *get_du_for_pvid(struct cmd_context *cmd, const char *pvid);
+
+char *devices_file_version(void);
+int devices_file_exists(struct cmd_context *cmd);
+int devices_file_touch(struct cmd_context *cmd);
+int lock_devices_file(struct cmd_context *cmd, int mode);
+int lock_devices_file_try(struct cmd_context *cmd, int mode, int *held);
+void unlock_devices_file(struct cmd_context *cmd);
+
+void devices_file_init(struct cmd_context *cmd);
+void devices_file_exit(struct cmd_context *cmd);
+
+void unlink_searched_devnames(struct cmd_context *cmd);
+
+#endif
diff --git a/lib/filters/filter-deviceid.c b/lib/filters/filter-deviceid.c
new file mode 100644
index 000000000..307e1d87c
--- /dev/null
+++ b/lib/filters/filter-deviceid.c
@@ -0,0 +1,69 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "base/memory/zalloc.h"
+#include "lib/misc/lib.h"
+#include "lib/filters/filter.h"
+#include "lib/commands/toolcontext.h"
+
+static int _passes_deviceid_filter(struct cmd_context *cmd, struct dev_filter *f, struct device *dev, const char *use_filter_name)
+{
+	dev->filtered_flags &= ~DEV_FILTERED_DEVICES_FILE;
+	dev->filtered_flags &= ~DEV_FILTERED_DEVICES_LIST;
+
+	if (!cmd->enable_devices_file && !cmd->enable_devices_list)
+		return 1;
+
+	if (cmd->filter_deviceid_skip)
+		return 1;
+
+	if (dev->flags & DEV_MATCHED_USE_ID)
+		return 1;
+
+	if (cmd->enable_devices_file)
+		dev->filtered_flags |= DEV_FILTERED_DEVICES_FILE;
+	else if (cmd->enable_devices_list)
+		dev->filtered_flags |= DEV_FILTERED_DEVICES_LIST;
+
+	log_debug_devs("%s: Skipping (deviceid)", dev_name(dev));
+	return 0;
+}
+
+static void _destroy_deviceid_filter(struct dev_filter *f)
+{
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying deviceid filter while in use %u times.", f->use_count);
+
+	free(f);
+}
+
+struct dev_filter *deviceid_filter_create(struct cmd_context *cmd)
+{
+	struct dev_filter *f;
+
+	if (!(f = zalloc(sizeof(struct dev_filter)))) {
+		log_error("deviceid filter allocation failed");
+		return NULL;
+	}
+
+	f->passes_filter = _passes_deviceid_filter;
+	f->destroy = _destroy_deviceid_filter;
+	f->use_count = 0;
+	f->name = "deviceid";
+
+	log_debug_devs("deviceid filter initialised.");
+
+	return f;
+}
diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index 7575981af..c6916983b 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -15,6 +15,7 @@
 
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
+#include "lib/commands/toolcontext.h"
 
 struct rfilter {
 	struct dm_pool *mem;
@@ -153,6 +154,12 @@ static int _accept_p(struct cmd_context *cmd, struct dev_filter *f, struct devic
 
 	dev->filtered_flags &= ~DEV_FILTERED_REGEX;
 
+	if (cmd->enable_devices_list)
+		return 1;
+
+	if (cmd->enable_devices_file && !cmd->filter_regex_with_devices_file)
+		return 1;
+
 	dm_list_iterate_items(sl, &dev->aliases) {
 		m = dm_regex_match(rf->engine, sl->str);
 
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index bfd045be5..bd4293090 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -30,6 +30,7 @@ struct dev_filter *partitioned_filter_create(struct dev_types *dt);
 struct dev_filter *persistent_filter_create(struct dev_types *dt, struct dev_filter *f);
 struct dev_filter *sysfs_filter_create(void);
 struct dev_filter *signature_filter_create(struct dev_types *dt);
+struct dev_filter *deviceid_filter_create(struct cmd_context *cmd);
 
 struct dev_filter *internal_filter_create(void);
 int internal_filter_allow(struct dm_pool *mem, struct device *dev);
@@ -63,5 +64,7 @@ struct dev_filter *usable_filter_create(struct cmd_context *cmd, struct dev_type
 #define DEV_FILTERED_DEVTYPE		0x00000100
 #define DEV_FILTERED_MINSIZE		0x00000200
 #define DEV_FILTERED_UNUSABLE		0x00000400
+#define DEV_FILTERED_DEVICES_FILE	0x00000800
+#define DEV_FILTERED_DEVICES_LIST	0x00001000
 
 #endif 	/* _LVM_FILTER_H */
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index b5e987e01..33844a2fd 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -23,6 +23,7 @@
 #include "lib/metadata/segtype.h"
 #include "lib/format_text/text_export.h"
 #include "lib/commands/toolcontext.h"
+#include "lib/device/device_id.h"
 #include "libdaemon/client/config-util.h"
 
 #include <stdarg.h>
@@ -527,6 +528,7 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 	struct physical_volume *pv;
 	char buffer[PATH_MAX * 2];
 	const char *name;
+	const char *idtype, *idname;
 
 	outf(f, "physical_volumes {");
 	_inc_indent(f);
@@ -555,6 +557,13 @@ static int _print_pvs(struct formatter *f, struct volume_group *vg)
 			dm_escape_double_quotes(buffer, pv_dev_name(pv)));
 		outnl(f);
 
+		idtype = dev_idtype_for_metadata(vg->cmd, pv->dev);
+		idname = dev_idname_for_metadata(vg->cmd, pv->dev);
+		if (idtype && idname) {
+			outf(f, "device_id_type = \"%s\"", idtype);
+			outf(f, "device_id = \"%s\"", idname);
+		}
+
 		if (!_print_flag_config(f, pv->status, PV_FLAGS))
 			return_0;
 
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 2bdbfeea9..ee56502e1 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -188,7 +188,7 @@ static int _read_pv(struct cmd_context *cmd,
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	const struct dm_config_value *cv;
-	const char *device_hint;
+	const char *str;
 	uint64_t size, ba_start;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
@@ -233,11 +233,21 @@ static int _read_pv(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (dm_config_get_str(pvn, "device", &device_hint)) {
-		if (!(pv->device_hint = dm_pool_strdup(mem, device_hint)))
+	if (dm_config_get_str(pvn, "device", &str)) {
+		if (!(pv->device_hint = dm_pool_strdup(mem, str)))
 			log_error("Failed to allocate memory for device hint in read_pv.");
 	}
 
+	if (dm_config_get_str(pvn, "device_id", &str)) {
+		if (!(pv->device_id = dm_pool_strdup(mem, str)))
+			log_error("Failed to allocate memory for device_id in read_pv.");
+	}
+
+	if (dm_config_get_str(pvn, "device_id_type", &str)) {
+		if (!(pv->device_id_type = dm_pool_strdup(mem, str)))
+			log_error("Failed to allocate memory for device_id_type in read_pv.");
+	}
+
 	if (!_read_uint64(pvn, "pe_start", &pv->pe_start)) {
 		log_error("Couldn't read extent start value (pe_start) "
 			  "for physical volume.");
@@ -306,7 +316,7 @@ static int _read_pvsummary(struct cmd_context *cmd,
 {
 	struct physical_volume *pv;
 	struct pv_list *pvl;
-	const char *device_hint;
+	const char *str;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
 	    !(pvl->pv = dm_pool_zalloc(mem, sizeof(*pvl->pv))))
@@ -326,9 +336,19 @@ static int _read_pvsummary(struct cmd_context *cmd,
 	    !_read_uint64(pvn, "dev_size", &pv->size))
 		log_warn("Couldn't read dev size for physical volume.");
 
-	if (dm_config_get_str(pvn, "device", &device_hint)) {
-		if (!(pv->device_hint = dm_pool_strdup(mem, device_hint)))
-			log_error("Failed to allocate memory for device hint in read_pv.");
+	if (dm_config_get_str(pvn, "device", &str)) {
+		if (!(pv->device_hint = dm_pool_strdup(mem, str)))
+			log_error("Failed to allocate memory for device hint in read_pv_sum.");
+	}
+
+	if (dm_config_get_str(pvn, "device_id", &str)) {
+		if (!(pv->device_id = dm_pool_strdup(mem, str)))
+			log_error("Failed to allocate memory for device_id in read_pv_sum.");
+	}
+
+	if (dm_config_get_str(pvn, "device_id_type", &str)) {
+		if (!(pv->device_id_type = dm_pool_strdup(mem, str)))
+			log_error("Failed to allocate memory for device_id_type in read_pv_sum.");
 	}
 
 	dm_list_add(&vgsummary->pvsummaries, &pvl->list);
diff --git a/lib/label/hints.c b/lib/label/hints.c
index 4a51ec918..aed0ea2ff 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -145,6 +145,7 @@
 #include "lib/activate/activate.h"
 #include "lib/label/hints.h"
 #include "lib/device/dev-type.h"
+#include "lib/device/device_id.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -166,8 +167,10 @@ static const char *_newhints_file = DEFAULT_RUN_DIR "/newhints";
  * than they were built with.  Increase the minor number
  * when adding features that older lvm versions can just
  * ignore while continuing to use the other content.
+ *
+ * MAJOR 2: add devices_file
  */
-#define HINTS_VERSION_MAJOR 1
+#define HINTS_VERSION_MAJOR 2
 #define HINTS_VERSION_MINOR 1
 
 #define HINT_LINE_LEN (PATH_MAX + NAME_LEN + ID_LEN + 64)
@@ -712,8 +715,9 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 				break;
 			}
 
-			if (hv_major > HINTS_VERSION_MAJOR) {
-				log_debug("ignore hints with newer major version %d.%d", hv_major, hv_minor);
+			if (hv_major != HINTS_VERSION_MAJOR) {
+				log_debug("ignore hints with version %d.%d current %d.%d",
+					  hv_major, hv_minor, HINTS_VERSION_MAJOR, HINTS_VERSION_MINOR);
 				*needs_refresh = 1;
 				break;
 			}
@@ -758,6 +762,25 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 			continue;
 		}
 
+		keylen = strlen("devices_file:");
+		if (!strncmp(_hint_line, "devices_file:", keylen)) {
+			const char *df_hint = _hint_line + keylen;
+			const char *df_config = find_config_tree_str(cmd, devices_devicesfile_CFG, NULL);
+			/* when a devices file is not used, hints should have devices_file:. */
+			if (!cmd->enable_devices_file || !df_hint || !df_config) {
+				if (df_hint[0] != '.') {
+					log_debug("ignore hints with different devices_file: not enabled vs %s", df_hint);
+					*needs_refresh = 1;
+					break;
+				}
+			} else if (strcmp(df_hint, df_config)) {
+				log_debug("ignore hints with different devices_file: %s vs %s", df_hint, df_config);
+				*needs_refresh = 1;
+				break;
+			}
+			continue;
+		}
+
 		keylen = strlen("devs_hash:");
 		if (!strncmp(_hint_line, "devs_hash:", keylen)) {
 			if (sscanf(_hint_line + keylen, "%u %u", &read_hash, &read_count) != 2) {
@@ -827,8 +850,12 @@ static int _read_hint_file(struct cmd_context *cmd, struct dm_list *hints, int *
 	if (!(iter = dev_iter_create(NULL, 0)))
 		return 0;
 	while ((dev = dev_iter_get(cmd, iter))) {
+		if (cmd->enable_devices_file && !get_du_for_dev(cmd, dev))
+			continue;
+
 		if (!_dev_in_hint_hash(cmd, dev))
 			continue;
+
 		(void) dm_strncpy(devpath, dev_name(dev), sizeof(devpath));
 		calc_hash = calc_crc(calc_hash, (const uint8_t *)devpath, strlen(devpath));
 		calc_count++;
@@ -887,6 +914,7 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 	struct device *dev;
 	const char *vgname;
 	char *filter_str = NULL;
+	const char *config_devices_file = NULL;
 	uint32_t hash = INITIAL_CRC;
 	uint32_t count = 0;
 	time_t t;
@@ -947,6 +975,19 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 
 	fprintf(fp, "scan_lvs:%d\n", cmd->scan_lvs);
 
+	/*
+	 * Only associate hints with the default/system devices file.
+	 * If no default/system devices file is used, "." is set.
+	 * If we are using a devices file other than the config setting
+	 * (from --devicesfile), then we should not be using hints and
+	 * shouldn't get here.
+	 */
+	config_devices_file = find_config_tree_str(cmd, devices_devicesfile_CFG, NULL);
+	if (cmd->enable_devices_file && !cmd->devicesfile && config_devices_file)
+		fprintf(fp, "devices_file:%s\n", config_devices_file);
+	else
+		fprintf(fp, "devices_file:.\n");
+
 	/* 
 	 * iterate through all devs and write a line for each
 	 * dev flagged DEV_SCAN_FOUND_LABEL
@@ -964,6 +1005,9 @@ int write_hint_file(struct cmd_context *cmd, int newhints)
 	 * 2. add PVs to the hint file
 	 */
 	while ((dev = dev_iter_get(cmd, iter))) {
+		if (cmd->enable_devices_file && !get_du_for_dev(cmd, dev))
+			continue;
+
 		if (!_dev_in_hint_hash(cmd, dev)) {
 			if (dev->flags & DEV_SCAN_FOUND_LABEL) {
 				/* should never happen */
@@ -1328,7 +1372,7 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 	}
 
 	/*
-	 * couln't read file for some reason, not normal, just skip using hints
+	 * couldn't read file for some reason, not normal, just skip using hints
 	 */
 	if (!_read_hint_file(cmd, &hints_list, &needs_refresh)) {
 		log_debug("get_hints: read fail");
@@ -1353,7 +1397,6 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 		/* create new hints after scan */
 		*newhints = NEWHINTS_REFRESH;
 		return 0;
-
 	}
 	
 	/*
@@ -1385,8 +1428,8 @@ int get_hints(struct cmd_context *cmd, struct dm_list *hints_out, int *newhints,
 
 	_apply_hints(cmd, &hints_list, vgname, devs_in, devs_out);
 
-	log_debug("get_hints: applied using %d other %d",
-		  dm_list_size(devs_out), dm_list_size(devs_in));
+	log_debug("get_hints: applied using %d other %d vgname %s",
+		  dm_list_size(devs_out), dm_list_size(devs_in), vgname ?: "");
 
 	dm_list_splice(hints_out, &hints_list);
 
diff --git a/lib/label/label.c b/lib/label/label.c
index 0fc832c08..318cf4d6c 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -25,6 +25,7 @@
 #include "lib/label/hints.h"
 #include "lib/metadata/metadata.h"
 #include "lib/format_text/layout.h"
+#include "lib/device/device_id.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -805,16 +806,6 @@ static int _scan_list(struct cmd_context *cmd, struct dev_filter *f,
 			}
 		}
 
-		/*
-		 * This will search the system's /dev for new path names and
-		 * could help us reopen the device if it finds a new preferred
-		 * path name for this dev's major:minor.  It does that by
-		 * inserting a new preferred path name on dev->aliases.  open
-		 * uses the first name from that list.
-		 */
-		log_debug_devs("Scanning refreshing device paths.");
-		dev_cache_scan();
-
 		/* Put devs that failed to open back on the original list to retry. */
 		dm_list_splice(devs, &reopen_devs);
 		goto scan_more;
@@ -936,6 +927,12 @@ static void _prepare_open_file_limit(struct cmd_context *cmd, unsigned int num_d
 #endif
 }
 
+/*
+ * Currently the only caller is pvck which probably doesn't need
+ * deferred filters checked after the read... it wants to know if
+ * anything has the pvid, even a dev that might be filtered.
+ */
+
 int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev_out)
 {
 	char buf[LABEL_SIZE] __attribute__((aligned(8)));
@@ -948,7 +945,20 @@ int label_scan_for_pvid(struct cmd_context *cmd, char *pvid, struct device **dev
 
 	dm_list_init(&devs);
 
-	dev_cache_scan();
+	/*
+	 * Creates a list of available devices, does not open or read any,
+	 * and does not filter them.
+	 */
+	if (!setup_devices(cmd)) {
+		log_error("Failed to set up devices.");
+		return 0;
+	}
+
+	/*
+	 * Iterating over all available devices with cmd->filter filters
+	 * devices; those returned from dev_iter_get are the devs that
+	 * pass filters, and are those we can use.
+	 */
 
 	if (!(iter = dev_iter_create(cmd->filter, 0))) {
 		log_error("Scanning failed to get devices.");
@@ -1022,6 +1032,7 @@ int label_scan(struct cmd_context *cmd)
 	struct device_list *devl, *devl2;
 	struct device *dev;
 	uint64_t max_metadata_size_bytes;
+	int device_ids_invalid = 0;
 	int using_hints;
 	int create_hints = 0; /* NEWHINTS_NONE */
 
@@ -1038,12 +1049,17 @@ int label_scan(struct cmd_context *cmd)
 	}
 
 	/*
-	 * dev_cache_scan() creates a list of devices on the system
-	 * (saved in in dev-cache) which we can iterate through to
-	 * search for LVM devs.  The dev cache list either comes from
-	 * looking at dev nodes under /dev, or from udev.
+	 * Creates a list of available devices, does not open or read any,
+	 * and does not filter them.  The list of all available devices
+	 * is kept in "dev-cache", and comes from /dev entries or libudev.
+	 * The list of devs found here needs to be filtered to get the
+	 * list of devs we can use. The dev_iter calls using cmd->filter
+	 * are what filters the devs.
 	 */
-	dev_cache_scan();
+	if (!setup_devices(cmd)) {
+		log_error("Failed to set up devices.");
+		return 0;
+	}
 
 	/*
 	 * If we know that there will be md components with an end
@@ -1196,15 +1212,26 @@ int label_scan(struct cmd_context *cmd)
 		if (!validate_hints(cmd, &hints_list)) {
 			log_debug("Will scan %d remaining devices", dm_list_size(&all_devs));
 			_scan_list(cmd, cmd->filter, &all_devs, 0, NULL);
+			/* scan_devs are the devs that have been scanned */
+			dm_list_splice(&scan_devs, &all_devs);
 			free_hints(&hints_list);
 			using_hints = 0;
 			create_hints = 0;
+			/* invalid hints means a new dev probably appeared and
+			   we should search for any missing pvids again. */
+			unlink_searched_devnames(cmd);
 		} else {
 			/* The hints may be used by another device iteration. */
 			dm_list_splice(&cmd->hints, &hints_list);
 		}
 	}
 
+	/*
+	 * Check if the devices_file content is up to date and
+	 * if not update it.
+	 */
+	device_ids_validate(cmd, &scan_devs, &device_ids_invalid, 0);
+
 	dm_list_iterate_items_safe(devl, devl2, &all_devs) {
 		dm_list_del(&devl->list);
 		free(devl);
@@ -1239,7 +1266,7 @@ int label_scan(struct cmd_context *cmd)
 	 * (create_hints variable has NEWHINTS_X value which indicates
 	 * the reason for creating the new hints.)
 	 */
-	if (create_hints)
+	if (create_hints && !device_ids_invalid)
 		write_hint_file(cmd, create_hints);
 
 	return 1;
diff --git a/lib/label/label.h b/lib/label/label.h
index 78724c1ce..fae0f1bcc 100644
--- a/lib/label/label.h
+++ b/lib/label/label.h
@@ -112,7 +112,6 @@ void label_scan_invalidate(struct device *dev);
 void label_scan_invalidate_lv(struct cmd_context *cmd, struct logical_volume *lv);
 void label_scan_drop(struct cmd_context *cmd);
 void label_scan_destroy(struct cmd_context *cmd);
-void label_scan_confirm(struct device *dev);
 int label_scan_setup_bcache(void);
 int label_scan_open(struct device *dev);
 int label_scan_open_excl(struct device *dev);
diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index 1a76485c1..015cefafb 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -247,6 +247,13 @@ static int _process_poll_init(const struct cmd_context *cmd, const char *poll_ty
 		goto out_req;
 	}
 
+	if (parms->devicesfile[0] &&
+	    !(daemon_request_extend(req, LVMPD_PARM_DEVICESFILE " = %s",
+			            parms->devicesfile, NULL))) {
+		log_error("Failed to create %s request." , poll_type);
+		goto out_req;
+	}
+
 	rep = daemon_send(_lvmpolld, req);
 
 	if (rep.error) {
diff --git a/lib/lvmpolld/polldaemon.h b/lib/lvmpolld/polldaemon.h
index 17ef7cb44..40ce7a546 100644
--- a/lib/lvmpolld/polldaemon.h
+++ b/lib/lvmpolld/polldaemon.h
@@ -60,6 +60,7 @@ struct daemon_parms {
 	const char *progress_title;
 	uint64_t lv_type;
 	struct poll_functions *poll_fns;
+	char devicesfile[128];
 };
 
 int poll_daemon(struct cmd_context *cmd, unsigned background,
diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 9cebbac01..855d52594 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -52,6 +52,20 @@ char *pv_tags_dup(const struct physical_volume *pv)
 	return tags_format_and_copy(pv->vg->vgmem, &pv->tags);
 }
 
+char *pv_deviceid_dup(struct dm_pool *mem, const struct physical_volume *pv)
+{
+	if (!pv->device_id)
+		return NULL;
+	return dm_pool_strdup(mem, pv->device_id);
+}
+
+char *pv_deviceidtype_dup(struct dm_pool *mem, const struct physical_volume *pv)
+{
+	if (!pv->device_id_type)
+		return NULL;
+	return dm_pool_strdup(mem, pv->device_id_type);
+}
+
 const struct format_type *pv_format_type(const struct physical_volume *pv)
 {
 	return pv_field(pv, fmt);
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index efa13e04b..95525a41a 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -27,6 +27,8 @@ struct physical_volume {
 	struct id old_id;		/* Set during pvchange -u. */
 	struct device *dev;
 	const char *device_hint;	/* primary name last time metadata was written */
+	const char *device_id;
+	const char *device_id_type;
 	const struct format_type *fmt;
 	struct format_instance *fid;
 
@@ -77,6 +79,8 @@ char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv);
 const char *pv_dev_name(const struct physical_volume *pv);
 char *pv_uuid_dup(struct dm_pool *mem, const struct physical_volume *pv);
 char *pv_tags_dup(const struct physical_volume *pv);
+char *pv_deviceid_dup(struct dm_pool *mem, const struct physical_volume *pv);
+char *pv_deviceidtype_dup(struct dm_pool *mem, const struct physical_volume *pv);
 uint64_t pv_size(const struct physical_volume *pv);
 uint64_t pv_size_field(const struct physical_volume *pv);
 uint64_t pv_dev_size(const struct physical_volume *pv);
diff --git a/lib/report/columns.h b/lib/report/columns.h
index 426a32c50..8d2f7a993 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -206,6 +206,8 @@ FIELD(PVS, pv, SIZ, "BA Start", ba_start, 0, size64, pv_ba_start, "Offset to the
 FIELD(PVS, pv, SIZ, "BA Size", ba_size, 0, size64, pv_ba_size, "Size of PV Bootloader Area in current units.", 0)
 FIELD(PVS, pv, BIN, "PInUse", id, 0, pvinuse, pv_in_use, "Set if PV is used.", 0)
 FIELD(PVS, pv, BIN, "Duplicate", id, 0, pvduplicate, pv_duplicate, "Set if PV is an unchosen duplicate.", 0)
+FIELD(PVS, pv, STR, "DeviceID", id, 0, pvdeviceid, pv_device_id, "Device ID such as the WWID.", 0)
+FIELD(PVS, pv, STR, "DeviceIDType", id, 0, pvdeviceidtype, pv_device_id_type, "Type of device ID such as WWID.", 0)
 /*
  * End of PVS type fields
  */
diff --git a/lib/report/properties.c b/lib/report/properties.c
index c013152f2..82a6a7856 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -238,6 +238,10 @@ GET_PV_NUM_PROPERTY_FN(pv_ba_start, SECTOR_SIZE * pv->ba_start)
 #define _pv_ba_start_set prop_not_implemented_set
 GET_PV_NUM_PROPERTY_FN(pv_ba_size, SECTOR_SIZE * pv->ba_size)
 #define _pv_ba_size_set prop_not_implemented_set
+GET_PV_STR_PROPERTY_FN(pv_device_id, pv->device_id)
+#define _pv_device_id_set prop_not_implemented_set
+GET_PV_STR_PROPERTY_FN(pv_device_id_type, pv->device_id_type)
+#define _pv_device_id_type_set prop_not_implemented_set
 
 #define _pv_allocatable_set prop_not_implemented_set
 #define _pv_allocatable_get prop_not_implemented_get
diff --git a/lib/report/report.c b/lib/report/report.c
index 2f50a990c..80fae2147 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3511,6 +3511,42 @@ static int _pvduplicate_disp(struct dm_report *rh, struct dm_pool *mem,
 	return _binary_disp(rh, mem, field, duplicate, GET_FIRST_RESERVED_NAME(pv_duplicate_y), private);
 }
 
+static int _pvdeviceid_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	const struct physical_volume *pv = (const struct physical_volume *) data;
+	char *repstr;
+
+	if (!pv->device_id)
+		return _field_set_value(field, "", NULL);
+
+	if (!(repstr = pv_deviceid_dup(mem, pv))) {
+		log_error("Failed to allocate buffer.");
+		return 0;
+	}
+
+	return _field_set_value(field, repstr, NULL);
+}
+
+static int _pvdeviceidtype_disp(struct dm_report *rh, struct dm_pool *mem,
+			    struct dm_report_field *field,
+			    const void *data, void *private)
+{
+	const struct physical_volume *pv = (const struct physical_volume *) data;
+	char *repstr;
+
+	if (!pv->device_id_type)
+		return _field_set_value(field, "", NULL);
+
+	if (!(repstr = pv_deviceidtype_dup(mem, pv))) {
+		log_error("Failed to allocate buffer.");
+		return 0;
+	}
+
+	return _field_set_value(field, repstr, NULL);
+}
+
 static int _vgpermissions_disp(struct dm_report *rh, struct dm_pool *mem,
 			       struct dm_report_field *field,
 			       const void *data, void *private)
diff --git a/man/Makefile.in b/man/Makefile.in
index 114e92b2a..3d4569673 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -45,7 +45,7 @@ MAN8=lvm.8 lvmdump.8 lvm-fullreport.8 lvm-lvpoll.8 \
      vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
      vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
      vgrename.8 vgs.8 vgscan.8 vgsplit.8 \
-     lvmsar.8 lvmsadc.8 lvmdiskscan.8
+     lvmsar.8 lvmsadc.8 lvmdiskscan.8 lvmdevices.8 vgimportdevices.8
 MAN8SO=lvm-config.8 lvm-dumpconfig.8
 MAN8DM=dmsetup.8 dmstats.8
 MAN8CLUSTER=
diff --git a/man/lvm.8_main b/man/lvm.8_main
index 9816f5fb6..ba151e367 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -173,6 +173,9 @@ Make exported Volume Groups known to the system.
 .B vgimportclone
 Import and rename duplicated Volume Group (e.g. a hardware snapshot).
 .TP
+.B vgimportdevices
+Add PVs from a VG to the devices file.
+.TP
 .B vgmerge
 Merge two Volume Groups.
 .TP
@@ -218,6 +221,9 @@ Extend the size of a Logical Volume.
 Display the configuration information after
 loading \fBlvm.conf\fP(5) and any other configuration files.
 .TP
+.B lvmdevices
+Manage the devices file.
+.TP
 .B lvmdiskscan
 Scan for all devices visible to LVM2.
 .TP
diff --git a/man/lvmdevices.8_des b/man/lvmdevices.8_des
new file mode 100644
index 000000000..a04a66683
--- /dev/null
+++ b/man/lvmdevices.8_des
@@ -0,0 +1,62 @@
+The LVM devices file lists devices that lvm can use.  The default file is
+/etc/lvm/devices/system.devices, and the lvmdevices(8) command is used to
+add or remove device entries.  If the file does not exist, or if lvm.conf
+includes use_devicesfile=0, then lvm will not use a devices file.
+
+To use a device with lvm, add it to the devices file with the command
+lvmdevices --adddev, and to prevent lvm from seeing or using a device,
+remove it from the devices file with lvmdevices --deldev.  The
+vgimportdevices(8) command adds all PVs from a VG to the devices file,
+and updates the VG metadata to include device IDs of the PVs.
+
+Commands adding new devices to the devices file necessarily look outside
+the existing devices file to find the devices to add.  pvcreate, vgcreate,
+and vgextend also look outside the devices file to create new PVs and add
+them to the devices file.
+
+LVM records devices in the devices file using hardware-specific IDs, such
+as the WWID, and attempts to use subsystem-specific IDs for virtual device
+types (which also aim to be as unique and stable as possible.)
+These device IDs are also written in the VG metadata.  When no hardware or
+virtual ID is available, lvm falls back using the unstable device name as
+the device ID.  When devnames are used, lvm performs extra scanning to
+find devices if their devname changes, e.g. after reboot.
+
+When proper device IDs are used, an lvm command will not look at devices
+outside the devices file, but when devnames are used as a fallback, lvm
+will scan devices outside the devices file to locate PVs on renamed
+devices.  A config setting search_for_devnames can be used to control the
+scanning for renamed devname entries.
+
+Related to the devices file, the new command option --devices <devnames>
+allows a list of devices to be specified for the command to use,
+overriding the devices file.  The listed devices act as a sort of devices
+file in terms of limiting which devices lvm will see and use.  Devices
+that are not listed will appear to be missing to the lvm command.
+    
+Multiple devices files can be kept in /etc/lvm/devices, which allows lvm
+to be used with different sets of devices, e.g. system devices do not need
+to be exposed to a specific application, and the application can use lvm on
+its own devices that are not exposed to the system.  The option
+--devicesfile <filename> is used to select the devices file to use with the
+command.  Without the option set, the default system devices file is used.
+
+Setting --devicesfile "" causes lvm to not use a devices file.
+
+With no devices file, lvm will use any device on the system, and applies
+the filter to limit the full set of system devices.  With a devices file,
+the regex filter is not used, and the filter settings in lvm.conf or the
+command line are ignored.  The vgimportdevices command is one exception
+which does apply the regex filter when looking for a VG to import.
+
+If a devices file exists, lvm will use it, even if it's empty.  An empty
+devices file means lvm will see no devices.
+
+If the system devices file does not yet exist, the pvcreate or vgcreate
+commands will create it if they see no existing VGs on the system.
+lvmdevices --addev and vgimportdevices will always create a new devices file
+if it does not yet exist.
+
+It is recommended to use lvm commands to make changes to the devices file to
+ensure proper updates.
+
diff --git a/man/lvmdevices.8_end b/man/lvmdevices.8_end
new file mode 100644
index 000000000..e69de29bb
diff --git a/man/see_also.end b/man/see_also.end
index 505c1599a..4dc9b0ec0 100644
--- a/man/see_also.end
+++ b/man/see_also.end
@@ -3,6 +3,7 @@
 .BR lvm (8)
 .BR lvm.conf (5)
 .BR lvmconfig (8)
+.BR lvmdevices (8)
 
 .BR pvchange (8)
 .BR pvck (8)
@@ -25,6 +26,7 @@
 .BR vgextend (8)
 .BR vgimport (8)
 .BR vgimportclone (8)
+.BR vgimportdevices (8)
 .BR vgmerge (8)
 .BR vgmknodes (8)
 .BR vgreduce (8)
diff --git a/man/vgimportdevices.8_des b/man/vgimportdevices.8_des
new file mode 100644
index 000000000..7c2287cfd
--- /dev/null
+++ b/man/vgimportdevices.8_des
@@ -0,0 +1,11 @@
+vgimportdevices adds PVs from a VG to the devices file.  This is similar
+to using using lvmdevices --adddev to add each PV to the devices file
+individually.  vgimportdevices will also update the VG metadata to include
+the device IDs of each PV.  vgimportdevices will create a new devices file
+if none exists.
+
+When a devices file is used, the regex filter is ignored, except in the case
+of vgimportdevices which will apply the regex filter when looking for the VGs
+to import to the devices file.  Use vgimportdevices -a to import all VGs on a
+system to the devices file.
+
diff --git a/man/vgimportdevices.8_end b/man/vgimportdevices.8_end
new file mode 100644
index 000000000..e69de29bb
diff --git a/spec/packages.inc b/spec/packages.inc
index c0d37936f..71aaeea7a 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -41,6 +41,7 @@ fi
 %{_sbindir}/lvextend
 %{_sbindir}/lvm
 %{_sbindir}/lvmconfig
+%{_sbindir}/lvmdevices
 %{_sbindir}/lvmdiskscan
 %{_sbindir}/lvmdump
 %{_sbindir}/lvmsadc
@@ -71,6 +72,7 @@ fi
 %{_sbindir}/vgextend
 %{_sbindir}/vgimport
 %{_sbindir}/vgimportclone
+%{_sbindir}/vgimportdevices
 %{_sbindir}/vgmerge
 %{_sbindir}/vgmknodes
 %{_sbindir}/vgreduce
@@ -99,6 +101,7 @@ fi
  %{_mandir}/man8/lvm2-activation-generator.8.gz
 %endif
 %{_mandir}/man8/lvmconfig.8.gz
+%{_mandir}/man8/lvmdevices.8.gz
 %{_mandir}/man8/lvmdiskscan.8.gz
 %{_mandir}/man8/lvmdump.8.gz
 %{_mandir}/man8/lvm-fullreport.8.gz
@@ -130,6 +133,7 @@ fi
 %{_mandir}/man8/vgextend.8.gz
 %{_mandir}/man8/vgimport.8.gz
 %{_mandir}/man8/vgimportclone.8.gz
+%{_mandir}/man8/vgimportdevices.8.gz
 %{_mandir}/man8/vgmerge.8.gz
 %{_mandir}/man8/vgmknodes.8.gz
 %{_mandir}/man8/vgreduce.8.gz
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 11160e655..b26bc64a6 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -27,6 +27,7 @@ SOURCES =\
 	lvdisplay.c \
 	lvextend.c \
 	lvmcmdline.c \
+	lvmdevices.c \
 	lvmdiskscan.c \
 	lvpoll.c \
 	lvreduce.c \
@@ -58,6 +59,7 @@ SOURCES =\
 	vgextend.c \
 	vgimport.c \
 	vgimportclone.c \
+	vgimportdevices.c \
 	vgmerge.c \
 	vgmknodes.c \
 	vgreduce.c \
diff --git a/tools/args.h b/tools/args.h
index 3a7e5d488..ca8f9ec51 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -44,6 +44,15 @@ arg(addtag_ARG, '\0', "addtag", tag_VAL, ARG_GROUPABLE, 0,
     "Adds a tag to a PV, VG or LV. This option can be repeated to add\n"
     "multiple tags at once. See \\fBlvm\\fP(8) for information about tags.\n")
 
+arg(adddev_ARG, '\0', "adddev", pv_VAL, 0, 0,
+    "Add a device to the devices file.\n")
+arg(deldev_ARG, '\0', "deldev", pv_VAL, 0, 0,
+    "Remove a device from the devices file.\n")
+arg(addpvid_ARG, '\0', "addpvid", string_VAL, 0, 0,
+    "Find a device with the PVID and add the device to the devices file.\n")
+arg(delpvid_ARG, '\0', "delpvid", string_VAL, 0, 0,
+    "Remove a device with the PVID from the devices file.\n")
+
 arg(aligned_ARG, '\0', "aligned", 0, 0, 0,
     "Use with --separator to align the output columns\n")
 
@@ -132,6 +141,9 @@ arg(cachedevice_ARG, '\0', "cachedevice", pv_VAL, ARG_GROUPABLE, 0,
 arg(cachesize_ARG, '\0', "cachesize", sizemb_VAL, 0, 0,
     "The size of cache to use.\n")
 
+arg(check_ARG, '\0', "check", 0, 0, 0,
+    "Check the content of the devices file.\n")
+
 arg(commandprofile_ARG, '\0', "commandprofile", string_VAL, 0, 0,
     "The command profile to use for command configuration.\n"
     "See \\fBlvm.conf\\fP(5) for more information about profiles.\n")
@@ -205,6 +217,18 @@ arg(detachprofile_ARG, '\0', "detachprofile", 0, 0, 0,
     "Detaches a metadata profile from a VG or LV.\n"
     "See \\fBlvm.conf\\fP(5) for more information about profiles.\n")
 
+arg(devices_ARG, '\0', "devices", pv_VAL, ARG_GROUPABLE, 0,
+    "Devices that the command can use. This option can be repeated\n"
+    "or accepts a comma separated list of devices. This overrides\n"
+    "the devices file.\n")
+
+arg(devicesfile_ARG, '\0', "devicesfile", string_VAL, 0, 0,
+    "A file listing devices that LVM should use.\n"
+    "The file must exist in /etc/lvm/devices/ and is managed\n"
+    "with the lvmdevices(8) command.\n"
+    "This overrides the lvm.conf devices/devicesfile and\n"
+    "devices/use_devicesfile settings.\n")
+
 arg(discards_ARG, '\0', "discards", discards_VAL, 0, 0,
     "Specifies how the device-mapper thin pool layer in the kernel should\n"
     "handle discards.\n"
@@ -280,6 +304,9 @@ arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", 0, 0, 0,
     "and \\fBdiff\\fP types include unsupported settings in their output by default,\n"
     "all the other types ignore unsupported settings.\n")
 
+arg(importdevices_ARG, '\0', "importdevices", 0, 0, 0,
+    "Add devices to the devices file.\n")
+
 arg(labelsector_ARG, '\0', "labelsector", number_VAL, 0, 0,
     "By default the PV is labelled with an LVM2 identifier in its second\n"
     "sector (sector 1). This lets you use a different sector near the\n"
@@ -775,6 +802,9 @@ arg(uncache_ARG, '\0', "uncache", 0, 0, 0,
     "Separates a cache pool from a cache LV, and deletes the unused cache pool LV.\n"
     "Before the separation, the cache is flushed. Also see --splitcache.\n")
 
+arg(update_ARG, '\0', "update", 0, 0, 0,
+    "Update the content of the devices file.\n")
+
 arg(cachepolicy_ARG, '\0', "cachepolicy", string_VAL, 0, 0,
     "Specifies the cache policy for a cache LV.\n"
     "See \\fBlvmcache\\fP(7) for more information.\n")
diff --git a/tools/command-lines.in b/tools/command-lines.in
index d6fd0e304..621731174 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -188,7 +188,7 @@
 #
 OO_ALL: --commandprofile String, --config String, --debug,
 --driverloaded Bool, --help, --nolocking, --lockopt String, --longhelp, --profile String, --quiet,
---verbose, --version, --yes, --test
+--verbose, --version, --yes, --test, --devicesfile String, --devices PV
 
 #
 # options for pvs, lvs, vgs, fullreport
@@ -1388,6 +1388,36 @@ ID: lvmconfig_general
 
 ---
 
+lvmdevices
+ID: lvmdevices_list
+DESC: Print devices in the devices file.
+
+lvmdevices --check
+ID: lvmdevices_check
+DESC: Check the devices file and report incorrect values.
+
+lvmdevices --update
+ID: lvmdevices_update
+DESC: Update the devices file to fix incorrect values.
+
+lvmdevices --adddev PV
+ID: lvmdevices_edit
+DESC: Add a device to the devices file.
+
+lvmdevices --deldev PV
+ID: lvmdevices_edit
+DESC: Remove a device from the devices file.
+
+lvmdevices --addpvid String
+ID: lvmdevices_edit
+DESC: Find the device with the given PVID and add it to the devices file.
+
+lvmdevices --delpvid String
+ID: lvmdevices_edit
+DESC: Remove the devices file entry for the given PVID.
+
+---
+
 lvreduce --size NSizeMB LV
 OO: --autobackup Bool, --force, --nofsck, --noudevsync,
 --reportformat ReportFmt, --resizefs
@@ -1768,11 +1798,23 @@ DESC: Import all VGs.
 ---
 
 vgimportclone PV ...
-OO: --basevgname VG, --import
+OO: --basevgname VG, --import, --importdevices
 ID: vgimportclone_general
 
 ---
 
+vgimportdevices VG|Tag|Select ...
+OO: --select String, --foreign, --reportformat ReportFmt
+ID: vgimportdevices_some
+DESC: Add devices from specific VGs to the devices file.
+
+vgimportdevices --all
+OO: --foreign, --reportformat ReportFmt
+ID: vgimportdevices_all
+DESC: Add devices from all accessible VGs to the devices file.
+
+---
+
 vgmerge VG VG
 OO: --autobackup Bool, --list
 ID: vgmerge_general
diff --git a/tools/commands.h b/tools/commands.h
index ae1bf3934..b12e451f2 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -69,6 +69,10 @@ xx(lvmconfig,
    "Display and manipulate configuration information",
    PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
+xx(lvmdevices,
+   "Manage the devices file",
+   0)
+
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
    PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ALLOW_EXPORTED)
@@ -207,6 +211,10 @@ xx(vgimportclone,
    "Import a VG from cloned PVs",
    ALLOW_EXPORTED)
 
+xx(vgimportdevices,
+   "Add devices for a VG to the devices file.",
+   ALL_VGS_IS_DEFAULT | ALLOW_EXPORTED)
+
 xx(vgmerge,
    "Merge volume groups",
    0)
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 560c78a77..4e87f0cbf 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -17,8 +17,10 @@
 
 #include "lvm2cmdline.h"
 #include "lib/label/label.h"
+#include "lib/device/device_id.h"
 #include "lvm-version.h"
 #include "lib/locking/lvmlockd.h"
+#include "lib/datastruct/str_list.h"
 
 #include "stub.h"
 #include "lib/misc/last-path-component.h"
@@ -2388,10 +2390,35 @@ static void _apply_current_output_settings(struct cmd_context *cmd)
 	init_silent(cmd->current_settings.silent);
 }
 
+static int _read_devices_list(struct cmd_context *cmd)
+{
+	struct arg_value_group_list *group;
+	const char *names;
+	struct dm_list *names_list;
+
+	dm_list_iterate_items(group, &cmd->arg_value_groups) {
+		if (!grouped_arg_is_set(group->arg_values, devices_ARG))
+			continue;
+
+		if (!(names = (char *)grouped_arg_str_value(group->arg_values, devices_ARG, NULL)))
+			continue;
+
+		if (!strchr(names, ',')) {
+			if (!str_list_add(cmd->mem, &cmd->deviceslist, names))
+				return 0;
+		} else {
+			if ((names_list = str_to_str_list(cmd->mem, names, ",", 1)))
+				dm_list_splice(&cmd->deviceslist, names_list);
+		}
+	}
+	return 1;
+}
+
 static int _get_current_settings(struct cmd_context *cmd)
 {
 	const char *activation_mode;
 	const char *hint_mode;
+	const char *search_mode;
 
 	_get_current_output_settings_from_args(cmd);
 
@@ -2445,6 +2472,10 @@ static int _get_current_settings(struct cmd_context *cmd)
 	else
 		cmd->use_hints = 0;
 
+	/* The hints file is associated with the default/system devices file. */
+	if (arg_is_set(cmd, devicesfile_ARG) || arg_is_set(cmd, devices_ARG))
+		cmd->use_hints = 0;
+
 	if ((hint_mode = find_config_tree_str(cmd, devices_hints_CFG, NULL))) {
 		if (!strcmp(hint_mode, "none")) {
 			cmd->enable_hints = 0;
@@ -2488,6 +2519,44 @@ static int _get_current_settings(struct cmd_context *cmd)
 	cmd->record_historical_lvs = find_config_tree_bool(cmd, metadata_record_lvs_history_CFG, NULL) ?
 							  (arg_is_set(cmd, nohistory_ARG) ? 0 : 1) : 0;
 
+	if (!(search_mode = find_config_tree_str(cmd, devices_search_for_devnames_CFG, NULL)))
+		cmd->search_for_devnames = DEFAULT_SEARCH_FOR_DEVNAMES;
+	else {
+		if (!strcmp(search_mode, "none") || !strcmp(search_mode, "auto") || !strcmp(search_mode, "all"))
+			cmd->search_for_devnames = search_mode;
+		else {
+			log_warn("Ignoring unknown search_for_devnames setting, using %s.", DEFAULT_SEARCH_FOR_DEVNAMES);
+			cmd->search_for_devnames = DEFAULT_SEARCH_FOR_DEVNAMES;
+		}
+	}
+
+	if (arg_is_set(cmd, devicesfile_ARG)) {
+		const char *devices_file = arg_str_value(cmd, devicesfile_ARG, NULL);
+		if (devices_file && !strlen(devices_file)) {
+			cmd->devicesfile = "";
+		} else if (!devices_file || !validate_name(devices_file)) {
+			log_error("Invalid devices file name.");
+			return EINVALID_CMD_LINE;
+		} else if (!(cmd->devicesfile = dm_pool_strdup(cmd->libmem, devices_file))) {
+			log_error("Failed to copy devices file name.");
+			return EINVALID_CMD_LINE;
+		}
+	}
+
+	dm_list_init(&cmd->deviceslist);
+
+	if (arg_is_set(cmd, devices_ARG)) {
+		if (cmd->devicesfile && strlen(cmd->devicesfile)) {
+			log_error("A --devices list cannot be used with --devicesfile.");
+			return EINVALID_CMD_LINE;
+		}
+		cmd->enable_devices_list = 1;
+		if (!_read_devices_list(cmd)) {
+			log_error("Failed to read --devices args.");
+			return EINVALID_CMD_LINE;
+		}
+	}
+
 	/*
 	 * This is set to zero by process_each which wants to print errors
 	 * itself rather than having them printed in vg_read.
@@ -3110,7 +3179,7 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	if (cmd->nolocking || _cmd_no_meta_proc(cmd))
 		nolocking = 1;
 
-	if (arg_is_set(cmd, sysinit_ARG))
+	if ((cmd->sysinit = arg_is_set(cmd, sysinit_ARG)))
 		sysinit = 1;
 
 	if (arg_is_set(cmd, readonly_ARG))
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
new file mode 100644
index 000000000..84b8e8003
--- /dev/null
+++ b/tools/lvmdevices.c
@@ -0,0 +1,465 @@
+/*
+ * Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "tools.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/filters/filter.h"
+#include "lib/device/device_id.h"
+
+static void _search_devs_for_pvids(struct cmd_context *cmd, struct dm_list *search_pvids, struct dm_list *found_devs)
+{
+	struct dev_iter *iter;
+	struct device *dev;
+	struct device_list *devl, *devl2;
+	struct device_id_list *dil, *dil2;
+	struct dm_list devs;
+	int found;
+
+	dm_list_init(&devs);
+
+	/*
+	 * Create a list of all devices on the system, without applying
+	 * any filters, since we do not want filters to read any of the
+	 * devices yet.
+	 */
+	if (!(iter = dev_iter_create(NULL, 0)))
+		return;
+	while ((dev = dev_iter_get(cmd, iter))) {
+		/* Skip devs with a valid match to a du. */
+		if (get_du_for_dev(cmd, dev))
+			continue;
+
+		if (!(devl = dm_pool_zalloc(cmd->mem, sizeof(*devl))))
+			continue;
+		devl->dev = dev;
+		dm_list_add(&devs, &devl->list);
+	}
+	dev_iter_destroy(iter);
+
+	/*
+	 * Apply the filters that do not require reading the devices
+	 */
+	log_debug("Filtering devices (no data) for pvid search");
+	cmd->filter_nodata_only = 1;
+	cmd->filter_deviceid_skip = 1;
+	dm_list_iterate_items_safe(devl, devl2, &devs) {
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL))
+			dm_list_del(&devl->list);
+	}
+
+	/*
+	 * Read header from each dev to see if it has one of the pvids we're
+	 * searching for.
+	 */
+	dm_list_iterate_items_safe(devl, devl2, &devs) {
+		/* sets dev->pvid if an lvm label with pvid is found */
+		if (!label_read_pvid(devl->dev))
+			continue;
+
+		found = 0;
+		dm_list_iterate_items_safe(dil, dil2, search_pvids) {
+			if (!strcmp(devl->dev->pvid, dil->pvid)) {
+				dm_list_del(&devl->list);
+				dm_list_del(&dil->list);
+				dm_list_add(found_devs, &devl->list);
+				log_print("Found PVID %s on %s.", dil->pvid, dev_name(devl->dev));
+				found = 1;
+				break;
+			}
+		}
+		if (!found)
+			label_scan_invalidate(devl->dev);
+
+		/*
+		 * FIXME: search all devs in case pvid is duplicated on multiple devs.
+		 */
+		if (dm_list_empty(search_pvids))
+			break;
+	}
+
+	dm_list_iterate_items(dil, search_pvids)
+		log_error("PVID %s not found on any devices.", dil->pvid);
+
+	/*
+	 * Now that the device has been read, apply the filters again
+	 * which will now include filters that read data from the device.
+	 * N.B. we've already skipped devs that were excluded by the
+	 * no-data filters, so if the PVID exists on one of those devices
+	 * no warning is printed.
+	 */
+	log_debug("Filtering devices (with data) for pvid search");
+	cmd->filter_nodata_only = 0;
+	cmd->filter_deviceid_skip = 1;
+	dm_list_iterate_items_safe(devl, devl2, found_devs) {
+		dev = devl->dev;
+		cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, NULL)) {
+			log_warn("WARNING: PVID %s found on %s which is excluded by filter: %s",
+			 	  dev->pvid, dev_name(dev), dev_filtered_reason(dev));
+			dm_list_del(&devl->list);
+		}
+	}
+}
+
+int lvmdevices(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct dm_list search_pvids;
+	struct dm_list found_devs;
+	struct device_id_list *dil;
+	struct device_list *devl;
+	struct device *dev;
+	struct dev_use *du, *du2;
+	int changes = 0;
+
+	dm_list_init(&search_pvids);
+	dm_list_init(&found_devs);
+
+	if (!setup_devices_file(cmd))
+		return ECMD_FAILED;
+
+	if (!cmd->enable_devices_file) {
+		log_error("Devices file not enabled.");
+		return ECMD_FAILED;
+	}
+
+	if (arg_is_set(cmd, update_ARG) ||
+	    arg_is_set(cmd, adddev_ARG) || arg_is_set(cmd, deldev_ARG) ||
+	    arg_is_set(cmd, addpvid_ARG) || arg_is_set(cmd, delpvid_ARG)) {
+		if (!lock_devices_file(cmd, LOCK_EX)) {
+			log_error("Failed to lock the devices file to create.");
+			return ECMD_FAILED;
+		}
+		if (!devices_file_exists(cmd)) {
+			if (!devices_file_touch(cmd)) {
+				log_error("Failed to create the devices file.");
+				return ECMD_FAILED;
+			}
+		}
+
+		/*
+		 * The hint file is associated with the default/system devices file,
+		 * so don't clear hints when using a different --devicesfile.
+		 */
+		if (!cmd->devicesfile)
+			clear_hint_file(cmd);
+	} else {
+		if (!lock_devices_file(cmd, LOCK_SH)) {
+			log_error("Failed to lock the devices file.");
+			return ECMD_FAILED;
+		}
+		if (!devices_file_exists(cmd)) {
+			log_error("Devices file does not exist.");
+			return ECMD_FAILED;
+		}
+	}
+
+	if (!device_ids_read(cmd)) {
+		log_error("Failed to read the devices file.");
+		return ECMD_FAILED;
+	}
+	dev_cache_scan();
+	device_ids_match(cmd);
+
+	if (arg_is_set(cmd, check_ARG) || arg_is_set(cmd, update_ARG)) {
+		int search_count = 0;
+		int invalid = 0;
+
+		label_scan_setup_bcache();
+
+		dm_list_iterate_items(du, &cmd->use_devices) {
+			if (!du->dev)
+				continue;
+			dev = du->dev;
+
+			label_read_pvid(dev);
+
+			/*
+			 * label_read_pvid has read the first 4K of the device
+			 * so these filters should not for the most part need
+			 * to do any further reading of the device.
+			 *
+			 * We run the filters here for the first time in the
+			 * check|update command.  device_ids_validate() then
+			 * checks the result of this filtering (by checking the
+			 * "persistent" filter explicitly), and prints a warning
+			 * if a devices file entry does not pass the filters.
+			 * The !passes_filter here is log_debug instead of log_warn
+			 * to avoid repeating the same message as device_ids_validate.
+			 * (We could also print the warning here and then pass a
+			 * parameter to suppress the warning in device_ids_validate.)
+			 */
+			log_debug("Checking filters with data for %s", dev_name(dev));
+			if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, NULL)) {
+				log_debug("filter result: %s in devices file is excluded by filter: %s.",
+					  dev_name(dev), dev_filtered_reason(dev));
+			}
+		}
+
+		/*
+		 * Check that the pvid read from the lvm label matches the pvid
+		 * for this devices file entry.  Also print a warning if a dev
+		 * from use_devices does not pass the filters that have been
+		 * run just above.
+		 */
+		device_ids_validate(cmd, NULL, &invalid, 1);
+
+		/*
+		 * Find and fix any devname entries that have moved to a
+		 * renamed device.
+		 */
+		device_ids_find_renamed_devs(cmd, &found_devs, &search_count, 1);
+
+		if (search_count && !strcmp(cmd->search_for_devnames, "none"))
+			log_print("Not searching for missing devnames, search_for_devnames=\"none\".");
+
+		dm_list_iterate_items(du, &cmd->use_devices) {
+			if (du->dev)
+				label_scan_invalidate(du->dev);
+		}
+
+		/*
+		 * check du->part
+		 */
+		dm_list_iterate_items(du, &cmd->use_devices) {
+			int part = 0;
+			if (!du->dev)
+				continue;
+			dev = du->dev;
+
+			dev_get_partition_number(dev, &part);
+
+			if (part != du->part) {
+				log_warn("Device %s partition %u has incorrect PART in devices file (%u)",
+					 dev_name(dev), part, du->part);
+				du->part = part;
+				changes++;
+			}
+		}
+
+		if (arg_is_set(cmd, update_ARG)) {
+			if (invalid || !dm_list_empty(&found_devs)) {
+				if (!device_ids_write(cmd))
+					goto_bad;
+				log_print("Updated devices file to version %s", devices_file_version());
+			} else {
+				log_print("No update for devices file is needed.");
+			}
+		}
+		goto out;
+	}
+
+	if (arg_is_set(cmd, adddev_ARG)) {
+		const char *devname;
+
+		if (!(devname = arg_str_value(cmd, adddev_ARG, NULL)))
+			goto_bad;
+
+		/*
+		 * addev will add a device to devices_file even if that device
+		 * is excluded by filters.
+		 */
+
+		/*
+		 * No filter applied here (only the non-data filters would
+		 * be applied since we haven't read the device yet.
+		 */
+		if (!(dev = dev_cache_get(cmd, devname, NULL))) {
+			log_error("No device found for %s.", devname);
+			goto_bad;
+		}
+
+		/*
+		 * reads pvid from dev header, sets dev->pvid.
+		 * (it's ok if the device is not a PV and has no PVID)
+		 */
+		label_scan_setup_bcache();
+		label_read_pvid(dev);
+
+		/*
+		 * Allow filtered devices to be added to devices_file, but
+		 * check if it's excluded by filters to print a warning.
+		 * Since label_read_pvid has read the first 4K of the device,
+		 * the filters should not for the most part need to do any further
+		 * reading of the device.
+		 *
+		 * (This is the first time filters are being run, so we do
+		 * not need to wipe filters of any previous result that was
+		 * based on filter_deviceid_skip=0.)
+		 */
+		cmd->filter_deviceid_skip = 1;
+
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, NULL)) {
+			log_warn("WARNING: adding device %s that is excluded by filter: %s.",
+				 dev_name(dev), dev_filtered_reason(dev));
+		}
+
+		/* allow deviceidtype_ARG/deviceid_ARG ? */
+		if (!device_id_add(cmd, dev, dev->pvid, NULL, NULL))
+			goto_bad;
+		if (!device_ids_write(cmd))
+			goto_bad;
+		goto out;
+	}
+
+	if (arg_is_set(cmd, addpvid_ARG)) {
+		struct id id;
+		char pvid[ID_LEN+1] = { 0 };
+		const char *pvid_arg;
+
+		label_scan_setup_bcache();
+
+		/*
+		 * Iterate through all devs on the system, reading the
+		 * pvid of each to check if it has this pvid.
+		 * Devices that are excluded by no-data filters will not
+		 * be checked for the PVID.
+		 * addpvid will not add a device to devices_file if it's
+		 * excluded by filters.
+		 */
+
+		pvid_arg = arg_str_value(cmd, addpvid_ARG, NULL);
+		if (!id_read_format_try(&id, pvid_arg)) {
+			log_error("Invalid PVID.");
+			goto bad;
+		}
+		memcpy(pvid, &id.uuid, ID_LEN);
+
+		if ((du = get_du_for_pvid(cmd, pvid))) {
+			log_error("PVID already exists in devices file for %s.", dev_name(du->dev));
+			goto bad;
+		}
+
+		if (!(dil = dm_pool_zalloc(cmd->mem, sizeof(*dil))))
+			goto_bad;
+		memcpy(dil->pvid, &pvid, ID_LEN);
+		dm_list_add(&search_pvids, &dil->list);
+
+		_search_devs_for_pvids(cmd, &search_pvids, &found_devs);
+
+		if (dm_list_empty(&found_devs)) {
+			log_error("PVID %s not found on any devices.", pvid);
+			goto bad;
+		}
+		dm_list_iterate_items(devl, &found_devs) {
+			if (!device_id_add(cmd, devl->dev, devl->dev->pvid, NULL, NULL))
+				goto_bad;
+		}
+		if (!device_ids_write(cmd))
+			goto_bad;
+		goto out;
+	}
+
+	if (arg_is_set(cmd, deldev_ARG)) {
+		const char *devname;
+
+		if (!(devname = arg_str_value(cmd, deldev_ARG, NULL)))
+			goto_bad;
+
+		/*
+		 * No filter because we always want to allow removing a device
+		 * by name from the devices file.
+		 */
+		if (!(dev = dev_cache_get(cmd, devname, NULL))) {
+			log_error("No device found for %s.", devname);
+			goto bad;
+		}
+
+		/*
+		 * dev_cache_scan uses sysfs to check if an LV is using each dev
+		 * and sets this flag is so.
+		 */
+		if (dev->flags & DEV_USED_FOR_LV) {
+			if (!arg_count(cmd, yes_ARG) &&
+			    yes_no_prompt("Device %s is used by an active LV, continue to remove? ", devname) == 'n') {
+				log_error("Device not removed.");
+				goto bad;
+			}
+		}
+
+		if (!(du = get_du_for_dev(cmd, dev))) {
+			log_error("Device not found in devices file.");
+			goto bad;
+		}
+
+		dm_list_del(&du->list);
+		free_du(du);
+		device_ids_write(cmd);
+		goto out;
+	}
+
+	if (arg_is_set(cmd, delpvid_ARG)) {
+		struct id id;
+		char pvid[ID_LEN+1] = { 0 };
+		const char *pvid_arg;
+
+		pvid_arg = arg_str_value(cmd, delpvid_ARG, NULL);
+		if (!id_read_format_try(&id, pvid_arg)) {
+			log_error("Invalid PVID.");
+			goto bad;
+		}
+		memcpy(pvid, &id.uuid, ID_LEN);
+
+		if (!(du = get_du_for_pvid(cmd, pvid))) {
+			log_error("PVID not found in devices file.");
+			goto_bad;
+		}
+
+		dm_list_del(&du->list);
+
+		if ((du2 = get_du_for_pvid(cmd, pvid))) {
+			log_error("Multiple devices file entries for PVID %s (%s %s), remove by device name.",
+				  pvid, du->devname, du2->devname);
+			goto_bad;
+		}
+
+		if (du->devname && (du->devname[0] != '.')) {
+			if ((dev = dev_cache_get(cmd, du->devname, NULL)) &&
+			    (dev->flags & DEV_USED_FOR_LV)) {
+				if (!arg_count(cmd, yes_ARG) &&
+			    	    yes_no_prompt("Device %s is used by an active LV, continue to remove? ", du->devname) == 'n') {
+					log_error("Device not removed.");
+					goto bad;
+				}
+			}
+		}
+
+		free_du(du);
+		device_ids_write(cmd);
+		goto out;
+	}
+
+	/* If no options, print use_devices list */
+
+	dm_list_iterate_items(du, &cmd->use_devices) {
+		char part_buf[64] = { 0 };
+
+		if (du->part)
+			snprintf(part_buf, 63, " PART=%d", du->part);
+
+		log_print("Device %s IDTYPE=%s IDNAME=%s DEVNAME=%s PVID=%s%s",
+			  du->dev ? dev_name(du->dev) : "none",
+			  du->idtype ? idtype_to_str(du->idtype) : "none",
+			  du->idname ? du->idname : "none",
+			  du->devname ? du->devname : "none",
+			  du->pvid ? (char *)du->pvid : "none",
+			  part_buf);
+	}
+
+out:
+	return ECMD_PROCESSED;
+
+bad:
+	return ECMD_FAILED;
+}
+
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index b0294ebb3..d4e0be13e 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -670,6 +670,15 @@ static int _daemon_parms_init(struct cmd_context *cmd, struct daemon_parms *parm
 
 	parms->progress_display = parms->interval ? 1 : 0;
 
+	memset(parms->devicesfile, 0, sizeof(parms->devicesfile));
+	if (cmd->devicesfile) {
+		if (strlen(cmd->devicesfile) >= sizeof(parms->devicesfile)) {
+			log_error("devicefile name too long for lvmpolld");
+			return 0;
+		}
+		strcpy(parms->devicesfile, cmd->devicesfile);
+	}
+
 	return 1;
 }
 
diff --git a/tools/pvchange.c b/tools/pvchange.c
index dd72bf1bd..5e457a60b 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -26,6 +26,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	struct pvchange_params *params = (struct pvchange_params *) handle->custom_handle;
 	const char *pv_name = pv_dev_name(pv);
 	char uuid[64] __attribute__((aligned(8)));
+	struct dev_use *du = NULL;
 	unsigned done = 0;
 	int used;
 
@@ -147,6 +148,9 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 
 	if (arg_is_set(cmd, uuid_ARG)) {
 		/* --uuid: Change PV ID randomly */
+
+		du = get_du_for_pvid(cmd, pv->dev->pvid);
+
 		memcpy(&pv->old_id, &pv->id, sizeof(pv->id));
 		if (!id_create(&pv->id)) {
 			log_error("Failed to generate new random UUID for %s.",
@@ -184,6 +188,16 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 		goto bad;
 	}
 
+	if (du) {
+		if (du->pvid)
+			free(du->pvid);
+		if (!(du->pvid = strndup((char *)&pv->id, ID_LEN)))
+			log_error("Failed to set pvid for devices file.");
+		if (!device_ids_write(cmd))
+			log_warn("Failed to update devices file.");
+		unlock_devices_file(cmd);
+	}
+
 	log_print_unless_silent("Physical volume \"%s\" changed", pv_name);
 
 	params->done++;
@@ -210,6 +224,9 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		goto out;
 	}
 
+	if (arg_is_set(cmd, uuid_ARG))
+		cmd->edit_devices_file = 1;
+
 	if (!(handle = init_processing_handle(cmd, NULL))) {
 		log_error("Failed to initialize processing handle.");
 		ret = ECMD_FAILED;
diff --git a/tools/pvck.c b/tools/pvck.c
index c02ccb9f7..46ef03fb6 100644
--- a/tools/pvck.c
+++ b/tools/pvck.c
@@ -19,6 +19,7 @@
 #include "lib/format_text/layout.h"
 #include "lib/mm/xlate.h"
 #include "lib/misc/crc.h"
+#include "lib/device/device_id.h"
 
 #define ONE_MB_IN_BYTES 1048576
 
@@ -3037,6 +3038,11 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 
 		clear_hint_file(cmd);
 
+		if (!setup_device(cmd, pv_name)) {
+			log_error("Failed to set up device %s.", pv_name);
+			return ECMD_FAILED;
+		}
+
 		if (!(dev = dev_cache_get(cmd, pv_name, NULL))) {
 			log_error("Cannot use %s: %s.", pv_name, devname_error_reason(pv_name));
 			return ECMD_FAILED;
@@ -3044,13 +3050,23 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (arg_is_set(cmd, dump_ARG)) {
-		pv_name = argv[0];
+		struct stat sb;
 
-		dev = dev_cache_get(cmd, pv_name, NULL);
+		pv_name = argv[0];
 
-		if (!dev)
+		if (stat(pv_name, &sb) < 0) {
+			log_error("Cannot access %s.", pv_name);
+			return ECMD_FAILED;
+		}
+		if (S_ISREG(sb.st_mode))
 			def = get_devicefile(pv_name);
-
+		else if (S_ISBLK(sb.st_mode)) {
+			if (!setup_device(cmd, pv_name)) {
+				log_error("Failed to set up device %s.", pv_name);
+				return ECMD_FAILED;
+			}
+			dev = dev_cache_get(cmd, pv_name, NULL);
+		}
 		if (!dev && !def) {
 			log_error("Cannot use %s: %s.", pv_name, devname_error_reason(pv_name));
 			return ECMD_FAILED;
@@ -3073,6 +3089,19 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	if (dev) {
 		char buf[4096];
 
+		/*
+		 * Check nodata filters including device_id filter,
+		 * then clear the result so the full filter can be
+		 * checked after reading the dev.
+		 */
+		cmd->filter_nodata_only = 1;
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, dev, NULL)) {
+			log_error("Cannot use %s: %s.", pv_name, dev_filtered_reason(dev));
+			return ECMD_FAILED;
+		}
+		cmd->filter_nodata_only = 0;
+		cmd->filter->wipe(cmd, cmd->filter, dev, NULL);
+
 		/*
 		 * This buf is not used, but bcache data is used for subsequent
 		 * reads in the filters and by _read_bytes for other disk structs.
@@ -3155,6 +3184,11 @@ int pvck(struct cmd_context *cmd, int argc, char **argv)
 	 * but this is here to preserve the historical output.
 	 */
 
+	if (argc == 1)
+		setup_device(cmd, argv[0]);
+	else
+		setup_devices(cmd);
+
 	for (i = 0; i < argc; i++) {
 		pv_name = argv[i];
 
diff --git a/tools/pvcreate.c b/tools/pvcreate.c
index 29ae0fa2e..71eb060a3 100644
--- a/tools/pvcreate.c
+++ b/tools/pvcreate.c
@@ -142,6 +142,8 @@ int pvcreate(struct cmd_context *cmd, int argc, char **argv)
 
 	clear_hint_file(cmd);
 
+	cmd->create_edit_devices_file = 1;
+
 	lvmcache_label_scan(cmd);
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {
diff --git a/tools/pvscan.c b/tools/pvscan.c
index f7aaf8ab9..6ade29bfe 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1390,6 +1390,8 @@ static int _pvscan_cache_all(struct cmd_context *cmd, int argc, char **argv,
 	_online_files_remove(_vgs_online_dir);
 	_online_files_remove(_pvs_lookup_dir);
 
+	unlink_searched_devnames(cmd);
+
 	/*
 	 * pvscan --cache removes existing hints and recreates new ones.
 	 * We begin by clearing hints at the start of the command.
@@ -1443,6 +1445,7 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	struct dm_list pvscan_devs; /* struct device_list */
 	struct pvscan_arg *arg;
 	struct device_list *devl, *devl2;
+	int relax_deviceid_filter = 0;
 	int pv_count = 0;
 	int ret;
 
@@ -1451,7 +1454,10 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 
 	cmd->pvscan_cache_single = 1;
 
-	dev_cache_scan();
+	if (!setup_devices(cmd)) {
+		log_error("Failed to set up devices.");
+		return_0;
+	}
 
 	/*
 	 * Get list of args.  Do not use filters.
@@ -1490,11 +1496,27 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 
 	/*
 	 * Apply nodata filters.
-	 * bcache is not yet set up so no filters will do io.
+	 *
+	 * We want pvscan autoactivation to work when using a devices file
+	 * containing idtype=devname, in cases when the devname changes
+	 * after reboot.  To make this work, we have to relax the devices
+	 * file restrictions somewhat here in cases where the devices file
+	 * contains entries with idtype=devname: disable filter-deviceid
+	 * when applying the nodata filters here, and read the label header.
+	 * Once the label header is read, check if the label header pvid
+	 * is in the devices file, and ignore the device if it's not.
+	 * The downside of this is that pvscans from the system will read
+	 * devs belonging to other devices files.
+	 * Enable/disable this behavior with a config setting?
 	 */
-
+	 
 	log_debug("pvscan_cache_args: filter devs nodata");
 
+	if (cmd->enable_devices_file && device_ids_use_devname(cmd)) {
+		relax_deviceid_filter = 1;
+		cmd->filter_deviceid_skip = 1;
+	}
+
 	cmd->filter_nodata_only = 1;
 
 	dm_list_iterate_items_safe(devl, devl2, &pvscan_devs) {
@@ -1533,6 +1555,19 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 			continue;
 		}
 
+		/*
+		 * filter-deviceid is not being used because of unstable devnames,
+		 * so in place of that check if the pvid is in the devices file.
+		 */
+		if (relax_deviceid_filter) {
+			if (!get_du_for_pvid(cmd, devl->dev->pvid)) {
+				log_print("pvscan[%d] %s excluded by devices file (checking PVID).",
+					  getpid(), dev_name(devl->dev));
+				dm_list_del(&devl->list);
+				continue;
+			}
+		}
+
 		/* Applies all filters, including those that need data from dev. */
 		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, NULL)) {
 			log_print("pvscan[%d] %s excluded by filters: %s.", getpid(),
@@ -1541,6 +1576,9 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 		}
 	}
 
+	if (relax_deviceid_filter)
+		cmd->filter_deviceid_skip = 0;
+
 	if (dm_list_empty(&pvscan_devs))
 		return 1;
 
@@ -1564,8 +1602,10 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	 * cases where this detects a change that the other methods
 	 * of detecting invalid hints doesn't catch.
 	 */
-	if (pv_count)
+	if (pv_count) {
 		invalidate_hints(cmd);
+		unlink_searched_devnames(cmd);
+	}
 
 	return ret;
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index d9295bb82..5c9ccb6f2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -16,6 +16,7 @@
 #include "tools.h"
 #include "lib/format_text/format-text.h"
 #include "lib/label/hints.h"
+#include "lib/device/device_id.h"
 
 #include <sys/stat.h>
 #include <signal.h>
@@ -5301,13 +5302,20 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	 * going to rerun the filters and don't want to get the results saved
 	 * by the prior filtering.  The filtering in label scan will use full
 	 * md filter.
+	 *
+	 * We allow pvcreate to look outside devices file here to find
+	 * the target device, in case the user has not added the device
+	 * being pvcreated to the devices file.
 	 */
 	dm_list_iterate_items(devl, &scan_devs)
 		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
 
 	cmd->use_full_md_check = 1;
 
-	log_debug("Scanning and filtering device args.");
+	if (cmd->enable_devices_file)
+		cmd->filter_deviceid_skip = 1;
+
+	log_debug("Scanning and filtering device args (%u).", dm_list_size(&scan_devs));
 	label_scan_devs(cmd, cmd->filter, &scan_devs);
 
 	/*
@@ -5320,6 +5328,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 			dm_list_add(&pp->arg_fail, &pd->list);
 		}
 	}
+	cmd->filter_deviceid_skip = 0;
 
 	/*
 	 * Can the command continue if some specified devices were not found?
@@ -5529,6 +5538,9 @@ do_command:
 	dm_list_iterate_items(devl, &rescan_devs)
 		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
 
+	if (cmd->enable_devices_file)
+		cmd->filter_deviceid_skip = 1;
+
 	log_debug("Rescanning and filtering device args with exclusive open");
 	if (!label_scan_devs_excl(cmd, cmd->filter, &rescan_devs)) {
 		log_debug("Failed to rescan devs excl");
@@ -5542,6 +5554,7 @@ do_command:
 			dm_list_add(&pp->arg_fail, &pd->list);
 		}
 	}
+	cmd->filter_deviceid_skip = 0;
 
 	if (dm_list_empty(&pp->arg_process) && dm_list_empty(&remove_duplicates)) {
 		log_debug("No devices to process.");
@@ -5637,6 +5650,10 @@ do_command:
 				log_debug("Using existing orphan PV %s.", pv_dev_name(vgpvl->pv));
 				pvl->pv = vgpvl->pv;
 				dm_list_add(&pp->pvs, &pvl->list);
+
+				/* allow deviceidtype_ARG/deviceid_ARG ? */
+				device_id_add(cmd, pd->dev, (const char *)&pvl->pv->id.uuid, NULL, NULL);
+
 			} else {
 				log_error("Failed to find PV %s", pd->name);
 				dm_list_move(&pp->arg_fail, &pd->list);
@@ -5673,6 +5690,9 @@ do_command:
 			continue;
 		}
 
+		/* allow deviceidtype_ARG/deviceid_ARG ? */
+		device_id_add(cmd, pd->dev, (const char *)&pv->id.uuid, NULL, NULL);
+
 		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
 			    " available sectors.", pv_name, pv_size(pv));
 
@@ -5717,6 +5737,8 @@ do_command:
 			continue;
 		}
 
+		device_id_pvremove(cmd, pd->dev);
+
 		log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped.",
 					pd->name);
 	}
@@ -5733,10 +5755,15 @@ do_command:
 
 		lvmcache_del_dev_from_duplicates(pd->dev);
 
+		device_id_pvremove(cmd, pd->dev);
+
 		log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped.",
 					pd->name);
 	}
 
+	/* TODO: when vgcreate uses only existing PVs this doesn't change and can be skipped */
+	device_ids_write(cmd);
+
 	/*
 	 * Don't keep devs open excl in bcache because the excl will prevent
 	 * using that dev elsewhere.
diff --git a/tools/tools.h b/tools/tools.h
index a0be4bedb..efbe1f44c 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -29,6 +29,7 @@
 #include "lib/config/defaults.h"
 #include "lib/device/dev-cache.h"
 #include "lib/device/device.h"
+#include "lib/device/device_id.h"
 #include "lib/display/display.h"
 #include "errors.h"
 #include "lib/metadata/metadata-exported.h"
diff --git a/tools/vgcreate.c b/tools/vgcreate.c
index 09b6a6c95..73066e9a4 100644
--- a/tools/vgcreate.c
+++ b/tools/vgcreate.c
@@ -82,6 +82,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	cmd->create_edit_devices_file = 1;
+
 	lvmcache_label_scan(cmd);
 
 	if (lvmcache_vginfo_from_vgname(vp_new.vg_name, NULL)) {
@@ -100,6 +102,8 @@ int vgcreate(struct cmd_context *cmd, int argc, char **argv)
 		return_ECMD_FAILED;
 	}
 
+	unlock_devices_file(cmd);
+
 	if (!(vg = vg_create(cmd, vp_new.vg_name)))
 		goto_bad;
 
diff --git a/tools/vgextend.c b/tools/vgextend.c
index 52393340f..04d37f886 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -168,6 +168,8 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 
 	clear_hint_file(cmd);
 
+	cmd->edit_devices_file = 1;
+
 	lvmcache_label_scan(cmd);
 
 	if (!(handle = init_processing_handle(cmd, NULL))) {
@@ -182,6 +184,8 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
+	unlock_devices_file(cmd);
+
 	/*
 	 * It is always ok to add new PVs to a VG - even if there are
 	 * missing PVs.  No LVs are affected by this operation, but
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index ee1c28fae..58cae5fac 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -15,62 +15,39 @@
 #include "tools.h"
 #include "lib/cache/lvmcache.h"
 #include "lib/filters/filter.h"
+#include "lib/device/device_id.h"
 
 struct vgimportclone_params {
-	unsigned done;
-	unsigned total;
-
-	int import_vg;
-	int found_args;
-	struct dm_list arg_import;
+	struct dm_list new_devs;
 	const char *base_vgname;
 	const char *old_vgname;
 	const char *new_vgname;
+	unsigned import_devices:1;
+	unsigned import_vg:1;
 };
 
-struct vgimportclone_device {
-	struct dm_list list;
-	struct device *dev;
-	unsigned found_in_vg : 1;
-};
-
-static int _vgimportclone_pv_single(struct cmd_context *cmd, struct volume_group *vg,
-				    struct physical_volume *pv, struct processing_handle *handle)
+static struct device_list *_get_device_list(struct dm_list *list, struct device *dev)
 {
-	struct vgimportclone_params *vp = (struct vgimportclone_params *) handle->custom_handle;
-	struct vgimportclone_device *vd;
+	struct device_list *devl;
 
-	if (vg && is_orphan_vg(vg->name)) {
-		log_error("Cannot import clone of orphan PV %s.", dev_name(pv->dev));
-		return ECMD_FAILED;
-	}
-
-	if (!(vd = dm_pool_zalloc(cmd->mem, sizeof(*vd)))) {
-		log_error("alloc failed.");
-		return ECMD_FAILED;
+	dm_list_iterate_items(devl, list) {
+		if (devl->dev == dev)
+			return devl;
 	}
-
-	vd->dev = pv->dev;
-	dm_list_add(&vp->arg_import, &vd->list);
-
-	log_debug("vgimportclone dev %s VG %s found to import",
-		  dev_name(vd->dev), vg ? vg->name : "<none>");
-
-	vp->found_args++;
-
-	return ECMD_PROCESSED;
+	return NULL;
 }
 
-static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name,
-		                    struct volume_group *vg, struct processing_handle *handle)
+static int _update_vg(struct cmd_context *cmd, struct volume_group *vg,
+		      struct vgimportclone_params *vp)
 {
 	char uuid[64] __attribute__((aligned(8)));
-	struct vgimportclone_params *vp = (struct vgimportclone_params *) handle->custom_handle;
-	struct vgimportclone_device *vd;
 	struct pv_list *pvl, *new_pvl;
 	struct lv_list *lvl;
+	struct device_list *devl;
+	struct dm_list tmp_devs;
 	int devs_used_for_lv = 0;
-	int found;
+
+	dm_list_init(&tmp_devs);
 
 	if (vg_is_exported(vg) && !vp->import_vg) {
 		log_error("VG %s is exported, use the --import option.", vg->name);
@@ -88,6 +65,10 @@ static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name
 	 * that's being imported, so check DEV_USED_FOR_LV.
 	 */
 	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (is_missing_pv(pvl->pv) || !pvl->pv->dev) {
+			log_error("VG is missing a device.");
+			goto bad;
+		}
 		if (pvl->pv->dev->flags & DEV_USED_FOR_LV) {
 			log_error("Device %s has active LVs, deactivate first.", dev_name(pvl->pv->dev));
 			devs_used_for_lv++;
@@ -98,21 +79,14 @@ static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name
 		goto_bad;
 
 	/*
-	 * The arg_import list must match the PVs in VG.
+	 * The new_devs list must match the PVs in VG.
 	 */
 
 	dm_list_iterate_items(pvl, &vg->pvs) {
-		found = 0;
-
-		dm_list_iterate_items(vd, &vp->arg_import) {
-			if (pvl->pv->dev != vd->dev)
-				continue;
-			vd->found_in_vg = 1;
-			found = 1;
-			break;
-		}
-
-		if (!found) {
+		if ((devl = _get_device_list(&vp->new_devs, pvl->pv->dev))) {
+			dm_list_del(&devl->list);
+			dm_list_add(&tmp_devs, &devl->list);
+		} else {
 			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
 				goto_bad;
 
@@ -124,21 +98,21 @@ static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name
 		}
 	}
 
-	dm_list_iterate_items(vd, &vp->arg_import) {
-		if (!vd->found_in_vg) {
-			/* device arg is not in the VG. */
-			log_error("Device %s was not found in VG %s.", dev_name(vd->dev), vg->name);
-			log_error("The devices to import must match the devices in the VG.");
-			goto bad;
-		}
+	dm_list_iterate_items(devl, &vp->new_devs) {
+		/* device arg is not in the VG. */
+		log_error("Device %s was not found in VG %s.", dev_name(devl->dev), vg->name);
+		log_error("The devices to import must match the devices in the VG.");
+		goto bad;
 	}
 
+	dm_list_splice(&vp->new_devs, &tmp_devs);
+
 	/*
 	 * Write changes.
 	 */
 
 	if (!archive(vg))
-		return_ECMD_FAILED;
+		goto_bad;
 
 	if (vp->import_vg)
 		vg->status &= ~EXPORTED_VG;
@@ -175,6 +149,8 @@ static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name
 		if (!id_create(&new_pvl->pv->id))
 			goto_bad;
 
+		memcpy(&pvl->pv->dev->pvid, &new_pvl->pv->id.uuid, ID_LEN);
+
 		dm_list_add(&vg->pv_write_list, &new_pvl->list);
 	}
 
@@ -183,97 +159,258 @@ static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name
 		lvl->lv->lock_args = NULL;
 	}
 
+	/*
+	 * Add the device id before writing the vg so that the device id
+	 * will be included in the metadata.  The device file is written
+	 * (with these additions) at the end of the command.
+	 */
+	if (vp->import_devices) {
+		dm_list_iterate_items(devl, &vp->new_devs) {
+			if (!device_id_add(cmd, devl->dev, devl->dev->pvid, NULL, NULL)) {
+				log_error("Failed to add device id for %s.", dev_name(devl->dev));
+				goto bad;
+			}
+		}
+	}
+
 	if (!vg_write(vg) || !vg_commit(vg))
 		goto_bad;
 
-	return ECMD_PROCESSED;
+	return 1;
 bad:
-	return ECMD_FAILED;
+	return 0;
+}
+
+/*
+ * Create a list of devices that label_scan would scan excluding devs in
+ * new_devs.
+ */
+static int _get_other_devs(struct cmd_context *cmd, struct dm_list *new_devs, struct dm_list *other_devs)
+{
+	struct dev_iter *iter;
+	struct device *dev;
+	struct device_list *devl;
+
+	if (!(iter = dev_iter_create(cmd->filter, 0)))
+		return_0;
+
+	while ((dev = dev_iter_get(cmd, iter))) {
+		if (_get_device_list(new_devs, dev))
+			continue;
+		if (!(devl = malloc(sizeof(*devl))))
+			return_0;
+		devl->dev = dev;
+		dm_list_add(other_devs, &devl->list);
+	}
+
+	dev_iter_destroy(iter);
+	return 1;
 }
 
 int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 {
-	struct vgimportclone_params vp = { 0 };
-	struct processing_handle *handle = NULL;
-	struct dm_list vgnameids_on_system;     /* vgnameid_list */
+	struct vgimportclone_params vp;
+	struct dm_list vgnames;
 	struct vgnameid_list *vgnl;
-	struct vgimportclone_device *vd;
-	struct lvmcache_info *info;
+	struct device *dev;
+	struct device_list *devl;
+	struct dm_list other_devs;
+	struct volume_group *vg, *error_vg;
 	const char *vgname;
 	char base_vgname[NAME_LEN] = { 0 };
 	char tmp_vgname[NAME_LEN] = { 0 };
+	uint32_t lockd_state = 0;
+	uint32_t error_flags = 0;
 	unsigned int vgname_count;
 	int ret = ECMD_FAILED;
+	int i;
 
-	if (!argc) {
-		log_error("PV names required.");
-		return EINVALID_CMD_LINE;
-	}
-
-	dm_list_init(&vgnameids_on_system);
-	dm_list_init(&vp.arg_import);
+	dm_list_init(&vgnames);
+	dm_list_init(&other_devs);
 
 	set_pv_notify(cmd);
 
+	memset(&vp, 0, sizeof(vp));
+	dm_list_init(&vp.new_devs);
+	vp.import_devices = arg_is_set(cmd, importdevices_ARG);
 	vp.import_vg = arg_is_set(cmd, import_ARG);
 
-	if (!(handle = init_processing_handle(cmd, NULL))) {
-		log_error("Failed to initialize processing handle.");
+	if (!lock_global(cmd, "ex"))
 		return ECMD_FAILED;
-	}
-	handle->custom_handle = &vp;
 
-	if (!lock_global(cmd, "ex")) {
-		destroy_processing_handle(cmd, handle);
+	clear_hint_file(cmd);
+
+	cmd->edit_devices_file = 1;
+
+	if (!setup_devices(cmd)) {
+		log_error("Failed to set up devices.");
 		return ECMD_FAILED;
 	}
 
 	/*
-	 * Find the devices being imported which are named on the command line.
-	 * They may be in the list of unchosen duplicates.
+	 * When importing devices not in the devices file
+	 * we cannot use the device id filter when looking
+	 * for the devs.
+	 */
+	if (vp.import_devices) {
+		if (!cmd->enable_devices_file) {
+			log_print("Devices file not enabled, ignoring importdevices.");
+			vp.import_devices = 0;
+		} else if (!devices_file_exists(cmd)) {
+			log_print("Devices file does not exist, ignoring importdevices.");
+			vp.import_devices = 0;
+		} else {
+			cmd->filter_deviceid_skip = 1;
+		}
+	}
+
+	/*
+	 * For each device arg, get the dev from dev-cache.
+	 * Only apply nodata filters when getting the devs
+	 * from dev cache.  The data filters will be applied
+	 * next when label scan is done on them.
 	 */
+	cmd->filter_nodata_only = 1;
+
+	for (i = 0; i < argc; i++) {
+		if (!(dev = dev_cache_get(cmd, argv[i], cmd->filter))) {
+			/* FIXME: if filtered print which */
+			log_error("Failed to find device %s.", argv[i]);
+			goto out;
+		}
 
-	log_debug("Finding devices to import.");
-	cmd->cname->flags |= ENABLE_DUPLICATE_DEVS;
-	process_each_pv(cmd, argc, argv, NULL, 0, 0, handle, _vgimportclone_pv_single);
+		if (!(devl = malloc(sizeof(*devl))))
+			goto_out;
 
-	if (vp.found_args != argc) {
-		log_error("Failed to find all devices.");
-		goto out;
+		devl->dev = dev;
+		dm_list_add(&vp.new_devs, &devl->list);
 	}
 
 	/*
-	 * Find the VG name of the PVs being imported, save as old_vgname.
-	 * N.B. If vd->dev is a duplicate, then it may not match info->dev.
+	 * Clear the result of nodata filtering so all
+	 * filters will be applied in label_scan.
+	 */
+	dm_list_iterate_items(devl, &vp.new_devs)
+		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
+
+	/*
+	 * Scan lvm info from each new dev, and apply the filters
+	 * again, this time applying filters that use data.
 	 */
+	log_debug("scan new devs");
+
+	label_scan_setup_bcache();
+
+	cmd->filter_nodata_only = 0;
 
-	dm_list_iterate_items(vd, &vp.arg_import) {
-		if (!(info = lvmcache_info_from_pvid(vd->dev->pvid, NULL, 0))) {
-			log_error("Failed to find PVID for device %s in lvmcache.", dev_name(vd->dev));
+	label_scan_devs(cmd, cmd->filter, &vp.new_devs);
+
+	/*
+	 * Check if any new devs were excluded by filters
+	 * in label scan, where all filters were applied.
+	 * (incl those that need data.)
+	 */
+	dm_list_iterate_items(devl, &vp.new_devs) {
+		if (!cmd->filter->passes_filter(cmd, cmd->filter, devl->dev, "persistent")) {
+			/* FIXME: print which filter */
+			log_error("Device %s was excluded by filters.", dev_name(devl->dev));
 			goto out;
 		}
+	}
 
-		if (!(vgname = lvmcache_vgname_from_info(info))) {
-			log_error("Failed to find VG name for device %s in lvmcache.", dev_name(vd->dev));
+	/*
+	 * Look up vg info in lvmcache for each new_devs entry.  This info was
+	 * found by label scan.  Verify all the new devs are from the same vg.
+	 * The lvmcache at this point only reflects a label scan, not a vg_read
+	 * which would assign PV info's for PVs without metadata.  So this
+	 * check is incomplete, and the same vg for devs is verified again
+	 * later.
+	 */
+	dm_list_iterate_items(devl, &vp.new_devs) {
+		struct lvmcache_info *info;
+
+		if (!(info = lvmcache_info_from_pvid(devl->dev->pvid, devl->dev, 0))) {
+			log_error("Failed to find PVID for device %s.", dev_name(devl->dev));
 			goto out;
 		}
 
+		if (!(vgname = lvmcache_vgname_from_info(info))) {
+			/* The PV may not have metadata, this will be resolved in
+			   the process_each_vg/vg_read at the end. */
+			continue;
+		}
+
 		if (!vp.old_vgname) {
 			if (!(vp.old_vgname = dm_pool_strdup(cmd->mem, vgname)))
 				goto_out;
-		} else {
-			if (strcmp(vp.old_vgname, vgname)) {
-				log_error("Devices must be from the same VG.");
-				goto out;
-			}
+		} else if (strcmp(vp.old_vgname, vgname)) {
+			log_error("Devices must be from the same VG.");
+			goto out;
 		}
 	}
 
+	if (!vp.old_vgname) {
+		log_error("No VG found on devices.");
+		goto out;
+	}
+
+	/*
+	 * Get rid of lvmcache info from the new devs because we are going to
+	 * read the other devs next (which conflict with the new devs because
+	 * of the duplicated info.)
+	 */
+	dm_list_iterate_items(devl, &vp.new_devs)
+		label_scan_invalidate(devl->dev);
+	lvmcache_destroy(cmd, 1, 0);
+
+	/*
+	 * Now processing other devs instead of new devs, so return to using
+	 * the deviceid filter.  (wiping filters not needed since these other
+	 * devs have not been filtered yet.)
+	 */
+	cmd->filter_deviceid_skip = 0;
+
+	/*
+	 * Scan all other devs (devs that would normally be seen excluding new
+	 * devs).  This is necessary to check if the new vgname conflicts with
+	 * an existing vgname on other devices.  We don't need to actually
+	 * process any existing VGs, we only process the VG on the new devs
+	 * being imported after this.
+	 *
+	 * This only requires a label_scan of the other devs which is enough to
+	 * see what the other vgnames are.
+	 *
+	 * Only apply nodata filters when creating the other_devs list.
+	 * Then apply all filters when label_scan_devs processes the label.
+	 */
+
+	log_debug("get other devices");
+
+	cmd->filter_nodata_only = 1;
+
+	if (!_get_other_devs(cmd, &vp.new_devs, &other_devs))
+		goto_out;
+
+	log_debug("scan other devices");
+
+	cmd->filter_nodata_only = 0;
+
+	/*
+	 * Clear the result of nodata filtering so all
+	 * filters will be applied in label_scan.
+	 */
+	dm_list_iterate_items(devl, &other_devs)
+		cmd->filter->wipe(cmd, cmd->filter, devl->dev, NULL);
+
+	label_scan_devs(cmd, cmd->filter, &other_devs);
+
+	if (!lvmcache_get_vgnameids(cmd, &vgnames, NULL, 0))
+		goto_out;
+
 	/*
 	 * Pick a new VG name, save as new_vgname.  The new name begins with
 	 * the basevgname or old_vgname, plus a $i suffix, if necessary, to
-	 * make it unique.  This requires comparing the old_vgname with all the
-	 * VG names on the system.
+	 * make it unique.
 	 */
 
 	if (arg_is_set(cmd, basevgname_ARG)) {
@@ -296,11 +433,8 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 		vgname_count = 1;
 	}
 
-	if (!lvmcache_get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
-		goto_out;
-
 retry_name:
-	dm_list_iterate_items(vgnl, &vgnameids_on_system) {
+	dm_list_iterate_items(vgnl, &vgnames) {
 		if (!strcmp(vgnl->vg_name, tmp_vgname)) {
 			vgname_count++;
 			if (dm_snprintf(tmp_vgname, sizeof(tmp_vgname), "%s%u", base_vgname, vgname_count) < 0) {
@@ -315,42 +449,72 @@ retry_name:
 		goto_out;
 	log_debug("Using new VG name %s.", vp.new_vgname);
 
-	lvmcache_destroy(cmd, 1, 0);
-
 	/*
-	 * Create a device filter so that we are only working with the devices
-	 * in arg_import.  With the original devs hidden (that arg_import were
-	 * cloned from), we can read and write the cloned PVs and VG without
-	 * touching the original PVs/VG.
+	 * Get rid of lvmcache info from the other devs because we are going to
+	 * read the new devs again, now to update them.
 	 */
+	dm_list_iterate_items(devl, &other_devs)
+		label_scan_invalidate(devl->dev);
+	lvmcache_destroy(cmd, 1, 0);
 
-	init_internal_filtering(1);
-	dm_list_iterate_items(vd, &vp.arg_import)
-		internal_filter_allow(cmd->mem, vd->dev);
-	refresh_filters(cmd);
-
-	log_debug("Changing VG %s to %s.", vp.old_vgname, vp.new_vgname);
+	log_debug("import vg on new devices");
 
 	if (!lock_vol(cmd, vp.new_vgname, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for new VG name %s", vp.new_vgname);
 		goto out;
 	}
 
-	/*
-	 * Trying to lock the duplicated VG would conflict with the original,
-	 * and it's not needed because the new VG will be imported as a local VG.
-	 */
-	cmd->lockd_vg_disable = 1;
+	if (!lock_vol(cmd, vp.old_vgname, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for VG name %s", vp.old_vgname);
+		goto out;
+	}
 
-	clear_hint_file(cmd);
+	/* No filter used since these devs have already been filtered above. */
+	label_scan_devs_rw(cmd, NULL, &vp.new_devs);
 
-	ret = process_each_vg(cmd, 0, NULL, vp.old_vgname, NULL, READ_FOR_UPDATE, 0, handle, _vgimportclone_vg_single);
+	cmd->can_use_one_scan = 1;
+	cmd->include_exported_vgs = 1;
 
+	vg = vg_read(cmd, vp.old_vgname, NULL, READ_WITHOUT_LOCK | READ_FOR_UPDATE, lockd_state, &error_flags, &error_vg);
+	if (!vg) {
+		log_error("Failed to read VG %s from devices being imported.", vp.old_vgname);
+		unlock_vg(cmd, NULL, vp.old_vgname);
+		unlock_vg(cmd, NULL, vp.new_vgname);
+		goto out;
+	}
+
+	if (error_flags) {
+		log_error("Error reading VG %s from devices being imported.", vp.old_vgname);
+		release_vg(vg);
+		unlock_vg(cmd, NULL, vp.old_vgname);
+		unlock_vg(cmd, NULL, vp.new_vgname);
+		goto out;
+	}
+
+	if (!_update_vg(cmd, vg, &vp)) {
+		log_error("Failed to update VG on devices being imported.");
+		release_vg(vg);
+		unlock_vg(cmd, NULL, vp.old_vgname);
+		unlock_vg(cmd, NULL, vp.new_vgname);
+		goto out;
+	}
+
+	release_vg(vg);
+	unlock_vg(cmd, NULL, vp.old_vgname);
 	unlock_vg(cmd, NULL, vp.new_vgname);
-out:
-	internal_filter_clear();
-	init_internal_filtering(0);
-	destroy_processing_handle(cmd, handle);
 
+	/*
+	 * Should we be using device_ids_validate to check/fix other
+	 * devs in the devices file?
+	 */
+	if (vp.import_devices) {
+		if (!device_ids_write(cmd)) {
+			log_error("Failed to write devices file.");
+			goto out;
+		}
+	}
+	ret = ECMD_PROCESSED;
+out:
+	unlock_devices_file(cmd);
 	return ret;
 }
diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
new file mode 100644
index 000000000..b7b363369
--- /dev/null
+++ b/tools/vgimportdevices.c
@@ -0,0 +1,207 @@
+/*
+ * Copyright (C) 2020 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#include "tools.h"
+#include "lib/cache/lvmcache.h"
+#include "lib/filters/filter.h"
+#include "lib/device/device_id.h"
+
+struct vgimportdevices_params {
+	uint32_t added_devices;
+};
+
+static int _vgimportdevices_single(struct cmd_context *cmd,
+				   const char *vg_name,
+				   struct volume_group *vg,
+				   struct processing_handle *handle)
+{
+	struct vgimportdevices_params *vp = (struct vgimportdevices_params *) handle->custom_handle;
+	struct pv_list *pvl;
+	struct physical_volume *pv;
+	int update_vg = 1;
+	int updated_pvs = 0;
+	const char *idtypestr = NULL; /* deviceidtype_ARG ? */
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (is_missing_pv(pvl->pv) || !pvl->pv->dev) {
+			log_error("Not importing devices for VG %s with missing PV %32s.",
+				 vg->name, (const char *)&pvl->pv->id.uuid);
+			goto bad;
+		}
+	}
+
+	/*
+	 * We want to allow importing devices of foreign and shared 
+	 * VGs, but we do not want to update device_ids in those VGs.
+	 *
+	 * If --foreign is set, then foreign VGs will be passed
+	 * to this function; add devices but don't update vg.
+	 * shared VGs are passed to this function; add devices
+	 * and do not update.
+	 */
+	if (vg_is_foreign(vg) || vg_is_shared(vg))
+		update_vg = 0;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		pv = pvl->pv;
+
+		if (!idtypestr && pv->device_id_type)
+			idtypestr = pv->device_id_type;
+
+		device_id_add(cmd, pv->dev, (const char *)&pvl->pv->id.uuid, idtypestr, NULL);
+		vp->added_devices++;
+
+		/* We could skip update if the device_id has not changed. */
+
+		if (!update_vg)
+			continue;
+
+		updated_pvs++;
+	}
+
+	if (updated_pvs) {
+		if (!vg_write(vg) || !vg_commit(vg))
+			goto_bad;
+		backup(vg);
+	}
+
+	return ECMD_PROCESSED;
+bad:
+	return ECMD_FAILED;
+}
+
+/*
+ * This command always scans all devices on the system,
+ * any pre-existing devices_file does not limit the scope.
+ *
+ * This command adds the VG's devices to whichever
+ * devices_file is set in config or command line.
+ * If devices_file doesn't exist, it's created.
+ *
+ * If devices_file is "" then this file will scan all devices
+ * and show the devices that it would otherwise have added to
+ * the devices_file.  The VG is not updated with device_ids.
+ *
+ * This command updates the VG metadata to add device_ids
+ * (if the metadata is missing them), unless an option is
+ * set to skip that, e.g. --nodeviceidupdate?
+ *
+ * If the VG found has a foreign system ID then an error
+ * will be printed.  To import devices from a foreign VG:
+ * vgimportdevices --foreign -a
+ * vgimportdevices --foreign VG
+ *
+ * If there are duplicate VG names it will do nothing.
+ *
+ * If there are duplicate PVIDs related to VG it will do nothing,
+ * the user would need to add the PVs they want with lvmdevices --add.
+ *
+ * vgimportdevices -a (no vg arg) will import all accesible VGs.
+ */
+
+int vgimportdevices(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct vgimportdevices_params vp = { 0 };
+	struct processing_handle *handle;
+	int ret = ECMD_PROCESSED;
+
+	if (arg_is_set(cmd, foreign_ARG))
+		cmd->include_foreign_vgs = 1;
+
+	cmd->include_shared_vgs = 1;
+
+	/* So that we can warn about this. */
+	cmd->handles_missing_pvs = 1;
+
+	if (!lock_global(cmd, "ex"))
+		return ECMD_FAILED;
+
+	/*
+	 * Prepare devices file preemptively because the error path for this
+	 * case from process_each is not as clean.
+	 */
+	if (!setup_devices_file(cmd)) {
+		log_error("Failed to set up devices file.");
+		return ECMD_FAILED;
+	}
+	if (!cmd->enable_devices_file) {
+		log_error("Devices file not enabled.");
+		return ECMD_FAILED;
+	}
+	if (!devices_file_exists(cmd) && !devices_file_touch(cmd)) {
+		log_error("Failed to create devices file.");
+		return ECMD_FAILED;
+	}
+
+	/*
+	 * The hint file is associated with the default/system devices file,
+	 * so don't clear hints when using a different --devicesfile.
+	 */
+	if (!cmd->devicesfile)
+		clear_hint_file(cmd);
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		ret = ECMD_FAILED;
+		goto out;
+	}
+	handle->custom_handle = &vp;
+
+	/*
+	 * import is a case where we do not want to be limited by an existing
+	 * devices file because we want to search outside the devices file for
+	 * new devs to add to it, but we do want devices file entries on
+	 * use_devices so we can update and write out that list.
+	 *
+	 * Ususally when devices file is enabled, we use filter-deviceid and
+	 * skip filter-regex.  In this import case it's reversed, and we skip
+	 * filter-deviceid and use filter-regex.
+	 */
+	cmd->filter_deviceid_skip = 1;
+	cmd->filter_regex_with_devices_file = 1;
+	cmd->create_edit_devices_file = 1;
+
+	/*
+	 * For each VG:
+	 * device_id_add() each PV in the VG
+	 * update device_ids in the VG (potentially)
+	 *
+	 * process_each_vg->label_scan->setup_devices
+	 * setup_devices sees create_edit_devices_file is 1,
+	 * so it does lock_devices_file(EX), then it creates/reads
+	 * the devices file, then each device_id_add happens
+	 * above, and then device_ids_write happens below.
+	 */
+	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE,
+			      0, handle, _vgimportdevices_single);
+	if (ret == ECMD_FAILED)
+		goto out;
+
+	if (!vp.added_devices) {
+		log_print("No devices to add.");
+		goto out;
+	}
+
+	if (!device_ids_write(cmd)) {
+		log_print("Failed to update devices file.");
+		ret = ECMD_FAILED;
+		goto out;
+	}
+
+	log_print("Added %u devices to devices file.", vp.added_devices);
+out:
+	destroy_processing_handle(cmd, handle);
+	return ret;
+}
+


