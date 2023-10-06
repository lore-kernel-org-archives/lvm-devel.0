From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Fri, 06 Oct 2023 09:08:55 +0000
Subject: [Git][lvmteam/lvm2][main] 5 commits: debug: fix message severity levels
Message-ID: <651fcea7a35cd_2a1d6a744136dd@gitlab-sidekiq-low-urgency-cpu-bound-v2-845b4dd648-rp52x.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
44f86d38 by Zdenek Kabelac at 2023-10-06T10:50:26+02:00
debug: fix message severity levels

Add some missing WARNS and correct some severity levels.

- - - - -
37329e41 by Zdenek Kabelac at 2023-10-06T10:51:15+02:00
tests: add delay to let dmevent initalize

There is short time period needed to fully initilize dmeventd and
handle &#39;kill&#39; signal.

- - - - -
f5512315 by Zdenek Kabelac at 2023-10-06T10:51:15+02:00
tests: ignore failure from stop

- - - - -
2c374203 by Zdenek Kabelac at 2023-10-06T10:51:15+02:00
tests: skip test if the memory cannot be allocated in kernel

- - - - -
f960fe05 by Zdenek Kabelac at 2023-10-06T10:51:15+02:00
tests: delay_dev to slowdown pvmove

throtling mirror device is becoming useless with faster CPUS,
as way to many data can be transferred before throttling steps-in.
So prefer using  dm-delay for test and keep throttling as fallback.

- - - - -


7 changed files:

- lib/device/filesystem.c
- lib/device/online.c
- test/shell/dmeventd-restart.sh
- test/shell/large-physical-sector-size.sh
- test/shell/pvcreate-md-fake-hdr.sh
- test/shell/pvmove-abort-all.sh
- test/shell/pvmove-abort.sh


Changes:

