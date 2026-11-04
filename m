Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793775482;
	b=l4GtTKT5b6dcQ0ZIj+rWJ9fjdEvq/C2LqHzh+u4P1tPsceyS2pBijIP/1NtZUPpijw/2
	 vKZQrGum7/UaSBpUULkuQJZd7Zlq43F2NjMZvJ3GlrGW09T/RaANnFy1ZU79mnInTg6fE
	 b2gunxFt6NVOvM1QSnnPa3pWrFc5kZmai0PKvZbNzZYdXfL6DyZxTvdyjw4vlrWycym0h
	 AS8+kPOhv90BDHaZU9GdITASsJdLEdHE6K9IjKchEYltPRiZHScogIOPfMiLSa6o/I5sw
	 4Nek3mZqW8u2LUPo+OvcU5QlTCgh0G+utJZaypyn4MzEM/g1h5MIhX8v62JYumLkFeg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793775482;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-Id:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=QtFP5vh4xZkpM+9PhBXMtxeku4TE0wlu8GWyI14iVQI=;
	b=ZkOnm2I5omPu6vDEVUvGbi4sT1Y3IppR1bi1gN45EbGNDLWHoOLAmXKNWn7cAoWtQaTZ
	 pvaSHjO7o+6aYA9XVpmVOZojjh4AALZZbXGq9uq7s0AmOyDJzOwjtMk6aTc6MrTfuyZUd
	 Ipc9SpBaBLk0J7nRIuDwGDLuvosE0v0KIliaDu7RixrwvMJJHRtQ6kDnQ8gluKzhBA7A0
	 Ml2O61lEk1jKx3r2Bq3KfngeyyrkbQtaJZL3AS4N5Oo4REzfvA/rEQ2t2vywlvUPGO6i8
	 HmCPRVvtguaEgSYmrVgd9pxJycVSGTMvG099IUQwGYHJIRP0253pFZo311M10/R7jog==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=E7NhtqnF;
	arc=none smtp.remote-ip=209.85.128.49
