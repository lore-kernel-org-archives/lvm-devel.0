From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 26 Oct 2015 21:09:41 +0000 (UTC)
Subject: master - pvs: fix missing PVs when VG is removed
Message-ID: <20151026210941.DC3AD60F93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6624833839645cbe75af073fd1dd9ab8c78e0d03
Commit:        6624833839645cbe75af073fd1dd9ab8c78e0d03
Parent:        b29593378f41f6dd401fb9582fba1a100f33dbbb
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 23 15:09:20 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 26 16:07:12 2015 -0500

pvs: fix missing PVs when VG is removed

PVs could be missing from the 'pvs' output if
their VG was removed at the same time that the
'pvs' command was run.  To fix this:

1. If a VG is not found when processed, don't
silently skip the PVs in it, as is done when
the "skip" variable is set.

2. Repeat the VG search if some PVs are not
found on the first search through all VGs.
The second search uses a specific list of
PVs that were missed the first time.

testing:
/dev/sdb is a PV
/dev/sdd is a PV
/dev/sdg is not a PV

each test begins with:
vgcreate test /dev/sdb /dev/sdd

variations to test:
vgremove -f test & pvs
vgremove -f test & pvs -a
vgremove -f test & pvs /dev/sdb /dev/sdd
vgremove -f test & pvs /dev/sdg
vgremove -f test & pvs /dev/sdb /dev/sdg

The pvs command should always display /dev/sdb
and /dev/sdd, either as a part of VG test or not.

