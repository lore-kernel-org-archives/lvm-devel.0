Received: from mail-yw1-f178.google.com (mail-yw1-f178.google.com [209.85.128.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 90C103563F3
	for <lvm-devel@lists.linux.dev>; Thu, 23 Apr 2026 02:32:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776911577; cv=none; b=b4Omrtd27DSPyicNa6S05iOJa0Vi0u8H1e6NMwPoYoK+JGUo0mc9i/kwiZQ0aXXbaeranVRmezTFNLmiWGMiAwwWbX0VAButXaZe/Jl408PszupWjhAkgQEdPbZVOkKtclO14MQ7RVR22MQk+WFKPgddv1WyrfmJWbCb+fX3/68=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776911577; c=relaxed/simple;
	bh=KLQ6cGL+klmhZs0aPYXxlVpNTJ4zYdKzHzPhNQZKEis=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=N+3EffzHLZFhUVItqPSeb74H6ibN9Vx7rbWVOHHlxWMruoTaa4foq1CsrysmaOQdAOVDaKDfZavQ+Qsoks8SXdOiPuI1yRUpgz/qfQLKK8qE8kdz0QjA6bkrwFHjR0TYLovxc1spmZQWjG76W9c+L2T3Iej1Dm9T+herC8J1gOc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=I1wqzHzN; arc=none smtp.client-ip=209.85.128.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I1wqzHzN"
Received: by mail-yw1-f178.google.com with SMTP id 00721157ae682-78fc4425b6bso52807737b3.1
        for <lvm-devel@lists.linux.dev>; Wed, 22 Apr 2026 19:32:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1776911575; x=1777516375; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=kdhwshKFJN32yInIFLCT9uErJKCqQdBl/KPxJ6phge4=;
        b=I1wqzHzNQeRRXkNa5oJoSaa1zO35pwVnF+DJnvsENcSeOy0yPzIfBkD6oIaBPy+Mni
         3hYORvS5Y2UobmgQ5N4CMsmdK0G9BeFuxdFaHLOQbd0J0ZCFPbBfZaHMHII9iWDGW1W3
         yP88FVSVlvkZaoZVHxTsvygbNN/L8a9Qa458CVcVRbeaWFYylI+OFE8fPQcQpGQYCM1b
         7IujfVoIhFQdfEPy+NlmrUmf0aKxXgqcx8uzklUcJbMw7PNP72rqBK+OOyh5cSRosUJe
         VDdlA11a2Hch06f33Sq5HXteF6rddQUAQ0Z+nU85Gb7vFqdA2hE5LilKik1qLYJdv1xO
         pPYg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1776911575; x=1777516375;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=kdhwshKFJN32yInIFLCT9uErJKCqQdBl/KPxJ6phge4=;
        b=XG/mglRPe+NpWWcv4twTdxLqmXr1R9cpOHHr/f9sUcJ3D8rP08fQf5UkJ6QcR441Ll
         t/bRE8g0vKrzfOS+zlqKz5zhN8wnBSiswSA4E5+kImGK4geAmkVoAXkq0ZMlZKb8QEDM
         0oJDbuWIEpHNs6h0lchRtmPcJOW21GJwF4YOkGT5GzFzVfYqO6hEmdRUKON6fZB62Zy7
         ozdRyWuaC4Q2DsLjWzC7X2mQz0bv1smEkguB2jRVJClXdyv/QPn4LFMN0K57Le33q3z9
         to/jy6dfD9fXwXy3HcEjLau0GBCoBbElOeywViR0fMg+UfDveJYUPuPmurNjjbhBZ6bD
         QweQ==
X-Gm-Message-State: AOJu0YxGEiSK9l8yolvOTJtltFzsPiq16ElU/47F0r2foRHSIeTJvKDl
	9NnH/g4CBJX1nDh/zAQytFgadG4G5xWbfcoQFSuJDfm0nFEky5tSSdF8dIKtVLWDH0g=
X-Gm-Gg: AeBDieuxpQikmH6h9jqPFs+6retDlcuXLq7tZSa5RmIsdV0n48GJbFipex5xS4TrLu4
	ZW8UQhxgPyA9Aj4i4LjKGeGXrwUzZ/ofLSsjExzEAxtbGaE/emGT09o0lzQQnz0n9+V64f6X6Z8
	aqoB5BoPM0wzk1QClpyiHd4zePeRotRg53ixm8mRNfN3pXFZ/juHKUeTP4JqI8p2E8PPM99QHQ8
	Nc7VwTc5A+gZhTr0mlC1LqpXN0/wEUBbgx2N12UBuAXorDZk8Yl3Wujx4OkyGApkAZsV2sLj1UP
	uY5GA/Zi/U1GSZf6rWKGQhHedbzTrwCyacVA/OoA4ptJslW5WRO0065FVDqB/GOE53vgabEMyGf
	GgvYF1sLGZZNBEcUY9YqCHcyBD8JPWpoHshf0cMAkbhPpQvjTBevV3rcqt4KYm96A/AXLOMfDSY
	EltPCyHAy8g5XET7rCGGVw1qIyUX5KaT4qBBBqNetb8J6lyQoXV9TQk6SeRnI=
X-Received: by 2002:a05:690c:e04e:b0:7b8:8d3c:17b7 with SMTP id 00721157ae682-7b9ecfd11cemr202473397b3.42.1776911575085;
        Wed, 22 Apr 2026 19:32:55 -0700 (PDT)
Received: from localhost (67.216.205.192.16clouds.com. [67.216.205.192])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-7b9ee89abd7sm74782217b3.1.2026.04.22.19.32.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 22 Apr 2026 19:32:53 -0700 (PDT)
From: lichun <lichunplus@gmail.com>
To: lvm-devel@lists.linux.dev
Cc: zkabelac@redhat.com,
	teigland@redhat.com,
	lichun <lichunplus@gmail.com>
Subject: [PATCH] man: fix typo in lvmcache.7
Date: Thu, 23 Apr 2026 10:32:50 +0800
Message-ID: <20260423023250.11324-1-lichunplus@gmail.com>
X-Mailer: git-send-email 2.45.0
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Correct /dev/slow_hhd to /dev/slow_hdd"

Signed-off-by: lichun <lichunplus@gmail.com>
---
 man/lvmcache.7_main | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/man/lvmcache.7_main b/man/lvmcache.7_main
index 776848490..7d38fb3c4 100644
--- a/man/lvmcache.7_main
+++ b/man/lvmcache.7_main
@@ -51,7 +51,7 @@ The main LV may already exist, and is located on larger, slower devices.
 A main LV would be created with a command like:
 .P
 .EX
-# lvcreate -n main -L Size vg /dev/slow_hhd
+# lvcreate -n main -L Size vg /dev/slow_hdd
 .EE
 .
 .SS 2. Identify fast LV to use as the cache
@@ -65,7 +65,7 @@ special LV will be used to hold the cache:
 # lvs -a
 \  LV   Attr       Type   Devices
 \  fast -wi------- linear /dev/fast_ssd
-\  main -wi------- linear /dev/slow_hhd
+\  main -wi------- linear /dev/slow_hdd
 .EE
 .
 .SS 3. Start caching the main LV
@@ -114,7 +114,7 @@ using dm-cache (with cachepool):
 \  [fast_cpool]                    cache-pool fast_pool_cdata(0)
 \  [fast_cpool_cdata]              linear     /dev/fast_ssd
 \  [fast_cpool_cmeta]              linear     /dev/fast_ssd
-\  [main_corig]                    linear     /dev/slow_hhd
+\  [main_corig]                    linear     /dev/slow_hdd
 .EE
 .P
 using dm-cache (with cachevol):
@@ -124,7 +124,7 @@ using dm-cache (with cachevol):
 \  LV           Pool        Type   Devices
 \  main         [fast_cvol] cache  main_corig(0)
 \  [fast_cvol]              linear /dev/fast_ssd
-\  [main_corig]             linear /dev/slow_hhd
+\  [main_corig]             linear /dev/slow_hdd
 .EE
 .P
 using dm-writecache (with cachevol):
@@ -134,7 +134,7 @@ using dm-writecache (with cachevol):
 \  LV            Pool        Type       Devices
 \  main          [fast_cvol] writecache main_wcorig(0)
 \  [fast_cvol]               linear     /dev/fast_ssd
-\  [main_wcorig]             linear     /dev/slow_hhd
+\  [main_wcorig]             linear     /dev/slow_hdd
 .EE
 .
 .SS 5. Use the main LV
@@ -151,7 +151,7 @@ use the --uncache:
 .P
 # lvs -a
 \  LV   VG Attr       Type   Devices
-\  main vg -wi------- linear /dev/slow_hhd
+\  main vg -wi------- linear /dev/slow_hdd
 .EE
 .P
 To stop caching the main LV, separate the fast LV from the main LV.  This
@@ -164,7 +164,7 @@ attached.
 # lvs -a
 \  LV   VG Attr       Type   Devices
 \  fast vg -wi------- linear /dev/fast_ssd
-\  main vg -wi------- linear /dev/slow_hhd
+\  main vg -wi------- linear /dev/slow_hdd
 .EE
 .
 .SS 7. Create a new LV with caching
@@ -174,10 +174,10 @@ using the following command:
 .P
 .EX
 # lvcreate --type cache|writecache -n Name -L Size
-	--cachedevice /dev/fast_ssd vg /dev/slow_hhd
+	--cachedevice /dev/fast_ssd vg /dev/slow_hdd
 .EE
 .P
-The main LV is created with the specified Name and Size from the slow_hhd.
+The main LV is created with the specified Name and Size from the slow_hdd.
 A hidden fast LV is created on the fast_ssd and is then attached to the
 new main LV.  If the fast_ssd is unused, the entire disk will be used as
 the cache unless the --cachesize option is used to specify a size for the
-- 
2.45.0

