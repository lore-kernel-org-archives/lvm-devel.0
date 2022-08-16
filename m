From: наб <nabijaczleweli@nabijaczleweli.xyz>
Date: Tue, 16 Aug 2022 14:13:30 +0200
Subject: [PATCH] devices: recognise zram (Compressed RAM block device)
Message-ID: <20220816121330.e5de2loxqeuvctyt@tarta.nabijaczleweli.xyz>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Description matches Linux drivers/block/zram/zram_drv.c
heading verbatim, no partitions are supported:
  zram->disk->minors = 1;

This can be done with types = ["zram", 1] as well,
but it's supported in upstream,
so it'd be nice for it to work out-of-box:
  zram1                   253:1    0     10G  0 disk
  ??vg--zram-cicadum      254:2    0     10G  0 lvm
---
I blamed all the way back to 
  commit 0dc2a4d6e47c1cccab4bfa1545c3f606d90a539e
  Author: Alasdair Kergon <agk@redhat.com>
  Date:   Tue Oct 9 17:20:02 2001 +0000

      o vgremove.
      o filter devices by major.
and didn't find any comment save for that exceptional commit message,
so: what's the reasoning behind filtering the blockdevs by major?

 lib/device/device-types.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/device/device-types.h b/lib/device/device-types.h
index a4191e839..97b6e0928 100644
--- a/lib/device/device-types.h
+++ b/lib/device/device-types.h
@@ -33,6 +33,7 @@ static const dev_known_type_t _dev_known_types[] = {
 	{"md", 1, "Multiple Disk (MD/SoftRAID)"},
 	{"loop", 1, "Loop device"},
 	{"ramdisk", 1, "RAM disk"},
+	{"zram", 1, "Compressed RAM block device"},
 	{"device-mapper", 1, "Mapped device"},
 	{"mdp", 1, "Partitionable MD"},
 	{"dasd", 4, "DASD disk (IBM S/390, zSeries)"},
-- 
2.30.2
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 833 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220816/0c0446ad/attachment.sig>
