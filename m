Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793535679;
	b=OGwg/8YUB4w7+ClElXHN0JBnXQf5B7XQEPuaTU0wr/fqLKqJMebXifM6rTo13ta3yYat
	 pUZXEjsqAVpSZ74Gkb+KaHJpP8Vcpd+9k9qBwSacErP4NfVf8W9Mm6+mQmtgQq3kBGBdZ
	 FCgAS2ut0qXdRTB8hhOrgI0xQdJ2T4RlSAtguBe3Ct9IV6BXiFywepCghrqfQJfJifgk6
	 cnt8N1c+VUYeKDoDerEa2m3CP0x+M3uOgc/wNbjRqDkLy+J9ynCyYxkyDOZlfcNIvDrWQ
	 g8KhmpqaZsvbuTDk4Vh/95z8yk2GCVa3XfHLFJEGYKOGSNfhHHY+3H+ybZNV0vTZHYw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793535679;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=d7yCgAlt9UWCWdiN7zDF6h8mLRByDWcCxhvZOnLnrGw=;
	b=u7dk8n19bsdABgfqdUr3Gkvg1Q0hWguND1oYMz6yKptWZWK8fsnIXSa0qeWm5+ijJdkf
	 4Qldp2VtOy58XWI3hahdKprPafZ3Q01d9lZ2WW1eY7xYld/lYkPoQgUWWeN7Oo1A6TrNy
	 ypl7v5S/4rUIwYfccn0AE+28bqAw/HG5aVw+PYab/+oTMbPbhYJKaJR2/uYHebOW+MA4S
	 e5LEZwO+uyHgtyJAT1Cx+zdu9lyrLjeGRqpP/siczrf/CW/IlfSw+8N/SQ3tuW2xD2KCd
	 CCzGUhvdE/tqleJCo/PvH0fPfNmr1KSOGrnzgd5medsw2b4XMudz0q9uZ+l9+nTVABQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=yr0wmu+9;
	arc=none smtp.remote-ip=209.85.128.45
Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99C4E606A324
	for <lvm-devel@lists.linux.dev>; Sun,  1 Nov 2026 12:21:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 99C4E606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=yr0wmu+9
Received: by mail-wm1-f45.google.com with SMTP id 5b1f17b1804b1-4a7a3b29c11so2483225e9.0
        for <lvm-devel@lists.linux.dev>; Sun, 01 Nov 2026 04:21:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793535677; x=1794140477; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=d7yCgAlt9UWCWdiN7zDF6h8mLRByDWcCxhvZOnLnrGw=;
        b=yr0wmu+9zYN0mfpoReTnqalBELeSAqQxQqjFmnPSp5DJWMTDOizyyzlDkmbJznnckw
         5wsWGrrLycEEvg9MpTo8417VtzuOw3CrWc/Cg8hoJwygR1lSM1P9r00dRfPIYgahALvf
         i5oeUCNRurQuKmRSH/ZzPGmADTdHW4CXgMwDSPhmPmBFVscCMsXJ2SXlpx/g/Ji1gqvJ
         +WxbKdP2GSG/ZU74odfqvA+3qNvWxzBOf//RbG7ueMvoSC6PezQbOYLGjZDdI+dyi5K6
         /it1Pm2XxJ5FibgjXTX8cAAelG/52FHfipLFMb8u2CfmFK5AX/omZFnZj6gcV7zA3yar
         QFww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793535677; x=1794140477;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=d7yCgAlt9UWCWdiN7zDF6h8mLRByDWcCxhvZOnLnrGw=;
        b=f62770FOD5RYQNpNpZDWWVcWaksocD2V4gp7Ti9cwQVsm2vAYoYFB0AF3sTXIWIEN9
         uzSGRLNJESICMp10NcnYzlyMwey64Mh5+rhCw5FCxRNVPaRhYwdp1GS2+jLEv7l0lqPf
         4LApES5oRLpWmGOE8L8XPdNxD3M5hNQdpTTHrdCrjSHg5k1rLKAY8YHCcK/TTWlAmV8z
         Ybn18Rw9po5lo+GQUtUH9tohM/x7Rf0KEfYzXfzqgkbaa7Ljkq/ponUIFhjEvuAHfQuw
         xrTq5vHjJjIxa7oSS38g+Q+B0oSRMsBd/fNRrwOL7otu5MYmAdfIDpDdhlmfhtUEnhDD
         +zQA==
