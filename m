Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C69A91EA7C3
	for <lvm-devel@lists.linux.dev>; Tue, 13 May 2025 06:14:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747116891; cv=none; b=azlePymM+ISju+L/b9ViZKrB0C8zZ4K2c/tOfNPzC1H2U+zHvziUWvoDbQgDsbNiIDJk3hmwF34JBADGLA0LTtwnr3x9I5OjdtJ/lov6z1Ah9xRaJ187HTgWJlpbfrZzB1gmwxICcXC1GIT7Qn+4J8e6eGkBfJNAmbydCtSzZOc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747116891; c=relaxed/simple;
	bh=OrAOSvSJNO49ozMWEpjuBE9YSamh4UDF3/HvbLTbD0c=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=RCL6cV66aNh6MWoVg/coitmbEhkfptR8GNB19q+0ai682irY0S/Ww38FL1+nvxPabQgsZwgGeSYIf6aVP1l4AdwX/a0xKvzApScYPUvFX19iFOkaVs4qcjV8GKpAvUyGwTJ5ew+C0Xyw/P8cTCAJ4c8a5piwRPkOl/G+bbTMX6s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=gtDH/FAx; arc=none smtp.client-ip=209.85.221.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="gtDH/FAx"
Received: by mail-wr1-f51.google.com with SMTP id ffacd0b85a97d-3a1f5d2d91eso2871715f8f.1
        for <lvm-devel@lists.linux.dev>; Mon, 12 May 2025 23:14:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1747116886; x=1747721686; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=CuhPUPAQyYfjjlVTbN0v9wBLwiQ/vTG7p/hQVygwhws=;
        b=gtDH/FAxp8siMGpF3s4lxx882y2fOIQEJ5WevcgvAcLmVyKsQjnyQsH2sVOtktR5yl
         KdiRUd3fKgzqAaMZxPG2ByLRvb656vZSuvyyww8VROxDVoVrQldjbhe7Gowc/5rHsQVX
         CxGJE3I+f3h1vnCMK4RkJJ7gJLuISK3shT79ireZcJEIhbWbDA/eHpUgIkbupGV5G72A
         WIsfIxZS44Rnw+ypEBSkGcvufrkVllOMJDpFvpHx8qggBl2t6SdK+b6MX703+xoDgZoh
         Wize/gNzM2chFx/nX+uTMSusMbC5u9a9GWRLf+VwS5SHBibDWYf9j4O+U7wdjvk4PjT9
         mNWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747116886; x=1747721686;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=CuhPUPAQyYfjjlVTbN0v9wBLwiQ/vTG7p/hQVygwhws=;
        b=I3/G7fmX+6HKpEi45L8NUZMaPj79tWvl8Ojt7HY5GivD8DPUIhaYaXmE0hEOgRB4JH
         3jVwwSA8e/8tGF3zTifTb8vSsXOMf0njyS3am6YWHarHbYq0nDINL8DoEMs+GlrQx3Qq
         tD3iShdzDlldOhqgawnQQqZIGLm8ZSvV8yZ4ZInoJzJ2BXiyuxJp9qD4t319PwkcWBZ0
         R8d73fyglS2ED29c5KHPCoF2q/YeKx5NcDfxSi+9RA4ngeYpFAjIuaKJwHa4AYNIQHiQ
         6sdF55HxJd2nNFD+2AETI3aJxKTA4TB9APXHOvoxYZmga8vvLo1xtKeXY0yhP7iFwSab
         g02A==
X-Gm-Message-State: AOJu0Yx6hFqzJAVKly0bjj1st//gg7p1ZSymJQPwEdsTrVDkR4JYqTsm
	x8imi1Ps1NrEG5yNRT0y8+pJcPVFUnVbMtmBnt2OhyxQpD3ebJVLUEuD1mmAVaSX9Czr1K73lmt
	+ehw=
