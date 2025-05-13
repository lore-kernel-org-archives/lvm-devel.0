Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com [209.85.128.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC02E1E9B37
	for <lvm-devel@lists.linux.dev>; Tue, 13 May 2025 06:14:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747116888; cv=none; b=hhQx9fPka4hFti7g8m2ejARKaKQ/lAvQlkQXkkImczjxBzW7J62aHd9CLyy9em7ror7pozy1ZsX4hxnjr/vtXsgZzYS1b92mwzDT1OUrMfwYlODYrtTLkYMUicpuJ7tVJjFmEY36U2W3Hjhm59TYpbJjCIXhrbkBqtagcr5HXR0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747116888; c=relaxed/simple;
	bh=stbZcl1yRYWHv+DsXE2+7E6gCFxS/xx8g7F2ZLzcpj8=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=aNfHtEMbjQ8mWlZNCZMWIkflu5bpE9BBP6uALegvamEOxN9bWkeubxVeJREBcED/1rN5LKFHjTCYL2GP6PXznkRXFQSfbYO6qXtoaTTwRdK+YyjkaLqZjLYewhl4yt1vhXrRUGJNKpfpLJOiDVr7ZZ2Eo446lqkaD7WUePRlBTs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=Hqc08bc+; arc=none smtp.client-ip=209.85.128.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="Hqc08bc+"
Received: by mail-wm1-f48.google.com with SMTP id 5b1f17b1804b1-442ed8a275fso632045e9.2
        for <lvm-devel@lists.linux.dev>; Mon, 12 May 2025 23:14:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1747116883; x=1747721683; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=k71GexrjZrl8eXy7JJKKVkN/38t9ftDFa6Orj0aM3kE=;
        b=Hqc08bc+o18p103xngiIFy3TOn8fIQvsjzzMbzEkgzHNoAw1jYIJdTC9ZtJt6ppc4D
         ZoHZ+py6YGqPYaVEEIvPNNEVDNOPhyB9WBDRZ3i2nus1WyC6sl8sBJHeGVJIBCNChBVX
         2KT9pszV5G6pJzKR7OH8MaOGvo9DtcwG5prktnW3l9u86dRUqg6zNXz1O7+iwIVpZtfu
         g+NA+LzUyB3RpZFTYdvwd5v+FpgeTOo9IcQ9FdEgbS480DjMKQ0AdQMzsA4lRdM+1ckd
         hkUDVivqI59njK7csrdX3fNpMEf/j8Gxsc630P+CqooY7guQshZb0hUI5DGH9gdyfmZc
         m1Tw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747116883; x=1747721683;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=k71GexrjZrl8eXy7JJKKVkN/38t9ftDFa6Orj0aM3kE=;
        b=tpjickK7j7R8xc1MBov9y5Bk2qMOn4zs7Mbh2/jSGNynXCvJ+DquudjP7Lb1j32nTl
         XUfy4bss6D7/VvQdk7JUlgBCIC84HAf9yF4FDaVv+u7F8ZmHOlqDrhikKPFOGEl/DUm0
         1R4k+GxJbC6i7XpKX9JsDGo3k9E647UYNj4de9+f+PxRPaSNvpnBxCaCs1yxSkXGKL2P
         hczv2k7KLrkOy7TeFAa56NM7VdMrqVt3R2JeW7O6kX0FXNDheJDZCC7hGUKLL2wjBrsJ
         mE0paTGkRUM1t1f7N1rKwOQTA/sc226aiqEPRbBkE6Pmnt+2Knnhf5O1HRuTN7DkfZM6
         rAPQ==
X-Gm-Message-State: AOJu0YwsO5P2lxdEQevNx/xdJVPyHc6ZGwOLbTm4IadSA2djeeSemf88
	Yt9J+jDF2KEfduQSuXjvFO47+mjKSBaEpTtDDe3YOLPMKFAygmeJK1NyJJHINTAuYYPafwugbMq
	d4Ws=
X-Gm-Gg: ASbGncvFkjQBfbcrcVWOVY0fH1sM4r4fpxhUTzff7gaL1Of6V3+zIHpa6br4jwap+dx
	72jicov8D+9bJUQi68vh+dvtGXaPUmTuINwlhTS4zbinZ+BBN0uAQgYYC1bgeY4pc3AWjwJmPjW
	oUg8f3fYjHw08Jgrd9XyD1orLs/Pw01zbB95erqpkGwg2pTU9cv5ciGOK2QFG1KT5BICOnhtsiC
	LjWU7EBsUWQbiTqHsU10K39Zw2FbJnw+0Wq8uOVD5NsUIqAd9tvBsFJzumKMeR9P3yJCkkeU7j1
	pr3UX8u2Cl+fSGg7M26dkvtS7ijqSAZhSqjlbf99z+D7nEEVQrA8nFOS7hkTFt1taAgRi5QkHHF
	dOw==
X-Google-Smtp-Source: AGHT+IGsBdm+PZSGzEu4DWdF0VNUM99x4Un2D5xG6BOH18oCxV4yr4pFAk1j1MaLMpm89L7X9MiSOA==
X-Received: by 2002:a05:6000:40cb:b0:3a1:fcd9:f300 with SMTP id ffacd0b85a97d-3a1fcd9ff06mr9073022f8f.39.1747116883184;
        Mon, 12 May 2025 23:14:43 -0700 (PDT)
Received: from localhost.localdomain ([202.127.77.110])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-30ad4fe2248sm10948310a91.35.2025.05.12.23.14.40
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Mon, 12 May 2025 23:14:42 -0700 (PDT)
From: Su Yue <glass.su@suse.com>
To: lvm-devel@lists.linux.dev
Cc: teigland@redhat.com,
	zkabelac@redhat.com,
	heming.zhao@suse.com,
	glass.su@suse.com,
	l@damenly.org
Subject: [PATCH 2/4] filesystem: factor out get mount point logic from fs_get_info() into _fs_get_mnt()
Date: Tue, 13 May 2025 14:14:25 +0800
Message-Id: <20250513061427.25843-3-glass.su@suse.com>
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

The new _fs_get_mnt() is used to get mount point info for fses.
No functional change.

Signed-off-by: Su Yue <glass.su@suse.com>
---
 lib/device/filesystem.c | 69 ++++++++++++++++++++++-------------------
 1 file changed, 37 insertions(+), 32 deletions(-)

diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index 49771bddf326..9c865b25fb57 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -108,6 +108,42 @@ int lv_crypt_is_active(struct cmd_context *cmd, char *lv_path)
 	return _get_crypt_path(st_lv.st_rdev, lv_path, crypt_path);
 }
 
