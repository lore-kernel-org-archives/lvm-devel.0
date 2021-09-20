From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Sep 2021 14:26:32 +0000 (GMT)
Subject: main - gcc: avoid name colision with function pv_id() from metadata.h
Message-ID: <20210920142632.95C7C3858C60@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=133686ebc79b29316d5f913bcce3fe21bbfea9ec
Commit:        133686ebc79b29316d5f913bcce3fe21bbfea9ec
Parent:        2e990d1fec93126017124d3db754aeed5b6c7dc3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 20 16:12:10 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 20 16:12:10 2021 +0200

gcc: avoid name colision with function pv_id() from metadata.h

---
 lib/cache/lvmcache.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 655da164c..d94d174b6 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -477,14 +477,14 @@ struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid_arg, struct devic
 	return info;
 }
 
-struct lvmcache_info *lvmcache_info_from_pv_id(const struct id *pv_id, struct device *dev, int valid_only)
+struct lvmcache_info *lvmcache_info_from_pv_id(const struct id *pvid, struct device *dev, int valid_only)
 {
 	/*
 	 * Since we know that lvmcache_info_from_pvid directly above
 	 * does not assume pvid_arg is null-terminated, we make an
 	 * exception here and cast a struct id to char *.
 	 */
-	return lvmcache_info_from_pvid((const char *)pv_id, dev, valid_only);
+	return lvmcache_info_from_pvid((const char *)pvid, dev, valid_only);
 }
 
 const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info)
@@ -1391,11 +1391,11 @@ int lvmcache_get_vgnameids(struct cmd_context *cmd,
 	return 1;
 }
 
-struct device *lvmcache_device_from_pv_id(struct cmd_context *cmd, const struct id *pv_id, uint64_t *label_sector)
+struct device *lvmcache_device_from_pv_id(struct cmd_context *cmd, const struct id *pvid, uint64_t *label_sector)
 {
 	struct lvmcache_info *info;
 
-	if ((info = lvmcache_info_from_pv_id(pv_id, NULL, 0))) {
+	if ((info = lvmcache_info_from_pv_id(pvid, NULL, 0))) {
 		if (info->label && label_sector)
 			*label_sector = info->label->sector;
 		return info->dev;