X-Gm-Gg: ASbGncvo3vNByw5cYp2T0cyijIECIfC0uPEG1ITTFlQ27PoibfWtwam+eokOk1048wq
	4UG9czc8n5sPSeQ+/7DaozSRHdq8rsAQw+q0bSxs3sC7BzMBMXSWQIZ5BNsghVv58MG+HyRcx4D
	ZkFy7nF86hiOv0zX7/ojj2rtbaxCbYmxkgPDC2ptoHSG1vpXnSf1r4IXCJfrLqmhoZJ6IadnD/6
	A8sQZXLC8J10vRfGk2YFAZkzyA025eqADEjZVPF2mLzx8zGgZXUl+wA+4r/J8vgYGapyTalLd0/
	OEOoUmbJC7XZj4JW4yLbXVbMHHGMIk2kwWUXA4P+w8XEigSYERjCo1VTfwQEydc6q4FAikbewjp
	pGA==
X-Google-Smtp-Source: AGHT+IGJQ2RdpqNFrmcxGO8TDSbUt28wcob0/m6hcZTvynE8gbOsE0TTURKcQ8uYLZpfS7o9jZcu+A==
X-Received: by 2002:a05:6000:2207:b0:3a1:4c72:9072 with SMTP id ffacd0b85a97d-3a1f6438490mr12545253f8f.17.1747116886287;
        Mon, 12 May 2025 23:14:46 -0700 (PDT)
Received: from localhost.localdomain ([202.127.77.110])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-30ad4fe2248sm10948310a91.35.2025.05.12.23.14.43
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Mon, 12 May 2025 23:14:45 -0700 (PDT)
From: Su Yue <glass.su@suse.com>
To: lvm-devel@lists.linux.dev
Cc: teigland@redhat.com,
	zkabelac@redhat.com,
	heming.zhao@suse.com,
	glass.su@suse.com,
	l@damenly.org
Subject: [PATCH 3/4] lvresize: add btrfs support
Date: Tue, 13 May 2025 14:14:26 +0800
Message-Id: <20250513061427.25843-4-glass.su@suse.com>
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

This commit adds lvresize/lvextend/lvreduce support for btrfs.
'btrfs filesystem resize [devid:][+/-]<newsize>[kKmMgGtTpPeE]|[devid:]max <path>'
is used to resize one device only when it's mounted.
The code pattern is like xfs but it supports shrink.

For multi-devices btrfs, There is one difficulty to be handled:

If `lvreduce --fs resize` is given, lvm2 will check newsize vs current fs size
to judge if it's need to shrink fs or not.
For one device btrfs, fslastblock * fsblocksize/FSSIZE is the correct value like
ext* and xfs. But for multi-devices btrfs, the two values are whole fs size.
There is no other way without relying btrfs superblock parse. It's too
complicated and inproper to implemnt the logic in lvm2.
So here just sets fs_last_byte to 0 for btrfs and skips boundary check in
_fs_reduce_allow(). It's safe as btrfs will handle it well.

The another complicated part is how to get mount point info if multi-devices.
There is only one mnt entry per mounted fs in /etc/mtab even it's a
multi-devices btrfs. So we first get uuid from lv device then traverse devices
under /sys/fs/btrfs/$uuid/devices and compare them to the mnt entry to get the
mount point.

Signed-off-by: Su Yue <glass.su@suse.com>
---
 lib/device/dev-type.c         |   7 ++
 lib/device/filesystem.c       | 132 ++++++++++++++++++++++++++++++++--
 lib/metadata/lv_manip.c       |  73 ++++++++++++-------
 scripts/lvresize_fs_helper.sh | 110 ++++++++++++++++++++++++----
 4 files changed, 276 insertions(+), 46 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 08848ca0f216..4c1040c9f055 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -1018,6 +1018,13 @@ int fs_get_blkid(const char *pathname, struct fs_info *fsi)
 			fsi->fs_last_byte += fsblocksize;
 
 	}