+static int _fs_get_mnt(struct fs_info *fsi, dev_t devt)
+{
+	struct stat stme;
+	FILE *fme = NULL;
+	struct mntent *me;
+
+	/*
+	 * Note: used swap devices are not considered as mount points,
+	 * hence they're not listed in /etc/mtab, we'd need to read the
+	 * /proc/swaps instead. We don't need it at this moment though,
+	 * but if we do once, read the /proc/swaps here if fsi->fstype == "swap".
+	 */
+	if (!(fme = setmntent("/etc/mtab", "r")))
+		return_0;
+
+	while ((me = getmntent(fme))) {
+		if (strcmp(me->mnt_type, fsi->fstype))
+			continue;
+		if (me->mnt_dir[0] != '/')
+			continue;
+		if (me->mnt_fsname[0] != '/')
+			continue;
+		if (stat(me->mnt_dir, &stme) < 0)
+			continue;
+		if (stme.st_dev != devt)
+			continue;
+
+		log_debug("fs_get_info %s is mounted \"%s\"", fsi->fs_dev_path, me->mnt_dir);
+		fsi->mounted = 1;
+		strncpy(fsi->mount_dir, me->mnt_dir, PATH_MAX-1);
+	}
+	endmntent(fme);
+
+	return 1;
+}
+
 int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 		struct fs_info *fsi, int include_mount)
 {
@@ -116,10 +152,7 @@ int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 	struct stat st_lv;
 	struct stat st_crypt;
 	struct stat st_top;
-	struct stat stme;
 	struct fs_info info;
-	FILE *fme = NULL;
-	struct mntent *me;
 	int fd;
 	int ret;
 
@@ -201,35 +234,7 @@ int fs_get_info(struct cmd_context *cmd, struct logical_volume *lv,
 	if (!include_mount)
 		return 1;
 
-	/*
-	 * Note: used swap devices are not considered as mount points,
-	 * hence they're not listed in /etc/mtab, we'd need to read the
-	 * /proc/swaps instead. We don't need it at this moment though,
-	 * but if we do once, read the /proc/swaps here if fsi->fstype == "swap".
-	 */
-
-	if (!(fme = setmntent("/etc/mtab", "r")))
-		return_0;
-
-	ret = 1;
-
-	while ((me = getmntent(fme))) {
-		if (strcmp(me->mnt_type, fsi->fstype))
-			continue;
-		if (me->mnt_dir[0] != '/')
-			continue;
-		if (me->mnt_fsname[0] != '/')
-			continue;
-		if (stat(me->mnt_dir, &stme) < 0)
-			continue;
-		if (stme.st_dev != st_top.st_rdev)
-			continue;
-
-		log_debug("fs_get_info %s is mounted \"%s\"", fsi->fs_dev_path, me->mnt_dir);
-		fsi->mounted = 1;
-		strncpy(fsi->mount_dir, me->mnt_dir, PATH_MAX-1);
-	}
-	endmntent(fme);
+	ret = _fs_get_mnt(fsi, st_top.st_rdev);
 
 	fsi->unmounted = !fsi->mounted;
 	return ret;
-- 
2.48.1

