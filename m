From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 25 Oct 2010 10:24:26 +0200
Subject: [PATCH 19/30] Fix constness warning
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com>
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <ce28656e64b2da18d26c3de9b17f33cbb869533e.1287994530.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

After update of device_from_pvid API fix few constness warnings

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 83ac1a5..60edcec 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -514,7 +514,7 @@ char *lvmcache_vgname_from_pvid(struct cmd_context *cmd, const char *pvid)
 	struct lvmcache_info *info;
 	char *vgname;
 
-	if (!device_from_pvid(cmd, (struct id *)pvid, NULL)) {
+	if (!device_from_pvid(cmd, (const struct id *)pvid, NULL)) {
 		log_error("Couldn't find device with uuid %s.", pvid);
 		return NULL;
 	}
@@ -740,7 +740,7 @@ struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 	struct lvmcache_info *info;
 
 	/* Already cached ? */
-	if ((info = info_from_pvid((char *) pvid, 0))) {
+	if ((info = info_from_pvid((const char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
@@ -751,7 +751,7 @@ struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 	lvmcache_label_scan(cmd, 0);
 
 	/* Try again */
-	if ((info = info_from_pvid((char *) pvid, 0))) {
+	if ((info = info_from_pvid((const char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
@@ -767,7 +767,7 @@ struct device *device_from_pvid(struct cmd_context *cmd, const struct id *pvid,
 		*scan_done_once = 1;
 
 	/* Try again */
-	if ((info = info_from_pvid((char *) pvid, 0))) {
+	if ((info = info_from_pvid((const char *) pvid, 0))) {
 		if (label_read(info->dev, &label, UINT64_C(0))) {
 			info = (struct lvmcache_info *) label->info;
 			if (id_equal(pvid, (struct id *) &info->dev->pvid))
-- 
1.7.3.1


