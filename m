From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Mar 2016 10:52:25 +0000 (UTC)
Subject: master - dev-cache: also index VGIDs and LVIDs if using persistent .cache file
Message-ID: <20160330105225.6F25A60FFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c27c5274980dddf64283602bc23b89a5623da0a
Commit:        8c27c5274980dddf64283602bc23b89a5623da0a
Parent:        91bb202ded059a4109ff4351825c77c1fcf9197b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 30 10:39:30 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 30 11:00:01 2016 +0200

dev-cache: also index VGIDs and LVIDs if using persistent .cache file

If we're using persistent .cache file, we're reading this file instead
of traversing the /dev content. Fix missing indexing by VGID and LVID
here - hook this into persistent_filter_load where we populate device
cache from persistent .cache file instead of scanning /dev.

For example, inducing situation in which we warn about different device
actually used than what LVM thinks should be used based on metadata:

$ lsblk -s /dev/vg/lvol0
NAME     MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
vg-lvol0 253:4    0  124M  0 lvm
`-loop1    7:1    0  128M  0 loop

$ lvmconfig --type diff

global {
	use_lvmetad=0
}
devices {
	obtain_device_list_from_udev=0
}

(obtain_device_list_from_udev=0 also means the persistent .cache file is used)

Before this patch - pvs is fine as it does the dev scan, but lvs relies
on persistent .cache file and it misses the VGID/LVID indices to check
and warn about incorrect devices used:

$ pvs
  Found duplicate PV B9gXTHkIdEIiMVwcOoT2LX3Ywh4YIHgR: using /dev/loop0 not /dev/loop1
  Using duplicate PV /dev/loop0 without holders, ignoring /dev/loop1
  WARNING: Device mismatch detected for vg/lvol0 which is accessing /dev/loop1 instead of /dev/loop0.
  PV          VG Fmt  Attr PSize   PFree
  /dev/loop0 vg lvm2 a--  124.00m    0

$ lvs
  Found duplicate PV B9gXTHkIdEIiMVwcOoT2LX3Ywh4YIHgR: using /dev/loop0 not /dev/loop1
  Using duplicate PV /dev/loop0 without holders, ignoring /dev/loop1
  LV    VG Attr       LSize
  lvol0 vg -wi-a----- 124.00m

With this patch applied - both pvs and lvs is fine - the indices are
always created correctly (lvs just an example here, other LVM commands
that rely on persistent .cache file are fixed with this patch too):

$ pvs
  Found duplicate PV B9gXTHkIdEIiMVwcOoT2LX3Ywh4YIHgR: using /dev/loop0 not /dev/loop1
  Using duplicate PV /dev/loop0 without holders, ignoring /dev/loop1
  WARNING: Device mismatch detected for vg/lvol0 which is accessing /dev/loop1 instead of /dev/loop0.
  PV          VG Fmt  Attr PSize   PFree
  /dev/loop0 vg lvm2 a--  124.00m    0

$ lvs
  Found duplicate PV B9gXTHkIdEIiMVwcOoT2LX3Ywh4YIHgR: using /dev/loop0 not /dev/loop1
  Using duplicate PV /dev/loop0 without holders, ignoring /dev/loop1
  WARNING: Device mismatch detected for vg/lvol0 which is accessing /dev/loop1 instead of /dev/loop0.
  LV    VG Attr       LSize
  lvol0 vg -wi-a----- 124.00m
---
 WHATS_NEW                       |    1 +
 lib/device/dev-cache.c          |    8 ++++++--
 lib/device/dev-cache.h          |    1 +
 lib/filters/filter-persistent.c |    2 ++
 4 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ca6077b..b389926 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.149 - 
 ==================================
+  Fix device mismatch detection for LV if persistent .cache file is used.
   Fix holder device not being found in /dev while sysfs has it during dev scan.
 
 Version 2.02.148 - 26th March 2016
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index b3d45b3..9989066 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -527,6 +527,10 @@ static int _index_dev_by_vgid_and_lvid(struct device *dev)
 	struct device_list *dl_vgid, *dl_lvid;
 	int r = 0;
 
+	if (dev->vgid)
+		/* already indexed */
+		return 1;
+
 	/* Get holders for device. */
 	if (dm_snprintf(path, sizeof(path), "%sdev/block/%d:%d/holders/", dm_sysfs_dir(), (int) MAJOR(dev->dev), (int) MINOR(dev->dev)) < 0) {
 		log_error("%s: dm_snprintf failed for path to holders directory.", devname);
@@ -848,7 +852,7 @@ bad:
 	return 0;
 }
 
-static int _add_devs_to_index(void)
+int dev_cache_index_devs(void)
 {
 	struct btree_iter *iter = btree_first(_cache.devices);
 	struct device *dev;
@@ -887,7 +891,7 @@ static void _insert_dirs(struct dm_list *dirs)
 				       "device cache fully", dl->dir);
 	}
 
-	(void) _add_devs_to_index();
+	(void) dev_cache_index_devs();
 }
 
 #else	/* UDEV_SYNC_SUPPORT */
diff --git a/lib/device/dev-cache.h b/lib/device/dev-cache.h
index d21f521..0406970 100644
--- a/lib/device/dev-cache.h
+++ b/lib/device/dev-cache.h
@@ -31,6 +31,7 @@ struct dev_filter {
 	unsigned use_count;
 };
 
+int dev_cache_index_devs(void);
 struct dm_list *dev_cache_get_dev_list_for_vgid(const char *vgid);
 struct dm_list *dev_cache_get_dev_list_for_lvid(const char *lvid);
 
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index ed7956c..4e8161e 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -129,6 +129,8 @@ int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out
 	if (dm_hash_get_num_entries(pf->devices)) {
 		/* We populated dev_cache ourselves */
 		dev_cache_scan(0);
+		if (!dev_cache_index_devs())
+			stack;
 		r = 1;
 	}
 


