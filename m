Received: from mxct.zte.com.cn (mxct.zte.com.cn [183.62.165.209])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97D682905
	for <lvm-devel@lists.linux.dev>; Mon, 31 Mar 2025 02:17:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=183.62.165.209
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743387461; cv=none; b=JAPOwzeyJmdCw2/6Movyf1o2M5MHQqqixkvXQGdm7bFJrtFqePU5/sDAN7JixUZnQ42DZzrBEXuIlYNJODhC4l0PABe+m/YvnhXnMjtgvSy0kXrWHJviS+AvOrsKh1cPK4OD2d3UgdDCgHPb4muSi4vlHws5YY7BJaXtDrkViEA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743387461; c=relaxed/simple;
	bh=NBoXCgsD9ghXXXVfYfgE5hK4J14gOj2jcdvxMAwrCso=;
	h=Date:Message-ID:Mime-Version:From:To:Cc:Subject:Content-Type; b=FyToK/hucticVT8F0dyIIq9gcPW5V1a9hpvodtxmD1mcRc0Z48fjd4bBicrzgWMUFBJUZJxRJ6Xj3qRIkDuJVsc1o3OHuqNkC402Y+oLWwEbBWhi9txHE2sbQQSEjgTk2iN0r1B4yLBXA9EkJ40RCW2A3+LWeGwhj2gU6xlOB5c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zte.com.cn; spf=pass smtp.mailfrom=zte.com.cn; arc=none smtp.client-ip=183.62.165.209
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zte.com.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=zte.com.cn
Received: from mse-fl1.zte.com.cn (unknown [10.5.228.132])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mxct.zte.com.cn (FangMail) with ESMTPS id 4ZQvsg5fgMz4x5pV
	for <lvm-devel@lists.linux.dev>; Mon, 31 Mar 2025 10:17:27 +0800 (CST)
Received: from njy2app04.zte.com.cn ([10.40.12.64])
	by mse-fl1.zte.com.cn with SMTP id 52V2HJCC020756
	for <lvm-devel@lists.linux.dev>; Mon, 31 Mar 2025 10:17:19 +0800 (+08)
	(envelope-from long.yunjian@zte.com.cn)
Received: from mapi (njy2app02[null])
	by mapi (Zmail) with MAPI id mid201;
	Mon, 31 Mar 2025 10:17:20 +0800 (CST)
Date: Mon, 31 Mar 2025 10:17:20 +0800 (CST)
X-Zmail-TransId: 2afa67e9fb304e4-b3e36
X-Mailer: Zmail v1.0
Message-ID: <20250331101720789auYOdkuyhugUbj6Nbu-H8@zte.com.cn>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
Mime-Version: 1.0
From: <long.yunjian@zte.com.cn>
To: <lvm-devel@lists.linux.dev>
Cc: <mou.yi@zte.com.cn>, <ouyang.maochun@zte.com.cn>,
        <jiang.xuexin@zte.com.cn>, <xu.lifeng1@zte.com.cn>
Subject: =?UTF-8?B?W1BBVENIXSBkZXZpY2U6IHJlbmFtZSBkZXZfY2FjaGVfaW5kZXhfZGV2cyB0byByZWFsIG5hbWU=?=
Content-Type: text/plain;
	charset="UTF-8"
X-MAIL:mse-fl1.zte.com.cn 52V2HJCC020756
X-Fangmail-Anti-Spam-Filtered: true
X-Fangmail-MID-QID: 67E9FB37.003/4ZQvsg5fgMz4x5pV

From: Long Yunjian <long.yunjian@zte.com.cn>

dev_cache_index_devs had been renamed to _dev_cache_index_devs
in "5da282fa2 device: propagate struct cmd_context". So,
add missing '_' for dev_cache_index_devs in logs.

Signed-off-by: Long Yunjian <long.yunjian@zte.com.cn>
---
 lib/device/dev-cache.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 15cbc1d84..65ab26ec3 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -971,7 +971,7 @@ static int _dev_cache_index_devs(struct cmd_context *cmd)
 	char path[PATH_MAX];

 	if (dm_snprintf(path, sizeof(path), "%sdev/block", dm_sysfs_dir()) < 0) {
-		log_error("dev_cache_index_devs: dm_snprintf failed.");
+		log_error("_dev_cache_index_devs: dm_snprintf failed.");
 		return 0;
 	}

-- 
2.27.0
