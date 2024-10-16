Received: from mxhk.zte.com.cn (mxhk.zte.com.cn [63.216.63.40])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DB64A21E3BF
	for <lvm-devel@lists.linux.dev>; Wed, 16 Oct 2024 02:16:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=63.216.63.40
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1729045008; cv=none; b=KPEIdLDIWO2QuBrZKwBewVM/8nz8rwnmG8c7xwj5mxDwSoiNQ+bKEKGH07teTBwSUjHWP6o3GpyXdHtIAZB5c4Ewtt795v/lKqL2pUzJcKoYhWf1SAPbTQ/chUP1Nzev3r0jafC+NCw9gxZQG2grq77Rd+Tk0feGS/VAu+IXUBU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1729045008; c=relaxed/simple;
	bh=f99Uhn6XqISKnV8XDWrnYmBb3cNDPI1pYsR80CllHgk=;
	h=Date:Message-ID:Mime-Version:From:To:Cc:Subject:Content-Type; b=quT3/HZPXbglZwfIeSuEqir88LURp7Gzcg4m4jtbJ/TubKNkjY0QHcfiQ6yevUWa1aijM6gfMnOJfemjxcnBb77FMJjpTmNpeagbYDPUX6MHpmzjIygYjBfbgOuZjz0UFSskoEYx9jE/ciKjAnD+CcFb0qIB5aAhSl2LMagPxXw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zte.com.cn; spf=pass smtp.mailfrom=zte.com.cn; arc=none smtp.client-ip=63.216.63.40
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zte.com.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=zte.com.cn
Received: from mse-fl2.zte.com.cn (unknown [10.5.228.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mxhk.zte.com.cn (FangMail) with ESMTPS id 4XSvjJ2Z55z8QrkZ
	for <lvm-devel@lists.linux.dev>; Wed, 16 Oct 2024 10:16:36 +0800 (CST)
Received: from njb2app06.zte.com.cn ([10.55.23.119])
	by mse-fl2.zte.com.cn with SMTP id 49G2GQYb026368
	for <lvm-devel@lists.linux.dev>; Wed, 16 Oct 2024 10:16:26 +0800 (+08)
	(envelope-from long.yunjian@zte.com.cn)
Received: from mapi (njy2app02[null])
	by mapi (Zmail) with MAPI id mid201;
	Wed, 16 Oct 2024 10:16:27 +0800 (CST)
Date: Wed, 16 Oct 2024 10:16:27 +0800 (CST)
X-Zmail-TransId: 2afa670f21fb0fb-6f06e
X-Mailer: Zmail v1.0
Message-ID: <20241016101627552OQp0AQIZhpja0akhFT2Da@zte.com.cn>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
Mime-Version: 1.0
From: <long.yunjian@zte.com.cn>
To: <lvm-devel@lists.linux.dev>
Cc: <xue.zhihong@zte.com.cn>, <cai.qu@zte.com.cn>, <jiang.yong5@zte.com.cn>,
        <long.yunjian@zte.com.cn>, <xu.lifeng1@zte.com.cn>
Subject: =?UTF-8?B?W1BBVENIXSBjbGVhbnVwOiByZW5hbWXCoGludmFsaWQgZnVuY3Rpb24gdG8gcmVhbCBmdW5jdGlvbiBpbiBhbm5vdGF0aW9u?=
Content-Type: text/plain;
	charset="UTF-8"
X-MAIL:mse-fl2.zte.com.cn 49G2GQYb026368
X-Fangmail-Anti-Spam-Filtered: true
X-Fangmail-MID-QID: 670F2204.001/4XSvjJ2Z55z8QrkZ

There are no fuction named print_common_options_cmd()
and print_common_options_lvm(). So, rename them to the
real function named print_usage_common_cmd() and
print_usage_common_lvm().

Signed-off-by: YunJian Long
---
 tools/command.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 114aa9b50..0ed486811 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1851,7 +1851,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
                        /*
                         * Skip common lvm options in lvm_all which
                         * are printed at the end under "Common options for lvm"
-                        * see print_common_options_lvm()
+                        * see print_usage_common_lvm()
                         */

                        if (_is_lvm_all_opt(opt_enum))
@@ -1863,7 +1863,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
                         * cname->common_options (options common
                         * to all variants), which are printed at
                         * the end under "Common options for command"
-                        * see print_common_options_cmd()
+                        * see print_usage_common_cmd()
                         */

                        if (cna && (cna->variants > 1) && cna->common_options[opt_enum])
@@ -1891,7 +1891,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
                        /*
                         * Skip common lvm options in lvm_all which
                         * are printed at the end under "Common options for lvm"
-                        * see print_common_options_lvm()
+                        * see print_usage_common_lvm()
                         */

                        if (_is_lvm_all_opt(opt_enum))
@@ -1903,7 +1903,7 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
                         * cname->common_options (options common
                         * to all variants), which are printed at
                         * the end under "Common options for command"
-                        * see print_common_options_cmd()
+                        * see print_usage_common_cmd()
                         */

                        if (cna && (cna->variants > 1) && cna->common_options[opt_enum])
-- 
2.31.1
