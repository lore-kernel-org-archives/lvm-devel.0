From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 14 Dec 2015 22:58:48 +0000 (UTC)
Subject: master - vgrename: use process_each_vg
Message-ID: <20151214225848.DD16960257@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=796461a9125a8324a63be154fc998245617e5990
Commit:        796461a9125a8324a63be154fc998245617e5990
Parent:        37bd35bc3ddbd4b669c523e2f56aaa68682df2ad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 1 14:09:01 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Dec 14 14:26:47 2015 -0600

vgrename: use process_each_vg

Use process_each_vg() to lock and read the old VG,
and then call the main vgrename code.

When real VG names are used (not a UUID in place of the
old name), the command still pre-locks the new name
(when strcmp wants it locked first), before calling
process_each_vg on the old name.

In the case where the old name is replaced with a UUID,
process_each_vg now translates that UUID into the real
VG name, which it locks and reads.  In this case, we
cannot do pre-locking to maintain lock ordering because
the old name is unknown.  So, in this case the strcmp
based lock ordering is suppressed and the old name is
always locked first.  This opens a remote chance for
lock ordering conflict between racing vgrenames between
two names where one or both commands use the UUID.
---
 daemons/clvmd/lvm-functions.c |    3 +-
 lib/cache/lvmcache.c          |   51 ++++++--
 lib/cache/lvmcache.h          |   13 ++-
 lib/format_pool/disk_rep.c    |    4 +-
 lib/format_text/format-text.c |    2 +-
 lib/metadata/metadata.c       |   23 ++--
 liblvm/lvm_vg.c               |    3 +-
 tools/commands.h              |    2 +-
 tools/reporter.c              |    2 +-
 tools/toollib.c               |   10 ++
 tools/tools.h                 |    2 +
 tools/vgrename.c              |  290 ++++++++++++++++++++++-------------------
 12 files changed, 242 insertions(+), 163 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index ae9d22b..03963cc 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -663,7 +663,8 @@ int do_refresh_cache(void)
 
 	init_full_scan_done(0);
 	init_ignore_suspended_devices(1);
-	lvmcache_label_scan(cmd, 2);
+	lvmcache_force_next_label_scan();
+	lvmcache_label_scan(cmd);
 	dm_pool_empty(cmd->mem);
 
 	pthread_mutex_unlock(&lvm_lock);
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2a01ec2..998ea6f 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -82,6 +82,7 @@ static int _has_scanned = 0;
 static int _vgs_locked = 0;
 static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
 static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
+static int _suppress_lock_ordering = 0;
 
 int lvmcache_init(void)
 {
@@ -371,6 +372,11 @@ static int _vgname_order_correct(const char *vgname1, const char *vgname2)
 	return 0;
 }
 
+void lvmcache_lock_ordering(int enable)
+{
+	_suppress_lock_ordering = !enable;
+}
+
 /*
  * Ensure VG locks are acquired in alphabetical order.
  */
@@ -379,6 +385,9 @@ int lvmcache_verify_lock_order(const char *vgname)
 	struct dm_hash_node *n;
 	const char *vgname2;
 
+	if (_suppress_lock_ordering)
+		return 1;
+
 	if (!_lock_hash)
 		return_0;
 
@@ -743,7 +752,24 @@ static int _scan_invalid(void)
 	return 1;
 }
 
-int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
+/*
+ * lvmcache_label_scan() remembers that it has already
+ * been called, and will not scan labels if it's called
+ * again.  (It will rescan "INVALID" devices if called again.)
+ *
+ * To force lvmcache_label_scan() to rescan labels on all devices,
+ * call lvmcache_force_next_label_scan() before calling
+ * lvmcache_label_scan().
+ */
+
+static int _force_label_scan;
+
+void lvmcache_force_next_label_scan(void)
+{
+	_force_label_scan = 1;
+}
+
+int lvmcache_label_scan(struct cmd_context *cmd)
 {
 	struct label *label;
 	struct dev_iter *iter;
@@ -767,15 +793,15 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 		goto out;
 	}
 
