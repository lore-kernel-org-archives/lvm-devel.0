From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 22 Jun 2016 18:13:24 +0000 (UTC)
Subject: master - vgimportclone: add native command
Message-ID: <20160622181324.C0DA36117A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ebd2758dab39bb70fd63d0d77314971f8bc9cbfd
Commit:        ebd2758dab39bb70fd63d0d77314971f8bc9cbfd
Parent:        dfc516f9bfd35ec36c60165bd319a9b0008764a3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 25 13:57:33 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 22 13:13:10 2016 -0500

vgimportclone: add native command

This is cleaner and more efficient than the script.
The args and usage are unchanged.
---
 lib/Makefile.in               |    1 +
 lib/commands/toolcontext.c    |    9 +-
 lib/filters/filter-internal.c |   81 +++++++++
 lib/filters/filter.h          |    4 +
 lib/metadata/metadata.c       |    3 +
 lib/misc/lvm-globals.c        |   11 ++
 lib/misc/lvm-globals.h        |    2 +
 scripts/Makefile.in           |    2 +-
 test/Makefile.in              |    3 +-
 tools/Makefile.in             |    1 +
 tools/args.h                  |    2 +
 tools/commands.h              |   15 ++
 tools/vgimportclone.c         |  363 +++++++++++++++++++++++++++++++++++++++++
 13 files changed, 493 insertions(+), 4 deletions(-)

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 467ef90..451d96d 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -76,6 +76,7 @@ SOURCES =\
 	filters/filter-partitioned.c \
 	filters/filter-type.c \
 	filters/filter-usable.c \
+	filters/filter-internal.c \
 	format_text/archive.c \
 	format_text/archiver.c \
 	format_text/export.c \
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 75f19c9..3ee9410 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -1053,7 +1053,7 @@ static int _init_dev_cache(struct cmd_context *cmd)
 	return 1;
 }
 
-#define MAX_FILTERS 8
+#define MAX_FILTERS 9
 
 static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 {
@@ -1078,6 +1078,13 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 			nr_filt++;
 	}
 
