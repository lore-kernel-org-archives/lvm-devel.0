From: Lidong Zhong <lidong.zhong@suse.com>
Date: Wed,  7 Jul 2021 13:58:11 +0800
Subject: [RFC PATCH] lvconvert: fix the size of log device when converting from linear to mirror
Message-ID: <20210707055811.10008-1-lidong.zhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When converting a large linear device to mirror with --stripes parameter
in lvconvert command, it will report the following error:

ioctl/libdm-iface.c:1895    device-mapper: reload ioctl on  (254:0) failed: Invalid argument

and the related kernel messages:

kernel: [ 2290.698171] device-mapper: dirty region log: log device 254:1 too small: need 7078912 bytes
kernel: [ 2290.698248] device-mapper: table: 254:0: mirror: Error creating mirror dirty log
kernel: [ 2290.698251] device-mapper: ioctl: error adding target to table

Steps to reproduce this problem
~$:pvs
  PV         VG Fmt  Attr PSize  PFree
  /dev/loop0 vg lvm2 a--  10.00t 10.00t
  /dev/loop1 vg lvm2 a--  10.00t 10.00t
  /dev/loop2 vg lvm2 a--  10.00t 10.00t
  /dev/loop3    lvm2 ---  10.00t 10.00t
  /dev/loop4    lvm2 ---  10.00t 10.00t
  /dev/loop5    lvm2 ---  10.00t 10.00t

~$:lvcreate -nlv  -L27T vg
  Logical volume "lv" created.

~$:vgextend vg /dev/loop[3-5]
  Volume group "vg" successfully extended

~$:lvconvert  --type mirror --mirrors 1 --stripes 3 -I256  /dev/vg/lv /dev/loop3 /dev/loop4 /dev/loop5
  device-mapper: reload ioctl on  (254:0) failed: Invalid argument
  Failed to lock logical volume vg/lv.
~$: lvs
  WARNING: Reading VG vg from disk because lvmetad metadata is invalid.
  LV      VG Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lv      vg -wi-a----- 27.00t
  lv_mlog vg -wi-a-----  4.00m
~$: pvs
  PV         VG Fmt  Attr PSize  PFree
  /dev/loop0 vg lvm2 a--  10.00t     0
  /dev/loop1 vg lvm2 a--  10.00t     0
  /dev/loop2 vg lvm2 a--  10.00t  3.00t
  /dev/loop3 vg lvm2 a--  10.00t 10.00t
  /dev/loop4 vg lvm2 a--  10.00t 10.00t
  /dev/loop5 vg lvm2 a--  10.00t 10.00t

Analysis: In kernel space the required log size depends on the whole
target device size.But in user space, the log size is calculated from
the whole target devices size divided by allocation area number, which
leads to the mismatch here.

Signed-off-by: Lidong Zhong <lidong.zhong@suse.com>
---
 lib/metadata/lv_manip.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7e66afd9c..e8d67c79b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3730,8 +3730,7 @@ static struct alloc_handle *_alloc_init(struct cmd_context *cmd,
 	} else {
 		ah->log_area_count = metadata_area_count;
 		ah->log_len = !metadata_area_count ? 0 :
-			_mirror_log_extents(ah->region_size, extent_size,
-					    (existing_extents + new_extents) / ah->area_multiple);
+			_mirror_log_extents(ah->region_size, extent_size, existing_extents + new_extents);
 	}
 
 	if (total_extents || existing_extents)
-- 
2.26.2