Received: from mail-wm1-f49.google.com (mail-wm1-f49.google.com [209.85.128.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 818F5606A326
	for <lvm-devel@lists.linux.dev>; Wed,  4 Nov 2026 06:58:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 818F5606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=E7NhtqnF
Received: by mail-wm1-f49.google.com with SMTP id 5b1f17b1804b1-4af520023fdso1404805e9.1
        for <lvm-devel@lists.linux.dev>; Tue, 03 Nov 2026 22:58:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793775481; x=1794380281; darn=lists.linux.dev;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=QtFP5vh4xZkpM+9PhBXMtxeku4TE0wlu8GWyI14iVQI=;
        b=E7NhtqnFxzywJud6DhMC1fu/gcy9ItKnlPkJ2TfHdNC3Ou9zvcbd5gAjGBr4dDg/1I
         0fML0eLdo8MSfUtkTFwfWeFeIGGLzAbG/dZtZNa+J4cCBMuM9+my7UUTrgpeOA0zyV5/
         wbkUfuBZ7V8bhwHY331JmrSwdAX53GBNX79BAWNVsH8BKWORaJ6Hilh8qbju4Qid8+LG
         GCSULeEUDg84iWmTLK3aI8pfFL190WGneEVN0U3EUPOZJ6RwvpFqatQVtjMum+ffV9qo
         HX+tWjdGHKBKcZxXBGiCBvLJDntX20HsAa0GkofpLLg0QdOJ+D7lpLfd6oSauazlWcrH
         xxpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793775481; x=1794380281;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=QtFP5vh4xZkpM+9PhBXMtxeku4TE0wlu8GWyI14iVQI=;
        b=WN4MZ6rPs8ym/v4Jo/XOfvoo4r8h7O5EpubXh5Zgp5z8dI8q8iKeisv8Y5bnqtw4ap
         qtUDPcb8VuP3DjgJcZ/+IC16Lirr/zT3hC3LCmJ2nTugD3BJ3AAo+8zr9D0xMspi6l8C
         JW4EtKLEtE9/OfE7NJNmRREPDCw7zO/5zEZ7jNnF7Nwsu0YZQXtHGtoQ7HUyRxoqJb+0
         p5omtr11c5breFQye6zIeQY1Hxo7qE/Cmdngg4sC8jpYaZrlGCPpdh0TFuL3yTJUdoXP
         omLdS1QSP2U7WRSbZs1EOI2PZB6Dh6+UGW1RFAXFvFNLbWw6c/z50kcuwFrqFHsr2F5V
         3IZQ==
X-Gm-Message-State: APuU4Z/hgn+iz2Tr747xNTG5h2h9CXoG7QtTBKM7YQ+T5gjcI+0UcahZ
	6soYYFT5neZFUsLVkA/NawQ/kOcLDHG9eW7siBPDPHIdUy7GrfTqDbyq5QQX8Q==
X-Gm-Gg: AYBFou30mjkeCU6AISnouq+lcllB8wDAyZGsdgErJNu/0FVpfPHHGT/ZfYmBRGCjIbQ
	FLgXdEDyqMFDFxqOsvrTz2Gi58UnM41w5XFBgiYvWwM4WvMmH5kKA1Z7SyOcJRj5R1gF7/aHyrf
	MLqMKg5nkhaaqHvGK/yssWrqswsX34300CnuY5LEwylaxb2Mj3NOv5y6/ZhD1zNVg2e2L3Hs6MA
	Ms6LOFzeOcr160W43riC8qCmIVwQUA/eGzFMdLgmOzAmbuzjT6jyUXRycpEtY60VPF/zJTd/oX+
	eXcdc+VMzXk/3FmqsZCUR1kVU9Ldporknx4F20cpNDobbDsy4v9TWEQzWCCgkgErH2nxDcCpJML
	A/LGV40WAWC0kF+8Hft9bUvvK4rJg5Y9vosc3ZDPTRI5jfuu6f2N2kvRN9aVwt0j+Iq+DN/Cfzl
	6JdrNTfLb/knuXX8QHwS/wOApY/HkVIYQl9fTnPChb6sbaYl4BLchRp4mpIyfHI7QZGSHRzfGfK
	02K3QDaAHX3rMf3GiiwqgkiBC+N7OIUSupeZ96LarT929lFjJwZVONv4mp4ZfbbOqjMwLDMO2Q2
	VWPEzRBUd4O2vz9RqPq+jEV/DvCY/T4UFybqynAoQf+77TpEQkc=
X-Received: by 2002:a05:600c:a5a5:b0:4a1:e774:370d with SMTP id 5b1f17b1804b1-4ac1765d60fmr221568415e9.1.1793775480645;
        Tue, 03 Nov 2026 22:58:00 -0800 (PST)
Received: from L-P-ITAIH2-L-RF.rf.local ([193.169.70.108])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4b40ff10f88sm28140465e9.0.2026.11.03.22.57.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 03 Nov 2026 22:57:59 -0800 (PST)
From: Itai Handler <itai.handler@gmail.com>
To: lvm-devel@lists.linux.dev
Cc: David Teigland <teigland@redhat.com>,
	Zdenek Kabelac <zkabelac@redhat.com>
Subject: [PATCH] test: skip metadata-write-rounding with pages larger than 4KiB
Date: Wed,  4 Nov 2026 08:57:29 +0200
Message-Id: <20261104065729.1305748-1-itai.handler@gmail.com>
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

On kernels configured with 64KiB pages, pvcreate in the test fails:

  Metadata area size too small: 66560 bytes. It must be at least 524288 bytes.

The metadata area starts at the page size and is at least 8 pages long,
so it can end one logical block after 64KiB, as the test needs, only
with 4KiB pages.  Skip the test with larger pages.

Fixes: 669e2f2b6ccf ("label: don't round writes past the logical block size")
Assisted-by: LLM
---
The layout cannot simply follow the page size: the first PE has to
start within the first 128KiB of the PV, which lvm reads before asking
for confirmation, and with 16KiB or larger pages the metadata area alone
extends past that.

Tested with 4KiB pages on x86_64, where the test passes as before, and
with 64KiB pages on arm64, where it is now skipped.

v2 of "blkio: fix writes when the logical block size is not 512 or
4096", which I am sending next, extends the same test and applies on
top of this patch.

 test/shell/metadata-write-rounding.sh | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/test/shell/metadata-write-rounding.sh b/test/shell/metadata-write-rounding.sh
index 7bc2da2eb..ac33a7960 100644
--- a/test/shell/metadata-write-rounding.sh
+++ b/test/shell/metadata-write-rounding.sh
@@ -20,6 +20,11 @@
 
 . lib/inittest --skip-with-lvmpolld --skip-with-lvmlockd
 
+# The metadata area starts at the page size and is at least 8 pages
+# long, so it can end one logical block after 64KiB, as below, only with
+# 4KiB pages.
+test "$(getconf PAGESIZE)" -le 4096 || skip "page size larger than 4KiB"
+
 mkfifo fifo
 
 for bs in 1024 2048 ; do

base-commit: 7ea850a1419522cc0c8096d718551015465322d2
-- 
2.34.1