-	if (_has_scanned && !full_scan) {
+	if (_has_scanned && !_force_label_scan) {
 		r = _scan_invalid();
 		goto out;
 	}
 
-	if (full_scan == 2 && (cmd->full_filter && !cmd->full_filter->use_count) && !refresh_filters(cmd))
+	if (_force_label_scan && (cmd->full_filter && !cmd->full_filter->use_count) && !refresh_filters(cmd))
 		goto_out;
 
-	if (!cmd->full_filter || !(iter = dev_iter_create(cmd->full_filter, (full_scan == 2) ? 1 : 0))) {
+	if (!cmd->full_filter || !(iter = dev_iter_create(cmd->full_filter, _force_label_scan))) {
 		log_error("dev_iter creation failed");
 		goto out;
 	}
@@ -803,7 +829,7 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 	 * If we are a long-lived process, write out the updated persistent
 	 * device cache for the benefit of short-lived processes.
 	 */
-	if (full_scan == 2 && cmd->is_long_lived &&
+	if (_force_label_scan && cmd->is_long_lived &&
 	    cmd->dump_filter && cmd->full_filter && cmd->full_filter->dump &&
 	    !cmd->full_filter->dump(cmd->full_filter, 0))
 		stack;
@@ -812,6 +838,7 @@ int lvmcache_label_scan(struct cmd_context *cmd, int full_scan)
 
       out:
 	_scanning_in_progress = 0;
+	_force_label_scan = 0;
 
 	return r;
 }
@@ -937,7 +964,7 @@ int lvmcache_get_vgnameids(struct cmd_context *cmd, int include_internal,
 	struct vgnameid_list *vgnl;
 	struct lvmcache_vginfo *vginfo;
 
-	lvmcache_label_scan(cmd, 0);
+	lvmcache_label_scan(cmd);
 
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (!include_internal && is_orphan_vg(vginfo->vgname))
@@ -969,7 +996,7 @@ struct dm_list *lvmcache_get_vgids(struct cmd_context *cmd,
 	struct lvmcache_vginfo *vginfo;
 
 	// TODO plug into lvmetad here automagically?
-	lvmcache_label_scan(cmd, 0);
+	lvmcache_label_scan(cmd);
 
 	if (!(vgids = str_list_create(cmd->mem))) {
 		log_error("vgids list allocation failed");
@@ -996,7 +1023,7 @@ struct dm_list *lvmcache_get_vgnames(struct cmd_context *cmd,
 	struct dm_list *vgnames;
 	struct lvmcache_vginfo *vginfo;
 
-	lvmcache_label_scan(cmd, 0);
+	lvmcache_label_scan(cmd);
 
 	if (!(vgnames = str_list_create(cmd->mem))) {
 		log_errno(ENOMEM, "vgnames list allocation failed");
@@ -1078,7 +1105,7 @@ struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct i
 	if (dev)
 		return dev;
 
-	lvmcache_label_scan(cmd, 0);
+	lvmcache_label_scan(cmd);
 
 	/* Try again */
 	dev = _device_from_pvid(pvid, label_sector);
@@ -1088,7 +1115,8 @@ struct device *lvmcache_device_from_pvid(struct cmd_context *cmd, const struct i
 	if (critical_section() || (scan_done_once && *scan_done_once))
 		return NULL;
 
-	lvmcache_label_scan(cmd, 2);
+	lvmcache_force_next_label_scan();
+	lvmcache_label_scan(cmd);
 	if (scan_done_once)
 		*scan_done_once = 1;
 
@@ -2126,7 +2154,8 @@ int lvmcache_populate_pv_fields(struct lvmcache_info *info,
 
 	/* Perform full scan (just the first time) and try again */
 	if (!scan_label_only && !critical_section() && !full_scan_done()) {
-		lvmcache_label_scan(info->fmt->cmd, 2);
+		lvmcache_force_next_label_scan();
+		lvmcache_label_scan(info->fmt->cmd);
 
 		if (_get_pv_if_in_vg(info, pv))
 			return 1;
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 509cfd6..6000ac1 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -66,9 +66,14 @@ void lvmcache_allow_reads_with_lvmetad(void);
 
 void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset);
 
-/* Set full_scan to 1 to reread every filtered device label or
- * 2 to rescan /dev for new devices */
-int lvmcache_label_scan(struct cmd_context *cmd, int full_scan);
+/*
+ * lvmcache_label_scan() will scan labels the first time it's
+ * called, but not on subsequent calls, unless
+ * lvmcache_force_next_label_scan() is called first
+ * to force the next lvmcache_label_scan() to scan again.
+ */
+void lvmcache_force_next_label_scan(void);
+int lvmcache_label_scan(struct cmd_context *cmd);
 
 /* Add/delete a device */
 struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
@@ -197,4 +202,6 @@ void lvmcache_get_max_name_lengths(struct cmd_context *cmd,
 
 int lvmcache_vg_is_foreign(struct cmd_context *cmd, const char *vgname, const char *vgid);
 
+void lvmcache_lock_ordering(int enable);
+
 #endif
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index fef0451..418a16e 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -373,7 +373,9 @@ int read_pool_pds(const struct format_type *fmt, const char *vg_name,
 					   vg_name);
 			return 0;
 		}
-		lvmcache_label_scan(fmt->cmd, full_scan);
+		if (full_scan > 0)
+			lvmcache_force_next_label_scan();
+		lvmcache_label_scan(fmt->cmd);
 
 	} while (1);
 
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 58d6209..9aad0fe 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1963,7 +1963,7 @@ static int _create_vg_text_instance(struct format_instance *fid,
 			 */
 			if (!critical_section())
 				/* Scan PVs in VG for any further MDAs */
-				lvmcache_label_scan(fid->fmt->cmd, 0);
+				lvmcache_label_scan(fid->fmt->cmd);
 
 			if (!(vginfo = lvmcache_vginfo_from_vgname(vg_name, vg_id)))
 				goto_out;
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 52647c3..ae40906 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1539,7 +1539,8 @@ out:
 		}
 
 	if (scan_needed) {
-		if (!lvmcache_label_scan(cmd, 2)) {
+		lvmcache_force_next_label_scan();
+		if (!lvmcache_label_scan(cmd)) {
 			stack;
 			r = 0;
 		}
@@ -3299,7 +3300,7 @@ static struct volume_group *_vg_read_orphans(struct cmd_context *cmd,
 	struct pv_list head;
 
 	dm_list_init(&head.list);
-	lvmcache_label_scan(cmd, 0);
+	lvmcache_label_scan(cmd);
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (!(vginfo = lvmcache_vginfo_from_vgname(orphan_vgname, NULL)))
@@ -3605,12 +3606,13 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
 	if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 1))) {
-		lvmcache_label_scan(cmd, 0);
+		lvmcache_label_scan(cmd);
 		if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 1))) {
 			/* Independent MDAs aren't supported under low memory */
 			if (!cmd->independent_metadata_areas && critical_section())
 				return_NULL;
-			lvmcache_label_scan(cmd, 2);
+			lvmcache_force_next_label_scan();
+			lvmcache_label_scan(cmd);
 			if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0)))
 				return_NULL;
 		}
@@ -3820,7 +3822,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		/* Independent MDAs aren't supported under low memory */
 		if (!cmd->independent_metadata_areas && critical_section())
 			return_NULL;
-		lvmcache_label_scan(cmd, 2);
+		lvmcache_force_next_label_scan();
+		lvmcache_label_scan(cmd);
 		if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0)))
 			return_NULL;
 
