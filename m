From: David Teigland <teigland@sourceware.org>
Date: Fri,  9 Sep 2022 20:50:53 +0000 (GMT)
Subject: main - fix fs block size detection
Message-ID: <20220909205053.65361385701B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b869a6ff7a3d254a56ad78444e7d7f8af93d6844
Commit:        b869a6ff7a3d254a56ad78444e7d7f8af93d6844
Parent:        6b05d6bd833c463b9a2074b2aa2bdaa531e7ab01
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Sep 9 15:16:56 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Sep 9 15:50:00 2022 -0500

fix fs block size detection

blkid_get_tag_value() is not a reliable way to query the fs
BLOCK_SIZE, so use the "probe" functions instead.
---
 lib/device/dev-type.c                      | 65 ++++++++++++++++++++++++------
 lib/device/dev-type.h                      |  3 +-
 lib/metadata/integrity_manip.c             |  4 +-
 test/shell/integrity-blocksize.sh          | 42 +++++++++----------
 test/shell/lvextend-caches-on-thindata.sh  |  2 +-
 test/shell/writecache-cache-blocksize-2.sh |  2 +-
 test/shell/writecache-cache-blocksize.sh   |  2 +-
 test/shell/writecache.sh                   |  2 +-
 tools/lvconvert.c                          |  4 +-
 9 files changed, 84 insertions(+), 42 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 1dc895b54..1e97f6c85 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -823,26 +823,67 @@ out:
 }
 
 #ifdef BLKID_WIPING_SUPPORT
-int get_fs_block_size(const char *pathname, uint32_t *fs_block_size)
+int fs_block_size_and_type(const char *pathname, uint32_t *fs_block_size_bytes, char *fstype, int *nofs)
 {
-	char *block_size_str = NULL;
+	blkid_probe probe = NULL;
+	const char *type_str = NULL, *size_str = NULL;
+	size_t len;
+	int ret = 1;
+	int rc;
 
-	if ((block_size_str = blkid_get_tag_value(NULL, "BLOCK_SIZE", pathname))) {
-		*fs_block_size = (uint32_t)atoi(block_size_str);
-		free(block_size_str);
-		log_debug("Found blkid BLOCK_SIZE %u for fs on %s", *fs_block_size, pathname);
-		return 1;
-	} else {
-		log_debug("No blkid BLOCK_SIZE for fs on %s", pathname);
-		*fs_block_size = 0;
+	if (!(probe = blkid_new_probe_from_filename(pathname))) {
+		log_error("Failed libblkid probe setup for %s", pathname);
 		return 0;
 	}
+
+	blkid_probe_enable_superblocks(probe, 1);
+	blkid_probe_set_superblocks_flags(probe,
+			BLKID_SUBLKS_LABEL | BLKID_SUBLKS_LABELRAW |
+			BLKID_SUBLKS_UUID | BLKID_SUBLKS_UUIDRAW |
+			BLKID_SUBLKS_TYPE | BLKID_SUBLKS_SECTYPE |
+			BLKID_SUBLKS_USAGE | BLKID_SUBLKS_VERSION |
+			BLKID_SUBLKS_MAGIC | BLKID_SUBLKS_FSINFO);
+	rc = blkid_do_safeprobe(probe);
+	if (rc < 0) {
+		log_debug("Failed libblkid probe for %s", pathname);
+		ret = 0;
+		goto out;
+	} else if (rc == 1) {
+		/* no file system on the device */
+		log_debug("No file system found on %s.", pathname);
+		if (nofs)
+			*nofs = 1;
+		goto out;
+	}
+
+	if (!blkid_probe_lookup_value(probe, "TYPE", &type_str, &len) && len && type_str) {
+		if (fstype)
+			strncpy(fstype, type_str, FSTYPE_MAX);
+	} else {
+		/* any difference from blkid_do_safeprobe rc=1? */
+		log_debug("No file system type on %s.", pathname);
+		if (nofs)
+			*nofs = 1;
+		goto out;
+	}
+
+	if (fs_block_size_bytes) {
+		if (!blkid_probe_lookup_value(probe, "BLOCK_SIZE", &size_str, &len) && len && size_str)
+			*fs_block_size_bytes = atoi(size_str);
+		else
+			*fs_block_size_bytes = 0;
+	}
+
+	log_debug("Found blkid fstype %s fsblocksize %s on %s",
+		  type_str ?: "none", size_str ?: "unused", pathname);
+out:
+	blkid_free_probe(probe);
+	return ret;
 }
 #else
-int get_fs_block_size(const char *pathname, uint32_t *fs_block_size)
+int fs_block_size_and_type(const char *pathname, uint32_t *fs_block_size_bytes, char *fstype, int *nofs)
 {
 	log_debug("Disabled blkid BLOCK_SIZE for fs.");
-	*fs_block_size = 0;
 	return 0;
 }
 #endif
diff --git a/lib/device/dev-type.h b/lib/device/dev-type.h
index 17c997641..4f793b0e0 100644
--- a/lib/device/dev-type.h
+++ b/lib/device/dev-type.h
@@ -101,7 +101,8 @@ int dev_is_nvme(struct dev_types *dt, struct device *dev);
 
 int dev_is_lv(struct device *dev);
 
-int get_fs_block_size(const char *pathname, uint32_t *fs_block_size);
+#define FSTYPE_MAX 16
+int fs_block_size_and_type(const char *pathname, uint32_t *fs_block_size_bytes, char *fstype, int *nofs);
 
 int dev_is_used_by_active_lv(struct cmd_context *cmd, struct device *dev, int *used_by_lv_count,
 			     char **used_by_dm_name, char **used_by_vg_uuid, char **used_by_lv_uuid);
diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index e053ac5f6..e9895b836 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -372,7 +372,7 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 		}
 
 		/*
-		 * get_fs_block_size() returns the libblkid BLOCK_SIZE value,
+		 * fs_block_size_and_type() returns the libblkid BLOCK_SIZE value,
 		 * where libblkid has fs-specific code to set BLOCK_SIZE to the
 		 * value we need here.
 		 *
@@ -382,7 +382,7 @@ static int _set_integrity_block_size(struct cmd_context *cmd, struct logical_vol
 		 * value the block size, but it's possible values are not the same
 		 * as xfs's, and do not seem to relate directly to the device LBS.
 		 */
