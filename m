From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 25 Feb 2016 15:15:33 +0000 (UTC)
Subject: master - toollib: add two phase pv processing code
Message-ID: <20160225151533.6B77C61BB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71671778ab0b2ae4f9f014b37372939b00e90e1d
Commit:        71671778ab0b2ae4f9f014b37372939b00e90e1d
Parent:        ff2267012aea37e08ed1fc2a511f8a0d3f0d145b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 16 14:15:24 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Feb 25 09:14:09 2016 -0600

toollib: add two phase pv processing code

This is common code for handling PV create/remove
that can be shared by pvcreate/vgcreate/vgextend/pvremove.
This does not change any commands to use the new code.

- Pull out the hidden equivalent of process_each_pv
  into an actual top level process_each_pv.

- Pull the prompts to the top level, and do not
  run any prompts while locks are held.
  The orphan lock is reacquired after any prompts are
  done, and the devices being created are checked for
  any change made while the lock was not held.

Previously, pvcreate_vol() was the shared function for
creating a PV for pvcreate, vgcreate, vgextend.
Now, it will be toollib function pvcreate_each_device().

pvcreate_vol() was called effectively as a helper, from
within vgcreate and vgextend code paths.
pvcreate_each_device() will be called at the same level
as other process_each functions.

One of the main problems with pvcreate_vol() is that
it included a hidden equivalent of process_each_pv for
each device being created:

  pvcreate_vol() -> _pvcreate_check() ->

   find_pv_by_name() -> get_pvs() ->

     get_pvs_internal() -> _get_pvs() -> get_vgids() ->

       /* equivalent to process_each_pv */
       dm_list_iterate_items(vgids)
         vg = vg_read_internal()
         dm_list_iterate_items(&vg->pvs)

pvcreate_each_device() reorganizes the code so that
each-VG-each-PV loop is done once, and uses the standard
process_each_pv function at the top level of the function.
---
 lib/metadata/metadata-exported.h |   57 +++
 lib/metadata/metadata.c          |   39 ++
 tools/commands.h                 |    6 +-
 tools/pvchange.c                 |    2 +-
 tools/pvdisplay.c                |    5 +-
 tools/pvmove.c                   |    2 +-
 tools/pvresize.c                 |    2 +-
 tools/pvscan.c                   |    2 +-
 tools/reporter.c                 |    6 +-
 tools/toollib.c                  |  996 +++++++++++++++++++++++++++++++++++++-
 tools/toollib.h                  |    8 +-
 tools/tools.h                    |    2 +
 tools/vgreduce.c                 |    2 +-
 13 files changed, 1097 insertions(+), 32 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index fc09e2e..87342d8 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -542,6 +542,62 @@ struct pvcreate_params {
 	struct pvcreate_restorable_params rp;
 };
 
+/*
+ * FIXME: rename this pvcreate_params once the old pvcreate_params is unused.
+ * This can probably be put in toollib.h.
+ */
+struct pvcreate_each_params {
+	/*
+	 * From argc and argv.
+	 */
+	char **pv_names;
+	uint32_t pv_count;
+
+	/*
+	 * From command line args.
+	 */
+	int zero;
+	uint64_t size;
+	uint64_t data_alignment;
+	uint64_t data_alignment_offset;
+	int pvmetadatacopies;
+	uint64_t pvmetadatasize;
+	int64_t labelsector;
+	force_t force;
+	unsigned yes;
+	unsigned metadataignore;
+
+	/*
+	 * From recovery-specific command line args.
+	 */
+	const char *restorefile; /* NULL if no --restorefile option */
+	const char *uuid_str;    /* id in printable format, NULL if no id */
+	struct id id;
+
+	/*
+	 * From reading VG backup file.
+	 */
+	uint64_t ba_start;
+	uint64_t ba_size;
+	uint64_t pe_start;
+	uint32_t extent_count;
+	uint32_t extent_size;
+
+	/*
+	 * Used for command processing.
+	 */
+	struct dm_list prompts;         /* pvcreate_prompt */
+	struct dm_list arg_devices;     /* pvcreate_device, one for each pv_name */
+	struct dm_list arg_process;     /* pvcreate_device, used for processing */
+	struct dm_list arg_confirm;     /* pvcreate_device, used for processing */
+	struct dm_list arg_create;      /* pvcreate_device, used for pvcreate */
+	struct dm_list arg_fail;        /* pvcreate_device, failed to create */
+	struct dm_list pvs;             /* pv_list, created and usable for vgcreate/vgextend */
+	const char *orphan_vg_name;
+	unsigned preserve_existing : 1;
+	unsigned check_failed : 1;
+};
+
 struct lvresize_params {
 	const char *vg_name; /* only-used when VG is not yet opened (in /tools) */
 	const char *lv_name;
@@ -705,6 +761,7 @@ int vg_rename(struct cmd_context *cmd, struct volume_group *vg,
 	      const char *new_name);
 int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names,
 	      struct pvcreate_params *pp);
+int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_each_params *pp);
 int vg_reduce(struct volume_group *vg, const char *pv_name);
 
 int vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index d7a9d81..92a9e82 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -791,6 +791,40 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 	return 1;
 }
 