The pvs command should always print an error
indicating that /dev/sdg could not be found.
---
 tools/toollib.c |  125 +++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 116 insertions(+), 9 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index fba075a..843a47b 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -184,14 +184,16 @@ const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
  *   If *skip is 1, it's OK for the caller to read the list of PVs in the VG.
  */
 static int _ignore_vg(struct volume_group *vg, const char *vg_name,
-		      struct dm_list *arg_vgnames, uint32_t read_flags, int *skip)
+		      struct dm_list *arg_vgnames, uint32_t read_flags,
+		      int *skip, int *notfound)
 {
 	uint32_t read_error = vg_read_error(vg);
+
 	*skip = 0;
+	*notfound = 0;
 
 	if ((read_error & FAILED_NOTFOUND) && (read_flags & READ_OK_NOTFOUND)) {
-		read_error &= ~FAILED_NOTFOUND;
-		*skip = 1;
+		*notfound = 1;
 		return 0;
 	}
 
@@ -1924,6 +1926,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	int skip;
+	int notfound;
 	int process_all = 0;
 
 	/*
@@ -1942,6 +1945,7 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
 		skip = 0;
+		notfound = 0;
 
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
 			ret_max = ECMD_FAILED;
@@ -1949,12 +1953,12 @@ static int _process_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		}
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags, lockd_state);
-		if (_ignore_vg(vg, vg_name, arg_vgnames, flags, &skip)) {
+		if (_ignore_vg(vg, vg_name, arg_vgnames, flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			goto endvg;
 		}
-		if (skip)
+		if (skip || notfound)
 			goto endvg;
 
 		/* Process this VG? */
@@ -2392,6 +2396,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	int skip;
+	int notfound;
 
 	dm_list_iterate_items(vgnl, vgnameids_to_process) {
 		if (sigint_caught())
@@ -2400,6 +2405,7 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
 		skip = 0;
+		notfound = 0;
 
 		/*
 		 * arg_lvnames contains some elements that are just "vgname"
@@ -2437,13 +2443,12 @@ static int _process_lv_vgnameid_list(struct cmd_context *cmd, uint32_t flags,
 		}
 
 		vg = vg_read(cmd, vg_name, vg_uuid, flags, lockd_state);
-		if (_ignore_vg(vg, vg_name, arg_vgnames, flags, &skip)) {
+		if (_ignore_vg(vg, vg_name, arg_vgnames, flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			goto endvg;
-
 		}
-		if (skip)
+		if (skip || notfound)
 			goto endvg;
 
 		ret = process_each_lv_in_vg(cmd, vg, &lvnames, tags_arg, 0,
@@ -2688,6 +2693,59 @@ static struct device_id_list *_device_list_find_pvid(struct dm_list *devices, st
 	return NULL;
 }
 
+static int _device_list_copy(struct cmd_context *cmd, struct dm_list *src, struct dm_list *dst)
+{
+	struct device_id_list *dil;
+	struct device_id_list *dil_new;
+
+	dm_list_iterate_items(dil, src) {
+		if (!(dil_new = dm_pool_alloc(cmd->mem, sizeof(*dil_new)))) {
+			log_error("device_id_list alloc failed.");
+			return ECMD_FAILED;
+		}
+
+		dil_new->dev = dil->dev;
+		strncpy(dil_new->pvid, dil->pvid, ID_LEN);
+		dm_list_add(dst, &dil_new->list);
+	}
+
+	return ECMD_PROCESSED;
+}
+
+/*
+ * For each device in arg_devices or all_devices that has a pvid, add a copy of
+ * that device to arg_missed.  All PVs (devices with a pvid) should have been
+ * found while processing all VGs (including orphan VGs).  But, some may have
+ * been missed if VGs were changing at the same time.  This function creates a
+ * list of PVs that still remain in the given list, i.e. were missed the first
+ * time.  A second iteration through VGs can look for these explicitly.
+ * (arg_devices is used if specific PVs are being processed; all_devices is
+ * used if all devs are being processed)
+ */
+static int _get_missed_pvs(struct cmd_context *cmd,
+			   struct dm_list *devices,
+			   struct dm_list *arg_missed)
+{
+	struct device_id_list *dil;
+	struct device_id_list *dil_missed;
+
+	dm_list_iterate_items(dil, devices) {
+		if (!dil->pvid[0])
+			continue;
+
+		if (!(dil_missed = dm_pool_alloc(cmd->mem, sizeof(*dil_missed)))) {
+			log_error("device_id_list alloc failed.");
+			return ECMD_FAILED;
+		}
+
+		dil_missed->dev = dil->dev;
+		strncpy(dil_missed->pvid, dil->pvid, ID_LEN);
+		dm_list_add(arg_missed, &dil_missed->list);
+	}
+
+	return ECMD_PROCESSED;
+}
+
 static int _process_device_list(struct cmd_context *cmd, struct dm_list *all_devices,
 				struct processing_handle *handle,
 				process_single_pv_fn_t process_single_pv)
@@ -2921,6 +2979,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 	int ret_max = ECMD_PROCESSED;
 	int ret;
 	int skip;
+	int notfound;
 
 	dm_list_iterate_items(vgnl, all_vgnameids) {
 		if (sigint_caught())
@@ -2929,6 +2988,7 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		vg_name = vgnl->vg_name;
 		vg_uuid = vgnl->vgid;
 		skip = 0;
+		notfound = 0;
 
 		if (!lockd_vg(cmd, vg_name, NULL, 0, &lockd_state)) {
 			ret_max = ECMD_FAILED;
@@ -2936,13 +2996,15 @@ static int _process_pvs_in_vgs(struct cmd_context *cmd, uint32_t read_flags,
 		}
 
 		vg = vg_read(cmd, vg_name, vg_uuid, read_flags, lockd_state);
-		if (_ignore_vg(vg, vg_name, NULL, read_flags, &skip)) {
+		if (_ignore_vg(vg, vg_name, NULL, read_flags, &skip, &notfound)) {
 			stack;
 			ret_max = ECMD_FAILED;
 			if (!skip)
 				goto endvg;
 			/* Drop through to eliminate a clustered VG's PVs from the devices list */
 		}
+		if (notfound)
+			goto endvg;
 		
 		/*
 		 * Don't continue when skip is set, because we need to remove
@@ -2982,6 +3044,7 @@ int process_each_pv(struct cmd_context *cmd,
 	struct dm_list arg_tags;	/* str_list */
 	struct dm_list arg_pvnames;	/* str_list */
 	struct dm_list arg_devices;	/* device_id_list */
+	struct dm_list arg_missed;	/* device_id_list */
 	struct dm_list all_vgnameids;	/* vgnameid_list */
 	struct dm_list all_devices;	/* device_id_list */
 	struct device_id_list *dil;
@@ -3009,6 +3072,7 @@ int process_each_pv(struct cmd_context *cmd,
 	dm_list_init(&arg_tags);
 	dm_list_init(&arg_pvnames);
 	dm_list_init(&arg_devices);
+	dm_list_init(&arg_missed);
 	dm_list_init(&all_vgnameids);
 	dm_list_init(&all_devices);
 
@@ -3068,6 +3132,49 @@ int process_each_pv(struct cmd_context *cmd,
 	if (ret > ret_max)
 		ret_max = ret;
 
+	/*
+	 * Some PVs may have been missed by the first search if another command
+	 * moved them at the same time.  Repeat the search for only the
+	 * specific PVs missed.  lvmcache needs clearing for a fresh search.
+	 *
+	 * If missed PVs are found in this repeated search, they are removed
+	 * from the arg_missed list, but they also need to be removed from the
+	 * arg_devices list, otherwise the check at the end will produce an
+	 * error, thinking they weren't found.  This is the reason for saving
+	 * and comparing the original arg_missed list.
+	 */
+	if (!process_all_pvs)
+		_get_missed_pvs(cmd, &arg_devices, &arg_missed);
+	else
+		_get_missed_pvs(cmd, &all_devices, &arg_missed);
+
+	if (!dm_list_empty(&arg_missed)) {
+		struct dm_list arg_missed_orig;
+
+		dm_list_init(&arg_missed_orig);
+		_device_list_copy(cmd, &arg_missed, &arg_missed_orig);
+
+		log_warn("Some PVs were not found in first search, retrying.");
+
+		lvmcache_destroy(cmd, 0, 0);
+		lvmcache_init();
+		lvmcache_seed_infos_from_lvmetad(cmd);
+
+		ret = _process_pvs_in_vgs(cmd, read_flags, &all_vgnameids, &all_devices,
+					  &arg_missed, &arg_tags, 0, 0,
+					  handle, process_single_pv);
+		if (ret != ECMD_PROCESSED)
+			stack;
+		if (ret > ret_max)
+			ret_max = ret;
+
+		/* Devices removed from arg_missed are removed from arg_devices. */
+		dm_list_iterate_items(dil, &arg_missed_orig) {
+			if (!_device_list_find_dev(&arg_missed, dil->dev))
+				_device_list_remove(&arg_devices, dil->dev);
+		}
+	}
+
 	dm_list_iterate_items(dil, &arg_devices) {
 		log_error("Failed to find physical volume \"%s\".", dev_name(dil->dev));
 		ret_max = ECMD_FAILED;


