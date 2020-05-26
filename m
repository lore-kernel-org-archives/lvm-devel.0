From: Yi Wang <wang.yi59@zte.com.cn>
Date: Tue, 26 May 2020 08:44:24 +0800
Subject: [PATCH] activation: replace link_path with lv_path accorinding to the previous context.
Message-ID: <1590453864-21535-1-git-send-email-wang.yi59@zte.com.cn>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: LiaoPingfang <liao.pingfang@zte.com.cn>

link_path should be lv_path, per previous condition check.

Signed-off-by: LiaoPingfang <liao.pingfang@zte.com.cn>
---
 lib/activate/fs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index b2c99fc..a92819c 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -176,7 +176,7 @@ static int _mk_link(const char *dev_dir, const char *vg_name,
 	if (!lstat(lv_path, &buf)) {
 		if (!S_ISLNK(buf.st_mode) && !S_ISBLK(buf.st_mode)) {
 			log_error("Symbolic link %s not created: file exists",
-				  link_path);
+				  lv_path);
 			return 0;
 		}
 
-- 
2.9.5


