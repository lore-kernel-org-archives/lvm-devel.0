Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=115.124.30.100
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795070127;
	b=TdhYCMIbddn7hPdyRIqTEKR44dtC91wFGlQJyXiGUJmll+gzp6jwxuTwM6lPD1mzcThQ
	 EM12Ng2GCJ6HKAzFAkSMptU9O9E1JxvEYem3gDzoCuFofG/2NIjb047vVqUIheqRb891j
	 Gxe8UBQq547vKjJ7ofrVitj2ARC+SM/VTraGOZ3I+Tknpeupndu7gLJDgfRy8TijQGiz4
	 einCCnev7BCSjpfhbJnqTe5N+th1hi8nZVX5sDz3DgDb/IuzBV1Hnu+3r+mwIXtV8q953
	 mEma1K8GgVYNGjui0m/XbXIpUXeEKk8tT4OmwVhwXkqBANHkPvd1rnzZn9jrXE2l73A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795070127;
	h=DMARC-Filter:DKIM-Signature:X-Alimail-AntiSpam:Received:From:To:Cc:
	 Subject:Date:Message-Id:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=oZH542GC6h+drpFKpvUNpDb8n9zIvFYI2mOe2tx1CA0=;
	b=tz62ukh0eijykG4I12O8YyW6sLcGPggJbCiM7wnu/6IgkRT1s455Z56arliXQGzAOkeW
	 7RC2iZ20y4cHMdOpIuHmfv0Ux9EQv3YhBb2W/t2SIgGRFafW3Vc3xkkU/Jbfys4OiW2SF
	 hKWn/hAsmjosz4Y6pvHiwepmoonZ7vOdezOl6Ov1Fz2MJcGc6K7IfufDRtAI9XSdWGxJ0
	 HKtnsKvkRRLfDEIldeJjT9ncVJ80gQqtKQW9P60lqiL5LN8NQnDZUI2+W6lHLdjFHUYBT
	 zjVJ7gNSlQqKp4oXq4jnYMBknBEMarOM8Ymj+qGDaK6a/ctIQs69Yg8Hpdl2T8nUMxQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=linux.alibaba.com;
	spf=pass smtp.mailfrom=linux.alibaba.com;
	dkim=pass header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=C23qzIMK;
	arc=none smtp.remote-ip=115.124.30.100
Received: from out30-100.freemail.mail.aliyun.com (out30-100.freemail.mail.aliyun.com [115.124.30.100])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 55443606A320
	for <lvm-devel@lists.linux.dev>; Thu, 19 Nov 2026 06:35:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 55443606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linux.alibaba.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=linux.alibaba.com header.i=@linux.alibaba.com header.a=rsa-sha256 header.s=default header.b=C23qzIMK
DKIM-Signature:v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=linux.alibaba.com; s=default;
	t=1795070121; h=From:To:Subject:Date:Message-Id:MIME-Version;
	bh=oZH542GC6h+drpFKpvUNpDb8n9zIvFYI2mOe2tx1CA0=;
	b=C23qzIMKmzS8pgSfKSQkgj4owUtZYVo//5KAoZHlP/qcfsK0rd1lewAGMt3gq1coAWF0qCTlFVYZwnCLdhWjiKtczwLy3UpRuSPiRvfqjmmzDVezDPYk3talS19BJFMu6ha0Y+yrWEvztsfIEMoH9uiC/K2jycL+SIzxvYXw650=
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R211e4;CH=green;DM=||false|;DS=||;FP=0|-1|-1|-1|0|-1|-1|-1;HT=maildocker-contentspam033037026112;MF=yunye.zhao@linux.alibaba.com;NM=1;PH=DS;RN=3;SR=0;TI=SMTPD_---0XF2fW4n_1795070119;
Received: from j66c13357.sqa.eu95.tbsite.net(mailfrom:yunye.zhao@linux.alibaba.com fp:SMTPD_---0XF2fW4n_1795070119 cluster:ay36)
          by smtp.aliyun-inc.com;
          Thu, 19 Nov 2026 14:35:20 +0800
From: Yunye Zhao <yunye.zhao@linux.alibaba.com>
To: lvm-devel@lists.linux.dev
Cc: joseph.qi@linux.alibaba.com,
	YunyeZhao <yunye.zhao@linux.alibaba.com>
Subject: [PATCH] test: dbus: make stripe size page-size aware
Date: Thu, 19 Nov 2026 14:35:19 +0800
Message-Id: <20261119063519.63461-1-yunye.zhao@linux.alibaba.com>
X-Mailer: git-send-email 2.19.1.6.gb485710b
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

From: YunyeZhao <yunye.zhao@linux.alibaba.com>

The hardcoded 8 KiB stripe size is rejected by lvcreate on 64K page
kernels (aarch64+64k, ppc64le), failing test_lv_create_striped and
test_lv_create_raid: STRIPE_SIZE_MIN is the page size, and MD RAID
4/5/6/10 requires chunk >= PAGE_SIZE. Use max(8, page_size_kib) so
the tests work on all page sizes.
---
 test/dbus/lvmdbustest.py | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index facd4877b..b29372348 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -32,6 +32,8 @@ g_lvm_shell = False
 # Approx. min size
 VDO_MIN_SIZE = mib(8192)
 
+STRIPE_SIZE_KB = max(8, os.sysconf('SC_PAGE_SIZE') // 1024)
+
 VG_TEST_SUFFIX = "_vg_LvMdBuS_TEST"
 
 EXE_NAME = "/lvmdbusd"
@@ -1008,7 +1010,7 @@ class TestDbusService(unittest.TestCase):
 		lv = self._test_lv_create(
 			vg.LvCreateStriped,
 			(dbus.String(lv_name), dbus.UInt64(mib(4)),
-				dbus.UInt32(2), dbus.UInt32(8), dbus.Boolean(False),
+				dbus.UInt32(2), dbus.UInt32(STRIPE_SIZE_KB), dbus.Boolean(False),
 				dbus.Int32(g_tmo), EOD), vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
@@ -1027,7 +1029,7 @@ class TestDbusService(unittest.TestCase):
 		lv = self._test_lv_create(
 			vg.LvCreateRaid,
 			(dbus.String(lv_name), dbus.String('raid5'), dbus.UInt64(mib(16)),
-				dbus.UInt32(2), dbus.UInt32(8), dbus.Int32(g_tmo), EOD),
+				dbus.UInt32(2), dbus.UInt32(STRIPE_SIZE_KB), dbus.Int32(g_tmo), EOD),
 			vg, LV_BASE_INT)
 		self._validate_lookup("%s/%s" % (vg.Name, lv_name), lv.object_path)
 
-- 
2.19.1.6.gb485710b

