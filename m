Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793278427;
	b=n4NZ8SIsHxWDUW5C9W6lLejVnlTSlTVU5c/sM8Q9wiAkZb7RznEkuv09E1tksa8jvD0e
	 gR2OPyaKZcjSuIIVEQy3zvVWTv6cDU9HByO80U5dhZVkKYrx3BBJB1hXWPT57+b74NQ5c
	 dcrf7d6Z2SuevZSLnesbvnJhDb1RKADtEL/yB0K57b3b8EUjGb0pj/9Pi7X6lTahAHUPv
	 mqnz/qhvm/FT6cXC5N5+aBRM+1OzEnjqMJYAprMsfahq5R7kKEfBgowmi2UxrKDMCPhW0
	 TgeO2eVC8PRJ59R7rYvQnW8Dp1C1SD02MJ1b8u8BqUhx5g2zsa3TVWiX4ojCNBR5BCw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793278427;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=inlH0eFXYYGE9SdV2CeN+7QcQ5FtPVIwXsGijCrGXyA=;
	b=gn19cI/vOVOZK6TkOYhI7K6CyaRgqiLvzPgmbxwuOSiWglwfT2gusORhgQKtObbd/bSI
	 FM0SnrzdYoo/JMI6DBuGXWIr8wPKKUdJPtHahW8ztuO0OT0oDAm7uIiBL70F8aSy9GpGU
	 +UpMXyxFhtHpn1+hJ2m2yarx7jDJYe9OZCkoQGaI5qQlnTRWorM+SdwWO3Ib+h1gDRePL
	 DQ78UOpKlBURCCvqPafIkoEbwzEPXKXIfylkaGcE3RwQ1MxUGAqldeWuBHSX3QsC/5sh8
	 2xLAVBkweFUnSCFl2tqftcA2RbDi9HbKdR/v+YApQPlP2nJ/c+mq6kkuSetnNYIP8sg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=sRd73oNp;
	arc=none smtp.remote-ip=209.85.128.54
