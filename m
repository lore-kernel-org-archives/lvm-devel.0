Received: from mail-wm1-f45.google.com (mail-wm1-f45.google.com [209.85.128.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6724A1E835C
	for <lvm-devel@lists.linux.dev>; Tue, 13 May 2025 06:14:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747116893; cv=none; b=dIjncWss7xJXCvKGa+0lQAwgvqPqeBWr3xMYSkc+206y1rYdW+VkYU3sO3h2QsLD9qowAzWPWPUt4gACBvi5ClZbEOkO7fWVUtCgb4Ko9QiQxARXLvHfnrxQ2BGh+UKBsVVrP5PBrUkWEwLd2asbyadA7Fch9u1kd4/Sr2hRF6Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747116893; c=relaxed/simple;
	bh=xUrQ4/ec9NLJbi50x1QiSFl0Fwj8bBQ2i/nYJVyxdS0=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=u4TNGC9768xPNo0wbZK5qCbAcn4U/YkW3pAoTW3m0yVGuwJm2UQIqEJLK58r+2xRu9z3MirEDdTnHnu8GpXLI6TyA9+HZJMbCL/feR45sgmwf0iQQQdfu868HnKMqc0wfsslHpAqNo4VlVXCPsQzB08G9UFRkyOYNMHy9nRqWdg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=KDra1VTU; arc=none smtp.client-ip=209.85.128.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="KDra1VTU"
Received: by mail-wm1-f45.google.com with SMTP id 5b1f17b1804b1-43cfe574976so37483255e9.1
        for <lvm-devel@lists.linux.dev>; Mon, 12 May 2025 23:14:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1747116889; x=1747721689; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=I3KjISDHWWOQgBL3twHkmT+vT8pwvdoSddO5zXDHhr4=;
        b=KDra1VTUWjRyz/6Rn/DRJN6xhLJO9c0xRR46bvoYljIYG4OHM5d0QKbg+MX1GEcVYe
         SwNVZZfqHN0AGXhMmLwZm76Lyeaj7TGDmQKdnm45FSZwumPe5cpDEBYd4eBTbX9m8HCG
         fV1PYvSw8wFWmNVYB63v1HNuBT6PS6jlqbEmy05B9RA6A/EoWRMGXNogjkGo5rvwaUip
         mvZHZXrxyUEKMRdzoZGLLFEbL1mWhZ2+Sg0AuwMyCZcd3kNXA3AuOIuJJSJeKCMbjoiw
         DCamIgSLLxRh6oOLIZVPskE3uQobj7Io4gsRBXhhWoJ0AX91jgQp/noRTj1sipYVi1oV
         HZGQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747116889; x=1747721689;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=I3KjISDHWWOQgBL3twHkmT+vT8pwvdoSddO5zXDHhr4=;
        b=BbaMlwL93gnv1ZMleoSDo0hBpsP4t7cd1PvCbOSHaJ7asDguXIm5xZAP9bSS5+Mf3A
         e3SxzwN1y2TOg5tku7EAOaYnLksikfz2fIa+qlvdkODYSuTcz85PrxNIVSlfySqlddqu
         ZV7twc17NhvYa5seWdq28fU0PBICgLYGUGZf4G+DtacvbAzswz5bZXkyx72WTMbskais
         tdEzcrqjZ+iqlyEmquP63tORhhhorpbV7gXfKL8cOiocydZfYpdcfpiukZejNNrkeBmd
         5gs7xGyR7HLLi5oshl2fHSH7LfwDYHLKAOKZT9J7s7HcHTsSFcM8n12dqUcQ1VVdrhvR
         83Dg==
X-Gm-Message-State: AOJu0YxgYvnNbTZq3PdCnv9hKaPJszo1ekTGh5ethuZsChF/s/xR5uAE
	1QgIS1Upn4stBZe1c+0RMzf4Un14Z7zq7G3sH9zj6igqxvrtgzJY9iRYdF88LhHFAIZ3q5QAlh7
	qCNw=
X-Gm-Gg: ASbGnctg3re3GvVcOLuw87FL26kM+Fma/wx7h7i8CysdV+5pF8Gp2Ihm5qy//K0iAyI
	gE50gi30b6jKfYSrGyvKM1HGo7Ry2r/q03LMgvN8Z/Wp+u9yP0nkXjErXUR2x2zkc3MkB8f3qSd
	dyqhzKWcniBGaPu54mtV+xB4YSfZJm9B3Xk6dPlEq6D4yaTo6xLIBlKcyIHUGDYimPvBpwa7zHN
	f71gNt2xeLdrYMkH48EbTC4XZQXkdr6XY8tv2kTUMP25XTbZOJFs53Z/x+j0np/fSF4NW1CndiN
	Iz01+/flcolY4vF69y71JhAU+CvMeusnnk3POHfH4O9egAsG4oulvTSLGinoPlsxCTDjDr/NISz
	GhA==
X-Google-Smtp-Source: AGHT+IFjCswmShY78+2RF956xrMhylQP6bcIx0IeJ5Mp9X2mRz9EGpHCA0AKgC/uF2UrdF9qMuMtMA==
X-Received: by 2002:a05:6000:3108:b0:3a1:faa7:89e2 with SMTP id ffacd0b85a97d-3a1faa78b1fmr11113447f8f.58.1747116889413;
        Mon, 12 May 2025 23:14:49 -0700 (PDT)
Received: from localhost.localdomain ([202.127.77.110])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-30ad4fe2248sm10948310a91.35.2025.05.12.23.14.46
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Mon, 12 May 2025 23:14:48 -0700 (PDT)
From: Su Yue <glass.su@suse.com>
To: lvm-devel@lists.linux.dev
Cc: teigland@redhat.com,
	zkabelac@redhat.com,
	heming.zhao@suse.com,
	glass.su@suse.com,
	l@damenly.org
Subject: [PATCH 4/4] test: addm shell/lvresize-btrfs.sh
Date: Tue, 13 May 2025 14:14:27 +0800
Message-Id: <20250513061427.25843-5-glass.su@suse.com>
X-Mailer: git-send-email 2.39.5 (Apple Git-154)
In-Reply-To: <20250513061427.25843-1-glass.su@suse.com>
References: <20250513061427.25843-1-glass.su@suse.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

refer legacy patche:
- Ondrej Kozina <okozina@redhat.com>
https://listman.redhat.com/archives/lvm-devel/2012-November/msg00055.html

Signed-off-by: Heming Zhao <heming.zhao@suse.com>
[Adjust to lvresize]
Signed-off-by: Su Yue <glass.su@suse.com>
---
 test/shell/lvresize-btrfs.sh | 244 +++++++++++++++++++++++++++++++++++
 1 file changed, 244 insertions(+)
 create mode 100644 test/shell/lvresize-btrfs.sh

diff --git a/test/shell/lvresize-btrfs.sh b/test/shell/lvresize-btrfs.sh
new file mode 100644
index 000000000000..408a84e34200
--- /dev/null
+++ b/test/shell/lvresize-btrfs.sh
@@ -0,0 +1,244 @@
+#!/usr/bin/env bash
+
+# Copyright (C) 2025 Red Hat, Inc. All rights reserved.
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+test_description='Exercise btrfs resize'
+
+. lib/inittest
+
+aux have_fsinfo || skip "Test needs --fs checksize support"
+
+aux prepare_vg 1 1024
+
+which mkfs.btrfs || skip
+which btrfs	 || skip
+grep btrfs /proc/filesystems || skip
+
+vg_lv=$vg/$lv1
+vg_lv2=$vg/${lv1}bar
+vg_lv3=$vg/${lv1}bar2
+dev_vg_lv="$DM_DEV_DIR/$vg_lv"
+dev_vg_lv2="$DM_DEV_DIR/$vg_lv2"
+dev_vg_lv3="$DM_DEV_DIR/$vg_lv3"
+mount_dir="mnt"
+mount_space_dir="mnt space dir"
+
+test ! -d "$mount_dir" && mkdir "$mount_dir"
+test ! -d "$mount_space_dir" && mkdir "$mount_space_dir"
+
+cleanup_mounted_and_teardown()
+{
+	umount "$mount_dir" || true
+	umount "$mount_space_dir" || true
+	aux teardown
+}
+
+reset_lvs()
+{
+	# Since we call mkfs.btrfs with '-f', lvreduce to 64M is enough
+	lvreduce -L64M -nf $vg_lv || true
+	lvreduce -L64M -nf $vg_lv2 || true
+	lvreduce -L64M -nf $vg_lv3 || true
+}
+
+fscheck_btrfs() {
+	btrfsck "$1"
+}
+scrub_btrfs() {
+	btrfs scrub start -B "$1"
+}
+
+btrfs_devid() {
+	local devpath="$1"
+	local devid
+
+	devpath="$(readlink "$devpath")"
+
+	# It could be a multi-devices btrfs so call grep.
+	devid="$(LC_ALL=C btrfs filesystem show "$devpath" | grep "$devpath"$ || true)"
+
+	# if DM_DEV_DIR is not /dev/ e.g /tmp, output of btrfs filesystem show would be like:
+	# Label: none  uuid: d17f6974-267f-4140-8d71-83d4afd36a72
+	# 		 Total devices 1 FS bytes used 144.00KiB
+	# 		 devid    1 size 256.00MiB used 16.75MiB path /dev/mapper/LVMTEST120665vg-LV1
+	#
+	# But the VOLUME here is /tmp/mapper/LVMTEST120665vg-LV1
+	if [ -z "$devid" ];then
+		tmp_path="${devpath/#${DM_DEV_DIR}//dev}"
+		devid="$(LC_ALL=C btrfs filesystem show "$devpath" | grep "$tmp_path"$)"
+		devid=${devid##*devid}
+	fi
+
+	devid=${devid##*devid}
+	devid=${devid%%size*}
+	devid="$(echo "$devid" |sed 's/^[ \t]*//g'|sed 's/[ \t]*$'//g)"
+
+	echo "$devid"
+}
+
+# in MiB
+btrfs_device_size() {
+	local dev="$1"
+	local mnt="$2"
+	local devid
+
+	devid="$(btrfs_devid $dev)"
+	btrfs device usage -b "$mnt" | grep -A1 "ID: $devid"$ | grep 'Device size:' \
+		| awk '{print $NF}'
+}
+
+verify_mounted_device_size() {
+	local dev="$1"
+	local mnt="$2"
+	local size="$(echo $3 | numfmt --from=iec)"
+	local used_size
+
+	used_size=$(btrfs_device_size "$dev" "$mnt")
+
+	[[ "$used_size" == "$size"  ]]
+}
+
+verify_device_size() {
+	local dev="$1"
+	local size="$2"
+	local mnt="$mount_dir"
+
+	mount "$dev" "$mnt"
+	verify_mounted_device_size "$dev" "$mnt" "$size"
+	umount "$mnt"
+}
+
+# btrfs minimal size calculation is complex, we use 64M here.
+lvcreate -n $lv1 -L64M $vg
+lvcreate -n ${lv1}bar -L64M $vg
+lvcreate -n ${lv1}bar2 -L64M $vg
+trap 'cleanup_mounted_and_teardown' EXIT
+
+single_device_test() {
+	mkfs.btrfs -m single "$dev_vg_lv"
+	mkfs.btrfs -m single "$dev_vg_lv2"
+
+
+	# kernel limits 256 MB as minimal btrfs resizable size
+	# you can grow fs from 64MB->256MB
+	# but you can't grow from 64MB->180MB
+	lvresize -y --fs resize $vg_lv -L 256M
+	verify_device_size $dev_vg_lv 256M
+	lvresize -y --fs resize $vg_lv2 -L 256M
+	verify_device_size $dev_vg_lv2 256M
+
+	not lvresize -y --fs resize $vg_lv -L 200M
+	lvresize -y -L+12M --fs resize $vg_lv
+	verify_device_size $dev_vg_lv 268M
+	# lvreduce default behavior is fs checksize, must fail
+	not lvreduce -y -L256M $vg_lv
+	lvreduce -y -L256M --fs resize $vg_lv
+	fscheck_btrfs $dev_vg_lv
+
+	# do test on mounted state
+	mount "$dev_vg_lv" "$mount_dir"
+	mount "$dev_vg_lv2" "$mount_space_dir"
+
+	# 'not': we expect a failure here.
+	not lvresize --fs resize $vg_lv -L 200M
+	lvresize -L+12M --fs resize $vg_lv
+
+	verify_mounted_device_size $dev_vg_lv "$mount_dir" 268M
+	# lvreduce default behavior is fs checksize, must fail
+	not lvreduce -L256M $vg_lv
+	lvreduce -L256M --fs resize $vg_lv
+	verify_mounted_device_size $dev_vg_lv "$mount_dir" 256M
+	scrub_btrfs $dev_vg_lv
+	umount "$mount_dir"
+
+	not lvresize --fs resize $vg_lv2 -L 200M
+	lvresize -L+12M --fs resize $vg_lv2
+	verify_mounted_device_size $dev_vg_lv2 "$mount_space_dir" 268M
+	not lvreduce -L256M --fs checksize $vg_lv2
+	lvreduce -L256M --fs resize $vg_lv2
+	verify_mounted_device_size $dev_vg_lv2 "$mount_space_dir" 256M
+	scrub_btrfs $dev_vg_lv2
+	umount "$mount_space_dir"
+}
+
+multiple_devices_test() {
+
+	# fs size is the sum of the three LVs size
+	mkfs.btrfs -m single -d single -f "$dev_vg_lv" "$dev_vg_lv2" "$dev_vg_lv3"
+
+	# The VG is 1GB size, we expect success here.
+	# lv,lv2,lv3 size are changed from 64M to 256M
+	lvresize --fs resize $vg_lv -L 256M --fsmode manage
+	lvresize --fs resize $vg_lv2 -L 256M --fsmode manage
+	lvresize --fs resize $vg_lv3 -L 256M --fsmode manage
+
+	verify_device_size $dev_vg_lv 256M
+	verify_device_size $dev_vg_lv2 256M
+	verify_device_size $dev_vg_lv3 256M
+
+	# check if lvextend/lvreduce is able to get/resize btrfs on
+	# the right device
+	lvextend -L+150M --fs resize $vg_lv --fsmode manage
+	lvreduce --fs resize $vg_lv -L 300M --fsmode manage
+	verify_device_size $dev_vg_lv 300M
+	not lvreduce -y -L256M --fs checksize $vg_lv --fsmode manage
+	lvreduce -L256M --fs resize $vg_lv --fsmode manage
+	verify_device_size $dev_vg_lv 256M
+	fscheck_btrfs $dev_vg_lv
+
+	lvextend -L+150M --fs resize $vg_lv2 --fsmode manage
+	lvreduce --fs resize $vg_lv2 -L 300M --fsmode manage
+	verify_device_size $dev_vg_lv2 300M
+	not lvreduce -y -L256M --fs checksize $vg_lv2 --fsmode manage
+	lvreduce -y -L256M --fs resize $vg_lv2 --fsmode manage
+	verify_device_size $dev_vg_lv2 256M
+	fscheck_btrfs $dev_vg_lv2
+
+	lvextend -L+150M --fs resize $vg_lv3 --fsmode manage
+	lvreduce --fs resize $vg_lv3 -L 300M --fsmode manage
+	verify_device_size $dev_vg_lv3 300M
+	not lvreduce -y -L256M --fs checksize $vg_lv3 --fsmode manage
+	lvreduce -y -L256M --fs resize $vg_lv3 --fsmode manage
+	verify_device_size $dev_vg_lv3 256M
+	fscheck_btrfs $dev_vg_lv3
+
+	# repeat with mounted fs
+	mount "$dev_vg_lv" "$mount_dir"
+
+	lvresize -L300M --fs resize $vg_lv
+	verify_mounted_device_size $dev_vg_lv "$mount_dir" 300M
+	lvreduce -y -L256M --fs resize $vg_lv
+	verify_mounted_device_size $dev_vg_lv "$mount_dir" 256M
+
+	lvresize -L300M --fs resize $vg_lv2
+	verify_mounted_device_size $dev_vg_lv2 "$mount_dir" 300M
+	lvreduce -y -L256M --fs resize $vg_lv2
+	verify_mounted_device_size $dev_vg_lv2 "$mount_dir" 256M
+
+	lvresize -L300M --fs resize $vg_lv3
+	verify_mounted_device_size $dev_vg_lv3 "$mount_dir" 300M
+	lvreduce -y -L256M --fs resize $vg_lv3
+	verify_mounted_device_size $dev_vg_lv3 "$mount_dir" 256M
+
+	scrub_btrfs $dev_vg_lv
+	umount "$mount_dir"
+
+	lvresize -nf -L300M $vg_lv
+	lvresize -nf -L300M $vg_lv2
+}
+
+single_device_test
+# after each test, reset_lv_size should be called to make sure
+# all lvs are in same state/size.
+reset_lvs
+multiple_devices_test
+
+
+vgremove -ff $vg
-- 
2.48.1