X-Gm-Message-State: AFq9FYLFum5aqr2IpjZUJAd6I1f3ijYcLti0CwenJbGPKC6v/DmJwQst
	Kmkii/I/fahAmi2VBUf2XsiecFBancb6EuLSv+GmwRSqYBUrwQuR/P4em9sXrA==
X-Gm-Gg: AYBFou1UB9mfm6P6q2gVHXdeK3hbeC12xATk+PFB2K1CHXWmqKqnvotlzbx53gJzvtx
	Um6dddCjFcxLfKf+zpOeWeaiHyWuqRKn/l/w85iixay0pF0X0rp0QMR8pQGqIRfxKN7eSDhERCq
	lqG017YC2K/QVhMMFNJpGNTGi0JStq7eK2dC+SGbo3NcQeiQmSv9FWLgCsSd3A9z/C5/1vtwMPl
	4xOq161l+bmxz1eQarrT1woulbqJ4XuU7UXGY+mm3q6TU1PgJHrYxv1LNQc9m8BqEA/bGF7FTzA
	O6Hxp+d5+Sp/A0wgZiF5VYCevYQeQjGIYG3SbJCiG5abfyfkQa/7i8q1XYd2J0+7tenisyacCeE
	3LpHOLDw7Fgdcby8SndZJnhlMCvS4n27U7UeKN0L6//GQBtL3cfXjmhO+7J48cnfZ+p57TE21W1
	wDARcM/Jh2iuqmYjR2KGpH2zzmPuS6epwGLicUerF/t0oiUeLR9BnVJ3+xOIfW3Z6/jip6C9q0T
	X+htSE5TU2rQcqcTWrXtJaf8Nz0iZpLMF9ImtlJfpmZNlDN96+rQoFmcMq97kF7paSqVzrpwpjF
	t/+Ts8YZffFcBeukuJkdpB+rJVGs/RA/tvwn6C0Q5NshhN6XUQ==
X-Received: by 2002:a05:600c:1798:b0:4a0:1f9e:5f78 with SMTP id 5b1f17b1804b1-4ac1228a41emr109237625e9.0.1793535676811;
        Sun, 01 Nov 2026 04:21:16 -0800 (PST)
Received: from L-P-ITAIH2-L-RF.rf.local ([193.169.70.108])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4abf5b289f7sm195608535e9.5.2026.11.01.04.21.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 01 Nov 2026 04:21:16 -0800 (PST)
From: Itai Handler <itai.handler@gmail.com>
To: lvm-devel@lists.linux.dev
Cc: David Teigland <teigland@redhat.com>,
	Zdenek Kabelac <zkabelac@redhat.com>
Subject: [PATCH] label: don't round writes past the logical block size
Date: Sun,  1 Nov 2026 14:20:56 +0200
Message-Id: <20261101122056.1868423-1-itai.handler@gmail.com>
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

When LVM updates its metadata, it writes back 128KiB pieces of the disk
that it read earlier, cut short at the end of the metadata area and
rounded up to whole blocks, as direct I/O requires.

LVM rounds up to 4096 on devices with 1024- or 2048-byte logical blocks
and 4096-byte physical blocks, such as dm-crypt with 2048-byte sectors
on a 512e disk.  If LV data starts at an offset that is not a multiple
of 4096, for example with pvcreate --dataalignmentoffset, the write
also covers up to 3KiB of LV data with what LVM read earlier, undoing
any write made there since.

Round up to the logical block size instead.  That is all direct I/O
needs, and the added bytes cannot belong to an active LV: an LV there
would start at an offset that is not a multiple of the logical block
size, which device-mapper refuses to map.  Devices with 512- or
4096-byte logical blocks are not affected.

Fixes: aecf54212664 ("metadata: prevent writing beyond metadata area")
Assisted-by: LLM
---
Split out of the review of "label: fix writes when the logical block
size is not 512 or 4096", where this case came up:
https://lore.kernel.org/lvm-devel/auOUULF672SkVzt8@redhat.com/
A v2 of that patch will follow on top of this one.

Tested on main 77da16212 with Linux 7.3 x86_64: the new test passes,
and fails without the fix.  allow-mixed-block-sizes,
large-physical-sector-size, mda-rollback, metadata-balance, pe-align,
pvcreate-metadata0, pvcreate-operation and topology-support still
pass.  Debian's lvm2 2.03.31 and Ubuntu's 2.03.11 lose the write too.

 WHATS_NEW                             |  1 +
 lib/label/label.c                     | 14 ++++--
 test/shell/metadata-write-rounding.sh | 66 +++++++++++++++++++++++++++
 3 files changed, 78 insertions(+), 3 deletions(-)
 create mode 100644 test/shell/metadata-write-rounding.sh