-		rv = get_fs_block_size(pathname, &fs_block_size);
+		rv = fs_block_size_and_type(pathname, &fs_block_size, NULL, NULL);
 		if (!rv || !fs_block_size) {
 			int use_bs;
 
diff --git a/test/shell/integrity-blocksize.sh b/test/shell/integrity-blocksize.sh
index 4e47ce427..55a618f7f 100644
--- a/test/shell/integrity-blocksize.sh
+++ b/test/shell/integrity-blocksize.sh
@@ -41,7 +41,7 @@ aux prepare_devs 1
 vgcreate $vg "$dev1"
 lvcreate -n $lv1 -l8 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
 vgremove -ff $vg
 
@@ -149,9 +149,9 @@ lvremove -y $vg2/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.xfs -f "$DM_DEV_DIR/$vg1/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
 lvconvert --raidintegrity y $vg1/$lv1
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
@@ -161,9 +161,9 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
 aux wipefs_a /dev/$vg2/$lv1
 mkfs.xfs -f "$DM_DEV_DIR/$vg2/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y $vg2/$lv1
-blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
@@ -173,9 +173,9 @@ lvremove -y $vg2/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvconvert --raidintegrity y $vg1/$lv1
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
@@ -185,11 +185,11 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvchange -an $vg1/$lv1
 lvconvert --raidintegrity y $vg1/$lv1
 lvchange -ay $vg1/$lv1
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
@@ -199,9 +199,9 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg2
 aux wipefs_a /dev/$vg2/$lv1
 mkfs.ext4 "$DM_DEV_DIR/$vg2/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y $vg2/$lv1
-blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
@@ -211,10 +211,10 @@ lvremove -y $vg2/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
 lvs -o raidintegrityblocksize $vg1/$lv1 | grep 512
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
@@ -224,13 +224,13 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.xfs -f -s size=4096 "$DM_DEV_DIR/$vg1/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvchange -an $vg1/$lv1
 # lv needs to be inactive to increase LBS from 512
 lvconvert --raidintegrity y --raidintegrityblocksize 1024 $vg1/$lv1
 lvs -o raidintegrityblocksize $vg1/$lv1 | grep 1024
 lvchange -ay $vg1/$lv1
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"4096\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 1024'
@@ -240,9 +240,9 @@ lvremove -y $vg1/$lv1
 lvcreate --type raid1 -m1 -l 8 -n $lv1 $vg1
 aux wipefs_a /dev/$vg1/$lv1
 mkfs.ext4 -b 1024 "$DM_DEV_DIR/$vg1/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 lvconvert --raidintegrity y --raidintegrityblocksize 512 $vg1/$lv1
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"1024\"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 umount $mnt
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
@@ -267,14 +267,14 @@ mkfs.xfs -f "$DM_DEV_DIR/$vg1/$lv1"
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 echo "test" > $mnt/test
 umount $mnt
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
 lvchange -an $vg1/$lv1
 lvconvert --raidintegrity y $vg1/$lv1
 lvchange -ay $vg1/$lv1
 mount "$DM_DEV_DIR/$vg1/$lv1" $mnt
 cat $mnt/test
 umount $mnt
-blkid -c /dev/null "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
+blkid -p "$DM_DEV_DIR/$vg1/$lv1" | grep BLOCK_SIZE=\"512\"
 pvck --dump metadata $LOOP1 | grep 'block_size = 512'
 lvchange -an $vg1/$lv1
 lvremove -y $vg1/$lv1
@@ -286,14 +286,14 @@ mkfs.xfs -f "$DM_DEV_DIR/$vg2/$lv1"
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 echo "test" > $mnt/test
 umount $mnt
-blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 lvchange -an $vg2/$lv1
 lvconvert --raidintegrity y $vg2/$lv1
 lvchange -ay $vg2/$lv1
 mount "$DM_DEV_DIR/$vg2/$lv1" $mnt
 cat $mnt/test
 umount $mnt
-blkid -c /dev/null "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
+blkid -p "$DM_DEV_DIR/$vg2/$lv1" | grep BLOCK_SIZE=\"4096\"
 pvck --dump metadata $LOOP3 | grep 'block_size = 4096'
 lvchange -an $vg2/$lv1
 lvremove -y $vg2/$lv1
diff --git a/test/shell/lvextend-caches-on-thindata.sh b/test/shell/lvextend-caches-on-thindata.sh
index 35b70546f..2000c005e 100644
--- a/test/shell/lvextend-caches-on-thindata.sh
+++ b/test/shell/lvextend-caches-on-thindata.sh
@@ -122,7 +122,7 @@ aux prepare_devs 6 400 # want 400M of usable space from each dev
 vgcreate $vg "$dev1"
 lvcreate -n $lv1 -L300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
 vgremove -ff $vg
 
diff --git a/test/shell/writecache-cache-blocksize-2.sh b/test/shell/writecache-cache-blocksize-2.sh
index 0ab715d50..d50b36950 100644
--- a/test/shell/writecache-cache-blocksize-2.sh
+++ b/test/shell/writecache-cache-blocksize-2.sh
@@ -164,7 +164,7 @@ aux prepare_devs 2 301
 vgcreate $vg "$dev1"
 lvcreate -n $lv1 -L300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
 vgremove -ff $vg
 
diff --git a/test/shell/writecache-cache-blocksize.sh b/test/shell/writecache-cache-blocksize.sh
index c38700755..18be6ed46 100644
--- a/test/shell/writecache-cache-blocksize.sh
+++ b/test/shell/writecache-cache-blocksize.sh
@@ -154,7 +154,7 @@ aux prepare_devs 2 301
 vgcreate $vg "$dev1"
 lvcreate -n $lv1 -L300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
 vgremove -ff $vg
 
diff --git a/test/shell/writecache.sh b/test/shell/writecache.sh
index 9cb6d3f94..9d1a5c09e 100644
--- a/test/shell/writecache.sh
+++ b/test/shell/writecache.sh
@@ -29,7 +29,7 @@ aux prepare_devs 2 301
 vgcreate $vg "$dev1"
 lvcreate -n $lv1 -L 300 $vg
 mkfs.xfs -f "$DM_DEV_DIR/$vg/$lv1"
-blkid -c /dev/null "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
+blkid -p "$DM_DEV_DIR/$vg/$lv1" | grep BLOCK_SIZE || skip
 lvchange -an $vg
 vgremove -ff $vg
 
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6e5d748cc..8888cac28 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -5996,7 +5996,7 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 	}
 
 	/*
-	 * get_fs_block_size() returns the libblkid BLOCK_SIZE value,
+	 * fs_block_size_and_type() returns the libblkid BLOCK_SIZE value,
 	 * where libblkid has fs-specific code to set BLOCK_SIZE to the
 	 * value we need here.
 	 *
@@ -6008,7 +6008,7 @@ static int _set_writecache_block_size(struct cmd_context *cmd,
 	 *
 	 * With 512 LBS and 4K PBS, mkfs.xfs will use xfs sector size 4K.
 	 */
-	rv = get_fs_block_size(pathname, &fs_block_size);
+	rv = fs_block_size_and_type(pathname, &fs_block_size, NULL, NULL);
 skip_fs:
 	if (!rv || !fs_block_size) {
 		if (block_size_setting)