+	/*
+	 * For a multi-devices btrfs, fslastblock * fsblocksize means the whole fs size.
+	 * Thus here fs_last_byte can't be used as a device size boundary.
+	 * Let btrfs handle it.
+	 */
+	if (!strcmp(fsi->fstype, "btrfs"))
+		fsi->fs_last_byte = 0;
 
 	log_debug("libblkid TYPE %s BLOCK_SIZE %d FSLASTBLOCK %llu FSBLOCKSIZE %u fs_last_byte %llu",
 		  fsi->fstype, fsi->fs_block_size_bytes, (unsigned long long)fslastblock, fsblocksize,
diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index 9c865b25fb57..e6aa8c570763 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -130,13 +130,25 @@ static int _fs_get_mnt(struct fs_info *fsi, dev_t devt)
 			continue;
 		if (me->mnt_fsname[0] != '/')
 			continue;
-		if (stat(me->mnt_dir, &stme) < 0)
-			continue;
-		if (stme.st_dev != devt)
-			continue;
+
+		/*
+		 * st_dev of mnt_dir in btrfs is an anonymous device number,
+		 * use mnt_fsname instead.
+		 */
+		if (!strcmp(fsi->fstype, "btrfs")) {
+			if (stat(me->mnt_fsname, &stme) < 0)
+				log_sys_error("stat", me->mnt_fsname);
+			if (stme.st_rdev != devt)
+				continue;
+		} else {
+			if (stat(me->mnt_dir, &stme) < 0)
+				continue;
+			if (stme.st_dev != devt)
+				continue;
+			fsi->mounted = 1;
+		}
 
 		log_debug("fs_get_info %s is mounted \"%s\"", fsi->fs_dev_path, me->mnt_dir);
-		fsi->mounted = 1;
 		strncpy(fsi->mount_dir, me->mnt_dir, PATH_MAX-1);
 	}
 	endmntent(fme);
@@ -144,6 +156,103 @@ static int _fs_get_mnt(struct fs_info *fsi, dev_t devt)
 	return 1;
 }
 
+static int _btrfs_get_mnt(struct fs_info *fsi, dev_t lv_devt)
+{
+	char devices_path[PATH_MAX];
+	char rdev_path[PATH_MAX];
+	unsigned major, minor;
+	dev_t devt;
+	char buffer[16];
+	char *device_name;
+	DIR *dr;
+	struct dirent *de;
+	int ret = 1;
+	int fd = -1;
+	int r;
+	bool found = false;
+
+	/* For a mounted btrfs, there will be a sys dir like /sys/fs/btrfs/$uuid/devices */
+	if (!dm_snprintf(devices_path, sizeof(devices_path), "%sfs/btrfs/%s/devices",
+			dm_sysfs_dir(), fsi->uuid)) {
+		log_error("Couldn't create btrfs devices path for %s.", fsi->fs_dev_path);
+		return 0;
+	}
+
+	/* btrfs module is not avaiable or the device is not mounted */
+	if (!(dr = opendir(devices_path))) {
+		if (errno == ENOENT) {
+			fsi->mounted = 0;
+			return 1;
+		}
+	}
+
+	/*
+	 * Here iterates entries under /sys/fs/btrfs/$uuid/devices and read devt.
+	 * There is only one mnt entry per mounted fs even it's a multi-devices fs.
+	 * So also call _fs_get_mnt for every devices to find a matched mount point.
+	 */
+	while ((de = readdir(dr))) {
+		if (!strcmp(de->d_name, ".") || !strcmp(de->d_name, ".."))
+			continue;
+
+		device_name = de->d_name;
+
+		if (!dm_snprintf(rdev_path, sizeof(devices_path), "%s/%s/dev",
+				 devices_path, device_name)) {
+			    log_error("Couldn't create rdev path for %s.", fsi->fs_dev_path);
+			    ret = 0;
+			    break;
+		}
+
+		if ((fd = open(rdev_path, O_RDONLY)) < 0) {
+			log_sys_debug("open", rdev_path);
+			ret = 0;
+			break;
+		}
+
+		r = read(fd, buffer, sizeof(buffer));
+		if (r < 0) {
+			ret = 0;
+			close(fd);
+			log_sys_debug("read", rdev_path);
+			break;
+		}
+
+		buffer[r - 1] = 0;
+
+		if (sscanf(buffer, "%u:%u", &major, &minor) != 2) {
+			ret = 0;
+			log_sys_debug("sscanf", rdev_path);
+			break;
+		}
+
+		devt = MKDEV(major, minor);
+		if (devt == lv_devt)
+			found = true;
+
+		if (fsi->mount_dir[0] == 0)
+			_fs_get_mnt(fsi, devt);
+
+		if (fsi->mounted && fsi->mount_dir[0])
+			break;
+	}
+
+	if (fd >= 0)
+		close(fd);
+
+	if (closedir(dr))
+		log_sys_debug("closedir", devices_path);
+
+	fsi->mounted = !!found;
+
+	if (fsi->mounted && fsi->mount_dir[0] == 0) {
+		log_error("Couldn't get mount point for %s.", fsi->fs_dev_path);
+		ret = 0;
+	}
+
+	return ret;
+}
+
 int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 		struct fs_info *fsi, int include_mount)
 {
@@ -234,7 +343,10 @@ int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!include_mount)
 		return 1;
 
