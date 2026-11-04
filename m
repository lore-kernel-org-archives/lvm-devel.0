Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793775515;
	b=CgyPt09TMoiwTImNQypM09WhaRF53r64USeRbg2eHViOYiAetQ3xl4uFnyxa8WwMx5sc
	 rQBc0BHL8CmCu+uxGH/ydJPYE1gSePAxLQRBi4d/ed5qmaUiYA+9pUGa1UlbA1g2osw7o
	 6sPWMpjUUhCYGy73v+StkKBZ4rLYXiX8cYbUe7ZzdJdy0ecc7pGUX0hXrYkCOdYT0RVDe
	 jA4cGuNiUIDjFhjuhDB6ngwEWRbvKvNZLkHD2N3VEhDZfM23tXmJvKw6nuWAbMa0xTe5o
	 NfYiyU+kHMxgrwOs/g/8M70Ocb6AapevFbLveGx5QYlYXZtisHoQy8zSRxum3XPTw4w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793775515;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=BFRvPVSc1LZp5SKDoUpfS+8ZPAoKGw3IAgY0pZnS8hY=;
	b=rix2qSWtmUN7+9aftIkEeYzBTqTc5Wi+r+DnqdprNMKcpNlfaVCsIP6OIj79tCF7Z+oL
	 wibwFVWDGrwS7+zkddLZG9eH7leMKl0u/TvK5UyclRldU+YUM+3r+WoQj/mQPmMShZ2Hd
	 EdYdW+3z72gYF3YS0dI7mQgfp4MbyWDeMFYOwy4E6xdSHmogKFvWukXUuyjEULR2JEijq
	 BcAfCP9l/mhnjKhQmnr1zFcR6LA0KhPST9l94OrS+OOkxwLK5mAgFKUNFelo8Hyr87m+e
	 uccqwBGTcxQc4pdh5Ont9TTBcN8pVsXfbjAiWnttadWwx4W0N+Xeizj2bdkre2GD8yw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=SnrPmUbM;
	arc=none smtp.remote-ip=209.85.128.53
