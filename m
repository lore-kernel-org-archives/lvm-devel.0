From: David Teigland <teigland@sourceware.org>
Date: Mon, 20 Sep 2021 14:37:28 +0000 (GMT)
Subject: main - lvmcache: follow pv_id/pvid naming convention
Message-ID: <20210920143728.6F0703858421@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=130993bab1a6fe40c781bff396e13b56a2b2768b
Commit:        130993bab1a6fe40c781bff396e13b56a2b2768b
Parent:        b1f33a4000018df57b9af40a4b2a38434ad0079d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Sep 20 09:32:21 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 20 09:35:47 2021 -0500

lvmcache: follow pv_id/pvid naming convention

name the variable pv_id_arg to follow the convention:
. "pvid" variable is null-terminated string
. "pv_id" variable is non-null-terminated struct
---
 lib/cache/lvmcache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d94d174b6..655f34bd8 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -477,14 +477,14 @@ struct lvmcache_info *lvmcache_info_from_pvid(const char *pvid_arg, struct devic
 	return info;
 }
 
-struct lvmcache_info *lvmcache_info_from_pv_id(const struct id *pvid, struct device *dev, int valid_only)
+struct lvmcache_info *lvmcache_info_from_pv_id(const struct id *pv_id_arg, struct device *dev, int valid_only)
 {
 	/*
 	 * Since we know that lvmcache_info_from_pvid directly above
 	 * does not assume pvid_arg is null-terminated, we make an
 	 * exception here and cast a struct id to char *.
 	 */
-	return lvmcache_info_from_pvid((const char *)pvid, dev, valid_only);
+	return lvmcache_info_from_pvid((const char *)pv_id_arg, dev, valid_only);
 }
 
 const struct format_type *lvmcache_fmt_from_info(struct lvmcache_info *info)