-	ret = _fs_get_mnt(fsi, st_top.st_rdev);
+	if (!strcmp(fsi->fstype, "btrfs"))
+		ret = _btrfs_get_mnt(fsi, st_lv.st_rdev);
+	else
+		ret = _fs_get_mnt(fsi, st_top.st_rdev);
 
 	fsi->unmounted = !fsi->mounted;
 	return ret;
@@ -525,11 +637,15 @@ int fs_extend_script(struct cmd_context *cmd, struct logical_volume *lv, struct
 {
 	char lv_path[PATH_MAX];
 	char crypt_path[PATH_MAX];
+	char newsize_str[16] = { 0 };
 	const char *argv[FS_CMD_MAX_ARGS + 4];
 	char *devpath;
 	int args = 0;
 	int status;
 
+	if (dm_snprintf(newsize_str, sizeof(newsize_str), "%llu", (unsigned long long)fsi->new_size_bytes) < 0)
+		return_0;
+
 	if (dm_snprintf(lv_path, PATH_MAX, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0)
 		return_0;
 
@@ -540,6 +656,10 @@ int fs_extend_script(struct cmd_context *cmd, struct logical_volume *lv, struct
 	argv[++args] = "--lvpath";
 	argv[++args] = lv_path;
 
+	if (fsi->new_size_bytes) {
+		argv[++args] = "--newsizebytes";
+		argv[++args] = newsize_str;
+	}
 	if (fsi->mounted) {
 		argv[++args] = "--mountdir";
 		argv[++args] = fsi->mount_dir;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index b188ea28055f..193b1f4038ca 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6071,6 +6071,7 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	int equal = 0, smaller = 0, larger = 0;
 	int is_ext_fstype = 0;
 	int confirm_mount_change = 0;
+	int check_boundary = 1;
 
 	/*
 	 * Allow reducing the LV for other fs types if the fs is not using
@@ -6079,7 +6080,8 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!strcmp(fsi->fstype, "ext2") ||
 	    !strcmp(fsi->fstype, "ext3") ||
 	    !strcmp(fsi->fstype, "ext4") ||
-	    !strcmp(fsi->fstype, "xfs")) {
+	    !strcmp(fsi->fstype, "xfs") ||
+	    !strcmp(fsi->fstype, "btrfs")) {
 		log_debug("Found fs %s last_byte %llu new_size_bytes %llu",
 			  fsi->fstype,
 			  (unsigned long long)fsi->fs_last_byte,
@@ -6087,6 +6089,9 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!strncmp(fsi->fstype, "ext", 3)) {
 			is_ext_fstype = 1;
 			fs_reduce_cmd = " resize2fs";
+		} else if (!strncmp(fsi->fstype, "btrfs", 5)) {
+			/* let btrfs handle it */
+			check_boundary = 0;
 		}
 	}
 
@@ -6103,29 +6108,34 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 		if (!strcmp(fsi->fstype, "reiserfs")) {
 			log_error("File system reduce for reiserfs requires --fs resize_fsadm.");
 			return 0;
+		} else if (!strcmp(fsi->fstype, "btrfs")) {
+			log_print_unless_silent("Skipping check used device size for btrfs.");
+		} else {
+			log_error("File system device usage is not available from libblkid.");
+			return 0;
 		}
-		log_error("File system device usage is not available from libblkid.");
-		return 0;
 	}
 
-	if ((equal = (fsi->fs_last_byte == fsi->new_size_bytes)))
-		cmp_desc = "equal to";
-	else if ((smaller = (fsi->fs_last_byte < fsi->new_size_bytes)))
-		cmp_desc = "smaller than";
-	else if ((larger = (fsi->fs_last_byte > fsi->new_size_bytes)))
-		cmp_desc = "larger than";
+	if (check_boundary) {
+		if ((equal = (fsi->fs_last_byte == fsi->new_size_bytes)))
+			cmp_desc = "equal to";
+		else if ((smaller = (fsi->fs_last_byte < fsi->new_size_bytes)))
+			cmp_desc = "smaller than";
+		else if ((larger = (fsi->fs_last_byte > fsi->new_size_bytes)))
+			cmp_desc = "larger than";
 
-	log_print_unless_silent("File system size (%s) is %s the requested size (%s).",
-				display_size(cmd, fsi->fs_last_byte/512), cmp_desc,
-				display_size(cmd, fsi->new_size_bytes/512));
+		log_print_unless_silent("File system size (%s) is %s the requested size (%s).",
+					display_size(cmd, fsi->fs_last_byte/512), cmp_desc,
+					display_size(cmd, fsi->new_size_bytes/512));
 
-	/*
-	 * FS reduce is not needed, it's not using the affected space.
-	 */
-	if (smaller || equal) {
-		log_print_unless_silent("File system reduce is not needed, skipping.");
-		fsi->needs_reduce = 0;
-		return 1;
+		/*
+		 * FS reduce is not needed, it's not using the affected space.
+		 */
+		if (smaller || equal) {
+			log_print_unless_silent("File system reduce is not needed, skipping.");
+			fsi->needs_reduce = 0;
+			return 1;
+		}
 	}
 
 	/*
@@ -6134,19 +6144,23 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!strcmp(lp->fsopt, "checksize")) {
 		if (is_ext_fstype)
 			log_error("File system reduce is required (see resize2fs or --resizefs.)");
+		else if (!strcmp(fsi->fstype, "btrfs"))
+			log_error("File system reduce is required (see btrfs-progs or --resizefs.)");
 		else
 			log_error("File system reduce is required and not supported (%s).", fsi->fstype);
 		return 0;
 	}
 
 	/*
-	 * FS reduce required, ext* supports it, xfs does not.
+	 * FS reduce required, ext* and btrfs support it, xfs does not.
 	 */
 	if (is_ext_fstype) {
 		log_print_unless_silent("File system reduce is required using resize2fs.");
 	} else if (!strcmp(fsi->fstype, "reiserfs")) {
 		log_error("File system reduce for reiserfs requires --fs resize_fsadm.");
 		return 0;
+	} else if (!strcmp(fsi->fstype, "btrfs")) {
+		log_print_unless_silent("File system reduce is required using btrfs-progs.");
 	} else {
 		log_error("File system reduce is required and not supported (%s).", fsi->fstype);
 		return 0;
@@ -6169,6 +6183,11 @@ static int _fs_reduce_allow(struct cmd_context *cmd, struct logical_volume *lv,
 		fsi->needs_reduce = 1;
 	} else if (!strcmp(fsi->fstype, "swap")) {
 		fsi->needs_reduce = 1;
+	} else if (!strcmp(fsi->fstype, "btrfs")) {
+		/* btrfs requires fs to be mounted to shrink */
+		if (fsi->unmounted)
+			fsi->needs_mount = 1;
+		fsi->needs_reduce = 1;
 	} else {
 		/*
 		 * Shouldn't reach here since no other fs types get this far.
@@ -6261,7 +6280,8 @@ static int _fs_extend_allow(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!strcmp(fsi->fstype, "ext2") ||
 	    !strcmp(fsi->fstype, "ext3") ||
 	    !strcmp(fsi->fstype, "ext4") ||
-	    !strcmp(fsi->fstype, "xfs")) {
+	    !strcmp(fsi->fstype, "xfs") ||
+	    !strcmp(fsi->fstype, "btrfs")) {
 		log_debug("Found fs %s last_byte %llu",
 			  fsi->fstype, (unsigned long long)fsi->fs_last_byte);
 		if (!strncmp(fsi->fstype, "ext", 3))
@@ -6340,11 +6360,13 @@ static int _fs_extend_allow(struct cmd_context *cmd, struct logical_volume *lv,
 
 	} else if (!strcmp(fsi->fstype, "swap")) {
 		fsi->needs_extend = 1;
-	} else if (!strcmp(fsi->fstype, "xfs")) {
-		fs_extend_cmd = " xfs_growfs";
-
+	} else if (!strcmp(fsi->fstype, "xfs") || !strcmp(fsi->fstype, "btrfs")) {
+		if (!strcmp(fsi->fstype, "xfs"))
+			fs_extend_cmd = " xfs_growfs";
+		else
+			fs_extend_cmd = " btrfs filesystem resize";
 		/*
-		 * xfs must be mounted to extend.
+		 * xfs and btrfs must be mounted to extend.
 		 *
 		 * --fs resize --fsmode nochange: don't change mount condition.
 		 * if mounted: fs_extend
@@ -6377,7 +6399,6 @@ static int _fs_extend_allow(struct cmd_context *cmd, struct logical_volume *lv,
 				fsi->needs_extend = 1;
 			}
 		}
-
 	} else {
 		/* shouldn't reach here */
 		log_error("File system type %s not handled.", fsi->fstype);
diff --git a/scripts/lvresize_fs_helper.sh b/scripts/lvresize_fs_helper.sh
index 90b1a978220b..7a8c58b97741 100755
--- a/scripts/lvresize_fs_helper.sh
+++ b/scripts/lvresize_fs_helper.sh
@@ -12,6 +12,8 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
+DM_DEV_DIR="${DM_DEV_DIR:-/dev}"
+
 errorexit() {
 	echo "$1" >&2
 	exit 1
@@ -22,6 +24,34 @@ logmsg() {
 	logger "${SCRIPTNAME}: $1"
 }
 
+btrfs_devid() {
+	local devpath="$1"
+	local devid
+
+	devpath="$(readlink "$devpath")"
+
+	# It could be a multi-devices btrfs so call grep.
+	devid="$(LC_ALL=C btrfs filesystem show "$devpath" | grep "$devpath"$ )"
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
 # Set to 1 while the fs is temporarily mounted on $TMPDIR
 TMP_MOUNT_DONE=0
 # Set to 1 if the fs resize command fails
@@ -39,12 +69,22 @@ fsextend() {
 	fi
 
 	if [ "$DO_FSCK" -eq 1 ]; then
-		logmsg "e2fsck ${DEVPATH}"
-		if e2fsck -f -p "$DEVPATH"; then
-			logmsg "e2fsck done"
-		else
-			logmsg "e2fsck failed"
-			exit 1
+		if [[ "$FSTYPE" == "ext"* ]]; then
+			logmsg "e2fsck ${DEVPATH}"
+			if e2fsck -f -p "$DEVPATH"; then
+				logmsg "e2fsck done"
+			else
+				logmsg "e2fsck failed"
+				exit 1
+			fi
+		elif [[ "$FSTYPE" == "btrfs" ]]; then
+			logmsg "btrfsck ${DEVPATH}"
+			if btrfsck "$DEVPATH"; then
+				logmsg "btrfsck done"
+			else
+				logmsg "btrfsck failed"
+				exit 1
+			fi
 		fi
 	fi
 	
@@ -85,6 +125,22 @@ fsextend() {
 			logmsg "xfs_growfs failed"
 			RESIZEFS_FAILED=1
 		fi
+	elif [[ "$FSTYPE" == "btrfs" ]]; then
+		NEWSIZEBYTES=${NEWSIZEBYTES:-max}
+		BTRFS_DEVID="$(btrfs_devid "$DEVPATH")"
+		REAL_MOUNTPOINT="$MOUNTDIR"
+
+		if [ $TMP_MOUNT_DONE -eq 1 ]; then
+			REAL_MOUNTPOINT="$TMPDIR"
+		fi
+
+		logmsg "btrfs filesystem resize ${BTRFS_DEVID}:${NEWSIZEBYTES} ${REAL_MOUNTPOINT}"
+		if btrfs filesystem resize "$BTRFS_DEVID":"$NEWSIZEBYTES" "$REAL_MOUNTPOINT"; then
+			logmsg "btrfs filesystem resize done"
+		else
+			logmsg "btrfs filesystem resize failed"
+			RESIZEFS_FAILED=1
+		fi
 	fi
 
 	# If the fs was temporarily mounted, now unmount it.
@@ -131,12 +187,22 @@ fsreduce() {
 	fi
 
 	if [ "$DO_FSCK" -eq 1 ]; then
-		logmsg "e2fsck ${DEVPATH}"
-		if e2fsck -f -p "$DEVPATH"; then
-			logmsg "e2fsck done"
-		else
-			logmsg "e2fsck failed"
-			exit 1
+		if [[ "$FSTYPE" == "ext"* ]]; then
+			logmsg "e2fsck ${DEVPATH}"
+			if e2fsck -f -p "$DEVPATH"; then
+				logmsg "e2fsck done"
+			else
+				logmsg "e2fsck failed"
+				exit 1
+			fi
+		elif [[ "$FSTYPE" == "btrfs" ]]; then
+			logmsg "btrfsck ${DEVPATH}"
+			if btrfsck "$DEVPATH"; then
+				logmsg "btrfsck done"
+			else
+				logmsg "btrfsck failed"
+				exit 1
+			fi
 		fi
 	fi
 	
@@ -161,6 +227,21 @@ fsreduce() {
 			# will exit after cleanup unmount
 			RESIZEFS_FAILED=1
 		fi
+	elif [[ "$FSTYPE" == "btrfs" ]]; then
+		BTRFS_DEVID="$(btrfs_devid "$DEVPATH")"
+		REAL_MOUNTPOINT="$MOUNTDIR"
+
+		if [ $TMP_MOUNT_DONE -eq 1 ]; then
+			REAL_MOUNTPOINT="$TMPDIR"
+		fi
+
+		logmsg "btrfs filesystem resize ${BTRFS_DEVID}:${NEWSIZEBYTES} ${REAL_MOUNTPOINT}"
+		if btrfs filesystem resize "$BTRFS_DEVID":"$NEWSIZEBYTES" "$REAL_MOUNTPOINT"; then
+			logmsg "btrfs filesystem resize done"
+		else
+			logmsg "btrfs filesystem resize failed"
+			RESIZEFS_FAILED=1
+		fi
 	fi
 
 	# If the fs was temporarily mounted, now unmount it.
@@ -230,6 +311,7 @@ usage() {
 	echo "    [ --fsck ]"
 	echo "    [ --cryptresize ]"
 	echo "    [ --cryptpath path ]"
+	echo "    [ --newsizebytes num ]"
 	echo ""
 	echo "${SCRIPTNAME} --fsreduce --fstype name --lvpath path"
 	echo "    [ --newsizebytes num ]"
@@ -249,7 +331,7 @@ usage() {
 	echo "    --fsreduce"
 	echo "        Reduce the file system."
 	echo "    --fstype name"
-	echo "        The type of file system (ext*, xfs)."
+	echo "        The type of file system (ext*, xfs, btrfs.)"
 	echo "    --lvpath path"
 	echo "        The path to the LV being resized."
 	echo "    --mountdir path"
@@ -380,6 +462,7 @@ if [[ "$DO_FSEXTEND" -eq 1 || "$DO_FSREDUCE" -eq 1 ]]; then
 	case "$FSTYPE" in
 	  ext[234]) ;;
 	  "xfs")    ;;
+	  "btrfs")  ;;
 	  *) errorexit "Cannot resize --fstype \"$FSTYPE\"."
 	esac
 
@@ -447,4 +530,3 @@ elif [ "$DO_FSREDUCE" -eq 1 ]; then
 elif [ "$DO_CRYPTRESIZE" -eq 1 ]; then
 	cryptresize
 fi
-
-- 
2.48.1