+int vg_extend_each_pv(struct volume_group *vg, struct pvcreate_each_params *pp)
+{
+	struct pv_list *pvl;
+	unsigned int max_phys_block_size = 0;
+
+	log_debug_metadata("Adding PVs to VG %s", vg->name);
+
+	if (_vg_bad_status_bits(vg, RESIZEABLE_VG))
+		return_0;
+
+	dm_list_iterate_items(pvl, &pp->pvs) {
+		log_debug_metadata("Adding PV %s to VG %s", pv_dev_name(pvl->pv), vg->name);
+
+		if (!(check_dev_block_size_for_vg(pvl->pv->dev,
+						  (const struct volume_group *) vg,
+						  &max_phys_block_size))) {
+			log_error("PV %s has wrong block size", pv_dev_name(pvl->pv));
+			return_0;
+		}
+
+		if (!add_pv_to_vg(vg, pv_dev_name(pvl->pv), pvl->pv, 0)) {
+			log_error("PV %s cannot be added to VG %s.",
+				  pv_dev_name(pvl->pv), vg->name);
+			return_0;
+		}
+	}
+
+	(void) _check_pv_dev_sizes(vg);
+
+	dm_list_splice(&vg->pv_write_list, &pp->pvs);
+
+	return 1;
+}
+
 int vg_reduce(struct volume_group *vg, const char *pv_name)
 {
 	struct physical_volume *pv;
@@ -3839,6 +3873,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
 	unsigned use_previous_vg;
 
+	log_very_verbose("Reading VG %s %.32s", vgname ?: "<no name>", vgid ?: "<no vgid>");
+
 	if (is_orphan_vg(vgname)) {
 		if (use_precommitted) {
 			log_error(INTERNAL_ERROR "vg_read_internal requires vgname "
@@ -5322,6 +5358,9 @@ static struct volume_group *_vg_lock_and_read(struct cmd_context *cmd, const cha
 		return _vg_make_handle(cmd, vg, FAILED_LOCKING);
 	}
 
+	if (already_locked)
+		log_very_verbose("Locking %s already done", vg_name);
+
 	if (is_orphan_vg(vg_name))
 		status_flags &= ~LVM_WRITE;
 
diff --git a/tools/commands.h b/tools/commands.h
index 0748568..fcd2c24 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -766,7 +766,7 @@ xx(pvck,
 
 xx(pvcreate,
    "Initialize physical volume(s) for use by LVM",
-   0,
+   ENABLE_ALL_DEVS,
    "pvcreate\n"
    "\t[--norestorefile]\n"
    "\t[--restorefile file]\n"
@@ -1119,7 +1119,7 @@ xx(vgconvert,
 
 xx(vgcreate,
    "Create a volume group",
-   0,
+   MUST_USE_ALL_ARGS | ENABLE_ALL_DEVS,
    "vgcreate\n"
    "\t[-A|--autobackup {y|n}]\n"
    "\t[--addtag Tag]\n"
@@ -1214,7 +1214,7 @@ xx(vgexport,
 
 xx(vgextend,
    "Add physical volumes to a volume group",
-   0,
+   MUST_USE_ALL_ARGS | ENABLE_ALL_DEVS,
    "vgextend\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--restoremissing]\n"
diff --git a/tools/pvchange.c b/tools/pvchange.c
index 7f9aaf8..3c12c14 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -228,7 +228,7 @@ int pvchange(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, handle, _pvchange_single);
+	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE, handle, _pvchange_single);
 
 	if (!argc)
 		unlock_vg(cmd, VG_GLOBAL);
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index bad2df0..4d8275c 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -107,8 +107,9 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	ret = process_each_pv(cmd, argc, argv, NULL, 0, NULL,
-			      _pvdisplay_single);
+	ret = process_each_pv(cmd, argc, argv, NULL,
+			      arg_is_set(cmd, all_ARG), 0,
+			      NULL, _pvdisplay_single);
 
 	if (lock_global)
 		unlock_vg(cmd, VG_GLOBAL);
diff --git a/tools/pvmove.c b/tools/pvmove.c
index 0b8ca46..b590745 100644
--- a/tools/pvmove.c
+++ b/tools/pvmove.c
@@ -895,7 +895,7 @@ int pvmove(struct cmd_context *cmd, int argc, char **argv)
 
 		handle->custom_handle = &pp;
 
-		process_each_pv(cmd, 1, &pv_name, NULL,
+		process_each_pv(cmd, 1, &pv_name, NULL, 0,
 				is_abort ? 0 : READ_FOR_UPDATE,
 				handle,
 				is_abort ? &_pvmove_read_single : &_pvmove_setup_single);
diff --git a/tools/pvresize.c b/tools/pvresize.c
index e23c954..b79098c 100644
--- a/tools/pvresize.c
+++ b/tools/pvresize.c
@@ -87,7 +87,7 @@ int pvresize(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &params;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, READ_FOR_UPDATE, handle,
+	ret = process_each_pv(cmd, argc, argv, NULL, 0, READ_FOR_UPDATE, handle,
 			      _pvresize_single);
 
 	log_print_unless_silent("%d physical volume(s) resized / %d physical volume(s) "
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 7d7a96f..b224c30 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -422,7 +422,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 
 	handle->custom_handle = &params;
 
-	ret = process_each_pv(cmd, argc, argv, NULL, 0, handle, _pvscan_single);
+	ret = process_each_pv(cmd, argc, argv, NULL, 0, 0, handle, _pvscan_single);
 
 	if (!params.pvs_found)
 		log_print_unless_silent("No matching physical volumes found");
diff --git a/tools/reporter.c b/tools/reporter.c
index f7fb543..1a24698 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -893,7 +893,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	case PVS:
 		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL, 0,
+			r = process_each_pv(cmd, argc, argv, NULL,
+					    arg_is_set(cmd, all_ARG), 0,
 					    &handle, &_pvs_single);
 		else
 			r = process_each_vg(cmd, argc, argv, NULL, 0,
@@ -910,7 +911,8 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
 		break;
 	case PVSEGS:
 		if (args_are_pvs)
-			r = process_each_pv(cmd, argc, argv, NULL, 0,
+			r = process_each_pv(cmd, argc, argv, NULL,
+					    arg_is_set(cmd, all_ARG), 0,
 					    &handle,
 					    lv_info_needed && !lv_segment_status_needed ? &_pvsegs_with_lv_info_single :
 					    !lv_info_needed && lv_segment_status_needed ? &_pvsegs_with_lv_status_single :
diff --git a/tools/toollib.c b/tools/toollib.c
index 22c38a1..88cbb51 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -14,6 +14,8 @@
  */
 
 #include "tools.h"
+#include "format1.h"
+#include "format-text.h"
 
 #include <sys/stat.h>
 #include <signal.h>
@@ -1740,8 +1742,6 @@ static int _get_arg_vgnames(struct cmd_context *cmd,
 	int ret_max = ECMD_PROCESSED;
 	const char *vg_name;
 
-	log_verbose("Using volume group(s) on command line.");
-
 	if (one_vgname) {
 		if (!str_list_add(cmd->mem, arg_vgnames,
 				  dm_pool_strdup(cmd->mem, one_vgname))) {
@@ -1935,6 +1935,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 	int skip;
 	int notfound;
 	int process_all = 0;
+	int already_locked;
 
 	/*
 	 * If no VG names or tags were supplied, then process all VGs.
@@ -1964,6 +1965,8 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 			continue;
 		}
 
+		already_locked = lvmcache_vgname_is_locked(vg_name);
+
 		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
 		if (_ignore_vg(vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
 			stack;
@@ -1989,7 +1992,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t read_flags,
 				ret_max = ret;
 		}
 
-		if (!vg_read_error(vg))
+		if (!vg_read_error(vg) && !already_locked)
 			unlock_vg(cmd, vg_name);
 endvg:
 		release_vg(vg);
@@ -2177,6 +2180,8 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
+	log_debug("Processing each VG");
+
 	/* Disable error in vg_read so we can print it from ignore_vg. */
 	cmd->vg_read_print_access_error = 0;
 
@@ -2227,7 +2232,7 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	 * . A VG name is specified which may refer to one
 	 *   of multiple VGs on the system with that name.
 	 */
-	log_very_verbose("Get list of VGs on system");
+	log_debug("Get list of VGs on system");
 
 	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0)) {
 		ret_max = ECMD_FAILED;
@@ -2493,8 +2498,6 @@ static int _get_arg_lvnames(struct cmd_context *cmd,
 	const char *vgname_def;
 	unsigned dev_dir_found;
 
-	log_verbose("Using logical volume(s) on command line.");
-
 	for (; opt < argc; opt++) {
 		lv_name = argv[opt];
 		dev_dir_found = 0;
@@ -2596,6 +2599,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 	int ret;
 	int skip;
 	int notfound;
+	int already_locked;
 
 	dm_list_iterate_items(vgnl, vgnameids_to_process) {
 		if (sigint_caught())
@@ -2646,6 +2650,8 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 			continue;
 		}
 
+		already_locked = lvmcache_vgname_is_locked(vg_name);
+
 		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
 		if (_ignore_vg(vg, vg_name, arg_vgnames, read_flags, &skip, &notfound)) {
 			stack;
@@ -2662,7 +2668,8 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t read_flag
 		if (ret > ret_max)
 			ret_max = ret;
 
-		unlock_vg(cmd, vg_name);
+		if (!already_locked)
+			unlock_vg(cmd, vg_name);
 endvg:
 		release_vg(vg);
 		if (!lockd_vg(cmd, vg_name, "un", 0, &lockd_state))
@@ -2747,7 +2754,7 @@ int process_each_lv(struct cmd_context *cmd, int argc, char **argv, uint32_t rea
 	 * . A VG name is specified which may refer to one
 	 *   of multiple VGs on the system with that name.
 	 */
-	log_very_verbose("Get list of VGs on system");
+	log_debug("Get list of VGs on system");
 
 	if (!get_vgnameids(cmd, &vgnameids_on_system, NULL, 0)) {
 		ret_max = ECMD_FAILED;
@@ -2809,8 +2816,6 @@ static int _get_arg_pvnames(struct cmd_context *cmd,
 	char *arg_name;
 	int ret_max = ECMD_PROCESSED;
 
-	log_verbose("Using physical volume(s) on command line.");
-
 	for (; opt < argc; opt++) {
 		arg_name = argv[opt];
 
@@ -2875,6 +2880,8 @@ static int _get_all_devices(struct cmd_context *cmd, struct dm_list *all_devices
 	struct device_id_list *dil;
 	int r = ECMD_FAILED;
 
+	log_debug("Getting list of all devices");
+
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (!(iter = dev_iter_create(cmd->full_filter, 1))) {
@@ -3000,6 +3007,8 @@ static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_dev
 	int ret_max = ECMD_PROCESSED;
 	int ret = 0;
 
+	log_debug("Processing devices that are not PVs");
+
 	/*
 	 * Pretend that each device is a PV with dummy values.
 	 * FIXME Formalise this extension or find an alternative.
@@ -3243,6 +3252,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 	int ret;
 	int skip;
 	int notfound;
+	int already_locked;
 
 	dm_list_iterate_items(vgnl, all_vgnameids) {
 		if (sigint_caught())
@@ -3258,6 +3268,10 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 			continue;
 		}
 
+		log_debug("Processing PVs in VG %s", vg_name);
+
+		already_locked = lvmcache_vgname_is_locked(vg_name);
+
 		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
 		if (_ignore_vg(vg, vg_name, NULL, read_flags, &skip, &notfound)) {
 			stack;
@@ -3282,7 +3296,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		if (ret > ret_max)
 			ret_max = ret;
 
-		if (!skip)
+		if (!skip && !already_locked)
 			unlock_vg(cmd, vg->name);
 endvg:
 		release_vg(vg);
@@ -3298,9 +3312,8 @@ endvg:
 }
 
 int process_each_pv(struct cmd_context *cmd,
-		    int argc, char **argv,
-		    const char *only_this_vgname,
-		    uint32_t read_flags,
+		    int argc, char **argv, const char *only_this_vgname,
+		    int all_is_set, uint32_t read_flags,
 		    struct processing_handle *handle,
 		    process_single_pv_fn_t process_single_pv)
 {
@@ -3313,9 +3326,12 @@ int process_each_pv(struct cmd_context *cmd,
 	struct device_id_list *dil;
 	int process_all_pvs;
 	int process_all_devices;
+	int orphans_locked;
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 
+	log_debug("Processing each PV");
+
 	/*
 	 * When processing a specific VG name, warn if it's inconsistent and
 	 * print an error if it's not found.  Otherwise we're processing all
@@ -3352,10 +3368,11 @@ int process_each_pv(struct cmd_context *cmd,
 		return ret;
 	}
 
+	orphans_locked = lvmcache_vgname_is_locked(VG_ORPHANS);
+
 	process_all_pvs = dm_list_empty(&arg_pvnames) && dm_list_empty(&arg_tags);
 
-	process_all_devices = process_all_pvs && (cmd->command->flags & ENABLE_ALL_DEVS) &&
-			      arg_count(cmd, all_ARG);
+	process_all_devices = process_all_pvs && (cmd->command->flags & ENABLE_ALL_DEVS) && all_is_set;
 
 	/* Needed for a current listing of the global VG namespace. */
 	if (!only_this_vgname && !lockd_gl(cmd, "sh", 0))
@@ -3365,10 +3382,13 @@ int process_each_pv(struct cmd_context *cmd,
 	 * This full scan would be done by _get_all_devices() if
 	 * it were not done here first.  It's called here first
 	 * so that get_vgnameids() will look at any new devices.
+	 * When orphans is already locked, these steps are done
+	 * before process_each_pv is called.
 	 */
-	if (!trust_cache()) {
-		dev_cache_full_scan(cmd->full_filter);
+	if (!trust_cache() && !orphans_locked) {
+		log_debug("Scanning for available devices");
 		lvmcache_destroy(cmd, 1, 0);
+		dev_cache_full_scan(cmd->full_filter);
 	}
 
 	/*
@@ -3406,6 +3426,14 @@ int process_each_pv(struct cmd_context *cmd,
 		ret_max = ret;
 
 	/*
+	 * If the orphans lock was held, there shouldn't be missed devices.  If
+	 * there were, we cannot clear the cache while holding the orphans lock
+	 * anyway.
+	 */
+	if (orphans_locked)
+		goto skip_missed;
+
+	/*
 	 * Some PVs may have been missed by the first search if another command
 	 * moved them at the same time.  Repeat the search for only the
 	 * specific PVs missed.  lvmcache needs clearing for a fresh search.
@@ -3452,6 +3480,7 @@ int process_each_pv(struct cmd_context *cmd,
 		}
 	}
 
+skip_missed:
 	dm_list_iterate_items(dil, &arg_devices) {
 		log_error("Failed to find physical volume \"%s\".", dev_name(dil->dev));
 		ret_max = ECMD_FAILED;
@@ -3510,3 +3539,934 @@ int lvremove_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	return ECMD_PROCESSED;
 }
+
+void pvcreate_each_params_set_defaults(struct pvcreate_each_params *pp)
+{
+	memset(pp, 0, sizeof(*pp));
+
+	pp->zero = 1;
+	pp->size = 0;
+	pp->data_alignment = UINT64_C(0);
+	pp->data_alignment_offset = UINT64_C(0);
+	pp->pvmetadatacopies = DEFAULT_PVMETADATACOPIES;
+	pp->pvmetadatasize = DEFAULT_PVMETADATASIZE;
+	pp->labelsector = DEFAULT_LABELSECTOR;
+	pp->force = PROMPT;
+	pp->yes = 0;
+	pp->metadataignore = DEFAULT_PVMETADATAIGNORE;
+	pp->restorefile = NULL;
+	pp->uuid_str = NULL;
+	pp->ba_start = 0;
+	pp->ba_size = 0;
+	pp->pe_start = PV_PE_START_CALC;
+	pp->extent_count = 0;
+	pp->extent_size = 0;
+
+	dm_list_init(&pp->prompts);
+	dm_list_init(&pp->arg_devices);
+	dm_list_init(&pp->arg_process);
+	dm_list_init(&pp->arg_confirm);
+	dm_list_init(&pp->arg_create);
+	dm_list_init(&pp->arg_fail);
+	dm_list_init(&pp->pvs);
+}
+
+int pvcreate_each_params_from_args(struct cmd_context *cmd, struct pvcreate_each_params *pp)
+{
+	pp->yes = arg_count(cmd, yes_ARG);
+	pp->force = (force_t) arg_count(cmd, force_ARG);
+
+	if (arg_int_value(cmd, labelsector_ARG, 0) >= LABEL_SCAN_SECTORS) {
+		log_error("labelsector must be less than %lu.",
+			  LABEL_SCAN_SECTORS);
+		return 0;
+	} else {
+		pp->labelsector = arg_int64_value(cmd, labelsector_ARG,
+						  DEFAULT_LABELSECTOR);
+	}
+
+	if (!(cmd->fmt->features & FMT_MDAS) &&
+	    (arg_count(cmd, pvmetadatacopies_ARG) ||
+	     arg_count(cmd, metadatasize_ARG)   ||
+	     arg_count(cmd, dataalignment_ARG)  ||
+	     arg_count(cmd, dataalignmentoffset_ARG))) {
+		log_error("Metadata and data alignment parameters only "
+			  "apply to text format.");
+		return 0;
+	}
+
+	if (!(cmd->fmt->features & FMT_BAS) &&
+	    arg_count(cmd, bootloaderareasize_ARG)) {
+		log_error("Bootloader area parameters only "
+			  "apply to text format.");
+		return 0;
+	}
+
+	if (arg_count(cmd, metadataignore_ARG))
+		pp->metadataignore = arg_int_value(cmd, metadataignore_ARG,
+						   DEFAULT_PVMETADATAIGNORE);
+	else
+		pp->metadataignore = find_config_tree_bool(cmd, metadata_pvmetadataignore_CFG, NULL);
+
+	if (arg_count(cmd, pvmetadatacopies_ARG) &&
+	    !arg_int_value(cmd, pvmetadatacopies_ARG, -1) &&
+	    pp->metadataignore) {
+		log_error("metadataignore only applies to metadatacopies > 0");
+		return 0;
+	}
+
+	pp->zero = arg_int_value(cmd, zero_ARG, 1);
+
+	if (arg_sign_value(cmd, dataalignment_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Physical volume data alignment may not be negative.");
+		return 0;
+	}
+	pp->data_alignment = arg_uint64_value(cmd, dataalignment_ARG, UINT64_C(0));
+
+	if (pp->data_alignment > UINT32_MAX) {
+		log_error("Physical volume data alignment is too big.");
+		return 0;
+	}
+
+	if (arg_sign_value(cmd, dataalignmentoffset_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Physical volume data alignment offset may not be negative");
+		return 0;
+	}
+	pp->data_alignment_offset = arg_uint64_value(cmd, dataalignmentoffset_ARG, UINT64_C(0));
+
+	if (pp->data_alignment_offset > UINT32_MAX) {
+		log_error("Physical volume data alignment offset is too big.");
+		return 0;
+	}
+
+	if ((pp->data_alignment + pp->data_alignment_offset) &&
+	    (pp->pe_start != PV_PE_START_CALC)) {
+		if ((pp->data_alignment ? pp->pe_start % pp->data_alignment : pp->pe_start) != pp->data_alignment_offset) {
+			log_warn("WARNING: Ignoring data alignment %s"
+				 " incompatible with restored pe_start value %s)",
+				 display_size(cmd, pp->data_alignment + pp->data_alignment_offset),
+				 display_size(cmd, pp->pe_start));
+			pp->data_alignment = 0;
+			pp->data_alignment_offset = 0;
+		}
+	}
+
+	if (arg_sign_value(cmd, metadatasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Metadata size may not be negative.");
+		return 0;
+	}
+
+	if (arg_sign_value(cmd, bootloaderareasize_ARG, SIGN_NONE) == SIGN_MINUS) {
+		log_error("Bootloader area size may not be negative.");
+		return 0;
+	}
+
+	pp->pvmetadatasize = arg_uint64_value(cmd, metadatasize_ARG, UINT64_C(0));
+	if (!pp->pvmetadatasize)
+		pp->pvmetadatasize = find_config_tree_int(cmd, metadata_pvmetadatasize_CFG, NULL);
+
+	pp->pvmetadatacopies = arg_int_value(cmd, pvmetadatacopies_ARG, -1);
+	if (pp->pvmetadatacopies < 0)
+		pp->pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
+
+	if (pp->pvmetadatacopies > 2) {
+		log_error("Metadatacopies may only be 0, 1 or 2");
+		return 0;
+	}
+
+	pp->ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, pp->ba_size);
+
+	return 1;
+}
+
+enum {
+	PROMPT_PVCREATE_PV_IN_VG = 1,
+};
+
+enum {
+	PROMPT_ANSWER_NO = 1,
+	PROMPT_ANSWER_YES = 2
+};
+
+/*
+ * When a prompt entry is created, save any strings or info
+ * in this struct that are needed for the prompt messages.
+ * The VG/PV structs are not be available when the prompt
+ * is run.
+ */
+struct pvcreate_prompt {
+	struct dm_list list;
+	uint32_t type;
+	const char *pv_name;
+	const char *vg_name;
+	struct device *dev;
+	int answer;
+	unsigned abort_command : 1;
+	unsigned vg_name_unknown : 1;
+};
+
+struct pvcreate_device {
+	struct dm_list list;
+	const char *name;
+	struct device *dev;
+	char pvid[ID_LEN + 1];
+	const char *vg_name;
+	int wiped;
+	unsigned is_not_pv : 1;     /* device is not a PV */
+	unsigned is_orphan_pv : 1;  /* device is an orphan PV */
+	unsigned is_vg_pv : 1;      /* device is a PV used in a VG */
+	unsigned is_used_unknown_pv : 1; /* device is a PV used in an unknown VG */
+};
+
+static void _check_pvcreate_prompt(struct cmd_context *cmd,
+				   struct pvcreate_each_params *pp,
+				   struct pvcreate_prompt *prompt,
+				   int ask)
+{
+	if (prompt->type == PROMPT_PVCREATE_PV_IN_VG) {
+		if (pp->force != DONT_PROMPT_OVERRIDE) {
+			prompt->answer = PROMPT_ANSWER_NO;
+
+			/* FIXME: use similar error messages for these cases */
+
+			if (prompt->vg_name_unknown) {
+				log_error("PV '%s' is marked as belonging to a VG but its metadata is missing.",
+					  prompt->pv_name);
+				log_error("Can't initialize PV '%s' without -ff.", prompt->pv_name);
+			} else if (!strcmp(command_name(cmd), "pvcreate")) {
+				log_error("Can't initialize physical volume \"%s\" of volume group \"%s\" without -ff",
+					  prompt->pv_name, prompt->vg_name);
+			} else {
+				log_error("Physical volume '%s' is already in volume group '%s'",
+					  prompt->pv_name, prompt->vg_name);
+				log_error("Unable to add physical volume '%s' to volume group '%s'",
+					  prompt->pv_name, prompt->vg_name);
+			}
+		} else if (pp->yes) {
+			prompt->answer = PROMPT_ANSWER_YES;
+		} else if (ask) {
+			const char *vgname = prompt->vg_name ? prompt->vg_name : "<unknown>";
+
+			if (yes_no_prompt("Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ",
+					  prompt->pv_name, vgname) == 'n') {
+				prompt->answer = PROMPT_ANSWER_NO;
+				log_error("%s: physical volume not initialized", prompt->pv_name);
+			} else {
+				prompt->answer = PROMPT_ANSWER_YES;
+				log_warn("WARNING: Forcing physical volume creation on %s of volume group \"%s\"",
+					 prompt->pv_name, vgname);
+			}
+		}
+	}
+}
+
+static struct pvcreate_device *_pvcreate_list_find_dev(struct dm_list *devices, struct device *dev)
+{
+	struct pvcreate_device *pd;
+
+	dm_list_iterate_items(pd, devices) {
+		if (pd->dev == dev)
+			return pd;
+	}
+
+	return NULL;
+}
+
+static struct pvcreate_device *_pvcreate_list_find_name(struct dm_list *devices, const char *name)
+{
+	struct pvcreate_device *pd;
+
+	dm_list_iterate_items(pd, devices) {
+		if (!strcmp(pd->name, name))
+			return pd;
+	}
+
+	return NULL;
+}
+
+/*
+ * If this function decides that a arg_devices entry cannot be used, but the
+ * command might be able to continue without it, then it moves that entry from
+ * arg_devices to arg_fail.
+ *
+ * If this function decides that an arg_devices entry could be used (possibly
+ * requiring a prompt), then it moves the entry from arg_devices to arg_process.
+ *
+ * Any arg_devices entries that are not moved to arg_fail or arg_process were
+ * not found.  The caller will decide if the command can continue if any
+ * arg_devices entries were not found, or if any were moved to arg_fail.
+ *
+ * This check does not need to look at PVs in foreign, shared or clustered VGs.
+ * If pvcreate/vgcreate/vgextend specifies a device in a
+ * foreign/shared/clustered VG, that VG will not be processed by this function,
+ * and the arg will be reported as not found.
+ */
+
+static int _pvcreate_check1_single(struct cmd_context *cmd,
+				   struct volume_group *vg,
+				   struct physical_volume *pv,
+				   struct processing_handle *handle)
+{
+	struct pvcreate_each_params *pp = (struct pvcreate_each_params *) handle->custom_handle;
+	struct pvcreate_device *pd;
+	struct pvcreate_prompt *prompt;
+	struct device *dev;
+	int found = 0;
+
+	if (!pv->dev)
+		return 1;
+
+	/*
+	 * Check if one of the command args in arg_devices
+	 * matches this device.
+	 *
+	 * (Possible optimization: the first time this _single
+	 * function is called, we could iterate through all
+	 * arg_devices entries, do the name to dev lookup
+	 * with dev_cache_get() and set the pd->dev fields.
+	 * Subsequent _single calls would just compare devs
+	 * and not do any dev_cache_get(). This would avoid
+	 * repeating dev_cache_get() for arg_devices entries.)
+	 */
+	dm_list_iterate_items(pd, &pp->arg_devices) {
+		dev = dev_cache_get(pd->name, cmd->full_filter);
+		if (dev != pv->dev)
+			continue;
+
+		pd->dev = pv->dev;
+		if (pv->dev->pvid[0])
+			strncpy(pd->pvid, pv->dev->pvid, ID_LEN);
+		found = 1;
+		break;
+	}
+
+	/*
+	 * Check if the uuid specified for the new PV is used by another PV.
+	 */
+	if (!found && pv->dev && pp->uuid_str && id_equal(&pv->id, &pp->id)) {
+		log_error("uuid %s already in use on \"%s\"", pp->uuid_str, pv_dev_name(pv));
+		pp->check_failed = 1;
+		return 0;
+	}
+
+	if (!found)
+		return 1;
+
+	log_debug("Checking device %s for pvcreate %.32s",
+		  pv_dev_name(pv), pv->dev->pvid[0] ? pv->dev->pvid : "");
+
+	/*
+	 * This test will fail if the device belongs to an MD array.
+	 */
+	if (!dev_test_excl(pv->dev)) {
+		/* FIXME Detect whether device-mapper itself is still using it */
+		log_error("Can't open %s exclusively.  Mounted filesystem?",
+			  pv_dev_name(pv));
+		dm_list_move(&pp->arg_fail, &pd->list);
+		return 1;
+	}
+
+	/*
+	 * What kind of device is this: an orphan PV, an uninitialized/unused
+	 * device, a PV used in a VG.
+	 */
+
+	if (vg && !is_orphan_vg(vg->name)) {
+		/* Device is a PV used in a VG. */
+		log_debug("Found pvcreate arg %s: pv is used in %s", pd->name, vg->name);
+		pd->is_vg_pv = 1;
+		pd->vg_name = dm_pool_strdup(cmd->mem, vg->name);
+
+	} else if (vg && is_orphan_vg(vg->name)) {
+		if (is_used_pv(pv)) {
+			/* Device is used in an unknown VG. */
+			log_debug("Found pvcreate arg %s: pv is used in unknown VG", pd->name);
+			pd->is_used_unknown_pv = 1;
+		} else {
+			/* Device is an orphan PV. */
+			log_debug("Found pvcreate arg %s: pv is orphan in %s", pd->name, vg->name);
+			pd->is_orphan_pv = 1;
+		}
+
+		if (!strcmp(vg->name, FMT_LVM1_ORPHAN_VG_NAME))
+			pp->orphan_vg_name = FMT_LVM1_ORPHAN_VG_NAME;
+		else
+			pp->orphan_vg_name = FMT_TEXT_ORPHAN_VG_NAME;
+	} else {
+		log_debug("Found pvcreate arg %s: device is not a pv", pd->name);
+		/* Device is not a PV. */
+		pd->is_not_pv = 1;
+	}
+
+	/*
+	 * pvcreate is being run on this device, and it's not a PV,
+	 * or is an orphan PV.  Neither case requires a prompt.
+	 */
+	if (pd->is_orphan_pv || pd->is_not_pv) {
+		pd->dev = pv->dev;
+		dm_list_move(&pp->arg_process, &pd->list);
+		return 1;
+	}
+
+	/*
+	 * pvcreate is being run on this device, but the device is already
+	 * a PV in a VG.  A prompt or force option is required to use it.
+	 */
+
+	if (!(prompt = dm_pool_zalloc(cmd->mem, sizeof(*prompt)))) {
+		log_error("prompt alloc failed");
+		pp->check_failed = 1;
+		return 0;
+	}
+	prompt->dev = pd->dev;
+	prompt->type = PROMPT_PVCREATE_PV_IN_VG;
+	prompt->pv_name = dm_pool_strdup(cmd->mem, pd->name);
+	if (pd->is_used_unknown_pv)
+		prompt->vg_name_unknown = 1;
+	else
+		prompt->vg_name = dm_pool_strdup(cmd->mem, vg->name);
+	dm_list_add(&pp->prompts, &prompt->list);
+
+	pd->dev = pv->dev;
+	dm_list_move(&pp->arg_process, &pd->list);
+	return 1;
+}
+
+/*
+ * This repeats the first check -- devices should be found, and should not have
+ * changed since the first check.  If they were changed/used while the orphans
+ * lock was not held (during prompting), then they can't be used any more and
+ * are moved to arg_fail.  If they are not found by this loop, that also
+ * disqualifies them from being used.  Each arg_confirm entry that's found and
+ * is ok, is moved to arg_process.  Those not found will remain in arg_confirm.
+ *
+ * This check does not need to look in foreign/shared/clustered VGs.  If a
+ * device from arg_confirm was used in a foreign/shared/clustered VG during the
+ * prompts, then it will not be found during this check.
+ */
+
+static int _pvcreate_check2_single(struct cmd_context *cmd,
+				   struct volume_group *vg,
+				   struct physical_volume *pv,
+				   struct processing_handle *handle)
+{
+	struct pvcreate_each_params *pp = (struct pvcreate_each_params *) handle->custom_handle;
+	struct pvcreate_device *pd;
+	int found = 0;
+
+	dm_list_iterate_items(pd, &pp->arg_confirm) {
+		if (pd->dev != pv->dev)
+			continue;
+		found = 1;
+		break;
+	}
+
+	if (!found)
+		return 1;
+
+	/* Repeat the same from check1. */
+	if (!dev_test_excl(pv->dev)) {
+		/* FIXME Detect whether device-mapper itself is still using it */
+		log_error("Can't open %s exclusively.  Mounted filesystem?",
+			  pv_dev_name(pv));
+		goto fail;
+	}
+
+	/*
+	 * What kind of device is this: an orphan PV, an uninitialized/unused
+	 * device, a PV used in a VG.
+	 */
+
+	if (vg && !is_orphan_vg(vg->name)) {
+		/* Device is a PV used in a VG. */
+
+		if (pd->is_orphan_pv || pd->is_not_pv || pd->is_used_unknown_pv) {
+			/* In check1 it was an orphan or unused. */
+			goto fail;
+		}
+
+		if (pd->is_vg_pv && pd->vg_name && strcmp(pd->vg_name, vg->name)) {
+			/* In check1 it was in a different VG. */
+			goto fail;
+		}
+
+	} else if (is_orphan(pv)) {
+		/* Device is an orphan PV. */
+
+		if (pd->is_not_pv) {
+			/* In check1 it was not a PV. */
+			goto fail;
+		}
+
+		if (pd->is_vg_pv) {
+			/* In check1 it was in a VG. */
+			goto fail;
+		}
+
+		if (is_used_pv(pv) != pd->is_used_unknown_pv) {
+			/* In check1 it was different. */
+			goto fail;
+		}
+
+	} else {
+		/* Device is not a PV. */
+
+		if (pd->is_orphan_pv || pd->is_used_unknown_pv) {
+			/* In check1 it was an orphan PV. */
+			goto fail;
+		}
+
+		if (pd->is_vg_pv) {
+			/* In check1 it was in a VG. */
+			goto fail;
+		}
+	}
+
+	/* Device is unchanged from check1. */
+	dm_list_move(&pp->arg_process, &pd->list);
+	return 1;
+
+fail:
+	log_error("Cannot use device %s: it changed during create.", pd->name);
+	dm_list_move(&pp->arg_fail, &pd->list);
+	return 1;
+}
+
+/*
+ * This can be used by pvcreate, vgcreate and vgextend to create PVs.  The
+ * callers need to set up the pvcreate_each_params structure based on command
+ * line args.  This includes the pv_names field which specifies the devices to
+ * create PVs on.
+ *
+ * This uses process_each_pv() and should be called from a high level in the
+ * command -- the same level at which other instances of process_each are
+ * called.
+ *
+ * This function returns 0 (failed) if the caller requires all specified
+ * devices to be created, and any of those devices are not found, or any of
+ * them cannot be created.
+ *
+ * This function returns 1 (success) if the caller requires all specified
+ * devices to be created, and all are created, or if the caller does not
+ * require all specified devices to be created and one or more were created.
+ *
+ * When this function returns 1 (success), it returns to the caller with the
+ * VG_ORPHANS write lock held.
+ */
+
+int pvcreate_each_device(struct cmd_context *cmd,
+			 struct processing_handle *handle,
+			 struct pvcreate_each_params *pp)
+{
+	struct pvcreate_restorable_params rp;
+	struct pvcreate_device *pd, *pd2;
+	struct pvcreate_prompt *prompt, *prompt2;
+	struct physical_volume *pv;
+	struct volume_group *orphan_vg;
+	struct dm_list arg_sort;
+	struct pv_list *pvl;
+	struct pv_list *vgpvl;
+	const char *pv_name;
+	int consistent = 0;
+	int must_use_all = (cmd->command->flags & MUST_USE_ALL_ARGS);
+	int found;
+	int i;
+
+	dm_list_init(&arg_sort);
+
+	handle->custom_handle = pp;
+
+	/*
+	 * Create a list entry for each name arg.
+	 */
+	for (i = 0; i < pp->pv_count; i++) {
+		dm_unescape_colons_and_at_signs(pp->pv_names[i], NULL, NULL);
+
+		pv_name = pp->pv_names[i];
+
+		if (!(pd = dm_pool_zalloc(cmd->mem, sizeof(*pd)))) {
+			log_error("alloc failed");
+			return 0;
+		}
+
+		if (!(pd->name = dm_pool_strdup(cmd->mem, pv_name))) {
+			log_error("strdup failed");
+			return 0;
+		}
+
+		dm_list_add(&pp->arg_devices, &pd->list);
+	}
+
+	/*
+	 * This function holds the orphans lock while reading VGs to look for
+	 * devices.  This means the orphans lock is held while VG locks are
+	 * acquired, which is against lvmcache lock ordering rules, so disable
+	 * the lvmcache lock ordering checks.
+	 */
+	lvmcache_lock_ordering(0);
+
+	/*
+	 * Clear the cache before acquiring the orphan lock.  (Clearing the
+	 * cache with locks held is an error.)  We want the orphan lock
+	 * acquired before process_each_pv.  If the orphan lock is not held
+	 * when process_each_pv is called, then process_each_pv clears the
+	 * cache.
+	 */
+	lvmcache_destroy(cmd, 1, 0);
+
+	/*
+	 * If no prompts require a user response, this orphan lock is held
+	 * throughout, and pvcreate_each_device() returns with it held so that
+	 * vgcreate/vgextend use the PVs created here to add to a VG.
+	 */
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
+
+	dev_cache_full_scan(cmd->full_filter);
+
+	/*
+	 * Use process_each_pv to search all existing PVs and devices.
+	 *
+	 * This is a slightly different way to use process_each_pv, because the
+	 * command args (arg_devices) are not being processed directly by
+	 * process_each_pv (argc and argv are not passed).  Instead,
+	 * process_each_pv is processing all existing PVs and devices, and the
+	 * single function is matching each of those against the command args
+	 * (arg_devices).
+	 *
+	 * If an arg_devices entry is found during process_each_pv, it's moved
+	 * to arg_process if it can be used, or arg_fail if it cannot be used.
+	 * If it's added to arg_process but needs a prompt or force option, then
+	 * a corresponding prompt entry is added to pp->prompts.
+	 */
+	process_each_pv(cmd, 0, NULL, NULL, 1, 0, handle, _pvcreate_check1_single);
+
+	/*
+	 * A fatal error was found while checking.
+	 */
+	if (pp->check_failed)
+		goto_bad;
+
+	/*
+	 * Check if all arg_devices were found by process_each_pv.
+	 */
+	dm_list_iterate_items(pd, &pp->arg_devices)
+		log_error("Device %s not found (or ignored by filtering).", pd->name);
+
+	/*
+	 * Can the command continue if some specified devices were not found?
+	 */
+	if (!dm_list_empty(&pp->arg_devices) && must_use_all)
+		goto_bad;
+
+	/*
+	 * Can the command continue if some specified devices cannot be used?
+	 */
+	if (!dm_list_empty(&pp->arg_fail) && must_use_all)
+		goto_bad;
+
+	/*
+	 * The command cannot continue if there are no devices to create.
+	 */
+	if (dm_list_empty(&pp->arg_process)) {
+		log_error("No devices found.");
+		goto_bad;
+	}
+
+	/*
+	 * Clear any prompts that have answers without asking the user. 
+	 */
+	dm_list_iterate_items_safe(prompt, prompt2, &pp->prompts) {
+		_check_pvcreate_prompt(cmd, pp, prompt, 0);
+
+		switch (prompt->answer) {
+		case PROMPT_ANSWER_YES:
+			/* The PV can be used, leave it on arg_process. */
+			dm_list_del(&prompt->list);
+			break;
+		case PROMPT_ANSWER_NO:
+			/* The PV cannot be used, remove it from arg_process. */
+			if ((pd = _pvcreate_list_find_dev(&pp->arg_process, prompt->dev)))
+				dm_list_move(&pp->arg_fail, &pd->list);
+			dm_list_del(&prompt->list);
+			break;
+		}
+	}
+
+	if (!dm_list_empty(&pp->arg_fail) && must_use_all)
+		goto_bad;
+
+	/*
+	 * If no remaining prompts need a user response, then keep orphans
+	 * locked and go directly to the create steps. 
+	 */
+	if (dm_list_empty(&pp->prompts))
+		goto do_command;
+
+	/*
+	 * Prompts require asking the user, so release the orphans lock, ask
+	 * the questions, reacquire the orphans lock, verify that the PVs were
+	 * not used during the questions, then do the create steps.
+	 */
+	unlock_vg(cmd, VG_ORPHANS);
+
+	/*
+	 * Process prompts that require asking the user.  The orphans lock is
+	 * not held, so there's no harm in waiting for a user to respond.
+	 */
+	dm_list_iterate_items_safe(prompt, prompt2, &pp->prompts) {
+		_check_pvcreate_prompt(cmd, pp, prompt, 1);
+
+		switch (prompt->answer) {
+		case PROMPT_ANSWER_YES:
+			/* The PV can be used, leave it on arg_process. */
+			dm_list_del(&prompt->list);
+			break;
+		case PROMPT_ANSWER_NO:
+			/* The PV cannot be used, remove it from arg_process. */
+			if ((pd = _pvcreate_list_find_dev(&pp->arg_process, prompt->dev)))
+				dm_list_move(&pp->arg_fail, &pd->list);
+			dm_list_del(&prompt->list);
+			break;
+		}
+
+		if (!dm_list_empty(&pp->arg_fail) && must_use_all)
+			goto_out;
+
+		if (sigint_caught())
+			goto_out;
+
+		if (prompt->abort_command)
+			goto_out;
+	}
+
+	/*
+	 * Clear the cache, reacquire the orphans write lock, then check again
+	 * that the devices can still be used.  If the second loop finds them
+	 * changed, or can't find them any more, then they aren't used.
+	 * Clear the cache here before locking orphans, since it won't be
+	 * done by process_each_pv with orphans already locked.
+	 */
+
+	lvmcache_destroy(cmd, 1, 0);
+
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for orphan PVs");
+		goto_out;
+	}
+
+	/*
+	 * The device args began on the arg_devices list, then the first check
+	 * loop moved those entries to arg_process as they were found.  Devices
+	 * not found during the first loop are not being used, and remain on
+	 * arg_devices.
+	 * 
+	 * Now, the arg_process entries are moved to arg_confirm, and the second
+	 * check loop moves them back to arg_process as they are found and are
+	 * unchanged.  Like the first loop, the second loop moves an entry to
+	 * arg_fail if it cannot be used.  After the second loop, any devices
+	 * remaining on arg_confirm were not found and are not used.
+	 */
+
+	dm_list_splice(&pp->arg_confirm, &pp->arg_process);
+
+	process_each_pv(cmd, 0, NULL, NULL, 1, 0, handle, _pvcreate_check2_single);
+
+	dm_list_iterate_items(pd, &pp->arg_confirm)
+		log_error("Device %s not found (or ignored by filtering).", pd->name);
+
+	/* Some devices were not found during the second check. */
+	if (!dm_list_empty(&pp->arg_confirm) && must_use_all)
+		goto_bad;
+
+	/* Some devices changed during the second check. */
+	if (!dm_list_empty(&pp->arg_fail) && must_use_all)
+		goto_bad;
+
+	if (dm_list_empty(&pp->arg_process)) {
+		log_error("No devices found.");
+		goto_bad;
+	}
+
+do_command:
+
+	/*
+	 * Reorder arg_process entries to match the original order of args.
+	 */
+	dm_list_splice(&arg_sort, &pp->arg_process);
+	for (i = 0; i < pp->pv_count; i++) {
+		if ((pd = _pvcreate_list_find_name(&arg_sort, pp->pv_names[i])))
+			dm_list_move(&pp->arg_process, &pd->list);
+	}
+
+	dm_list_splice(&pp->arg_create, &pp->arg_process);
+
+	/*
+	 * Wipe signatures on devices being created.
+	 */
+	dm_list_iterate_items_safe(pd, pd2, &pp->arg_create) {
+		log_verbose("Wiping signatures on new PV %s", pd->name);
+
+		if (!wipe_known_signatures(cmd, pd->dev, pd->name, TYPE_LVM1_MEMBER | TYPE_LVM2_MEMBER,
+					    0, pp->yes, pp->force, &pd->wiped)) {
+			dm_list_move(&pp->arg_fail, &pd->list);
+		}
+
+		if (sigint_caught())
+			goto_bad;
+	}
+
+	if (!dm_list_empty(&pp->arg_fail) && must_use_all)
+		goto_bad;
+
+	/*
+	 * Find existing orphan PVs that vgcreate or vgextend want to use.
+	 * "preserve_existing" means that the command wants to use existing PVs
+	 * and not recreate a new PV on top of an existing PV.
+	 */
+	if (pp->preserve_existing && pp->orphan_vg_name) {
+		log_debug("Using existing orphan PVs in %s", pp->orphan_vg_name);
+
+		if (!(orphan_vg = vg_read_internal(cmd, pp->orphan_vg_name, NULL, 0, &consistent))) {
+			log_error("Cannot read orphans VG %s", pp->orphan_vg_name);
+			goto_bad;
+		}
+
+		dm_list_iterate_items_safe(pd, pd2, &pp->arg_create) {
+			if (!pd->is_orphan_pv)
+				continue;
+
+			if (!(pvl = dm_pool_alloc(cmd->mem, sizeof(*pvl)))) {
+				log_error("alloc pvl failed");
+				dm_list_move(&pp->arg_fail, &pd->list);
+				continue;
+			}
+
+			found = 0;
+			dm_list_iterate_items(vgpvl, &orphan_vg->pvs) {
+				if (vgpvl->pv->dev == pd->dev) {
+					found = 1;
+					break;
+				}
+			}
+
+			if (found) {
+				log_debug("Using existing orphan PV %s", pv_dev_name(vgpvl->pv));
+				pvl->pv = vgpvl->pv;
+				dm_list_add(&pp->pvs, &pvl->list);
+			} else {
+				log_error("Failed to find PV %s", pd->name);
+				dm_list_move(&pp->arg_fail, &pd->list);
+			}
+		}
+	}
+
+	/*
+	 * Create PVs on devices.  Either create a new PV on top of an existing
+	 * one (e.g. for pvcreate), or create a new PV on a device that is not
+	 * a PV.
+	 */
+	dm_list_iterate_items_safe(pd, pd2, &pp->arg_create) {
+		/* Using existing orphan PVs is covered above. */
+		if (pp->preserve_existing && pd->is_orphan_pv)
+			continue;
+
+		if (!dm_list_empty(&pp->arg_fail) && must_use_all)
+			break;
+
+		if (!(pvl = dm_pool_alloc(cmd->mem, sizeof(*pvl)))) {
+			log_error("alloc pvl failed");
+			dm_list_move(&pp->arg_fail, &pd->list);
+		}
+
+		pv_name = pd->name;
+
+		log_debug("Creating a new PV on %s", pv_name);
+
+		/* FIXME: get rid of rp usage in pv_create to avoid this. */
+		memset(&rp, 0, sizeof(rp));
+		rp.restorefile = pp->restorefile;
+		if (pp->uuid_str) {
+			rp.id = pp->id;
+			rp.idp = &pp->id;
+		}
+		rp.ba_start = pp->ba_start;
+		rp.ba_size = pp->ba_size;
+		rp.pe_start = pp->pe_start;
+		rp.extent_count = pp->extent_count;
+		rp.extent_size = pp->extent_size;
+
+		if (!(pv = pv_create(cmd, pd->dev, pp->size, pp->data_alignment,
+				     pp->data_alignment_offset, pp->labelsector,
+				     pp->pvmetadatacopies, pp->pvmetadatasize,
+				     pp->metadataignore, &rp))) {
+			log_error("Failed to setup physical volume \"%s\"", pv_name);
+			dm_list_move(&pp->arg_fail, &pd->list);
+			continue;
+		}
+
+		log_verbose("Set up physical volume for \"%s\" with %" PRIu64
+			    " available sectors", pv_name, pv_size(pv));
+
+		if (!label_remove(pv->dev)) {
+			log_error("Failed to wipe existing label on %s", pv_name);
+			dm_list_move(&pp->arg_fail, &pd->list);
+			continue;
+		}
+
+		if (pp->zero) {
+			log_verbose("Zeroing start of device %s", pv_name);
+
+			if (!dev_open_quiet(pv->dev)) {
+				log_error("%s not opened: device not zeroed", pv_name);
+				dm_list_move(&pp->arg_fail, &pd->list);
+				continue;
+			}
+
+			if (!dev_set(pv->dev, UINT64_C(0), (size_t) 2048, 0)) {
+                        	log_error("%s not wiped: aborting", pv_name);
+                        	if (!dev_close(pv->dev))
+                                	stack;
+				dm_list_move(&pp->arg_fail, &pd->list);
+				continue;
+                	}
+                	if (!dev_close(pv->dev))
+                        	stack;
+		}
+
+		log_verbose("Writing physical volume data to disk \"%s\"", pv_name);
+
+		if (!pv_write(cmd, pv, 0)) {
+			log_error("Failed to write physical volume \"%s\"", pv_name);
+			dm_list_move(&pp->arg_fail, &pd->list);
+		}
+
+		log_print_unless_silent("Physical volume \"%s\" successfully created", pv_name);
+
+		pvl->pv = pv;
+		dm_list_add(&pp->pvs, &pvl->list);
+	}
+
+	dm_list_iterate_items(pvl, &pp->pvs)
+		log_debug("pv command succeeded for %s", pv_dev_name(pvl->pv));
+
+	dm_list_iterate_items(pd, &pp->arg_fail)
+		log_debug("pv command failed for %s", pd->name);
+
+	if (!dm_list_empty(&pp->arg_fail))
+		goto_bad;
+
+	/*
+	 * Returns with VG_ORPHANS write lock held because vgcreate and
+	 * vgextend want to use the newly created PVs.
+	 */
+	return 1;
+
+bad:
+	unlock_vg(cmd, VG_ORPHANS);
+out:
+	return 0;
+}
+
diff --git a/tools/toollib.h b/tools/toollib.h
index fc502b9..0ef9e92 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -101,8 +101,8 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 		    struct processing_handle *handle,
 		    process_single_vg_fn_t process_single_vg);
 
-int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
-		    const char *vg_name, uint32_t read_flags,
+int process_each_pv(struct cmd_context *cmd, int argc, char **argv, const char *vg_name,
+		    int all_is_set, uint32_t read_flags,
 		    struct processing_handle *handle,
 		    process_single_pv_fn_t process_single_pv);
 
@@ -152,6 +152,10 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
 const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 			 unsigned *dev_dir_found);
 
+void pvcreate_each_params_set_defaults(struct pvcreate_each_params *pp);
+int pvcreate_each_params_from_args(struct cmd_context *cmd, struct pvcreate_each_params *pp);
+int pvcreate_each_device(struct cmd_context *cmd, struct processing_handle *handle, struct pvcreate_each_params *pp);
+
 /*
  * Builds a list of pv's from the names in argv.  Used in
  * lvcreate/extend.
diff --git a/tools/tools.h b/tools/tools.h
index 979b5e3..5875376 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -107,6 +107,8 @@ struct arg_value_group_list {
 #define NO_METADATA_PROCESSING	0x00000040
 /* Command wants to scan for new devices and force labels to be read from them all. */
 #define REQUIRES_FULL_LABEL_SCAN 0x00000080
+/* Command must use all specified arg names and fail if all cannot be used. */
+#define MUST_USE_ALL_ARGS        0x00000100
  
 /* a register of the lvm commands */
 struct command {
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 2efaa7c..41b5b83 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -188,7 +188,7 @@ int vgreduce(struct cmd_context *cmd, int argc, char **argv)
 		/* FIXME: Pass private struct through to all these functions */
 		/* and update in batch afterwards? */
 		return process_each_pv(cmd, argc, argv, vg_name,
-				       READ_FOR_UPDATE, NULL,
+				       0, READ_FOR_UPDATE, NULL,
 				      _vgreduce_single);
 
 	log_verbose("Finding volume group \"%s\"", vg_name);