Received: from mail-wm1-f54.google.com (mail-wm1-f54.google.com [209.85.128.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41BA5606A31C
	for <lvm-devel@lists.linux.dev>; Thu, 29 Oct 2026 12:53:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 41BA5606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=sRd73oNp
Received: by mail-wm1-f54.google.com with SMTP id 5b1f17b1804b1-4a215344409so3668825e9.2
        for <lvm-devel@lists.linux.dev>; Thu, 29 Oct 2026 05:53:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793278425; x=1793883225; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=inlH0eFXYYGE9SdV2CeN+7QcQ5FtPVIwXsGijCrGXyA=;
        b=sRd73oNppu/2O+xzyZb0YiwHtdmuSE3CDrhwDNw4vgQj9g8+r1vFZEuqysgDw6kHTW
         3BPCRkr5tX84rOKMTVZxEkb1uaEeFx8ZjoTNzO10DgCtDIM7KOH4xUVFx8uWkA2Cf2KP
         KYsTKw4sOgaXJKAovtRE2keNzC9j3NDsXYBa2s3MhbVezGy/ib4ylTLexKTuiaQH3Vri
         DjuRFzxMwha0v0LaCboCRAKS2Yp3g0tFimbT2nZMTBd4KZBRjag7fgiYFFkwhg6h2hFb
         zOJ2PoHWFvXEGuUDz+bd7UborUdetW6YB9q0BBJSmtXP5qrw/EbpcBzGW6dBEoiQVl8N
         CwIA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793278425; x=1793883225;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=inlH0eFXYYGE9SdV2CeN+7QcQ5FtPVIwXsGijCrGXyA=;
        b=Po5IfajNl3F/IZ6BfWMqBYvHMhTeG7jfjO7YuqiPg7sf5AMIpD6sSJlCtlBNlbwGoi
         0Ga1Pu5XXdt59SFl/ZuV+2v30kvPBTD5YKpOZo+ba5aaC07PYz3fJp1ZmK6NZ+5lxFto
         UZNF5tTCHva6p8uSArUJyerHll+OKqoRRirYXIORXyvoHqRfTzLMplGSJBnlsdx572z1
         W3mkKLOhIP0Q6XR2VR8tgfraFKP6CYcgpJgL7aNU/GIHpY37IBs3TC26IZglp7yXIum3
         nT0niV0DaIm1CfFRgLb2hDq1nAGsIYby4NsEtyeYDEq4jETxXl0XWgQhT4nKP/niYxzC
         9CYg==
X-Gm-Message-State: AFq9FYIHF93KwAFqzHWcPw1n2F52oauyW/eKz6lZ5G1QndM4FNqC775J
	13/5SOrZJnDk4G4ibjswc1GX3NPLzyWEJUrWJHztvozrcE7oTkneagQkgnfrVA==
X-Gm-Gg: AYBFou0sUAuvoRAqu05XgMZd0uh/LVmU0gOQzMMkSZGyMcokjIrcGTOSf9OHMWmcIOc
	MOPI7vN4Hf5Iuhrifu5ofhXb1QesbkB7DeDCFt4i2BocadxSCcO1UfxsXBmuFa2avxuyWOviIN/
	WrXWOd7vc4TctuJuN5+9G8XUUYvhTnSfaii6NdxHjNZyLP+6LOa6lPX17gs1KrQJP4S6kBIsWBo
	qWxSu7+oeKkszICHpIDozV5WljJQi2qzJwEuYTgzIP5TMqcCBiG3IKp0YfMxokSVTDrqbiOa/Mc
	ySgk23uss+TPWhkA7i54h8d6FDJrzB+1VWfGWKQO9kDHQDJQz8nTkvI2jY76iiBgR9+JnmCOm31
	bKL06X6T7zRiFLCXctBzNBkJdRMpePS3AuNm+aQQK4HBogUas7D6d/Ph4hXPNrhe+Xlb6CAmYu3
	7ZsfSa5SZxFokoNIFwlvYgst4bKKWMN7SNDZZNRcomLLBjBXkqot3rG7cp197OB2/XkTb2PNvAn
	zSk5+OOJ8q3rtMMhi+3XxLfoCuHVtXPxYq2tATutM8q2Rnm41O/pgsHoxNGOuKoUTNIU+gkOdUG
	0vwEsGKiElzhPYxv0HWWxNLqLlKbA9J7K5o63WL5PASwzbOEe5Y+4FDLtZzgRtsIMTH3RLg=
X-Received: by 2002:a5d:4bd0:0:b0:48d:f1b3:7e82 with SMTP id ffacd0b85a97d-48e5d27ed3dmr10836026f8f.0.1793278425293;
        Thu, 29 Oct 2026 05:53:45 -0700 (PDT)
Received: from L-P-ITAIH2-L-RF.rf.local ([193.169.70.108])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e4806e208sm28353365f8f.40.2026.10.29.05.53.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 05:53:44 -0700 (PDT)
From: Itai Handler <itai.handler@gmail.com>
To: lvm-devel@lists.linux.dev
Cc: David Teigland <teigland@redhat.com>,
	Zdenek Kabelac <zkabelac@redhat.com>
Subject: [PATCH] label: fix writes when the logical block size is not 512 or 4096
Date: Thu, 29 Oct 2026 14:53:12 +0200
Message-Id: <20261029125312.3631129-1-itai.handler@gmail.com>
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

Since lvm2 2.03.06, LVM cannot be used on a device whose logical block
size, the smallest unit it can read or write, is neither 512 nor 4096
bytes.  pvcreate, which prepares a device for LVM, fails:

  # truncate -s 64M disk.img
  # losetup --sector-size 2048 --show -f disk.img
  /dev/loop8
  # pvcreate /dev/loop8
    WARNING: threads io engine write device offset 0 len 4608: Invalid argument.
    Error writing device /dev/loop8 at 4096 length 512.
    Failed to write mda header to /dev/loop8.
    Failed to write physical volume "/dev/loop8".

LVM writes with direct I/O, bypassing the kernel's cache, and such
writes must cover whole logical blocks.  LVM keeps the data it reads in
memory, in 128KiB pieces.  To save a change, it writes a piece back from
its start up to the end of the area being updated, rounded up to a
whole block.  But for this rounding it only knows block sizes of 512
and 4096 bytes, and uses 512 for any other size.  So above, to update
the 512-byte metadata header at offset 4096, LVM writes the first 4608
bytes, 2.25 blocks of 2048 bytes, and the kernel rejects the write.

Fix this by rounding up to the logical block size of the device when
it is neither 512 nor 4096.  Writes then cover a little more of the
device, but the extra bytes are rewritten with the data already there,
just as on devices with 4096-byte blocks.  Devices with 512- or
4096-byte blocks, which are almost all disks, are not affected.

Devices with other block sizes are uncommon, but easy to create: loop
devices with --sector-size 1024 or 2048, and dm-crypt (disk encryption)
devices with 1024- or 2048-byte sectors.  On kernels configured with
pages larger than 4KiB, both can also use 8KiB up to the page size.
For dm-crypt this needs target version 1.30.0, added by Linux commit
1acc65c30f85 ("dm-crypt: allow encryption sector size up to PAGE_SIZE").
With blocks that large, the fix also lets lvcreate clear the first 4KiB
of a new logical volume, which inherits the block size of the device it
is on.

Fixes: 7f347698e3d0 ("Fix rounding writes up to sector size")
Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
---
Tested on main a2decfaf4:

- Linux 6.8 x86_64 host: the new test passes with 1KiB and 2KiB loop
  devices and fails without the fix (larger sizes are skipped, loop
  accepts at most the page size there).  allow-mixed-block-sizes,
  large-physical-sector-size and topology-support still pass.
  pvcreate with two metadata areas, vgcreate, lvcreate, lvextend and
  reactivation work on dm-crypt with sector_size 2048.

- QEMU, Linux 7.4 merge window kernel (65ba8f34ec88), arm64 with 64KiB
  pages: the new test passes with all six sizes, 1KiB to 64KiB, and
  fails without the fix.  The same sequence works on dm-crypt with
  these sector sizes; a new LV on reused extents has its first 4KiB
  zeroed and the rest of its first logical block unchanged.  Debian's
  lvm2 2.03.31 fails pvcreate on each of these devices.

 WHATS_NEW                        |  1 +
 lib/label/label.c                | 11 ++++--
 test/shell/logical-block-size.sh | 65 ++++++++++++++++++++++++++++++++
 3 files changed, 74 insertions(+), 3 deletions(-)
 create mode 100644 test/shell/logical-block-size.sh

diff --git a/WHATS_NEW b/WHATS_NEW
index 1dad9be52..8f2cdd5a1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.45 - 
 ==================
+  Fix writes to devices with logical block size other than 512 or 4096.
   Explain RAID extend failures when images share a PV or PVs differ.
 
 Version 2.03.44 - 27th October 2026
diff --git a/lib/label/label.c b/lib/label/label.c
index b9c0e7ca9..adf0540a0 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -2082,9 +2082,14 @@ void dev_set_last_byte(struct device *dev, uint64_t offset)
 			  physical_block_size, logical_block_size);
 		bs = 4096;
 	} else {
-		log_debug("Set last byte mixed block sizes physical %u logical %u using 512",
-			  physical_block_size, logical_block_size);
-		bs = 512;
+		/*
+		 * Neither size is 512 or 4096, e.g. a loop device or dm-crypt
+		 * with 2048-byte sectors.  Direct I/O must still cover whole
+		 * logical blocks.
+		 */
+		bs = logical_block_size ? logical_block_size : 512;
+		log_debug("Set last byte block sizes physical %u logical %u using %u",
+			  physical_block_size, logical_block_size, bs);
 	}
 
 	blkio_set_last_byte(scan_blkio, dev->blkio_di, offset, bs);
diff --git a/test/shell/logical-block-size.sh b/test/shell/logical-block-size.sh
new file mode 100644
index 000000000..2091a65ff
--- /dev/null
+++ b/test/shell/logical-block-size.sh
@@ -0,0 +1,65 @@
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
+# device with --sector-size 1024 or 2048, or larger up to the page size.
+# dm-crypt with such a sector_size behaves the same.  Direct I/O fails
+# unless writes cover whole logical blocks, on the PV and on LVs that
+# inherit its size.
+
+
+. lib/inittest --skip-with-lvmpolld --skip-with-lvmlockd
+
+losetup -h | grep sector-size || skip
+
+# A multiple of every tested block size but not of the 128KiB I/O block,
+# so the metadata area at the end of the device ends in a partial block.
+dd if=/dev/zero of=loopa bs=64k count=0 seek=513 2>/dev/null
+LOOP=$(losetup -f --show loopa)
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
+losetup -d "$LOOP"
+rm loopa
+
+test -n "$tested" || skip "No logical block size other than 512 or 4096"
+echo "Tested logical block sizes:$tested"

base-commit: a2decfaf4ce6f132137da61ba9132578b840e333
-- 
2.34.1

