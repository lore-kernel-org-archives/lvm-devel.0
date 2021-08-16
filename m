From: David Teigland <teigland@sourceware.org>
Date: Mon, 16 Aug 2021 15:12:58 +0000 (GMT)
Subject: main - lvchange: fix lvchange refresh failed for dm suspend or resume failed
Message-ID: <20210816151258.DBBF1385742B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=47bcb446b83f9aa4fca74301fda109a8bf670fbb
Commit:        47bcb446b83f9aa4fca74301fda109a8bf670fbb
Parent:        e5c0562654b8449f91c423e92e9b78d4ce986dc3
Author:        Yi Wang <wang.yi59@zte.com.cn>
AuthorDate:    Fri Aug 13 13:49:13 2021 +0800
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 16 09:45:40 2021 -0500

lvchange: fix lvchange refresh failed for dm suspend or resume failed

When multiple lvchange refresh processes executed at the same time,
suspend/resume ioctl on the same dm, some of these commands will be failed
for dm aready change status, and ioctl will return EINVAL in _do_dm_ioctl function.
to avoid this problem, add READ_FOR_ACTIVATE flags in lvchange refresh process,
it will hold LCK_WRITE lock and avoid suspend/resume dm at the same time.

Signed-off-by: Long YunJian <long.yunjian@zte.com.cn>
Signed-off-by: Yi Wang <wang.yi59@zte.com.cn>
---
 tools/lvchange.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index d4c40df47..0525bc53c 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1622,7 +1622,7 @@ int lvchange_refresh_cmd(struct cmd_context *cmd, int argc, char **argv)
 	cmd->lockd_vg_default_sh = 1;
 	cmd->ignore_device_name_mismatch = 1;
 
-	return process_each_lv(cmd, argc, argv, NULL, NULL, 0,
+	return process_each_lv(cmd, argc, argv, NULL, NULL, READ_FOR_ACTIVATE,
 			       NULL, &_lvchange_refresh_check, &_lvchange_refresh_single);
 }
 


