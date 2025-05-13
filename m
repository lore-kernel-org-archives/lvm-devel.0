Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 90BBC1E8333
	for <lvm-devel@lists.linux.dev>; Tue, 13 May 2025 06:14:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747116885; cv=none; b=ItOBdSabEwd/2+9tWhdEDXL648vEef5XCk4GUrB+UbKhruKkLlCsFoRz0FgflLBn8X6orWnE8fSFCHeVN5/rw/MgB/nIlmkMas8W4IjmszS8FehqYvurAc/05oqADLzP1wEMlAVu2wc0JGvWlLh1fq25Xspvmv3QpocUhpOGiEA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747116885; c=relaxed/simple;
	bh=aPieDYyfALfKZfC5449R2q5mfJBRHaZhD/35hodC2nw=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=myMX7k/wSxwt5x/Si9Cc5Cj+yZN2JU0XyLn+fxFKT02aeSGywkuIoKjIxXuU4D1TF+n5nSfuuypoYlGsDhFPa0oZOugb4WkGCJhOlE0QGyknrrcBBdhO1PUuuoPCq30du7MCNx7yL8QN0r6hf/W1scgXmzEfdRaqjV6kr1nLRCU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=c4uR1Z1l; arc=none smtp.client-ip=209.85.221.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="c4uR1Z1l"
Received: by mail-wr1-f50.google.com with SMTP id ffacd0b85a97d-3a0adcc3e54so3128906f8f.1
        for <lvm-devel@lists.linux.dev>; Mon, 12 May 2025 23:14:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1747116880; x=1747721680; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=sPWF5DGBQEa046JWlwu55trTDN6VooTbF1LB2gyy88U=;
        b=c4uR1Z1lCMRfki6vIJtviMy4d6SGmCPhDsqlKBeL0Wdzi5W3hDTBfcFbikk21Yhu8i
         XZvWuCfjawP6HF9sltDUHLJZMmbQFrBcklozQowNcLk4wjIUlSjaLxCYv4U0sLJ/2280
         vYJelvsgl1VzoZHn/uvY0Zu+tS7yRPcGe2fD6mROLVQNRG4ifw7wMgw6rTGsrojvSW6h
         GJzUpnP/VDWeXHEQL5tS9pryejtVFKZKe7QecaygZiB6uXz0Rqan44f4wzDtif9nw170
         opU/9LwUi46gYoYSVltqEgyn9Gf4cvZaBG4gkRQS+/ey0y7krSd+wdEh8REpzR9aB+05
         AF0A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747116880; x=1747721680;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=sPWF5DGBQEa046JWlwu55trTDN6VooTbF1LB2gyy88U=;
        b=pBcIOTS1BqwQQ1fEseMysHHzuC9U1PR6/jDwfn0kulf9WpfA0lePEIh0A3aDK/kswC
         ZXtUceTR0rSz6yq+z72U5aZuDozN58CR1qb13YagTnIVSfjFZb4XOx1/XBXDQo22s76L
         U1cpy7JPv8vRk5y13HBLxhrbiXe5vFARCap/pW+mmRCCFqhEw2kBzPnvDlSfODwDkyc2
         T9ABtaakZXwSA+jVXIkvmhYCIUaEXlLjfni1n5fb0YMbAt0KosB2XKtP4DBAHXb+lFce
         5gD4/HNinC/t0hgCGpGDMA4bmBpPMdcN+hZrUGnXj6D0ZMbqVFq6176o7aJvNRjZdl4/
         Dd/w==
X-Gm-Message-State: AOJu0YzaV5S96L4OR8ry5gZjQ7qMrJTW4srHPGR/Gf/5SRUDnb5J2/M1
	+OPfTg8HMrXD8Lzn8JdvBlKdvz/1MrQbvrKaBdXhuuOvt+gwYPIIfPWKLwUEoBdnGDvdBMwLWEm
	o1eY=
X-Gm-Gg: ASbGncu192gREm7Ap1yd5Sn1E+7TKEej3gRMXt37iBt77D8UvKXcYp8XwyvL6s6sfMJ
	Y1ncD2dmrh7vway5/4xOzlq1gfPcJls6CEawRH7eRt9K8Ob1iHi0psuHySsdH0ld6xkGJMAWiAq
	QMDBF1swFcgTzRwdDE/8+vYIog6y453peWlOjuvBHo0p1g0KmiN4ZOQOjlKu/cVEMB4aM3oiuKo
	c6q3vo7LN8WSti5qRdZs8i755j4ytr0tflvERa5JKomdw7bdXTmJkOdyHziLADTwqrZkPjTKg0G
	R21ZYzXrWIuWbVNufSbo6PxZ6FxwRMNuDmBKBMp35baR8rUPbR9unv/ReMC8LMwcQx2K8YwUBMl
	zmw==
X-Google-Smtp-Source: AGHT+IFIIY3odIngUMtYAKg41gGA57DLs4VQxjU4AsH+1qPAcaEbaocdnmTwC/K71Cy0by8JAAKlUA==
X-Received: by 2002:a05:6000:430e:b0:3a0:b63f:c88c with SMTP id ffacd0b85a97d-3a1f64f6812mr11511258f8f.58.1747116880227;
        Mon, 12 May 2025 23:14:40 -0700 (PDT)
Received: from localhost.localdomain ([202.127.77.110])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-30ad4fe2248sm10948310a91.35.2025.05.12.23.14.37
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Mon, 12 May 2025 23:14:39 -0700 (PDT)
From: Su Yue <glass.su@suse.com>
To: lvm-devel@lists.linux.dev
Cc: teigland@redhat.com,
	zkabelac@redhat.com,
	heming.zhao@suse.com,
	glass.su@suse.com,
	l@damenly.org
Subject: [PATCH 1/4] filesystem: get device uuid in fs_get_blkid
Date: Tue, 13 May 2025 14:14:24 +0800
Message-Id: <20250513061427.25843-2-glass.su@suse.com>
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

Add new field fs_info::uuid to record device uuid when calling
fs_get_blkid() for further use.

No functional change.

Signed-off-by: Su Yue <glass.su@suse.com>
---
 lib/device/dev-type.c   | 3 +++
 lib/device/filesystem.h | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index c4a366d0089d..08848ca0f216 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -999,6 +999,9 @@ int fs_get_blkid(const char *pathname, struct fs_info *fsi)
 	if (!blkid_probe_lookup_value(probe, "FSSIZE", &str, &len) && len)
 		fssize = strtoull(str, NULL, 0);
 
+	if (!blkid_probe_lookup_value(probe, "UUID", &str, &len) && len)
+		memcpy(fsi->uuid, str, UUID_LEN);
+
 	blkid_free_probe(probe);
 
 	if (fslastblock && fsblocksize)
diff --git a/lib/device/filesystem.h b/lib/device/filesystem.h
index 024c9974a19d..4ba6f0db99b7 100644
--- a/lib/device/filesystem.h
+++ b/lib/device/filesystem.h
@@ -19,10 +19,12 @@
 #include "lib/device/device.h"
 
 #define FSTYPE_MAX 16
+#define UUID_LEN 37
 
 struct fs_info {
 	char fstype[FSTYPE_MAX];
 	char mount_dir[PATH_MAX];
+	char uuid[UUID_LEN];
 	char fs_dev_path[PATH_MAX]; /* usually lv dev, can be crypt dev */
 	unsigned int fs_block_size_bytes; /* 512 or 4k */
 	uint64_t fs_last_byte; /* last byte on the device used by the fs */
-- 
2.48.1

