Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 465801E8333
	for <lvm-devel@lists.linux.dev>; Tue, 13 May 2025 06:14:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1747116881; cv=none; b=mIV8yi4S9YlvXSN/3qV8eY9TWhNV0Xpbsjg7WILK2Wdckt7vxru8F3BHKb93o0D/Y4ccOH0hgH2t5e7VOVwF1s+5X0gmQ7W0snFYvDnInYT+crYW/HY4b0d3OGThdtnrhl7J/E2rWsC9hqP+ndF1NC6ZgN6LiJU169wHvJadGu4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1747116881; c=relaxed/simple;
	bh=uM/lYhCO0mz2hNegfJXKjZGFsf3V1J4BpzwiOj/bC0o=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=A06BQ+99/FcDTWeJy9B993QOvncj8MdRfSJRNNRZhbBdH3T6WGY0qS22t3ea7+4mvEDmFd7G06J+EdYNQoA35lGD9eq5PB/17DImacNMmMD+QZQ2mSgQKX4A7snxE+IMMHso/l+Fx+LNqEfBJ3Zva3DDFNfEdhK6udCCPyZxcRA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com; spf=pass smtp.mailfrom=suse.com; dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b=HSoclndg; arc=none smtp.client-ip=209.85.221.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=suse.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suse.com header.i=@suse.com header.b="HSoclndg"
Received: by mail-wr1-f51.google.com with SMTP id ffacd0b85a97d-3a0b9af89f2so3069454f8f.3
        for <lvm-devel@lists.linux.dev>; Mon, 12 May 2025 23:14:38 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=suse.com; s=google; t=1747116877; x=1747721677; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=0sLptr9vvpbqhC0Labkmuy3HtoNWqAqoLJ8sNWzVEKo=;
        b=HSoclndgaKartzMiiyISNgz7pFH2xdQqe1bhh/8slFAFl5NchY0ujmifhRxDItuRSd
         OFW6nrcg6aQz9MzTd4KEo5YIeScWthBdy+D4SCExyzdyPAgKIWPUVXyX6SaGzutwhQXJ
         D+K0yAPK/hFU1h/pBp0mTg8Dj1KCZTPKVFWNQL4a6IJHzNLeie4thUDRoThzvg+4C+F9
         MWFwPSswE3BtWLc9N9I0XV7Hv0joIIxTh7D44uZGWWpW8oR30FaZbT361QiLoRhNOROT
         pGG9xd1J+rdMOF3F+Vi35SgAxhaK6wNVt4+AmXi5rw2l/OkQLHnL837g4R/UKGc2FIhC
         4pkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1747116877; x=1747721677;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=0sLptr9vvpbqhC0Labkmuy3HtoNWqAqoLJ8sNWzVEKo=;
        b=tOSluwVUDsQnAr0DVA1GN35GFrADrzCBEBLpi3lfAREOr/MYcSCFm9pDuUa1ly8Rd5
         roLJCG2/LDKysiZM5qSmvkVMDEyCbhb9tRu/zDFl2b7OAeISYGAxXQCHb4eWnRNdJ7lq
         y/uho03FlC35DrS4XRQsLctir7oDvCRP0lJQ6DH/4LmqMOGg6edX9rWVjx3Fk3gVVnvi
         k0eKTvRTHRPmRPBBNnxchJiwwht1cyCbuaI5JP5nPcuPcoDBRgXCnfnXkOS5NvTI+djI
         RXrhFCWnvBaEZKdWvR+v8GC6gbtzp7PqjpCHSmipPkgc6Igb31YYqRBk9ZVOmO8xUiK+
         Pi/w==
X-Gm-Message-State: AOJu0YyhtCtgrWIm5TUVIQLecVIJVOHownAaN0NvR8RlbRYnnpkPjqxY
	A9IstfNbHFhNhQJm/x6XChv0oeTfgxDV+QwVo0UqGgphXICPeHefSzVDtwHnytX4dHw8GxY2BY6
	hrok=
X-Gm-Gg: ASbGnctzeTzE8brwnA7A+aLvddv62PmD7waAwtwPLYGWBmYbSWUU5NDVDeTAxTZ59zC
	JGgH1pBkFjJpZPuo3shFmRt1ZINw0ZcbtVWxH/H36ayZg2rC/1t6n2iyb7MFusFkTWy3zrALwkl
	C1CZ4pLmim1WO1/LMUevQtJeqNNwwuzE9jJ6J7r25czOB9PU6XsAMdVnYMI4brWAbP3xyqWQYrc
	1ng6aFoyizu83ewl9nMDgrFAZEPmozZhtAyr5B7LB1mfW85fMO4dDRwjeMDZhG03I/l1C5AQrM/
	FQNnQ4x1U+sTYsq7uM9/GtOuOvxIAZyH9sAOk6xnvIeiyDkIHfioAy+8yWvimhdOz4hsO6E1zC7
	Nyw==
X-Google-Smtp-Source: AGHT+IG1dXgxd8zOYWwEE5i693gfo/WGu2jMm48gqB0wy79USkd1ZAnY7HExaR4c6jmheaGFhGcCtg==
X-Received: by 2002:a5d:60c5:0:b0:391:2e6a:30fe with SMTP id ffacd0b85a97d-3a1f647fed3mr11360897f8f.39.1747116877318;
        Mon, 12 May 2025 23:14:37 -0700 (PDT)
Received: from localhost.localdomain ([202.127.77.110])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-30ad4fe2248sm10948310a91.35.2025.05.12.23.14.34
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Mon, 12 May 2025 23:14:36 -0700 (PDT)
From: Su Yue <glass.su@suse.com>
To: lvm-devel@lists.linux.dev
Cc: teigland@redhat.com,
	zkabelac@redhat.com,
	heming.zhao@suse.com,
	glass.su@suse.com,
	l@damenly.org
Subject: [PATCH 0/4] lvm2: add btrfs support for lvresize
Date: Tue, 13 May 2025 14:14:23 +0800
Message-Id: <20250513061427.25843-1-glass.su@suse.com>
X-Mailer: git-send-email 2.39.5 (Apple Git-154)
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi,
  This patchset adds btrfs support for lvresize.
  I tried to split patches as small as minimal for review but 3rd is still
complicated for bisecting.
  The patchset passed shell/lvresize-xfs.sh and shell/lvresize-fs.sh on
CentOS stream, fedora 42 and archlinux to make sure that other fs resize
functionalties are not broken by the feature.

Su Yue (4):
  filesystem: get device uuid in fs_get_blkid
  filesystem: factor out get mount point logic from fs_get_info() into
    _fs_get_mnt()
  lvresize: add btrfs support
  test: addm shell/lvresize-btrfs.sh

 lib/device/dev-type.c         |  10 ++
 lib/device/filesystem.c       | 189 +++++++++++++++++++++-----
 lib/device/filesystem.h       |   2 +
 lib/metadata/lv_manip.c       |  73 ++++++----
 scripts/lvresize_fs_helper.sh | 110 +++++++++++++--
 test/shell/lvresize-btrfs.sh  | 244 ++++++++++++++++++++++++++++++++++
 6 files changed, 556 insertions(+), 72 deletions(-)
 create mode 100644 test/shell/lvresize-btrfs.sh

-- 
2.48.1

