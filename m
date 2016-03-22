From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 22 Mar 2016 09:53:14 +0000 (UTC)
Subject: master - dev: also count with suffixes in UUID for LVs when constructing VGID and LVID index
Message-ID: <20160322095314.4426360E73@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed002ed22adc61dfe477c3d42c9aae356f450d2c
Commit:        ed002ed22adc61dfe477c3d42c9aae356f450d2c
Parent:        2a47f0957fb95136985c97d0b7b4580044e3f68d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 22 10:28:01 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 22 10:52:24 2016 +0100

dev: also count with suffixes in UUID for LVs when constructing VGID and LVID index

UUID for LV is either "LVM-<vg_uuid><lv_uuid>" or "LVM-<vg_uuid><lv_uuid>-<suffix>".
The code before just checked the length of the UUID based on the first
template, not the variant with suffix - so LVs with this suffix were not
processed properly.

For example a thin pool LV (as an example of an LV that contains
sub LVs where UUIDs have suffixes):

[0] fedora/~ # lsblk -s /dev/vg/lvol1
NAME              MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
vg-lvol1          253:8    0    4M  0 lvm
`-vg-pool-tpool   253:6    0  116M  0 lvm
  |-vg-pool_tmeta 253:2    0    4M  0 lvm
  | `-sda           8:0    0  128M  0 disk
  `-vg-pool_tdata 253:3    0  116M  0 lvm
    `-sda           8:0    0  128M  0 disk

Before this patch (spurious warning message about device mismatch):

[0] fedora/~ # pvs
  WARNING: Device mismatch detected for vg/lvol1 which is accessing /dev/mapper/vg-pool-tpool instead of (null).
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda   vg     lvm2 a--  124.00m    0

With this patch applied (no spurious warning message about device mismatch):

[0] fedora/~ # pvs
  PV         VG     Fmt  Attr PSize   PFree
  /dev/sda   vg     lvm2 a--  124.00m    0
---
 lib/device/dev-cache.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index bcee783..06438d9 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -453,13 +453,23 @@ static struct device *_get_device_for_sysfs_dev_name_using_devno(const char *dev
 
 static int _get_vgid_and_lvid_for_dev(struct device *dev)
 {
-	size_t lvm_prefix_len = strlen(UUID_PREFIX);
+	static size_t lvm_prefix_len = sizeof(UUID_PREFIX) - 1;
+	static size_t lvm_uuid_len = sizeof(UUID_PREFIX) - 1 + 2 * ID_LEN;
 	char uuid[DM_UUID_LEN];
+	size_t uuid_len;
 
 	if (!_get_dm_uuid_from_sysfs(uuid, sizeof(uuid), (int) MAJOR(dev->dev), (int) MINOR(dev->dev)))
 		return_0;
 
-	if (strlen(uuid) == (2 * ID_LEN + 4) &&
+	uuid_len = strlen(uuid);
+
+	/*
+	 * UUID for LV is either "LVM-<vg_uuid><lv_uuid>" or "LVM-<vg_uuid><lv_uuid>-<suffix>",
+	 * where vg_uuid and lv_uuid has length of ID_LEN and suffix len is not restricted
+	 * (only restricted by whole DM UUID max len).
+	 */
+	if (((uuid_len == lvm_uuid_len) ||
+	     ((uuid_len > lvm_uuid_len) && (uuid[lvm_uuid_len] == '-'))) &&
 	    !strncmp(uuid, UUID_PREFIX, lvm_prefix_len)) {
 		/* Separate VGID and LVID part from DM UUID. */
 		if (!(dev->vgid = dm_pool_strndup(_cache.mem, uuid + lvm_prefix_len, ID_LEN)) ||