+	/* internal filter used by command processing. */
+	if (!(filters[nr_filt] = internal_filter_create())) {
+		log_error("Failed to create internal device filter");
+		goto bad;
+	}
+	nr_filt++;
+
 	/* global regex filter. Optional. */
 	if ((cn = find_config_tree_node(cmd, devices_global_filter_CFG, NULL))) {
 		if (!(filters[nr_filt] = regex_filter_create(cn->v))) {
diff --git a/lib/filters/filter-internal.c b/lib/filters/filter-internal.c
new file mode 100644
index 0000000..1a58a37
--- /dev/null
+++ b/lib/filters/filter-internal.c
@@ -0,0 +1,81 @@
+/*
+ * Copyright (C) 2006 Red Hat, Inc. All rights reserved.
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
+#include "lib.h"
+#include "filter.h"
+
+static DM_LIST_INIT(_allow_devs);
+
+int internal_filter_allow(struct dm_pool *mem, struct device *dev)
+{
+	struct device_list *devl;
+
+	if (!(devl = dm_pool_alloc(mem, sizeof(*devl)))) {
+		log_error("device_list element allocation failed");
+		return 0;
+	}
+	devl->dev = dev;
+
+	dm_list_add(&_allow_devs, &devl->list);
+	return 1;
+}
+
+void internal_filter_clear(void)
+{
+	dm_list_init(&_allow_devs);
+}
+
+static int _passes_internal(struct dev_filter *f __attribute__((unused)),
+			    struct device *dev)
+{
+	struct device_list *devl;
+
+	if (!internal_filtering())
+		return 1;
+	
+	dm_list_iterate_items(devl, &_allow_devs) {
+		if (devl->dev == dev)
+			return 1;
+	}
+	
+	log_debug_devs("%s: Skipping for internal filtering.", dev_name(dev));
+	return 0;
+}
+
+static void _destroy(struct dev_filter *f)
+{
+	if (f->use_count)
+		log_error(INTERNAL_ERROR "Destroying internal filter while in use %u times.", f->use_count);
+
+	dm_free(f);
+}
+
+struct dev_filter *internal_filter_create(void)
+{
+	struct dev_filter *f;
+
+	if (!(f = dm_zalloc(sizeof(*f)))) {
+		log_error("md filter allocation failed");
+		return NULL;
+	}
+
+	f->passes_filter = _passes_internal;
+	f->destroy = _destroy;
+	f->use_count = 0;
+
+	log_debug_devs("internal filter initialised.");
+
+	return f;
+}
+
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index ebd25e2..d75f6e1 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -32,6 +32,10 @@ struct dev_filter *persistent_filter_create(struct dev_types *dt,
 					    const char *file);
 struct dev_filter *sysfs_filter_create(void);
 
+struct dev_filter *internal_filter_create(void);
+int internal_filter_allow(struct dm_pool *mem, struct device *dev);
+void internal_filter_clear(void);
+
 /*
  * patterns must be an array of strings of the form:
  * [ra]<sep><regex><sep>, eg,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ea42fb7..9b1fd31 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3306,6 +3306,9 @@ static int _check_old_pv_ext_for_vg(struct volume_group *vg)
 		    !pvl->pv->fmt->ops->pv_needs_rewrite)
 			continue;
 
+		if (_pv_in_pv_list(pvl->pv, &vg->pv_write_list))
+			continue;
+
 		if (!pvl->pv->fmt->ops->pv_needs_rewrite(pvl->pv->fmt, pvl->pv,
 							 &pv_needs_rewrite))
 			return_0;
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index b7af353..9c78f3e 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -26,6 +26,7 @@ static int _verbose_level = VERBOSE_BASE_LEVEL;
 static int _silent = 0;
 static int _test = 0;
 static int _md_filtering = 0;
+static int _internal_filtering = 0;
 static int _fwraid_filtering = 0;
 static int _pvmove = 0;
 static int _full_scan_done = 0;	/* Restrict to one full scan during each cmd */
@@ -79,6 +80,11 @@ void init_md_filtering(int level)
 	_md_filtering = level;
 }
 
+void init_internal_filtering(int level)
+{
+	_internal_filtering = level;
+}
+
 void init_fwraid_filtering(int level)
 {
 	_fwraid_filtering = level;
@@ -242,6 +248,11 @@ int md_filtering(void)
 	return _md_filtering;
 }
 
+int internal_filtering(void)
+{
+	return _internal_filtering;
+}
+
 int fwraid_filtering(void)
 {
 	return _fwraid_filtering;
diff --git a/lib/misc/lvm-globals.h b/lib/misc/lvm-globals.h
index 77c01b4..14a7d43 100644
--- a/lib/misc/lvm-globals.h
+++ b/lib/misc/lvm-globals.h
@@ -26,6 +26,7 @@ void init_verbose(int level);
 void init_silent(int silent);
 void init_test(int level);
 void init_md_filtering(int level);
+void init_internal_filtering(int level);
 void init_fwraid_filtering(int level);
 void init_pvmove(int level);
 void init_full_scan_done(int level);
@@ -60,6 +61,7 @@ void set_sysfs_dir_path(const char *path);
 
 int test_mode(void);
 int md_filtering(void);
+int internal_filtering(void);
 int fwraid_filtering(void);
 int pvmove_mode(void);
 int full_scan_done(void);
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 9c3d72d..e674239 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -31,7 +31,7 @@ endif
 	LVMLIBS = @LVM2APP_LIB@ -ldevmapper
 endif
 
-LVM_SCRIPTS = lvmdump.sh lvmconf.sh vgimportclone.sh
+LVM_SCRIPTS = lvmdump.sh lvmconf.sh
 DM_SCRIPTS =
 
 ifeq ("@FSADM@", "yes")
diff --git a/test/Makefile.in b/test/Makefile.in
index 59fcc96..f48d6ea 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -321,7 +321,6 @@ LIB = $(addprefix lib/, $(LIB_SHARED) $(LIB_LOCAL) $(LIB_NOT) $(LIB_LINK_NOT) $(
 	$(LN_S) -f $(abs_top_builddir)/tools/dmsetup lib/dmstats
 	$(LN_S) -f $(abs_top_srcdir)/conf/thin-performance.profile lib/
 	$(LN_S) -f $(abs_top_srcdir)/scripts/fsadm.sh lib/fsadm
-	$(LN_S) -f $(abs_top_srcdir)/scripts/vgimportclone.sh lib/vgimportclone
 	test "$(srcdir)" = . || for i in $(LIB_LVMLOCKD_CONF); do \
 		$(LN_S) -f $(abs_top_srcdir)/test/lib/$$i lib/; done
 	touch $@
@@ -333,7 +332,7 @@ endif
 
 CLEAN_TARGETS += .lib-dir-stamp .tests-stamp $(LIB) $(addprefix lib/,\
 	$(CMDS) clvmd dmeventd dmsetup dmstats lvmetad lvmpolld \
-	harness thin-performance.profile fsadm vgimportclone \
+	harness thin-performance.profile fsadm \
 	dm-version-expected version-expected \
 	paths-installed paths-installed-t paths-common paths-common-t)
 
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 8dfac7f..d93c31b 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -60,6 +60,7 @@ SOURCES =\
 	vgmerge.c \
 	vgmknodes.c \
 	lvpoll.c \
+	vgimportclone.c \
 	vgreduce.c \
 	vgremove.c \
 	vgrename.c \
diff --git a/tools/args.h b/tools/args.h
index 670d6a0..5902513 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -154,6 +154,7 @@ arg(autobackup_ARG, 'A', "autobackup", yes_no_arg, 0, 0)
 arg(activevolumegroups_ARG, 'A', "activevolumegroups", NULL, 0, 0)
 arg(background_ARG, 'b', "background", NULL, 0, 0)
 arg(backgroundfork_ARG, 'b', "background", NULL, 0, 0)
+arg(basevgname_ARG, 'n', "basevgname", string_arg, 0, 0)
 arg(blockdevice_ARG, 'b', "blockdevice", NULL, 0, 0)
 arg(chunksize_ARG, 'c', "chunksize", size_kb_arg, 0, 0)
 arg(clustered_ARG, 'c', "clustered", yes_no_arg, 0, 0)
@@ -170,6 +171,7 @@ arg(help_ARG, 'h', "help", NULL, 0, 0)
 arg(cache_ARG, 'H', "cache", NULL, 0, 0)
 arg(history_ARG, 'H', "history", NULL, 0, 0)
 arg(help2_ARG, '?', "", NULL, 0, 0)
+arg(import_ARG, 'i', "import", NULL, 0, 0)
 arg(interval_ARG, 'i', "interval", int_arg, 0, 0)
 arg(iop_version_ARG, 'i', "iop_version", NULL, 0, 0)
 arg(stripes_ARG, 'i', "stripes", int_arg, 0, 0)
diff --git a/tools/commands.h b/tools/commands.h
index c0b3f3b..ed86b7f 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1358,6 +1358,21 @@ xx(vgimport,
 
    all_ARG, force_ARG, reportformat_ARG, select_ARG, test_ARG)
 
+xx(vgimportclone,
+   "Import a VG from cloned PVs",
+   NO_LVMETAD_AUTOSCAN,
+   "vgimportclone\n"
+   "\t[-d|--debug]\n"
+   "\t[-h|--help]\n"
+   "\t[-i|--import]\n"
+   "\t[-n|--basevgname]\n"
+   "\t[-t|--test]\n"
+   "\t[-v|--verbose]\n"
+   "\t[--version]\n"
+   "\t[PhysicalVolumePath...]\n",
+
+   basevgname_ARG, test_ARG, import_ARG)
+
 xx(vgmerge,
    "Merge volume groups",
    0,
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
new file mode 100644
index 0000000..7028fbb
--- /dev/null
+++ b/tools/vgimportclone.c
@@ -0,0 +1,363 @@
+/*
+ * Copyright (C) 2016 Red Hat, Inc. All rights reserved.
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
+#include "lvmcache.h"
+#include "lvmetad-client.h"
+#include "filter.h"
+
+struct vgimportclone_params {
+	unsigned done;
+	unsigned total;
+
+	int import_vg;
+	int found_args;
+	struct dm_list arg_import;
+	const char *base_vgname;
+	const char *old_vgname;
+	const char *new_vgname;
+};
+
+struct vgimportclone_device {
+	struct dm_list list;
+	struct device *dev;
+	unsigned found_in_vg : 1;
+};
+
+static int _vgimportclone_pv_single(struct cmd_context *cmd, struct volume_group *vg,
+				    struct physical_volume *pv, struct processing_handle *handle)
+{
+	struct vgimportclone_params *vp = (struct vgimportclone_params *) handle->custom_handle;
+	struct vgimportclone_device *vd;
+
+	if (vg && is_orphan_vg(vg->name)) {
+		log_error("Cannot import clone of orphan PV %s.", dev_name(pv->dev));
+		return ECMD_FAILED;
+	}
+
+	if (!(vd = dm_pool_zalloc(cmd->mem, sizeof(*vd)))) {
+		log_error("alloc failed.");
+		return ECMD_FAILED;
+	}
+
+	vd->dev = pv->dev;
+	dm_list_add(&vp->arg_import, &vd->list);
+
+	log_debug("vgimportclone dev %s VG %s found to import",
+		  dev_name(vd->dev), vg ? vg->name : "<none>");
+
+	vp->found_args++;
+
+	return ECMD_PROCESSED;
+}
+
+static int _vgimportclone_vg_single(struct cmd_context *cmd, const char *vg_name,
+		                    struct volume_group *vg, struct processing_handle *handle)
+{
+	char uuid[64] __attribute__((aligned(8)));
+	struct vgimportclone_params *vp = (struct vgimportclone_params *) handle->custom_handle;
+	struct vgimportclone_device *vd;
+	struct pv_list *pvl, *new_pvl;
+	struct lv_list *lvl;
+	int devs_used_for_lv = 0;
+	int found;
+
+	if (vg_is_exported(vg) && !vp->import_vg) {
+		log_error("VG %s is exported, use the --import option.", vg->name);
+		goto_bad;
+	}
+
+	if (vg_status(vg) & PARTIAL_VG) {
+		log_error("VG %s is partial, it must be complete.", vg->name);
+		goto_bad;
+	}
+
+	/*
+	 * N.B. lvs_in_vg_activated() is not smart enough to distinguish
+	 * between LVs that are active in the original VG vs the cloned VG
+	 * that's being imported, so check DEV_USED_FOR_LV.
+	 */
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (pvl->pv->dev->flags & DEV_USED_FOR_LV) {
+			log_error("Device %s has active LVs, deactivate first.", dev_name(pvl->pv->dev));
+			devs_used_for_lv++;
+		}
+	}
+
+	if (devs_used_for_lv)
+		goto_bad;
+
+	/*
+	 * The arg_import list must match the PVs in VG.
+	 */
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		found = 0;
+
+		dm_list_iterate_items(vd, &vp->arg_import) {
+			if (pvl->pv->dev != vd->dev)
+				continue;
+			vd->found_in_vg = 1;
+			found = 1;
+			break;
+		}
+
+		if (!found) {
+			if (!id_write_format(&pvl->pv->id, uuid, sizeof(uuid)))
+				goto_bad;
+
+			/* all PVs in the VG must be imported together, pvl is missing from args. */
+			log_error("PV with UUID %s is part of VG %s, but is not included in the devices to import.",
+				   uuid, vg->name);
+			log_error("All PVs in the VG must be imported together.");
+			goto_bad;
+		}
+	}
+
+	dm_list_iterate_items(vd, &vp->arg_import) {
+		if (!vd->found_in_vg) {
+			/* device arg is not in the VG. */
+			log_error("Device %s was not found in VG %s.", dev_name(vd->dev), vg->name);
+			log_error("The devices to import must match the devices in the VG.");
+			goto_bad;
+		}
+	}
+
+	/*
+	 * Write changes.
+	 */
+
+	if (!archive(vg))
+		return_ECMD_FAILED;
+
+	if (vp->import_vg)
+		vg->status &= ~EXPORTED_VG;
+
+	if (!id_create(&vg->id))
+		goto_bad;
+
+	/* Low level vg_write code needs old_name to be set! */
+	vg->old_name = vg->name;
+
+	if (!(vg->name = dm_pool_strdup(vg->vgmem, vp->new_vgname)))
+		goto_bad;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (!(new_pvl = dm_pool_zalloc(vg->vgmem, sizeof(*new_pvl))))
+			goto_bad;
+
+		new_pvl->pv = pvl->pv;
+
+		if (!(pvl->pv->vg_name = dm_pool_strdup(vg->vgmem, vp->new_vgname)))
+			goto_bad;
+
+		if (vp->import_vg)
+			new_pvl->pv->status &= ~EXPORTED_VG;
+
+		/* Low level pv_write code needs old_id to be set! */
+		memcpy(&new_pvl->pv->old_id, &new_pvl->pv->id, sizeof(new_pvl->pv->id));
+
+		if (!id_create(&new_pvl->pv->id))
+			goto_bad;
+
+		dm_list_add(&vg->pv_write_list, &new_pvl->list);
+	}
+
+	dm_list_iterate_items(lvl, &vg->lvs)
+		memcpy(&lvl->lv->lvid, &vg->id, sizeof(vg->id));
+
+	if (!vg_write(vg) || !vg_commit(vg))
+		goto_bad;
+
+	return ECMD_PROCESSED;
+bad:
+	return ECMD_FAILED;
+}
+
+int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
+{
+	struct vgimportclone_params vp = { 0 };
+	struct processing_handle *handle = NULL;
+	struct dm_list vgnameids_on_system;     /* vgnameid_list */
+	struct vgnameid_list *vgnl;
+	struct vgimportclone_device *vd;
+	struct lvmcache_info *info;
+	const char *vgname;
+	char base_vgname[NAME_LEN] = { 0 };
+	char tmp_vgname[NAME_LEN] = { 0 };
+	unsigned int vgname_count;
+	int lvmetad_rescan = 0;
+	int ret = ECMD_FAILED;
+
+	if (!argc) {
+		log_error("PV names required.");
+		return EINVALID_CMD_LINE;
+	}
+
+	dm_list_init(&vgnameids_on_system);
+	dm_list_init(&vp.arg_import);
+
+	set_pv_notify(cmd);
+
+	vp.import_vg = arg_is_set(cmd, import_ARG);
+
+	if (lvmetad_used()) {
+		lvmetad_set_disabled(cmd, LVMETAD_DISABLE_REASON_DUPLICATES);
+		lvmetad_disconnect();
+		lvmetad_rescan = 1;
+	}
+
+	if (!(handle = init_processing_handle(cmd, NULL))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+	handle->custom_handle = &vp;
+
+	if (!lock_vol(cmd, VG_GLOBAL, LCK_VG_WRITE, NULL)) {
+		log_error("Unable to obtain global lock.");
+		destroy_processing_handle(cmd, handle);
+		return ECMD_FAILED;
+	}
+
+	if (!lockd_gl(cmd, "ex", 0))
+		goto_out;
+	cmd->lockd_gl_disable = 1;
+
+	/*
+	 * Find the devices being imported which are named on the command line.
+	 * They may be in the list of unchosen duplicates.
+	 */
+
+	log_debug("Finding devices to import.");
+	cmd->command->flags |= ENABLE_DUPLICATE_DEVS;
+	process_each_pv(cmd, argc, argv, NULL, 0, READ_ALLOW_EXPORTED, handle, _vgimportclone_pv_single);
+
+	if (vp.found_args != argc) {
+		log_error("Failed to find all devices.");
+		goto_out;
+	}
+
+	/*
+	 * Find the VG name of the PVs being imported, save as old_vgname.
+	 * N.B. If vd->dev is a duplicate, then it may not match info->dev.
+	 */
+
+	dm_list_iterate_items(vd, &vp.arg_import) {
+		if (!(info = lvmcache_info_from_pvid(vd->dev->pvid, NULL, 0))) {
+			log_error("Failed to find PVID for device %s in lvmcache.", dev_name(vd->dev));
+			goto_out;
+		}
+
+		if (!(vgname = lvmcache_vgname_from_info(info))) {
+			log_error("Failed to find VG name for device %s in lvmcache.", dev_name(vd->dev));
+			goto_out;
+		}
+
+		if (!vp.old_vgname) {
+			if (!(vp.old_vgname = dm_pool_strdup(cmd->mem, vgname)))
+				goto_out;
+		} else {
+			if (strcmp(vp.old_vgname, vgname)) {
+				log_error("Devices must be from the same VG.");
+				goto_out;
+			}
+		}
+	}
+
+	/*
+	 * Pick a new VG name, save as new_vgname.  The new name begins with
+	 * the basevgname or old_vgname, plus a $i suffix, if necessary, to
+	 * make it unique.  This requires comparing the old_vgname with all the
+	 * VG names on the system.
+	 */
+
+	if (arg_is_set(cmd, basevgname_ARG)) {
+		snprintf(base_vgname, sizeof(base_vgname) - 1, "%s", arg_str_value(cmd, basevgname_ARG, ""));
+		memcpy(tmp_vgname, base_vgname, NAME_LEN);
+		vgname_count = 0;
+	} else {
+		snprintf(base_vgname, sizeof(base_vgname) - 1, "%s", vp.old_vgname);
+		snprintf(tmp_vgname, sizeof(tmp_vgname) - 1, "%s1", vp.old_vgname);
+		vgname_count = 1;
+	}
+
+	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0))
+		goto_out;
+
+retry_name:
+	dm_list_iterate_items(vgnl, &vgnameids_on_system) {
+		if (!strcmp(vgnl->vg_name, tmp_vgname)) {
+			vgname_count++;
+			snprintf(tmp_vgname, sizeof(tmp_vgname) - 1, "%s%u", base_vgname, vgname_count);
+			goto retry_name;
+		}
+	}
+
+	if (!(vp.new_vgname = dm_pool_strdup(cmd->mem, tmp_vgname)))
+		goto_out;
+	log_debug("Using new VG name %s.", vp.new_vgname);
+
+	/*
+	 * Create a device filter so that we are only working with the devices
+	 * in arg_import.  With the original devs hidden (that arg_import were
+	 * cloned from), we can read and write the cloned PVs and VG without
+	 * touching the original PVs/VG.
+	 */
+
+	init_internal_filtering(1);
+	dm_list_iterate_items(vd, &vp.arg_import)
+		internal_filter_allow(cmd->mem, vd->dev);
+	lvmcache_destroy(cmd, 1, 0);
+	dev_cache_full_scan(cmd->full_filter);
+
+	log_debug("Changing VG %s to %s.", vp.old_vgname, vp.new_vgname);
+
+	/* We don't care if the new name comes before the old in lock order. */
+	lvmcache_lock_ordering(0);
+
+	if (!lock_vol(cmd, vp.new_vgname, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for new VG name %s", vp.new_vgname);
+		goto out;
+	}
+
+	ret = process_each_vg(cmd, 0, NULL, vp.old_vgname, NULL, READ_FOR_UPDATE | READ_ALLOW_EXPORTED, 0, handle, _vgimportclone_vg_single);
+
+	unlock_vg(cmd, vp.new_vgname);
+out:
+	unlock_vg(cmd, VG_GLOBAL);
+	internal_filter_clear();
+	init_internal_filtering(0);
+	lvmcache_lock_ordering(1);
+	destroy_processing_handle(cmd, handle);
+
+	/* Enable lvmetad again if no duplicates are left. */
+	if (lvmetad_rescan) {
+		if (!lvmetad_connect(cmd)) {
+			log_warn("WARNING: Failed to connect to lvmetad.");
+			log_warn("WARNING: Update lvmetad with pvscan --cache.");
+			return ret;
+		}
+
+		if (!refresh_filters(cmd))
+			stack;
+
+		if (!lvmetad_pvscan_all_devs(cmd, 1)) {
+			log_warn("WARNING: Failed to scan devices.");
+			log_warn("WARNING: Update lvmetad with pvscan --cache.");
+		}
+	}
+
+	return ret;
+}
+


