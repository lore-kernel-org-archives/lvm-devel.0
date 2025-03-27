Received: from mxhk.zte.com.cn (mxhk.zte.com.cn [63.216.63.40])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 731B920B7EA
	for <lvm-devel@lists.linux.dev>; Thu, 27 Mar 2025 08:59:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=63.216.63.40
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743065971; cv=none; b=YuEU554vfFRjrdivjZU6nfo66g/MAiBnXZXdF6FNYPSd8hJZrqPbBF/7o/KEHX7L6YVCB+C3RKIJv2FUmrRhF7ozv2p+8d+GOJ09+DebbM1b1pqdfrTcV9RGEG/cWTKLnhlWfsHFrC/uQKVWUoa/1n4o4JJUaOlFXcxHlXe62B0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743065971; c=relaxed/simple;
	bh=0NvL4oXFG5gRDxex9pcMw/Zq6AZl+Jc3+NbIT0BnaiU=;
	h=Date:Message-ID:Mime-Version:From:To:Cc:Subject:Content-Type; b=jriGfE9PKr4csOCqlmKfjZIscipmLAPMmxlG3cz+ePpMbuD4qhlrs7mnG26xEpoqvkxa0hjsk7HZYljJhiH9auLCOarK99ICszrJENcfTC2QfbkYHIcrJskJpyj8b7H0s0VI33FVUYOXfr5YH7sBS630RYEfEk7FqjMyhxc3ukw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zte.com.cn; spf=pass smtp.mailfrom=zte.com.cn; arc=none smtp.client-ip=63.216.63.40
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zte.com.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=zte.com.cn
Received: from mse-fl2.zte.com.cn (unknown [10.5.228.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mxhk.zte.com.cn (FangMail) with ESMTPS id 4ZNcz96Lwpz8R040
	for <lvm-devel@lists.linux.dev>; Thu, 27 Mar 2025 16:59:17 +0800 (CST)
Received: from njb2app07.zte.com.cn ([10.55.22.95])
	by mse-fl2.zte.com.cn with SMTP id 52R8wujd021955
	for <lvm-devel@lists.linux.dev>; Thu, 27 Mar 2025 16:58:56 +0800 (+08)
	(envelope-from long.yunjian@zte.com.cn)
Received: from mapi (njy2app01[null])
	by mapi (Zmail) with MAPI id mid201;
	Thu, 27 Mar 2025 16:58:58 +0800 (CST)
Date: Thu, 27 Mar 2025 16:58:58 +0800 (CST)
X-Zmail-TransId: 2af967e513523f7-eb627
X-Mailer: Zmail v1.0
Message-ID: <202503271658587110eSppwPsg21ncwifiIKCh@zte.com.cn>
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
Subject: =?UTF-8?B?W1BBVENIXSBsdm1jbWRsaW5lOiBjbGVhbnVwIHRhYg==?=
Content-Type: text/plain;
	charset="UTF-8"
X-MAIL:mse-fl2.zte.com.cn 52R8wujd021955
X-Fangmail-Anti-Spam-Filtered: true
X-Fangmail-MID-QID: 67E51365.006/4ZNcz96Lwpz8R040

From: Long Yunjian <long.yunjian@zte.com.cn>

cleanup tab in _get_current_settings

Signed-off-by: Long Yunjian <long.yunjian@zte.com.cn>
---
 tools/lvmcmdline.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ddcef0063..3e32367c1 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2614,7 +2614,7 @@ static int _get_current_settings(struct cmd_context *cmd)
 	 * itself rather than having them printed in vg_read.
 	 */
 	cmd->vg_read_print_access_error = 1;
-		
+
 	if (arg_is_set(cmd, nosuffix_ARG))
 		cmd->current_settings.suffix = 0;

-- 
2.27.0
