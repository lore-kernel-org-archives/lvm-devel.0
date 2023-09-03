From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Sun, 03 Sep 2023 20:57:46 +0000
Subject: [Git][lvmteam/lvm2][main] 16 commits: vdo: lvm_import_vdo uses devname from vdoconf.yml
Message-ID: <64f4f34a13dfc_28a3fac50294@gitlab-sidekiq-low-urgency-cpu-bound-v2-7d8d549b69-cv4xf.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
b81835b5 by Zdenek Kabelac at 2023-09-03T16:01:07+02:00
vdo: lvm_import_vdo uses devname from vdoconf.yml

VDO is using specific path for some device paths.
i.e. for /dev/sda it could be /dev/disk/by-id/scsi-xxxxx.

This used to be not a problem before lvm2 started to use snapshot,
but now it needs to replace matching device path.
So switch to the path naming used in vdoconf.yml file.

- - - - -
c693aa8d by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
vdo: enhance import script for devices file

When the import is used on a system, that uses devices file,
the final activation was impossible for the case the converted
volume was not present in devices file.
Currently add volume automatically in such case.

Also add some more debugging output from the script.

TODO: Consider enhnacing lvconvert with extending devices file.

- - - - -
aa7f2ac9 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
lvconvert: thin conversion accept passed PVs

When creating thin pool or check pool there is allocated LV
for metadata and for such allocation user should be able to
specify list of PVs on cmdline.

Also fix unused passed list of PV for thick to thin conversion,
where the code was using whole PV set from a VG (but since it&#39;s
been not enabled on cmdline, user could not hit this issue).
Also remove unneeded initialization of use_pvh.

- - - - -
29630b2d by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
dmeventd: move var set to locked section

It should not change the actual code flow, however make the
set of the current_event variable inside locked section.

- - - - -
cb61d229 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
filesystem: move stat after open check

To avoid time-of-check-time-of-use clash, take the stat()
after successful open with fstat().
Also add some debugs for failing sys calls.

- - - - -
6a0e54f8 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
clang: ensure status is initilized

Initialize status before handling error path.

- - - - -
a4884726 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
clang: ensure all variables intialized

Just in case of some wierd kernel bug, which would forget
to report these values...

- - - - -
97770d5a by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
debug: check for syscalls

Add some debug checks for possibly failing syscalls.

- - - - -
670d9825 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
debug: drop stack from regular path

- - - - -
d34d1f01 by Zdenek Kabelac at 2023-09-03T22:03:33+02:00
debug: trace result failure

- - - - -
9087ace2 by Zdenek Kabelac at 2023-09-03T22:15:48+02:00
aux: teardown also devices with testing UUID

Hunt also for devices with LVMTEST prefix in UUID.

Call teardown_devs_prefixed - so if they hold RAM or SCSI
they are closed before trying to remove kernel modules.

- - - - -
06464f7c by Zdenek Kabelac at 2023-09-03T22:33:11+02:00
tests: vdo wrapper support symlinks

Enhance internal VDO replacement wrapper script to handle symlinks
for i.e. SCSI device like VDO manager.

- - - - -
39f31210 by Zdenek Kabelac at 2023-09-03T22:33:11+02:00
tests: check passing PV list

- - - - -
b85f9c18 by Zdenek Kabelac at 2023-09-03T22:33:11+02:00
tests: vdo convert

Require VDO version 6.2.3.

Skip the part of the test that needs vdo wrapper and 2 different
versions of vdoprepareforlvm to prepare shifted VDO header
at the 2MiB offset.

- - - - -
86cf593e by Zdenek Kabelac at 2023-09-03T22:44:08+02:00
tests: vdo scsi convert

Somewhat tricky test to check VDO import of a SCSI device.

- - - - -
e9eeb840 by Zdenek Kabelac at 2023-09-03T22:51:22+02:00
WHATS_NEW: update

- - - - -


21 changed files:

- WHATS_NEW
- daemons/dmeventd/dmeventd.c
- daemons/lvmlockd/lvmlockd-dlm.c
- daemons/lvmlockd/lvmlockd-internal.h
- lib/cache/lvmcache.c
- lib/device/dev-cache.c
- lib/device/dev-mpath.c
- lib/device/device_id.c
- lib/device/filesystem.c
- lib/device/online.c
- lib/metadata/lv_manip.c
- lib/metadata/vdo_manip.c
- lib/notify/lvmnotify.c
- scripts/lvm_import_vdo.sh
- test/lib/aux.sh
- test/lib/lvm_vdo_wrapper.sh
- test/shell/lvconvert-thin-from-thick.sh
- test/shell/vdo-convert.sh
- + test/shell/vdo-scsi-convert.sh
- tools/command-lines.in
- tools/lvconvert.c


