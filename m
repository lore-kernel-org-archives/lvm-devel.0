From: David Teigland <teigland@sourceware.org>
Date: Mon, 13 Dec 2021 19:34:58 +0000 (GMT)
Subject: main - devices: recognise rbd (ceph rados block device)
Message-ID: <20211213193458.4F2033858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a431eb24241caf2277d3e5b4718782d92650a2a
Commit:        6a431eb24241caf2277d3e5b4718782d92650a2a
Parent:        c28541eccdbf76191f7728035cd2a48d26d06922
Author:        ?????? <nabijaczleweli@nabijaczleweli.xyz>
AuthorDate:    Mon Dec 13 13:32:06 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Dec 13 13:32:06 2021 -0600

devices: recognise rbd (ceph rados block device)

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