=====================================
lib/device/filesystem.c
=====================================
@@ -50,8 +50,10 @@ static int _get_crypt_path(dev_t lv_devt, char *lv_path, char *crypt_path)
 	int ret = 0;
 
 	if (dm_snprintf(holders_path, sizeof(holders_path), "%sdev/block/%d:%d/holders",
-			dm_sysfs_dir(), (int)MAJOR(lv_devt), (int)MINOR(lv_devt)) < 0)
-		return_0;
+			dm_sysfs_dir(), (int)MAJOR(lv_devt), (int)MINOR(lv_devt)) < 0) {
+		log_error("Couldn't create holder path for %s.", lv_path);
+		return 0;
+	}
 
 	/* If the crypt dev is not active, there will be no LV holder. */
 	if (stat(holders_path, &st)) {
@@ -557,17 +559,16 @@ int fs_extend_script(struct cmd_context *cmd, struct logical_volume *lv, struct
 
 	devpath = fsi->needs_crypt ? crypt_path : (char *)display_lvname(lv);
 
-	log_print("Extending file system %s to %s (%llu bytes) on %s...",
-		  fsi->fstype, display_size(cmd, newsize_bytes_fs/512),
-		  (unsigned long long)newsize_bytes_fs, devpath);
+	log_print_unless_silent("Extending file system %s to %s (%llu bytes) on %s...",
+				fsi->fstype, display_size(cmd, newsize_bytes_fs/512),
+				(unsigned long long)newsize_bytes_fs, devpath);
 
 	if (!exec_cmd(cmd, argv, &status, 1)) {
 		log_error("Failed to extend file system with lvresize_fs_helper.");
 		return 0;
 	}
 
-	log_print("Extended file system %s on %s.", fsi->fstype, devpath);
+	log_print_unless_silent("Extended file system %s on %s.", fsi->fstype, devpath);
 
 	return 1;
 }
-


=====================================
lib/device/online.c
=====================================
@@ -68,7 +68,7 @@ int online_pvid_file_read(char *path, int *major, int *minor, char *vgname, char
 
 	fd = open(path, O_RDONLY);
 	if (fd < 0) {
-		log_warn("Failed to open %s", path);
+		log_warn("WARNING: Failed to open %s.", path);
 		return 0;
 	}
 
@@ -76,13 +76,13 @@ int online_pvid_file_read(char *path, int *major, int *minor, char *vgname, char
 	if (close(fd))
 		log_sys_debug("close", path);
 	if (!rv || rv < 0) {
-		log_warn("No info in %s", path);
+		log_warn("WARNING: No info in %s.", path);
 		return 0;
 	}
 	buf[rv] = 0; /* \0 terminated buffer */
 
 	if (sscanf(buf, "%d:%d", major, minor) != 2) {
-		log_warn("No device numbers in %s", path);
+		log_warn("WARNING: No device numbers in %s.", path);
 		return 0;
 	}
 
@@ -94,13 +94,13 @@ int online_pvid_file_read(char *path, int *major, int *minor, char *vgname, char
 		}
 
 		if (!_copy_pvid_file_field("vg:", buf, MAX_PVID_FILE_SIZE, vgname, NAME_LEN)) {
-			log_warn("Ignoring invalid vg field in %s", path);
+			log_warn("WARNING: Ignoring invalid vg field in %s.", path);
 			vgname[0] = '\0';
 			goto copy_dev;
 		}
 
 		if (!validate_name(vgname)) {
-			log_warn("Ignoring invalid vgname in %s (%s)", path, vgname);
+			log_warn("WARNING: Ignoring invalid vgname in %s (%s).", path, vgname);
 			vgname[0] = '\0';
 			goto copy_dev;
 		}
@@ -115,13 +115,13 @@ int online_pvid_file_read(char *path, int *major, int *minor, char *vgname, char
 		}
 
 		if (!_copy_pvid_file_field("dev:", buf, MAX_PVID_FILE_SIZE, devname, NAME_LEN)) {
-			log_warn("Ignoring invalid devname field in %s", path);
+			log_warn("WARNING: Ignoring invalid devname field in %s.", path);
 			devname[0] = '\0';
 			goto out;
 		}
 
 		if (strncmp(devname, "/dev/", 5)) {
-			log_warn("Ignoring invalid devname in %s (%s)", path, devname);
+			log_warn("WARNING: Ignoring invalid devname in %s (%s).", path, devname);
 			devname[0] = '\0';
 			goto out;
 		}
@@ -208,7 +208,7 @@ void online_vg_file_remove(const char *vgname)
 	char path[PATH_MAX];
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s", VGS_ONLINE_DIR, vgname) < 0) {
-		log_error("Path %s/%s is too long.", VGS_ONLINE_DIR, vgname);
+		log_debug("Path %s/%s is too long.", VGS_ONLINE_DIR, vgname);
 		return;
 	}
 
@@ -422,7 +422,7 @@ int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
 		if (vgname && file_vgname[0] && strcmp(file_vgname, vgname)) {
 			/* Should never happen */
 			log_error("Incorrect VG lookup file %s PVID %s %s.", vgname, pvid, file_vgname);
-			goto_bad;
+			goto bad;
 		}
 
 		if (!(po = zalloc(sizeof(*po))))
@@ -436,11 +436,11 @@ int get_pvs_lookup(struct dm_list *pvs_online, const char *vgname)
 		if (file_devname[0])
 			strncpy(po->devname, file_devname, NAME_LEN-1);
 
-		log_debug("Found PV online lookup %s for VG %s on %s", path, vgname, file_devname);
+		log_debug("Found PV online lookup %s for VG %s on %s.", path, vgname, file_devname);
 		dm_list_add(pvs_online, &po->list);
 	}
 
-	log_debug("Found PVs online lookup %d for %s", dm_list_size(pvs_online), vgname);
+	log_debug("Found PVs online lookup %d for %s.", dm_list_size(pvs_online), vgname);
 
 	if (fclose(fp))
 		log_sys_debug("fclose", lookup_path);
@@ -513,7 +513,7 @@ void online_lookup_file_remove(const char *vgname)
 	char path[PATH_MAX];
 
 	if (dm_snprintf(path, sizeof(path), "%s/%s", PVS_LOOKUP_DIR, vgname) < 0) {
-		log_error("Path %s/%s is too long.", PVS_LOOKUP_DIR, vgname);
+		log_debug("Path %s/%s is too long.", PVS_LOOKUP_DIR, vgname);
 		return;
 	}
 


=====================================
test/shell/dmeventd-restart.sh
=====================================
@@ -72,6 +72,7 @@ for i in $(seq 1 10); do
   sleep .1
 done
 
+sleep 1 # wait a bit, so we talk to the new dmeventd later
 kill -INT "$(< LOCAL_DMEVENTD)"
 sleep 1
 


=====================================
test/shell/large-physical-sector-size.sh
=====================================
@@ -26,7 +26,8 @@ aux prepare_scsi_debug_dev 256 sector_size=$LOGICAL_BLOCK_SIZE physblk_exp=$PHYS
 
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size "$LOGICAL_BLOCK_SIZE"
 
-aux prepare_pvs 1 256
+# Eventually we may fail here on 'page allocation failure' if kernel is low on sequential memory
+aux prepare_pvs 1 256 || skip "Cannot handle large logical block size"
 
 get_devs
 


=====================================
test/shell/pvcreate-md-fake-hdr.sh
=====================================
@@ -82,7 +82,7 @@ dmsetup info -c
 
 # if for any reason array went up - stop it again
 if mdadm --detail "$mddev" ; then
-	mdadm --stop "$mddev"
+	mdadm --stop "$mddev" || true
 	aux udev_wait
 	should not mdadm --detail "$mddev"
 fi


=====================================
test/shell/pvmove-abort-all.sh
=====================================
@@ -22,12 +22,17 @@ export DM_ABORT_ON_INTERNAL_ERRORS=0
 
 aux lvmconf 'activation/raid_region_size = 16'
 
-aux target_at_least dm-mirror 1 10 0 || skip
-# Throttle mirroring
-aux throttle_dm_mirror || skip
+aux target_at_least dm-mirror 1 2 0 || skip
 
 aux prepare_pvs 6 90
 
+for i in "$dev3" "$dev6" ; do
+	aux delay_dev "$i" 0 1 "$(get first_extent_sector "$i"):"
+done
+# fallback to mirror throttling
+# this does not work too well with fast CPUs
+test -f HAVE_DM_DELAY || { aux throttle_dm_mirror || skip ; }
+
 vgcreate -s 512k $vg "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"


=====================================
test/shell/pvmove-abort.sh
=====================================
@@ -18,12 +18,15 @@ SKIP_WITH_LVMLOCKD=1
 
 aux lvmconf 'activation/raid_region_size = 16'
 
-aux target_at_least dm-mirror 1 10 0 || skip
-# Throttle mirroring
-aux throttle_dm_mirror || skip
+aux target_at_least dm-mirror 1 2 0 || skip
 
 aux prepare_pvs 3 90
 
+aux delay_dev "$dev3" 0 1 "$(get first_extent_sector "$dev3"):"
+# fallback to mirror throttling
+# this does not work too well with fast CPUs
+test -f HAVE_DM_DELAY || { aux throttle_dm_mirror || skip ; }
+
 vgcreate -s 512k $vg "$dev1" "$dev2"
 pvcreate --metadatacopies 0 "$dev3"
 vgextend $vg "$dev3"



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/1901a47df12ceef65115e5148e425f4b8441081f...f960fe0578fa77d35f3d5baaae6efeaa1eb62ed4

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/1901a47df12ceef65115e5148e425f4b8441081f...f960fe0578fa77d35f3d5baaae6efeaa1eb62ed4
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231006/0092f5ff/attachment-0001.htm>
