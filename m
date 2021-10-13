From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Oct 2021 22:30:40 +0000 (GMT)
Subject: main - fix lvmcache_add log_debug pvid
Message-ID: <20211013223040.2421D385840B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e88163ceac0ca7d78ab728867a6e84d0e535ad1d
Commit:        e88163ceac0ca7d78ab728867a6e84d0e535ad1d
Parent:        6fb497ef42a5f8324a90cb93734cd8071ed0dc0b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 13 16:26:00 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Oct 13 17:30:21 2021 -0500

fix lvmcache_add log_debug pvid

from previous cleanup
---
 lib/cache/lvmcache.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index e04f00f2d..2c4254324 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2168,15 +2168,17 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
 {
 	const char *pvid = pvid_arg;
 	const char *vgid = vgid_arg;
-	char pvid_dashed[64] __attribute__((aligned(8)));
 	struct lvmcache_vgsummary vgsummary = { 0 };
 	struct lvmcache_info *info;
 	struct lvmcache_info *info_lookup;
 	struct device_list *devl;
 	int created = 0;
 
-	if (!id_write_format((const struct id *)&pvid, pvid_dashed, sizeof(pvid_dashed)))
-		stack;
+	/*
+	 * Note: ensure that callers of lvmcache_add() pass null terminated
+	 * pvid and vgid strings, and do not pass char* that is type cast
+	 * from struct id.
+	 */
 
 	log_debug_cache("Found PVID %s on %s", pvid, dev_name(dev));
 
@@ -2206,7 +2208,7 @@ struct lvmcache_info *lvmcache_add(struct cmd_context *cmd, struct labeller *lab
 	if (!created) {
 		if (info->dev != dev) {
 			log_debug_cache("Saving initial duplicate device %s previously seen on %s with PVID %s.",
-					dev_name(dev), dev_name(info->dev), pvid_dashed);
+					dev_name(dev), dev_name(info->dev), pvid);
 
 			memset(&dev->pvid, 0, sizeof(dev->pvid));
 			memcpy(dev->pvid, pvid, ID_LEN);