Changes:

=====================================
WHATS_NEW
=====================================
@@ -1,5 +1,7 @@
 version 2.03.23 - 
 ==================================
+  Support PV lists with thin lvconvert.
+  Fix support for lvm_import_vdo and SCSI VDO volumes.
   Recognize lvm.conf report/headings=2 for full column names in report headings.
   Add --headings none|abbrev|full cmd line option to set report headings type.
   Require writable LV for convertion to vdo pool.


=====================================
daemons/dmeventd/dmeventd.c
=====================================
@@ -1044,9 +1044,9 @@ static void *_monitor_thread(void *arg)
 			_unlock_mutex();
 
 			_do_process_event(thread);
-			thread->current_events = 0; /* Current events processed */
 
 			_lock_mutex();
+			thread->current_events = 0; /* Current events processed */
 			thread->processing = 0;
 
 			/*


=====================================
daemons/lvmlockd/lvmlockd-dlm.c
=====================================
@@ -226,14 +226,14 @@ static int get_local_nodeid(void)
 {
 	struct dirent *de;
 	DIR *ls_dir;
-	char ls_comms_path[PATH_MAX];
+	char ls_comms_path[PATH_MAX] = { 0 };
+	char path[PATH_MAX] = { 0 };
 	FILE *file;
 	char line[LOCK_LINE_MAX];
 	char *str1, *str2;
 	int rv = -1, val;
 
-	memset(ls_comms_path, 0, sizeof(ls_comms_path));
-	snprintf(ls_comms_path, PATH_MAX, "%s",DLM_COMMS_PATH);
+	snprintf(ls_comms_path, sizeof(ls_comms_path), "%s", DLM_COMMS_PATH);
 
 	if (!(ls_dir = opendir(ls_comms_path)))
 		return -ECONNREFUSED;
@@ -241,31 +241,31 @@ static int get_local_nodeid(void)
 	while ((de = readdir(ls_dir))) {
 		if (de->d_name[0] == '.')
 			continue;
-		memset(ls_comms_path, 0, sizeof(ls_comms_path));
-		snprintf(ls_comms_path, PATH_MAX, "%s/%s/local",
-		     DLM_COMMS_PATH, de->d_name);
+
+		snprintf(path, sizeof(path), "%s/%s/local",
+			 DLM_COMMS_PATH, de->d_name);
 
 		if (!(file = fopen(ls_comms_path, "r")))
 			continue;
-		str1 = fgets(line, LOCK_LINE_MAX, file);
-		fclose(file);
-
+		str1 = fgets(line, sizeof(line), file);
+		if (fclose(file))
+			log_sys_debug("fclose", path);
 		if (str1) {
 			rv = sscanf(line, "%d", &val);
 			if ((rv == 1) && (val == 1 )) {
-				memset(ls_comms_path, 0, sizeof(ls_comms_path));
-				snprintf(ls_comms_path, PATH_MAX, "%s/%s/nodeid",
-				    DLM_COMMS_PATH, de->d_name);
+				snprintf(path, sizeof(path), "%s/%s/nodeid",
+					 DLM_COMMS_PATH, de->d_name);
 
-				if (!(file = fopen(ls_comms_path, "r")))
+				if (!(file = fopen(path, "r")))
 					continue;
-				str2 = fgets(line, LOCK_LINE_MAX, file);
-				fclose(file);
-
+				str2 = fgets(line, sizeof(line), file);
+				if (fclose(file))
+					log_sys_debug("fclose", path);
 				if (str2) {
 					rv = sscanf(line, "%d", &val);
 					if (rv == 1) {
-						closedir(ls_dir);
+						if (closedir(ls_dir))
+							log_sys_debug("closedir", ls_comms_path);
 						return val;
 					}
 				}
@@ -274,7 +274,8 @@ static int get_local_nodeid(void)
 	}
 
 	if (closedir(ls_dir))
-		log_error("get_local_nodeid closedir error");
+		log_sys_debug("closedir", ls_comms_path);
+
 	return rv;
 }
 


=====================================
daemons/lvmlockd/lvmlockd-internal.h
=====================================
@@ -363,6 +363,8 @@ void log_level(int level, const char *fmt, ...)  __attribute__((format(printf, 2
 #define log_debug(fmt, args...) log_level(LOG_DEBUG, fmt, ##args)
 #define log_error(fmt, args...) log_level(LOG_ERR, fmt, ##args)
 #define log_warn(fmt, args...) log_level(LOG_WARNING, fmt, ##args)
+#define log_sys_debug(x, y) \
+		log_debug("%s: %s failed: %s", y, x, strerror(errno))
 
 struct lockspace *alloc_lockspace(void);
 int lockspaces_empty(void);


=====================================
lib/cache/lvmcache.c
=====================================
@@ -401,10 +401,10 @@ const char *lvmcache_vgid_from_vgname(struct cmd_context *cmd, const char *vgnam
 
 	if (_found_duplicate_vgnames) {
 		if (!(vginfo = _search_vginfos_list(vgname, NULL)))
-			return_NULL;
+			return NULL;
 	} else {
 		if (!(vginfo = dm_hash_lookup(_vgname_hash, vgname)))
-			return_NULL;
+			return NULL;
 	}
 
 	if (vginfo->has_duplicate_local_vgname) {


=====================================
lib/device/dev-cache.c
=====================================
@@ -393,7 +393,10 @@ int get_sysfs_binary(const char *path, char *buf, size_t buf_size, int *retlen)
 	if (fd < 0)
 		return 0;
 	ret = read(fd, buf, buf_size);
-	close(fd);
+
+	if (close(fd))
+		log_sys_debug("close", path);
+
 	if (ret <= 0)
 		return 0;
 	*retlen = ret;
@@ -2136,6 +2139,7 @@ int setup_devices_for_online_autoactivation(struct cmd_context *cmd)
 
 static char *_get_devname_from_devno(struct cmd_context *cmd, dev_t devno)
 {
+	static const char _partitions[] = "/proc/partitions";
 	char path[PATH_MAX];
 	char devname[PATH_MAX] = { 0 };
 	char namebuf[NAME_LEN];
@@ -2174,7 +2178,8 @@ static char *_get_devname_from_devno(struct cmd_context *cmd, dev_t devno)
 			}
 			break;
 		}
-		closedir(dir);
+		if (closedir(dir))
+			log_sys_debug("closedir", path);
 
 		if (devname[0]) {
 			log_debug("Found %s for %d:%d from sys", devname, major, minor);
@@ -2214,7 +2219,7 @@ static char *_get_devname_from_devno(struct cmd_context *cmd, dev_t devno)
 	 */
 
 try_partition:
