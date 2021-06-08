From: Leo Yan <leo.yan@linaro.org>
Date: Tue,  8 Jun 2021 14:45:09 +0800
Subject: [PATCH] lvmlockd: Fix the compilation warning
Message-ID: <20210608064509.6970-1-leo.yan@linaro.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

As SUSE build tool reports the warning:

lvmlockd-core.c: In function 'client_thread_main':
lvmlockd-core.c:4959:37: warning: '%d' directive output may be truncated writing between 1 and 10 bytes into a region of size 6 [-Wformat-truncation=]
    snprintf(buf, sizeof(buf), "path[%d]", i);
                                     ^~
lvmlockd-core.c:4959:31: note: directive argument in the range [0, 2147483647]
    snprintf(buf, sizeof(buf), "path[%d]", i);
                               ^~~~~~~~~~

To dismiss the compilation warning, enlarge the array "buf" to 17
bytes to support the max signed integer: string format 6 bytes + signed
integer 10 bytes + terminal char "\0".

Reported-by: Heming Zhao <heming.zhao@suse.com>
Signed-off-by: Leo Yan <leo.yan@linaro.org>
---
 daemons/lvmlockd/lvmlockd-core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index ea76f2214..fef9589b9 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -4780,7 +4780,7 @@ static void client_recv_action(struct client *cl)
 	const char *path;
 	const char *str;
 	struct pvs pvs;
-	char buf[11];	/* p a t h [ x x x x ] \0 */
+	char buf[17];	/* "path[%d]\0", %d outputs signed integer so max to 10 bytes */
 	int64_t val;
 	uint32_t opts = 0;
 	int result = 0;
-- 
2.25.1


