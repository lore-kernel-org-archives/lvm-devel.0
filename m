From: наб <nabijaczleweli@nabijaczleweli.xyz>
Date: Fri, 10 Dec 2021 18:40:00 +0100
Subject: [PATCH] devices: recognise rbd (ceph rados block device)
Message-ID: <20211210174000.isejrjcydltdpeio@tarta.nabijaczleweli.xyz>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Description stolen from linux d/b/rbd.c L3:
  rbd.c -- Export ceph rados objects as a Linux block device

16 partitions seem to make sense according to L90:
  #define RBD_SINGLE_MAJOR_PART_SHIFT 4

Running *scan -vvvvvvdddddd yields
  #filters/filter-type.c:28            /dev/rbd1p5: Skipping: Unrecognised LVM device type 252
  #filters/filter-persistent.c:131           filter caching bad /dev/rbd1p5
right now, and adding
  types = ["rbd", 252]
to /e/l/lvm.conf (with the matching "252 rbd" in /p/devices) works as a
per-machine fix:
  rbd1               252:16   0      1T  1 disk
  |-rbd1p1           252:17   0    243M  1 part
  |-rbd1p2           252:18   0      1K  1 part
  `-rbd1p5           252:21   0 1023.8G  1 part
    `-dev01--vg-root 253:0    0 1023.8G  0 lvm
but rbd is supported by upstream so it'd be nice to have it work OOB
---
Please keep me in CC, as I'm not subscribed

 lib/device/device-types.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/device/device-types.h b/lib/device/device-types.h
index 2834cd11f..a4191e839 100644
--- a/lib/device/device-types.h
+++ b/lib/device/device-types.h
@@ -43,6 +43,7 @@ static const dev_known_type_t _dev_known_types[] = {
 	{"ubd", 16, "User-mode virtual block device"},
 	{"ataraid", 16, "ATA Raid"},
 	{"drbd", 16, "Distributed Replicated Block Device (DRBD)"},
+	{"rbd", 16, "Ceph rados object as a Linux block device"},
 	{"emcpower", 16, "EMC Powerpath"},
 	{"power2", 16, "EMC Powerpath"},
 	{"i2o_block", 16, "i2o Block Disk"},
-- 
2.30.2
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 833 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20211210/c8e910c8/attachment.sig>