Received: from mail-wm1-f53.google.com (mail-wm1-f53.google.com [209.85.128.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05F42606A326
	for <lvm-devel@lists.linux.dev>; Wed,  4 Nov 2026 06:58:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 05F42606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=SnrPmUbM
Received: by mail-wm1-f53.google.com with SMTP id 5b1f17b1804b1-4a68f888a41so598925e9.0
        for <lvm-devel@lists.linux.dev>; Tue, 03 Nov 2026 22:58:34 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793775513; x=1794380313; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=BFRvPVSc1LZp5SKDoUpfS+8ZPAoKGw3IAgY0pZnS8hY=;
        b=SnrPmUbMXUmDNTGRQO7VKdQz51a552Y1BFOYDG8Xdx+o1AHE6ss1WuClDwRGdD5Omw
         O2qyzmzWHkDinUUXzk5tNwvOVvE4OZ1z6UWHhXWkUXhF2qT30GXFodkIiMnz8pcOTTfM
         05g4h2mPVP5xwCeHPh1T/y0uaIv8RgRYaRNPL2L1AQfjN5qw7H5kHDLDsSExGjgP8Xw+
         7jXG/7jpbhIk5gWGU0qEeaYTlKhL4NTLdxJR8V2ZPtIdzE8eC2FPa9czi22sDk9Ovr2Y
         VDQ/XrhVZy03OK6enDBFvAowVsg2ZQXC835kYVwR1q7aphOW2GQ0WOujJ3m579JJdjrA
         PXcw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793775513; x=1794380313;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=BFRvPVSc1LZp5SKDoUpfS+8ZPAoKGw3IAgY0pZnS8hY=;
        b=jL7dKbFLEHBnio55CfI55cdmWOjwl+kCVFbgCuIuGorTYMH3oc3LOhMo3LRbL98qis
         NZWo2GokXveVd+wvYjibVRGIMPtKIBIg3xzvXCax66GTcCsMFlwjFj3HC/WbLAkp1JdV
         CWiSOlJOUBN3sJ+TP/qBSFvAvdT6WqgPgnUq1wP0vLJr58C2K/9L3kc1HIl/Rpr9z0nT
         S82DdT+W5DzhwHKm2QISVZ43Li5QE+WOjJ0mhMUa20ii6Dn+ezyCRMQD4B0uiLcmbWlG
         z7Su1tC6HqSHty4jeLk5Np1VQ5GR5RZGgppoEHpynQWfGXD0KmCGjbsRnWlIy/mN9VH5
         LK0g==
X-Gm-Message-State: APuU4Z9UN5D5CbKB7HuPrMcXolHCxyaKb/ScDoASYWu+KbupaWnLmviY
	nl2rrSKeA8gQ/eTSewkMytRrnynilkVdduLtVveLGDd/qHR2cCiCzUvAZuIyoQ==
X-Gm-Gg: AYBFou3t3DiZVkdmjhH1A9k/FP6ES/e7oRvcneIFQOd+A3GO4cCNbC4zwe1MssZsPS5
	fKQymV6DDAvoiIUF96LVxWDlv67xx2xhPifbL3l3IL7aSjxEcDZKcyaMbvXIVJ9IeCDZgMI2wFx
	tw9b4nfZbiixij9L4tuVFv49rhVQ/TkIprhs9kuCDPLHG70unVXtEmXLK+McpPTenLhZEBlUOf5
	clMdAAaUHBGBtSmCBgLNz/aro0ndrUyU1+d0rfOA7KsUdYSL7wH5DiZduz6bvTAZV8n0MF6FlEb
	kor805cYJ1w6u8Q/BDP5NA9gQtNy1Glg7p54KdpdUQTeBl+ylw0ksgceyYtc8b3aBEiZcuCmJri
	NPaEgWGRoBz1VoQM6brawXPfZdHolLqk2pK8jVOdWg1RfZXgkpuGKixR1bCM0ut/T+eDJ5xQhX6
	P1hHnr4uSn6rvVMtz2kPA392jChTFTGDOauYwPdfnjgxeQIrJDUS/aoVsup2QHzi/EgZm+qQm6j
	rVzyozKBsWAeUs+T48J2GdVn8HDHgBTSsfDyJCbQdgyOQTP+To6O9JyxFOGB2XwfOgmG/WrFX7n
	g7pk7XEC8hZQsdMHX2Mw9wWNGYlPhUV1RsQqOucdOk3CchFa7Q==
X-Received: by 2002:a05:600d:6505:20b0:4b2:3c81:103 with SMTP id 5b1f17b1804b1-4b23c8106abmr104162305e9.2.1793775513067;
        Tue, 03 Nov 2026 22:58:33 -0800 (PST)
Received: from L-P-ITAIH2-L-RF.rf.local ([193.169.70.108])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4b433ebd278sm29676805e9.3.2026.11.03.22.58.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Nov 2026 22:58:32 -0800 (PST)
From: Itai Handler <itai.handler@gmail.com>
To: lvm-devel@lists.linux.dev
Cc: David Teigland <teigland@redhat.com>,
	Zdenek Kabelac <zkabelac@redhat.com>
Subject: [PATCH v2] blkio: fix writes when the logical block size is not 512 or 4096
Date: Wed,  4 Nov 2026 08:58:17 +0200
Message-Id: <20261104065817.1306582-1-itai.handler@gmail.com>
X-Mailer: git-send-email 2.34.1
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Post: <mailto:lvm-devel@lists.linux.dev>
List-Help: <mailto:lvm-devel+help@lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
List-Owner: <mailto:lvm-devel+owner@lists.linux.dev>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Since lvm2 2.03.06, pvcreate fails on devices where neither the logical
nor the physical block size is 512 or 4096 bytes, such as a loop device
with 2048-byte sectors:

  # truncate -s 64M disk.img
  # losetup --sector-size 2048 --show -f disk.img
  /dev/loop8
  # pvcreate /dev/loop8
    WARNING: threads io engine write device offset 0 len 4608: Invalid argument.
    Error writing device /dev/loop8 at 4096 length 512.
    Failed to write mda header to /dev/loop8.
    Failed to write physical volume "/dev/loop8".

LVM rounds its metadata writes up to whole blocks, as direct I/O
requires, but on such devices it rounds up to 512 bytes.  Above, it
writes 4608 bytes, 2.25 blocks of 2048 bytes, and the kernel rejects
the write.

Move the rounding into blkio, which does the direct I/O, and round up
to the logical block size of the device being written, read with
BLKSSZGET.  As explained in 669e2f2b6ccf ("label: don't round writes
past the logical block size"), the added bytes cannot belong to an
active LV.  On devices with a logical or physical block size of 512 or
4096, that is almost all disks, LVM already rounds up to the logical
block size, so they are not affected.

Such devices are uncommon but easy to create: loop devices with
--sector-size 1024 or 2048, and dm-crypt with 1024- or 2048-byte
sectors on disks with 512-byte physical sectors.

With this change, LVM can also use logical blocks larger than 4KiB,
where the kernel supports them.  Loop devices accept them on recent
kernels, and dm-crypt accepts sectors up to the page size since target
version 1.30.0, added by Linux commit 1acc65c30f85 ("dm-crypt: allow
encryption sector size up to PAGE_SIZE").  For example, on a kernel
configured with 64KiB pages, a dm-crypt device can have 64KiB sectors;
without this change, the kernel rejects LVM's writes to it and pvcreate
fails.

Fixes: 7f347698e3d0 ("Fix rounding writes up to sector size")
Assisted-by: LLM
---
v2:
- Round up in blkio, as Zdenek suggested: blkio reads the logical
  block size of the device it writes (BLKSSZGET), and
  dev_set_last_byte() only passes where the write must end.
- Rebased on main, which has since fixed the 1K/2K logical, 4K
  physical case separately (669e2f2b6).
- metadata-write-rounding.sh also covers 2048-byte logical blocks with
  8192-byte physical blocks.
- logical-block-size.sh removes its LV and loop device if it fails.

v1: https://lore.kernel.org/lvm-devel/20261029125312.3631129-1-itai.handler@gmail.com/

Tested on main 7ea850a14 in QEMU, with Linux 7.3 on x86_64, where loop
accepts sector sizes up to 64KiB, and with dm-crypt 1.30.0 (Linux 7.4
merge window, 65ba8f34ec88) on arm64 with 64KiB pages:
- logical-block-size passes with 1KiB to 64KiB loop devices, and
  metadata-write-rounding with all three cases on x86_64.  Without the
  blkio change both fail, and pvcreate fails as shown above, with 64KiB
  pages at offset 65536.
- The unit tests, allow-mixed-block-sizes, large-physical-sector-size,
  mda-rollback, metadata-balance, pe-align, pvcreate-metadata0,
  pvcreate-operation and topology-support still pass on x86_64.  On
  arm64, pe-align fails on main too, as it expects 4KiB pages, and so
  do pvcreate-metadata0 and topology-support, which need dm-snapshot,
  missing from that kernel.
- On dm-crypt with sector sizes from 1KiB up to the page size,
  pvcreate with two metadata areas, vgcreate, lvcreate, lvextend and
  reactivation work.  Debian's lvm2 2.03.31 fails pvcreate on each,
  and main fails it with 64KiB sectors.

With pages larger than 4KiB, metadata-write-rounding fails in pvcreate,
on main too.  "test: skip metadata-write-rounding with pages larger
than 4KiB", sent just before this patch, skips it.  This patch applies
with or without it.

 WHATS_NEW                             |  1 +
 lib/blkio/blkio.c                     | 46 ++++++++++++-----
 lib/blkio/blkio.h                     |  6 ++-
 lib/label/label.c                     | 37 +-------------
 test/shell/logical-block-size.sh      | 73 +++++++++++++++++++++++++++
 test/shell/metadata-write-rounding.sh | 15 +++---
 test/unit/blkio_t.c                   |  2 +-
 7 files changed, 124 insertions(+), 56 deletions(-)
 create mode 100644 test/shell/logical-block-size.sh

diff --git a/WHATS_NEW b/WHATS_NEW
index fff0fcfde..65a3d57ec 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.45 - 
 ==================
+  Fix failing writes on devices whose block sizes are neither 512 nor 4096.
   Fix vgcfgbackup segfault for a VG name ending in .tmp.
   Fix pvscan --allpvs crash when a PV has no device.
   Fix a stack overflow checking config definition paths with long names.
diff --git a/lib/blkio/blkio.c b/lib/blkio/blkio.c
index a84e00269..c9b86805d 100644
--- a/lib/blkio/blkio.c
+++ b/lib/blkio/blkio.c
@@ -17,7 +17,9 @@
 #include "lib/datastruct/radix-tree.h"
 
 #include <errno.h>
+#include <sys/ioctl.h>
 #include <sys/types.h>
+#include <linux/fs.h>
 #include <stdbool.h>
 #include <stdlib.h>
 #include <stdint.h>
@@ -92,7 +94,6 @@ struct blkio {
 	 */
 	int last_byte_di;
 	uint64_t last_byte_offset;
-	size_t last_byte_sector_size;
 
 	/*
 	 * Lists that categorize the blocks.
@@ -345,6 +346,20 @@ static uint64_t _round_up_to_sector(uint64_t nr_bytes, sector_t sector_size)
 	return remainder ? nr_bytes + (sector_size - remainder) : nr_bytes;
 }
 
+/*
+ * The logical block size of the device open on fd, the smallest unit it
+ * can read or write, or SECTOR_SIZE if it cannot be read.
+ */
+static size_t _logical_block_size(int fd)
+{
+	int lbs;
+
+	if (ioctl(fd, BLKSSZGET, &lbs) || lbs < SECTOR_SIZE)
+		return SECTOR_SIZE;
+
+	return (size_t) lbs;
+}
+
 struct clamped_write_range {
 	bool valid;
 	sector_t end;
@@ -355,7 +370,7 @@ static struct clamped_write_range _clamp_write_range(struct blkio *bio, int di,
 						     const struct blkio_io *io)
 {
 	struct blkio_byte_range bytes = io->range;
-	size_t limit_nbytes, rounded_nbytes, block_nbytes;
+	size_t limit_nbytes, rounded_nbytes, block_nbytes, sector_size;
 	struct clamped_write_range range = {
 		.valid = true,
 		.end = (io->range.offset + io->range.len) >> SECTOR_SHIFT,
@@ -384,23 +399,32 @@ static struct clamped_write_range _clamp_write_range(struct blkio *bio, int di,
 	 * If the blkio block offset+len goes beyond where lvm is
 	 * intending to write, then reduce the len being written
 	 * (which is the blkio block size) so we don't write past
-	 * the limit set by lvm.  A partial sector is never written,
-	 * so the reduced len is rounded up to a whole sector when
-	 * that does not take it past the end of the block, which is
-	 * possible because the block size is a multiple of it.
+	 * the limit set by lvm.  Direct I/O must cover whole logical
+	 * blocks of the device, so the reduced len is rounded up to a
+	 * multiple of the logical block size when that does not take
+	 * it past the end of the blkio block, which is possible because
+	 * the blkio block size is a multiple of it.
+	 *
+	 * Rounding up to the logical block size, and no further, is
+	 * safe.  LV extents do not overlap the area lvm writes, so an
+	 * extent holding any of the added bytes would start among them,
+	 * at an offset that is not a multiple of the logical block size.
+	 * device-mapper refuses to map such an extent, so no active LV
+	 * can write there, and writing back what was read there changes
+	 * nothing.
 	 */
 	limit_nbytes = bio->last_byte_offset - bytes.offset;
 	block_nbytes = bytes.len;
+	sector_size = _logical_block_size(io->fd);
 
-	rounded_nbytes = _round_up_to_sector(limit_nbytes,
-					     bio->last_byte_sector_size);
+	rounded_nbytes = _round_up_to_sector(limit_nbytes, sector_size);
 	if (rounded_nbytes > block_nbytes) {
 		log_warn("WARNING: Skip extending write at %llu len %llu limit %llu extra %llu sector_size %llu.",
 			 (unsigned long long)bytes.offset,
 			 (unsigned long long)block_nbytes,
 			 (unsigned long long)limit_nbytes,
 			 (unsigned long long)(rounded_nbytes - limit_nbytes),
-			 (unsigned long long)bio->last_byte_sector_size);
+			 (unsigned long long)sector_size);
 		rounded_nbytes = limit_nbytes;
 	}
 
@@ -1315,11 +1339,10 @@ bool blkio_abort_di(struct blkio *bio, int di)
 
 /*----------------------------------------------------------------*/
 
-void blkio_set_last_byte(struct blkio *bio, int di, uint64_t offset, size_t sector_size)
+void blkio_set_last_byte(struct blkio *bio, int di, uint64_t offset)
 {
 	bio->last_byte_di = di;
 	bio->last_byte_offset = offset;
-	bio->last_byte_sector_size = sector_size ? sector_size : SECTOR_SIZE;
 }
 
 void blkio_unset_last_byte(struct blkio *bio, int di)
@@ -1327,7 +1350,6 @@ void blkio_unset_last_byte(struct blkio *bio, int di)
 	if (bio->last_byte_di == di) {
 		bio->last_byte_di = 0;
 		bio->last_byte_offset = 0;
-		bio->last_byte_sector_size = 0;
 	}
 }
 
diff --git a/lib/blkio/blkio.h b/lib/blkio/blkio.h
index 7ca2a1e54..b7227443a 100644
--- a/lib/blkio/blkio.h
+++ b/lib/blkio/blkio.h
@@ -80,7 +80,11 @@ bool blkio_zero_bytes(struct blkio *bio, int di, uint64_t start, size_t len);
 bool blkio_set_bytes(struct blkio *bio, int di, uint64_t start, size_t len, uint8_t val);
 bool blkio_invalidate_bytes(struct blkio *bio, int di, uint64_t start, size_t len);
 
-void blkio_set_last_byte(struct blkio *bio, int di, uint64_t offset, size_t sector_size);
+/*
+ * Writes to di stop at offset, rounded up to the logical block size of
+ * the device.
+ */
+void blkio_set_last_byte(struct blkio *bio, int di, uint64_t offset);
 void blkio_unset_last_byte(struct blkio *bio, int di);
 
 /*----------------------------------------------------------------*/
diff --git a/lib/label/label.c b/lib/label/label.c
index 68698bf4d..e07c8a000 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -2060,42 +2060,7 @@ fail:
 
 void dev_set_last_byte(struct device *dev, uint64_t offset)
 {
-	unsigned int physical_block_size = 0;
-	unsigned int logical_block_size = 0;
-	unsigned int bs;
-
-	if (!dev_get_direct_block_sizes(dev, &physical_block_size, &logical_block_size)) {
-		stack;
-		return; /* FIXME: error path ? */
-	}
-
-	if ((physical_block_size == 512) && (logical_block_size == 512))
-		bs = 512;
-	else if ((physical_block_size == 4096) && (logical_block_size == 4096))
-		bs = 4096;
-	else if ((physical_block_size == 512) || (logical_block_size == 512)) {
-		log_debug("Set last byte mixed block sizes physical %u logical %u using 512",
-			  physical_block_size, logical_block_size);
-		bs = 512;
-	} else if ((physical_block_size == 4096) || (logical_block_size == 4096)) {
-		/*
-		 * Use the logical block size, not 4096.  With 1024 or 2048
-		 * byte logical blocks, the first PE can start at an offset
-		 * that is not a multiple of 4096, and rounding up to 4096
-		 * would overwrite its start with data read earlier.
-		 * device-mapper maps PEs only at multiples of the logical
-		 * block size, so rounding up to that never reaches a PE in use.
-		 */
-		bs = logical_block_size ? logical_block_size : 4096;
-		log_debug("Set last byte mixed block sizes physical %u logical %u using %u",
-			  physical_block_size, logical_block_size, bs);
-	} else {
-		log_debug("Set last byte mixed block sizes physical %u logical %u using 512",
-			  physical_block_size, logical_block_size);
-		bs = 512;
-	}
-
-	blkio_set_last_byte(scan_blkio, dev->blkio_di, offset, bs);
+	blkio_set_last_byte(scan_blkio, dev->blkio_di, offset);
 }
 
 void dev_unset_last_byte(struct device *dev)
diff --git a/test/shell/logical-block-size.sh b/test/shell/logical-block-size.sh
new file mode 100644
index 000000000..cf51f19d2
--- /dev/null
+++ b/test/shell/logical-block-size.sh
@@ -0,0 +1,73 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2026 Itai Handler. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+
+# Use a PV with a logical block size other than 512 and 4096: a loop
+# device with --sector-size 1024 or 2048, or larger where the kernel
+# allows it.  dm-crypt with such a sector_size behaves the same.  Direct
+# I/O fails unless writes cover whole logical blocks, on the PV and on
+# LVs that inherit its size.
+
+
+. lib/inittest --skip-with-lvmpolld --skip-with-lvmlockd
+
+losetup -h | grep sector-size || skip
+
+cleanup_loop_and_teardown()
+{
+	# Remove the LV even if its VG cannot be read, so the loop is not busy.
+	aux teardown_devs_prefixed "$PREFIX"
+	test -n "${LOOP-}" && should losetup -d "$LOOP"
+	rm -f loopa
+	aux teardown
+}
+
+trap 'cleanup_loop_and_teardown' EXIT
+
+# A multiple of every tested block size but not of the 128KiB I/O block,
+# so the metadata area at the end of the device ends in a partial block.
+dd if=/dev/zero of=loopa bs=64k count=0 seek=513 2>/dev/null
+LOOP=$(losetup -f --show loopa) || skip "Cannot find free loop device"
+
+# prepare devX mapping so it works for real & fake dev dir
+m=${LOOP##*loop}
+dev1="$DM_DEV_DIR/loop$m"
+test -e "$dev1" || mknod "$dev1" b 7 "$m"
+
+aux extend_filter "a|$dev1|"
+aux extend_devices "$dev1"
+
+tested=
+for bs in 1024 2048 8192 16384 32768 65536 ; do
+	# The kernel rejects sizes above its limit (page size or 64KiB).
+	for i in {1..5} ; do
+		losetup --sector-size "$bs" "$LOOP" && break
+		sleep .1
+	done
+	test "$(blockdev --getss "$LOOP")" -eq "$bs" || continue
+
+	pvcreate --pvmetadatacopies 2 "$dev1"
+	vgcreate $vg "$dev1"
+	# Zeroes the first 4KiB of the LV.
+	lvcreate -l2 -n $lv1 $vg
+	check sysfs "$DM_DEV_DIR/$vg/$lv1" queue/logical_block_size "$bs"
+	lvextend -l+1 $vg/$lv1
+	vgchange -an $vg
+	vgchange -ay $vg
+	check lv_field $vg/$lv1 seg_size_pe "3"
+	vgremove -ff $vg
+	pvremove "$dev1"
+
+	tested="$tested $bs"
+done
+
+test -n "$tested" || skip "No logical block size other than 512 or 4096"
+echo "Tested logical block sizes:$tested"
diff --git a/test/shell/metadata-write-rounding.sh b/test/shell/metadata-write-rounding.sh
index 7bc2da2eb..d22cc3abb 100644
--- a/test/shell/metadata-write-rounding.sh
+++ b/test/shell/metadata-write-rounding.sh
@@ -12,8 +12,9 @@
 
 # lvm writes a metadata update back from data it read earlier, up to the
 # end of the metadata area, rounded up to whole blocks for direct I/O.
-# With 1024- or 2048-byte logical and 4096-byte physical blocks, the
-# first PE can start at an offset that is not a multiple of 4096.  Check
+# With logical blocks smaller than physical ones, such as 1024- or
+# 2048-byte logical and 4096-byte physical blocks, the first PE can start
+# at an offset that is not a multiple of the physical block size.  Check
 # that a metadata update does not undo a write to an LV on that PE, made
 # while the command waits for confirmation.
 
@@ -22,11 +23,13 @@
 
 mkfifo fifo
 
-for bs in 1024 2048 ; do
-	aux prepare_scsi_debug_dev 64 sector_size=$bs \
-		physblk_exp=$(( bs == 1024 ? 2 : 1 )) || skip
+# Logical block size and physical block exponent: 1024/4096, 2048/4096
+# and 2048/8192.
+for sizes in "1024 2" "2048 1" "2048 2" ; do
+	read -r bs exp <<< "$sizes"
+	aux prepare_scsi_debug_dev 64 sector_size=$bs physblk_exp=$exp || skip
 	check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $bs
-	check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size 4096
+	check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size $(( bs << exp ))
 	aux prepare_pvs 1 60
 	get_devs
 
diff --git a/test/unit/blkio_t.c b/test/unit/blkio_t.c
index afd9e3ae0..245ce8e2b 100644
--- a/test/unit/blkio_t.c
+++ b/test/unit/blkio_t.c
@@ -1071,7 +1071,7 @@ static void test_rejected_write_preserves_pending(void *context)
 
 	T_ASSERT(blkio_get(f->bio, 0, 1, GF_ZERO, &b));
 	blkio_put(b);
-	blkio_set_last_byte(f->bio, 0, 512, 512);
+	blkio_set_last_byte(f->bio, 0, 512);
 	T_ASSERT(!blkio_flush(f->bio));
 
 	/* Removing the limit must let the same dirty block be retried. */

base-commit: 7ea850a1419522cc0c8096d718551015465322d2
-- 
2.34.1