-	if (!(fp = fopen("/proc/partitions", "r")))
+	if (!(fp = fopen(_partitions, "r")))
 		return NULL;
 
 	while (fgets(line, sizeof(line), fp)) {
@@ -2231,10 +2236,12 @@ try_partition:
 		}
 		break;
 	}
-	fclose(fp);
+
+	if (fclose(fp))
+		log_sys_debug("fclose", _partitions);
 
 	if (devname[0]) {
-		log_debug("Found %s for %d:%d from proc", devname, major, minor);
+		log_debug("Found %s for %d:%d from %s", devname, major, minor, _partitions);
 		return _strdup(devname);
 	}
 


=====================================
lib/device/dev-mpath.c
=====================================
@@ -164,6 +164,7 @@ static void _read_blacklist_file(const char *path)
 
 static void _read_wwid_exclusions(void)
 {
+	static const char _mpath_conf[] = "/etc/multipath/conf.d";
 	char path[PATH_MAX] = { 0 };
 	DIR *dir;
 	struct dirent *de;
@@ -172,14 +173,15 @@ static void _read_wwid_exclusions(void)
 
 	_read_blacklist_file("/etc/multipath.conf");
 
-	if ((dir = opendir("/etc/multipath/conf.d"))) {
+	if ((dir = opendir(_mpath_conf))) {
 		while ((de = readdir(dir))) {
 			if (de->d_name[0] == '.')
 				continue;
-			snprintf(path, PATH_MAX-1, "/etc/multipath/conf.d/%s", de->d_name);
+			snprintf(path, sizeof(path), "%s/%s", _mpath_conf, de->d_name);
 			_read_blacklist_file(path);
 		}
-		closedir(dir);
+		if (closedir(dir))
+                        log_sys_debug("closedir", _mpath_conf);
 	}
 
 	/* for each wwid in ignored_exceptions, remove it from ignored */
@@ -594,7 +596,7 @@ static int _dev_is_mpath_component_sysfs(struct cmd_context *cmd, struct device
 
  out:
 	if (closedir(dr))
-		stack;
+		log_sys_debug("closedir", holders_path);
 
 	if (is_mpath_component)
 		*mpath_devno = MKDEV(dm_dev_major, dm_dev_minor);
@@ -778,7 +780,7 @@ const char *dev_mpath_component_wwid(struct cmd_context *cmd, struct device *dev
 			break;
 	}
 	if (closedir(dr))
-		stack;
+		log_sys_debug("closedir", slaves_path);
 
 	return wwid;
 }


=====================================
lib/device/device_id.c
=====================================
@@ -2352,7 +2352,8 @@ void device_ids_validate(struct cmd_context *cmd, struct dm_list *scanned_devs,
 		if ((du->idtype == DEV_ID_TYPE_SYS_SERIAL) && du->pvid &&
 		    memcmp(dev->pvid, du->pvid, ID_LEN)) {
 			log_debug("suspect device id serial %s for %s", du->idname, dev_name(dev));
-			str_list_add(cmd->mem, &cmd->device_ids_check_serial, dm_pool_strdup(cmd->mem, du->idname));
+			if (!str_list_add(cmd->mem, &cmd->device_ids_check_serial, dm_pool_strdup(cmd->mem, du->idname)))
+				stack;
 			*device_ids_invalid = 1;
 			continue;
 		}


=====================================
lib/device/filesystem.c
=====================================
@@ -155,26 +155,26 @@ int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 			return 0;
 		}
 
-		if (stat(crypt_path, &st_crypt) < 0) {
-			log_error("Failed to get crypt path %s", crypt_path);
-			return 0;
-		}
-
 		memset(&info, 0, sizeof(info));
 
 		log_print_unless_silent("Checking crypt device %s on LV %s.",
 					crypt_path, display_lvname(lv));
 
 		if ((fd = open(crypt_path, O_RDONLY)) < 0) {
-			log_error("Failed to open crypt path %s", crypt_path);
+			log_error("Failed to open crypt path %s.", crypt_path);
 			return 0;
 		}
-		if (ioctl(fd, BLKGETSIZE64, &info.crypt_dev_size_bytes) < 0) {
-			log_error("Failed to get crypt device size %s", crypt_path);
-			close(fd);
+
+		if ((ret = fstat(fd, &st_crypt)) < 0)
+			log_sys_error("fstat", crypt_path);
+		else if ((ret = ioctl(fd, BLKGETSIZE64, &info.crypt_dev_size_bytes)) < 0)
+			log_error("Failed to get crypt device size %s.", crypt_path);
+
+		if (close(fd))
+			log_sys_debug("close", crypt_path);
+
+		if (ret < 0)
 			return 0;
-		}
-		close(fd);
 
 		if (!fs_get_blkid(crypt_path, &info)) {
 			log_error("No file system info from blkid for dm-crypt device %s on LV %s.",
@@ -274,7 +274,8 @@ int fs_mount_state_is_misnamed(struct cmd_context *cmd, struct logical_volume *l
 			continue;
 		if (stme.st_dev != st_lv.st_rdev)
 			continue;
-		dm_strncpy(mtab_mntpath, me->mnt_dir, sizeof(mtab_mntpath));
+		if (!dm_strncpy(mtab_mntpath, me->mnt_dir, sizeof(mtab_mntpath)))
+			continue; /* Ignore too long unsupported paths */
 		break;
 	}
 	endmntent(fme);


=====================================
lib/device/online.c
=====================================
@@ -392,7 +392,7 @@ int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
 	int file_major = 0, file_minor = 0;
 	FILE *fp;
 
-	if (dm_snprintf(lookup_path, sizeof(path), "%s/%s", PVS_LOOKUP_DIR, vgname) < 0)
+	if (dm_snprintf(lookup_path, sizeof(lookup_path), "%s/%s", PVS_LOOKUP_DIR, vgname) < 0)
 		return_0;
 
 	if (!(fp = fopen(lookup_path, "r")))
@@ -403,7 +403,6 @@ int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
 		if (strlen(pvid) != ID_LEN)
 			goto_bad;
 
-		memset(path, 0, sizeof(path));
 		snprintf(path, sizeof(path), "%s/%s", PVS_ONLINE_DIR, pvid);
 
 		file_major = 0;
@@ -443,12 +442,16 @@ int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
 
 	log_debug("Found PVs online lookup %d for %s", dm_list_size(pvs_online), vgname);
 
-	fclose(fp);
+	if (fclose(fp))
+		log_sys_debug("fclose", lookup_path);
+
 	return 1;
 
 bad:
 	free_po_list(pvs_online);
-	fclose(fp);
+	if (fclose(fp))
+		log_sys_debug("fclose", lookup_path);
+
 	return 0;
 }
 


=====================================
lib/metadata/lv_manip.c
=====================================
@@ -5036,6 +5036,9 @@ static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 		find_config_tree_str(cmd, global_fsadm_executable_CFG, NULL)
 	};
 
+	if (status)
+		*status = -1;
+
 	if (!argv[0] || !*argv[0]) {
 		log_error("Cannot use misconfigured fsadm executable to resize %s.", display_lvname(lv));
 		return 0;
@@ -5055,9 +5058,6 @@ static int _fsadm_cmd(enum fsadm_cmd_e fcmd,
 
 	argv[i++] = (fcmd == FSADM_CMD_RESIZE) ? "resize" : "check";
 
-	if (status)
-		*status = -1;
-
 	if (dm_snprintf(lv_path, sizeof(lv_path), "%s%s/%s", cmd->dev_dir,
 			vg->name, lv->name) < 0) {
 		log_error("Couldn't create LV path for %s.", display_lvname(lv));


=====================================
lib/metadata/vdo_manip.c
=====================================
@@ -543,7 +543,7 @@ static int _compare_mem_table_s(const void *a, const void *b){
 
 static int _get_memory_info(uint64_t *total_mb, uint64_t *available_mb)
 {
-	uint64_t anon_pages, mem_available, mem_free, mem_total, shmem, swap_free;
+	uint64_t anon_pages = 0, mem_available = 0, mem_free = 0, mem_total = 0, shmem = 0, swap_free = 0;
 	uint64_t can_swap;
 	mem_table_t mt[] = {
 		{ "AnonPages",    &anon_pages },


=====================================
lib/notify/lvmnotify.c
=====================================
@@ -83,7 +83,9 @@ static int lvmdbusd_running(void)
 		}
 	}
 
-	close(fd);
+	if (close(fd))
+		log_sys_debug("close", lockfile);
+
 	return running;
 }
 


=====================================
scripts/lvm_import_vdo.sh
=====================================
@@ -121,8 +121,13 @@ dry() {
 
 cleanup() {
 	trap '' 2
-
-	test -n "$VDO_DM_SNAPSHOT_NAME" && { "$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" || true ; }
+	test -n "$VDO_DM_SNAPSHOT_NAME" && {
+		for i in {1..20} ; do
+			test "$("$DMSETUP" info --noheading -co open "$VDO_DM_SNAPSHOT_NAME")" = "0" && break
+			sleep .1
+		done
+		"$DMSETUP" remove "$VDO_DM_SNAPSHOT_NAME" || true
+	}
 	test -n "$VDO_SNAPSHOT_LOOP" && { "$LOSETUP" -d "$VDO_SNAPSHOT_LOOP" || true ; }
 
 	test -z "$PROMPTING" || echo "No"
@@ -370,7 +375,13 @@ convert_non_lv_() {
 	fi
 
 	verbose "Moving VDO header."
-	output=$(dry "$VDO" convert $VDOCONF $VERB --force --name "$VDONAME")
+
+	output=$(dry "$VDO" convert $VDOCONF $VERB --force --name "$VDONAME" 2>&1) || {
+		echo "$output"
+		error "Failed to convert VDO volume \"$DEVICE\" (exit code $?)."
+	}
+
+	echo "$output"
 
 	if [ "$ABORT_AFTER_VDO_CONVERT" != "0" ] ; then
 		verbose "Aborting VDO conversion after moving VDO header, volume is useless!"
@@ -456,12 +467,19 @@ convert_non_lv_() {
 		dry snapshot_merge_ "$DEVICE"
 		if [ -e "$TEMPDIR/vdo_snap.yml" ]; then
 			dry cp "$TEMPDIR/vdo_snap.yml" "$VDO_CONFIG"
-		else
+		elif [ -e "$VDO_CONFIG" ]; then
 			dry rm -f "$VDO_CONFIG"
 		fi
 		verbose "Merging of VDO device finished."
 	fi
 
+	output=$(dry "$LVM" pvs "$DEVICE" 2>&1) || {
+		if echo "$output" | grep -q "not in devices file" ; then
+			verbose "Adding \"$DEVICE\" to devices file."
+			dry "$LVM" lvmdevices --adddev "$DEVICE"
+		fi
+	}
+
 	dry "$LVM" lvchange -ay $VERB $FORCE "$VGNAME/$LVNAME"
 }
 
@@ -598,6 +616,7 @@ EOF
 	# Make a backup of the existing VDO yaml configuration file
 	test -e "$VDO_CONFIG" && dry cp -a "$VDO_CONFIG" "${VDO_CONFIG}.backup"
 
+	DEVICE=$FOUND
 	case "$DM_UUID" in
 		LVM-*) convert_lv_ "$vdo_logicalSize" ;;
 		*)     convert_non_lv_ "$vdo_logicalSize" ;;


=====================================
test/lib/aux.sh
=====================================
@@ -403,7 +403,7 @@ teardown_devs_prefixed() {
 			# HACK: sort also by minors - so we try to close 'possibly later' created device first
 			test "$i" = 0 || sortby="-minor"
 
-			for dm in $(dm_info name,open --separator ';'  --nameprefixes --unquoted --sort open,"$sortby" -S "name=~$prefix" --mangle none || true) ; do
+			for dm in $(dm_info name,open --separator ';'  --nameprefixes --unquoted --sort open,"$sortby" -S "name=~$prefix || uuid=~$prefix" --mangle none || true) ; do
 				test "$dm" != "No devices found" || break 2
 				eval "$dm"
 				local force="-f"
@@ -436,10 +436,14 @@ teardown_devs() {
 	restore_dm_mirror
 
 	test ! -f MD_DEV || cleanup_md_dev
-	test ! -f DEVICES || teardown_devs_prefixed "$PREFIX"
+
+	if [ -f DEVICES ] || [ -f RAMDISK ] || [ -f SCSI_DEBUG_DEV ];  then
+		teardown_devs_prefixed "$PREFIX"
+	fi
+
 	if test -f RAMDISK ; then
 		for i in 1 2 ; do
-			modprobe -r brd && break
+			modprobe -r brd && { rm -f RAMDISK ;  break ; }
 			sleep .1
 			udev_wait
 		done
@@ -451,7 +455,7 @@ teardown_devs() {
 		udev_wait
 		test "${LVM_TEST_PARALLEL:-0}" -eq 1 || {
 			for i in 1 2 ; do
-				modprobe -r scsi_debug && break
+				modprobe -r scsi_debug && { rm -f SCSI_DEBUG_DEV ; break ; }
 				sleep .1
 				udev_wait
 			done
@@ -741,7 +745,7 @@ prepare_scsi_debug_dev() {
 
 cleanup_scsi_debug_dev() {
 	teardown_devs
-	rm -f SCSI_DEBUG_DEV LOOP
+	rm -f LOOP
 }
 
 mdadm_create() {


=====================================
test/lib/lvm_vdo_wrapper.sh
=====================================
@@ -159,6 +159,14 @@ cachesize=$(( cachesize / 4 ))		# 4KiB units
 maxdiscardsize=$(vdo_get_kb_size_with_unit_ "$vdo_maxDiscardSize" M)
 maxdiscardsize=$(( maxdiscardsize / 4 )) # 4KiB units
 
+vdo_link=$(udevadm info --no-pager --query=symlink --name="$vdo_device" 2>/dev/null)
+vdo_link=${vdo_link%% *}
+if test -n "$vdo_link" ; then
+	vdo_link="/dev/$vdo_link"
+else
+	vdo_link=$vdo_device
+fi
+
 test -e "$vdo_confFile" || {
 	cat > "$vdo_confFile" <<EOF
 ####################################################################
@@ -181,7 +189,7 @@ cat >> "$vdo_confFile" <<EOF
       compression: $vdo_compression
       cpuThreads: $vdo_cpuThreads
       deduplication: $vdo_deduplication
-      device: $vdo_device
+      device: $vdo_link
       hashZoneThreads: $vdo_hashZoneThreads
       indexCfreq: $vdo_indexCfreq
       indexMemory: $vdo_indexMemory
@@ -259,7 +267,7 @@ do
 	shift
 done
 
-vdo_dry_ dmsetup status --target vdo "$vdo_name" 2>/dev/null || return 0
+test -z "$vdo_verbose" || vdo_dry_ dmsetup status --target vdo "$vdo_name" 2>/dev/null || return 0
 vdo_dry_ dmsetup remove $vdo_force "$vdo_name" || true
 }
 


=====================================
test/shell/lvconvert-thin-from-thick.sh
=====================================
@@ -40,13 +40,17 @@ aux prepare_vg 2 6000
 
 # error -> thin
 lvcreate --type error -Zn -L10 -n $lv1 $vg
-lvconvert --yes --type thin  $vg/$lv1
+lvconvert --yes --type thin  $vg/$lv1 "$dev2"
+check lv_on $vg ${lv1}_tpool0_tmeta "$dev2"
+check lv_on $vg lvol0_pmspare "$dev2"
 not dd if="$DM_DEV_DIR/$vg/$lv1" of=/dev/null bs=512 count=1
 lvremove -f $vg
 
 # zero -> thin
 lvcreate --type zero -L2T -n $lv1 $vg
-lvconvert --yes --type thin  $vg/$lv1
+lvconvert --yes --type thin  $vg/$lv1 "$dev1"
+check lv_on $vg ${lv1}_tpool0_tmeta "$dev1"
+check lv_on $vg lvol0_pmspare "$dev1"
 lvremove -f $vg
 
 # zero -> thin --test


=====================================
test/shell/vdo-convert.sh
=====================================
@@ -44,7 +44,8 @@ fi
 which mkfs.ext4 || skip
 export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
 
-aux have_vdo 6 2 0 || skip
+# Conversion can be made with this version of vdo driver
+aux have_vdo 6 2 3 || skip
 
 aux prepare_devs 2 20000
 
@@ -53,9 +54,6 @@ aux extend_filter_LVMTEST
 export TMPDIR=$PWD
 
 
-# Conversion can be made with this version of vdo driver
-aux have_vdo 6 2 5 || skip
-
 #
 #  Check conversion of VDO volume made on some LV
 #
@@ -139,6 +137,15 @@ fsck -n "$DM_DEV_DIR/$vg1/$lv2"
 
 vgremove -f $vg1
 
+
+
+########################################################################
+#
+# Preparation of already moved header works only with fake vdo wrapper
+#
+########################################################################
+test "${VDO_BINARY-}" != "lvm_vdo_wrapper" && exit
+
 aux wipefs_a "$dev1"
 
 # let's assume users with VDO target have 'new' enough version of stat too
@@ -188,8 +195,9 @@ dmsetup table
 dmsetup table "$VDONAME" | tr " " "\n" | sed -e '5,6d' -e '12d' | tee vdo-orig
 
 mkfs.ext4 -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
+rm -f debug.log*
 
-# For conversion we
+# For the easy table validation of conversion we use old version4 format
 aux lvmconf 'global/vdo_disabled_features = [ "version4" ]'
 
 #
@@ -200,11 +208,13 @@ if which "$LVM_VDO_PREPARE" ; then
 # Use old vdoprepareforlvm tool, that always moves header to 2M offset
 cp "$VDO_CONFIG" "$VDO_CONFIG.backup"
 lvm_import_vdo --abort-after-vdo-convert --vdo-config "$VDO_CONFIG" -v -y --name $vg/$lv "$TEST"
+rm -f debug.log*
 # Restore VDO configuration (as it's been removed with succeful vdo conversion
 cp "$VDO_CONFIG.backup" "$VDO_CONFIG"
 # Check VDO header is seen at 2M offset
-blkid -c /dev/null --probe --offset 2M "$TEST"
+blkid -c /dev/null --probe --offset 2M "$TEST" || die "VDO header at unknown offset, expected 2M!"
 fi
+
 unset LVM_VDO_PREPARE
 
 #lvm_import_vdo --no-snapshot --vdo-config "$VDO_CONFIG" -v -y --name $vg/$lv "$TEST"
@@ -226,5 +236,5 @@ tail -n+3 new-vdo-lv >new-vdo-lv-3
 diff -u vdo-orig-3 new-vdo-lv-3 || die "Found mismatching VDO table lines!"
 
 check lv_field $vg/$lv size "23.00g"
-unset LVM_VDO_PREPARE
 
+vgremove -f $vg


=====================================
test/shell/vdo-scsi-convert.sh
=====================================
@@ -0,0 +1,79 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2021 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Test conversion of VDO volumes made by vdo manager into VDO LV.
+
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+# Use local for this test vdo configuratoin
+VDO_CONFIG="vdotestconf.yml"
+VDOCONF="-f $VDO_CONFIG"
+#VDOCONF=""
+export VDOCONF VDO_CONFIG
+VDONAME="${PREFIX}-TESTVDO"
+export DM_UUID_PREFIX=$PREFIX
+
+# Conversion can be made with this version of vdo driver
+aux have_vdo 6 2 3 || skip
+
+if not which vdo ; then
+	which lvm_vdo_wrapper || skip "Missing 'lvm_vdo_wrapper'."
+	# enable expansion of aliasis within script itself
+	shopt -s expand_aliases
+	alias vdo='lvm_vdo_wrapper'
+	export VDO_BINARY=lvm_vdo_wrapper
+	echo "Using 'lvm_vdo_wrapper' emulation of 'vdo' manager."
+fi
+
+# VDO automatically starts dmeventd
+aux prepare_dmeventd
+
+which mkfs.ext4 || skip
+export MKE2FS_CONFIG="$TESTDIR/lib/mke2fs.conf"
+export TMPDIR=$PWD
+
+######################################################################
+#
+# !!! This is rather tricky way how to 'play' with large SCSI !!!
+#
+# Use 311/313MB 'wrap-around' RAM for 4GiB virtual disk.
+# (using prime number for dev_size_mb)
+#
+# ATM this seems work with the test for layout of VDO written data.
+# Minimal required size for VDO volume is ~4GiB
+#
+aux prepare_scsi_debug_dev 311 "virtual_gb=4"
+SCSI_DEV=$(< SCSI_DEBUG_DEV)
+
+# this non-scsi backend should always work, but we want to get DEVLINKS
+#aux prepare_devs 1 6144
+#SCSI_DEV=$dev1
+
+blockdev --getsize64 "$SCSI_DEV"
+
+aux extend_filter_LVMTEST "a|$SCSI_DEV|"
+
+# use some not so 'well' aligned virtual|logical size
+vdo create $VDOCONF --name "$VDONAME" --device "$SCSI_DEV" \
+ --vdoSlabSize 128M --vdoLogicalSize 5M
+
+mkfs.ext4 -E nodiscard "$DM_DEV_DIR/mapper/$VDONAME"
+# Try just dry run and observe logging
+lvm_import_vdo --dry-run -y -v --name $lv1 "$SCSI_DEV"
+
+lvm_import_vdo -y --name $vg/$lv "$SCSI_DEV"
+check lv_field $vg/$lv size "6.00m"
+
+vgremove -f $vg


=====================================
tools/command-lines.in
=====================================
@@ -456,6 +456,7 @@ FLAGS: SECONDARY_SYNTAX
 
 lvconvert --type thin --thinpool LV LV_linear_striped_raid_cache_thin_error_zero
 OO: --thin, --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
+OP: PV ...
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin.
 RULE: all and lv_is_visible
@@ -465,6 +466,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 # alternate form of lvconvert --type thin
 lvconvert --thin --thinpool LV LV_linear_striped_raid_cache_thin_error_zero
 OO: --originname LV_new, OO_LVCONVERT_POOL, OO_LVCONVERT
+OP: PV ...
 ID: lvconvert_to_thin_with_external
 DESC: Convert LV to a thin LV, using the original LV as an external origin.
 FLAGS: SECONDARY_SYNTAX
@@ -476,6 +478,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 # Convert to thin volume
 lvconvert --type thin LV_linear_striped_raid_cache_writecache_vdo_error_zero
 OO: --thin, OO_LVCONVERT_POOL, OO_LVCONVERT
+OP: PV ...
 ID: lvconvert_to_thin_with_data
 DESC: Convert LV to a thin LV, using LV as thin-pool data volume.
 RULE: all and lv_is_visible
@@ -485,6 +488,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 # Convert to thin volume
 lvconvert --thin LV_linear_striped_raid_cache_writecache_vdo_error_zero
 OO: OO_LVCONVERT_POOL, OO_LVCONVERT
+OP: PV ...
 ID: lvconvert_to_thin_with_data
 DESC: Convert LV to a thin LV, using LV as thin-pool data volume.
 FLAGS: SECONDARY_SYNTAX
@@ -497,6 +501,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 
 lvconvert --type cache --cachepool LV LV_linear_striped_raid_thinpool_vdo_vdopool_vdopooldata_thin_error_zero
 OO: --cache, OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
+OP: PV ...
 ID: lvconvert_to_cache_with_cachepool
 DESC: Attach a cache pool to an LV, converts the LV to type cache.
 RULE: all not lv_is_locked lv_is_merging_origin lv_is_merging_cow lv_is_cow
@@ -505,6 +510,7 @@ RULE: --poolmetadata not --readahead --stripesize --stripes_long
 # alternate form of lvconvert --type cache
 lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool_vdo_vdopool_vdopooldata_thin_error_zero
 OO: OO_LVCONVERT_CACHE, OO_LVCONVERT_POOL, OO_LVCONVERT
+OP: PV ...
 ID: lvconvert_to_cache_with_cachepool
 DESC: Attach a cache pool to an LV.
 RULE: all not lv_is_locked lv_is_merging_origin lv_is_merging_cow lv_is_cow


=====================================
tools/lvconvert.c
=====================================
@@ -4773,8 +4773,7 @@ static int _lvconvert_to_thin_with_data(struct cmd_context *cmd,
 					struct logical_volume *lv,
 					struct processing_handle *handle)
 {
-	struct volume_group *vg = lv->vg;
-	struct dm_list *use_pvh = NULL;
+	struct dm_list *use_pvh;
 
 	if (cmd->position_argc > 1) {
 		/* First pos arg is required LV, remaining are optional PVs. */
@@ -4784,7 +4783,7 @@ static int _lvconvert_to_thin_with_data(struct cmd_context *cmd,
 	} else
 		use_pvh = &lv->vg->pvs;
 
-	if (!_lvconvert_to_pool(cmd, lv, lv, 1, 0, 1, &vg->pvs)) {
+	if (!_lvconvert_to_pool(cmd, lv, lv, 1, 0, 1, use_pvh)) {
 		log_error("LV %s could not be converted to a thin volume.",
 			  display_lvname(lv));
 		return ECMD_FAILED;



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/c37416b6aac10521fe4fdc26618eb476bba0bd2f...e9eeb84040aacf5c65b2f8f87b9dc3943da0fcdd

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/c37416b6aac10521fe4fdc26618eb476bba0bd2f...e9eeb84040aacf5c65b2f8f87b9dc3943da0fcdd
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230903/cb4906a2/attachment-0001.htm>