diff --git a/WHATS_NEW b/WHATS_NEW
index e3462124e..7017c5c3e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.45 - 
 ==================
+  Fix metadata writes overwriting LV data with 1K or 2K logical block size.
   Skip kernel VDO formatting in test mode for pool creation and conversion.
   Round up and size extended RAID integrity metadata with image journal.
   Fit percentage-sized RAID integrity LVs with their metadata.
diff --git a/lib/label/label.c b/lib/label/label.c
index b9c0e7ca9..68698bf4d 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -2078,9 +2078,17 @@ void dev_set_last_byte(struct device *dev, uint64_t offset)
 			  physical_block_size, logical_block_size);
 		bs = 512;
 	} else if ((physical_block_size == 4096) || (logical_block_size == 4096)) {
-		log_debug("Set last byte mixed block sizes physical %u logical %u using 4096",
-			  physical_block_size, logical_block_size);
-		bs = 4096;
+		/*
+		 * Use the logical block size, not 4096.  With 1024 or 2048
+		 * byte logical blocks, the first PE can start at an offset
+		 * that is not a multiple of 4096, and rounding up to 4096
+		 * would overwrite its start with data read earlier.
+		 * device-mapper maps PEs only at multiples of the logical
+		 * block size, so rounding up to that never reaches a PE in use.
+		 */
+		bs = logical_block_size ? logical_block_size : 4096;
+		log_debug("Set last byte mixed block sizes physical %u logical %u using %u",
+			  physical_block_size, logical_block_size, bs);
 	} else {
 		log_debug("Set last byte mixed block sizes physical %u logical %u using 512",
 			  physical_block_size, logical_block_size);
diff --git a/test/shell/metadata-write-rounding.sh b/test/shell/metadata-write-rounding.sh
new file mode 100644
index 000000000..7bc2da2eb
--- /dev/null
+++ b/test/shell/metadata-write-rounding.sh
@@ -0,0 +1,66 @@
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
+# lvm writes a metadata update back from data it read earlier, up to the
+# end of the metadata area, rounded up to whole blocks for direct I/O.
+# With 1024- or 2048-byte logical and 4096-byte physical blocks, the
+# first PE can start at an offset that is not a multiple of 4096.  Check
+# that a metadata update does not undo a write to an LV on that PE, made
+# while the command waits for confirmation.
+
+
+. lib/inittest --skip-with-lvmpolld --skip-with-lvmlockd
+
+mkfifo fifo
+
+for bs in 1024 2048 ; do
+	aux prepare_scsi_debug_dev 64 sector_size=$bs \
+		physblk_exp=$(( bs == 1024 ? 2 : 1 )) || skip
+	check sysfs "$(< SCSI_DEBUG_DEV)" queue/logical_block_size $bs
+	check sysfs "$(< SCSI_DEBUG_DEV)" queue/physical_block_size 4096
+	aux prepare_pvs 1 60
+	get_devs
+
+	# The metadata area ends, and the first PE starts, one logical
+	# block after 64KiB.
+	pvcreate --metadatasize 8k --dataalignment 64k \
+		--dataalignmentoffset $(( bs / 1024 ))k "$dev1"
+	check pv_field "$dev1" pe_start $(( 64 + bs / 1024 )).00k
+	vgcreate $SHARED $vg "$dev1"
+	lvcreate -l1 -n $lv1 $vg "$dev1:0"
+	lvcreate -l1 -n $lv2 $vg
+
+	head -c $bs /dev/zero | tr '\0' A > A
+	head -c $bs /dev/zero | tr '\0' B > B
+	dd if=A of="$DM_DEV_DIR/$vg/$lv1" bs=$bs count=1 oflag=direct
+
+	# lvremove reads the start of the PV before asking, and writes the
+	# metadata after.
+	lvremove $vg/$lv2 <fifo 2>err &
+	PID=$!
+	exec 3>fifo
+	for i in {1..300} ; do
+		grep -q "really want" err && break
+		sleep .1
+	done
+	dd if=B of="$DM_DEV_DIR/$vg/$lv1" bs=$bs count=1 oflag=direct
+	echo y >&3
+	exec 3>&-
+	wait $PID
+	grep "really want" err
+
+	dd if="$DM_DEV_DIR/$vg/$lv1" of=data bs=$bs count=1 iflag=direct
+	cmp data B
+
+	vgremove -ff $vg
+	aux cleanup_scsi_debug_dev
+done

base-commit: 77da16212876fa7694fb266575b37a88c6e0108c
-- 
2.34.1

