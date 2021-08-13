From: Yi Wang <wang.yi59@zte.com.cn>
Date: Fri, 13 Aug 2021 13:49:13 +0800
Subject: [PATCH] lvchange: fix lvchange refresh failed for dm suspend or resume failed
Message-ID: <20210813054913.4868-1-wang.yi59@zte.com.cn>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

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
 
-- 
2.18.1