@@ -4113,7 +4116,8 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	 *       allowed to do a full scan here any more. */
 
 	// The slow way - full scan required to cope with vgrename
-	lvmcache_label_scan(cmd, 2);
+	lvmcache_force_next_label_scan();
+	lvmcache_label_scan(cmd);
 	if (!(vgnames = get_vgnames(cmd, 0))) {
 		log_error("vg_read_by_vgid: get_vgnames failed");
 		return NULL;
@@ -4374,7 +4378,7 @@ static int _get_pvs(struct cmd_context *cmd, uint32_t warn_flags,
 	struct vg_list *vgl_item = NULL;
 	int have_pv = 0;
 
-	lvmcache_label_scan(cmd, 0);
+	lvmcache_label_scan(cmd);
 
 	/* Get list of VGs */
 	if (!(vgids = get_vgids(cmd, 1))) {
@@ -5179,7 +5183,7 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 	/* Find the vgname in the cache */
 	/* If it's not there we must do full scan to be completely sure */
 	if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 1)) {
-		lvmcache_label_scan(cmd, 0);
+		lvmcache_label_scan(cmd);
 		if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 1)) {
 			/* Independent MDAs aren't supported under low memory */
 			if (!cmd->independent_metadata_areas && critical_section()) {
@@ -5190,7 +5194,8 @@ uint32_t vg_lock_newname(struct cmd_context *cmd, const char *vgname)
 				unlock_vg(cmd, vgname);
 				return FAILED_LOCKING;
 			}
-			lvmcache_label_scan(cmd, 2);
+			lvmcache_force_next_label_scan();
+			lvmcache_label_scan(cmd);
 			if (!lvmcache_fmt_from_vgname(cmd, vgname, NULL, 0)) {
 				/* vgname not found after scanning */
 				return SUCCESS;
diff --git a/liblvm/lvm_vg.c b/liblvm/lvm_vg.c
index a2d42d2..1a36bcc 100644
--- a/liblvm/lvm_vg.c
+++ b/liblvm/lvm_vg.c
@@ -511,7 +511,8 @@ int lvm_scan(lvm_t libh)
 	int rc = 0;
 	struct saved_env e = store_user_env((struct cmd_context *)libh);
 
-	if (!lvmcache_label_scan((struct cmd_context *)libh, 2))
+	lvmcache_force_next_label_scan();
+	if (!lvmcache_label_scan((struct cmd_context *)libh))
 		rc = -1;
 
 	restore_user_env(&e);
diff --git a/tools/commands.h b/tools/commands.h
index 8c5162b..a10d8a3 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1323,7 +1323,7 @@ xx(vgremove,
 
 xx(vgrename,
    "Rename a volume group",
-   ALLOW_UUID_AS_NAME,
+   ALLOW_UUID_AS_NAME | REQUIRES_FULL_LABEL_SCAN,
    "vgrename\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--commandprofile ProfileName]\n"
diff --git a/tools/reporter.c b/tools/reporter.c
index 88025ec..416038c 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -582,7 +582,7 @@ static void _check_pv_list(struct cmd_context *cmd, int argc, char **argv,
 			if (!rescan_done && !dev_cache_get(argv[i], cmd->full_filter)) {
 				cmd->filter->wipe(cmd->filter);
 				/* FIXME scan only one device */
-				lvmcache_label_scan(cmd, 0);
+				lvmcache_label_scan(cmd);
 				rescan_done = 1;
 			}
 			if (*argv[i] == '@') {
diff --git a/tools/toollib.c b/tools/toollib.c
index 0b9f505..728e61d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2205,6 +2205,16 @@ int process_each_vg(struct cmd_context *cmd, int argc, char **argv,
 	}
 
 	/*
+	 * First rescan for available devices, then force the next
+	 * label scan to be done.  get_vgnameids() will scan labels
+	 * (when not using lvmetad).
+	 */
+	if (cmd->command->flags & REQUIRES_FULL_LABEL_SCAN) {
+		dev_cache_full_scan(cmd->full_filter);
+		lvmcache_force_next_label_scan();
+	}
+
+	/*
 	 * A list of all VGs on the system is needed when:
 	 * . processing all VGs on the system
 	 * . A VG name is specified which may refer to one
diff --git a/tools/tools.h b/tools/tools.h
index 010fbf4..4179cc8 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -105,6 +105,8 @@ struct arg_value_group_list {
 #define LOCKD_VG_SH		0x00000020
 /* Command does not process any metadata. */
 #define NO_METADATA_PROCESSING	0x00000040
+/* Command wants to scan for new devices and force labels to be read from them all. */
+#define REQUIRES_FULL_LABEL_SCAN 0x00000080
  
 /* a register of the lvm commands */
 struct command {
diff --git a/tools/vgrename.c b/tools/vgrename.c
index 9e6beec..e6b808b 100644
--- a/tools/vgrename.c
+++ b/tools/vgrename.c
@@ -15,137 +15,107 @@
 
 #include "tools.h"
 
-static struct volume_group *_get_old_vg_for_rename(struct cmd_context *cmd,
-						   const char *vg_name_old,
-						   const char *vgid,
-						   uint32_t lockd_state)
-{
-	struct volume_group *vg;
-
-	/* FIXME we used to print an error about EXPORTED, but proceeded
-	   nevertheless. */
-	vg = vg_read_for_update(cmd, vg_name_old, vgid, READ_ALLOW_EXPORTED, lockd_state);
-	if (vg_read_error(vg)) {
-		release_vg(vg);
-		return_NULL;
-	}
-
-	return vg;
-}
+struct vgrename_params {
+	const char *vg_name_old;
+	const char *vg_name_new;
+	unsigned int old_name_is_uuid : 1;
+	unsigned int lock_vg_old_first : 1;
+	unsigned int unlock_new_name: 1;
+};
 
 static int _lock_new_vg_for_rename(struct cmd_context *cmd,
 				   const char *vg_name_new)
 {
-	int rc;
-
-	log_verbose("Checking for new volume group \"%s\"", vg_name_new);
-
-	rc = vg_lock_newname(cmd, vg_name_new);
-
-	if (rc == FAILED_LOCKING) {
+	if (!lock_vol(cmd, vg_name_new, LCK_VG_WRITE, NULL)) {
 		log_error("Can't get lock for %s", vg_name_new);
 		return 0;
 	}
 
-	if (rc == FAILED_EXIST) {
-		log_error("New volume group \"%s\" already exists",
-			  vg_name_new);
-		return 0;
-	}
 	return 1;
 }
 
-static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
-			  const char *new_vg_path)
+static int _vgrename_single(struct cmd_context *cmd, const char *vg_name,
+			    struct volume_group *vg, struct processing_handle *handle)
 {
-	char *dev_dir;
+	struct vgrename_params *vp = (struct vgrename_params *) handle->custom_handle;
+	struct lvmcache_vginfo *vginfo;
+	char old_path[NAME_LEN];
+	char new_path[NAME_LEN];
 	struct id id;
-	int match = 0;
-	int found_id = 0;
-	struct dm_list *vgids;
-	struct dm_str_list *sl;
-	const char *vg_name_new;
-	const char *vgid = NULL, *vg_name, *vg_name_old;
-	char old_path[NAME_LEN], new_path[NAME_LEN];
-	struct volume_group *vg = NULL;
-	uint32_t lockd_state = 0;
-	int lock_vg_old_first = 1;
-
-	vg_name_old = skip_dev_dir(cmd, old_vg_path, NULL);
-	vg_name_new = skip_dev_dir(cmd, new_vg_path, NULL);
-
-	dev_dir = cmd->dev_dir;
-
-	if (!validate_vg_rename_params(cmd, vg_name_old, vg_name_new))
-		return_0;
-
-	log_verbose("Checking for existing volume group \"%s\"", vg_name_old);
-
-	/* populate lvmcache */
-	if (!lvmetad_vg_list_to_lvmcache(cmd))
-		stack;
-
-	lvmcache_label_scan(cmd, 2);
+	const char *name;
+	char *dev_dir;
 
-	/* Avoid duplicates */
-	if (!(vgids = get_vgids(cmd, 0)) || dm_list_empty(vgids)) {
-		log_error("No complete volume groups found");
-		return 0;
+	/*
+	 * vg_name_old may be a UUID which process_each_vg
+	 * replaced with the real VG name.  In that case,
+	 * vp->vg_name_old will be the UUID and vg_name will be
+	 * the actual VG name.  Check again if the old and new
+	 * names match, using the real names.
+	 */
+	if (vp->old_name_is_uuid && !strcmp(vp->vg_name_new, vg_name)) {
+		log_error("New VG name must differ from the old VG name.");
+		return ECMD_FAILED;
 	}
 
-	dm_list_iterate_items(sl, vgids) {
-		vgid = sl->str;
-		if (!vgid || !(vg_name = lvmcache_vgname_from_vgid(NULL, vgid)))
-			continue;
-		if (!strcmp(vg_name, vg_name_old)) {
-			if (match) {
-				log_error("Found more than one VG called %s. "
-					  "Please supply VG uuid.", vg_name_old);
-				return 0;
-			}
-			match = 1;
-		}
+	/*
+	 * Check if a VG already exists with the new VG name.
+	 *
+	 * When not using lvmetad, it's essential that a full scan has
+	 * been done to ensure we see all existing VG names, so we
+	 * do not use an existing name.  This has been done by
+	 * process_each_vg REQUIRES_FULL_LABEL_SCAN.
+	 *
+	 * (FIXME: We could look for the new name in the list of all
+	 * VGs that process_each_vg created, but we don't have access
+	 * to that list here, so we have to look in lvmcache.
+	 * This requires populating lvmcache when using lvmetad.)
+	 */
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
+	if ((vginfo = lvmcache_vginfo_from_vgname(vp->vg_name_new, NULL))) {
+		log_error("New VG name \"%s\" already exists", vp->vg_name_new);
+		return ECMD_FAILED;
 	}
 
-	found_id = id_read_format_try(&id, vg_name_old);
-
-	if (found_id && (vg_name = lvmcache_vgname_from_vgid(cmd->mem, (char *)id.uuid))) {
-		if (!strcmp(vg_name, vg_name_new)) {
-			log_error("New VG name must differ from the old VG name.");
-			return 0;
-		}
-
-		vg_name_old = vg_name;
-		vgid = (char *)id.uuid;
-	} else
-		vgid = NULL;
-
-	if (!lockd_vg(cmd, vg_name_old, "ex", 0, &lockd_state))
-		return_0;
-
-	if (strcmp(vg_name_new, vg_name_old) < 0)
-		lock_vg_old_first = 0;
-
-	if (lock_vg_old_first) {
-		vg = _get_old_vg_for_rename(cmd, vg_name_old, vgid, lockd_state);
-		if (!vg)
-			return_0;
+	if (id_read_format_try(&id, vp->vg_name_new) &&
+	    (name = lvmcache_vgname_from_vgid(cmd->mem, (const char *)&id))) {
+		log_error("New VG name \"%s\" matches the UUID of existing VG %s", vp->vg_name_new, name);
+		return ECMD_FAILED;
+	}
 
-		if (!_lock_new_vg_for_rename(cmd, vg_name_new)) {
-			unlock_and_release_vg(cmd, vg, vg_name_old);
-			return_0;
-		}
-	} else {
-		if (!_lock_new_vg_for_rename(cmd, vg_name_new))
-			return_0;
-
-		vg = _get_old_vg_for_rename(cmd, vg_name_old, vgid, lockd_state);
-		if (!vg) {
-			unlock_vg(cmd, vg_name_new);
-			return_0;
-		}
+	/*
+	 * Lock the old VG name first:
+	 * . The old VG name has already been locked by process_each_vg.
+	 * . Now lock the new VG name here, second.
+	 *
+	 * Lock the new VG name first:
+	 * . The new VG name has already been pre-locked below,
+	 *   before process_each_vg was called.
+	 * . process_each_vg then locked the old VG name second.
+	 * . Nothing to do here.
+	 *
+	 * Special case when the old VG name is a uuid:
+	 * . The old VG's real name wasn't known before process_each_vg,
+	 *   so the correct lock ordering wasn't known beforehand,
+	 *   so no pre-locking was done.
+	 * . The old VG's real name has been locked by process_each_vg.
+	 * . Now lock the new VG name here, second.
+	 * . Suppress lock ordering checks because the lock order may
+	 *   have wanted the new name first, which wasn't possible in
+	 *   this uuid-for-name case.
+	 */
+	if (vp->lock_vg_old_first || vp->old_name_is_uuid) {
+		if (vp->old_name_is_uuid)
+			lvmcache_lock_ordering(0);
+
+		if (!_lock_new_vg_for_rename(cmd, vp->vg_name_new))
+			return ECMD_FAILED;
+
+		lvmcache_lock_ordering(1);
 	}
 
+	dev_dir = cmd->dev_dir;
+
 	if (!archive(vg))
 		goto error;
 
@@ -159,7 +129,7 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 	}
 
 	/* Change the volume group name */
-	vg_rename(cmd, vg, vg_name_new);
+	vg_rename(cmd, vg, vp->vg_name_new);
 
 	/* store it on disks */
 	log_verbose("Writing out updated volume group");
@@ -167,8 +137,8 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 		goto error;
 	}
 
-	sprintf(old_path, "%s%s", dev_dir, vg_name_old);
-	sprintf(new_path, "%s%s", dev_dir, vg_name_new);
+	sprintf(old_path, "%s%s", dev_dir, vg_name);
+	sprintf(new_path, "%s%s", dev_dir, vp->vg_name_new);
 
 	if (activation() && dir_exists(old_path)) {
 		log_verbose("Renaming \"%s\" to \"%s\"", old_path, new_path);
@@ -189,49 +159,101 @@ static int vg_rename_path(struct cmd_context *cmd, const char *old_vg_path,
 
 	if (!backup(vg))
 		stack;
-	if (!backup_remove(cmd, vg_name_old))
+	if (!backup_remove(cmd, vg_name))
 		stack;
 
-	unlock_vg(cmd, vg_name_new);
-	unlock_and_release_vg(cmd, vg, vg_name_old);
+	unlock_vg(cmd, vp->vg_name_new);
+	vp->unlock_new_name = 0;
 
 	log_print_unless_silent("Volume group \"%s\" successfully renamed to \"%s\"",
-				vg_name_old, vg_name_new);
-
-	/* FIXME lvmcache corruption - vginfo duplicated instead of renamed */
-	if (cmd->filter->wipe)
-		cmd->filter->wipe(cmd->filter);
-	lvmcache_destroy(cmd, 1, 0);
-
+				vp->vg_name_old, vp->vg_name_new);
 	return 1;
 
-      error:
+ error:
+	unlock_vg(cmd, vp->vg_name_new);
+	vp->unlock_new_name = 0;
+
 	lockd_rename_vg_final(cmd, vg, 0);
 
-	if (lock_vg_old_first) {
-		unlock_vg(cmd, vg_name_new);
-		unlock_and_release_vg(cmd, vg, vg_name_old);
-	} else {
-		unlock_and_release_vg(cmd, vg, vg_name_old);
-		unlock_vg(cmd, vg_name_new);
-	}
 	return 0;
 }
 
 int vgrename(struct cmd_context *cmd, int argc, char **argv)
 {
+	struct vgrename_params vp = { 0 };
+	struct processing_handle *handle;
+	const char *vg_name_new;
+	const char *vg_name_old;
+	struct id id;
+	int ret;
+
 	if (argc != 2) {
 		log_error("Old and new volume group names need specifying");
 		return EINVALID_CMD_LINE;
 	}
 
+	vg_name_old = skip_dev_dir(cmd, argv[0], NULL);
+	vg_name_new = skip_dev_dir(cmd, argv[1], NULL);
+
+	if (!validate_vg_rename_params(cmd, vg_name_old, vg_name_new))
+		return_0;
+
+	if (!(vp.vg_name_old = dm_pool_strdup(cmd->mem, vg_name_old)))
+		return_ECMD_FAILED;
+
+	if (!(vp.vg_name_new = dm_pool_strdup(cmd->mem, vg_name_new)))
+		return_ECMD_FAILED;
+
 	/* Needed change the global VG namespace. */
 	if (!lockd_gl(cmd, "ex", LDGL_UPDATE_NAMES))
 		return_ECMD_FAILED;
 
-	if (!vg_rename_path(cmd, argv[0], argv[1]))
-		return_ECMD_FAILED;
+	/*
+	 * Special case where vg_name_old may be a UUID:
+	 * If vg_name_old is a UUID, then process_each may
+	 * translate it to an actual VG name that we don't
+	 * yet know.  The lock ordering, and pre-locking,
+	 * needs to be done based on VG names.  When
+	 * vg_name_old is a UUID, do not do any pre-locking
+	 * based on it, since it's likely to be wrong, and
+	 * defer all the locking to the _single function.
+	 *
+	 * When it's not a UUID, we know the two VG names,
+	 * and we can pre-lock the new VG name if the lock
+	 * ordering wants it locked before the old VG name
+	 * which will be locked by process_each.  If lock
+	 * ordering wants the old name locked first, then
+	 * the _single function will lock the new VG name.
+	 */
+	if (!(vp.old_name_is_uuid = id_read_format_try(&id, vg_name_old))) {
+		if (strcmp(vg_name_new, vg_name_old) < 0) {
+			vp.lock_vg_old_first = 0;
+			vp.unlock_new_name = 1;
+
+			if (!_lock_new_vg_for_rename(cmd, vg_name_new))
+				return ECMD_FAILED;
+		} else {
+			/* The old VG is locked by process_each_vg. */
+			vp.lock_vg_old_first = 1;
+		}
+	}
+
+	if (!(handle = init_processing_handle(cmd))) {
+		log_error("Failed to initialize processing handle.");
+		return ECMD_FAILED;
+	}
+
+	handle->custom_handle = &vp;
+
+	ret = process_each_vg(cmd, 0, NULL, vg_name_old,
+			      READ_FOR_UPDATE | READ_ALLOW_EXPORTED,
+			      handle, _vgrename_single);
+
+	/* Needed if process_each_vg returns error before calling _single. */
+	if (vp.unlock_new_name)
+		unlock_vg(cmd, vg_name_new);
 
-	return ECMD_PROCESSED;
+	destroy_processing_handle(cmd, handle);
+	return ret;
 }
 


