From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Oct 2019 15:36:35 -0400
Subject: master - cache: change default cachevol metadata sizes
Message-ID: <201910151936.x9FJaZ8l008365@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81fe0457141d74e20a7fda45a69164405fc9f151
Commit:        81fe0457141d74e20a7fda45a69164405fc9f151
Parent:        0443d00ff1efdb5af05def774a4961563377dbd0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Oct 15 14:16:14 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 15 14:36:03 2019 -0500

cache: change default cachevol metadata sizes

The first part of a cachevol LV is used for metadata,
and the rest of the space is used for data.  The
division of space between metadata and data depends
on the total size of the cachevol.

The previous division gave more space than needed to
metadata, it was:

cachevol size 8M to 128M -> metadata size 16M *
cachevol size 128M to 1G -> metadata size 32M
cachevol size 1G and up  -> metadata size 64M

(* if this resulted in over half the LV used as
metadata, then half the cachevol would be used
for metadata, and the other half for data.)

The division of space now gives less space to
metadata, it is:

cachevol size 8M to 16M  -> metadata size 4M
cachevol size 16M to 4G  -> metadata size 8M
cachevol size 4G to 16G  -> metadata size 16M
cachevol size 16G to 32G -> metadata size 32M
cachevol size 32G and up -> metadata size 64M
---
 lib/metadata/cache_manip.c |   34 ++++++++++++++++++++++++----------
 1 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 6eb68d5..53600d9 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -969,8 +969,8 @@ int cache_set_metadata_format(struct lv_segment *seg, cache_metadata_format_t fo
 	return 1;
 }
 
-#define ONE_MB_S 2048 /* 1MB in sectors */
-#define ONE_GB_S 2097152 /* 1GB in sectors */
+#define ONE_MB_IN_SECTORS 2048 /* 1MB in sectors */
+#define ONE_GB_IN_SECTORS 2097152 /* 1GB in sectors */
 
 int cache_vol_set_params(struct cmd_context *cmd,
 		     struct logical_volume *cache_lv,
@@ -1082,18 +1082,32 @@ int cache_vol_set_params(struct cmd_context *cmd,
 		}
 	}
 
+	/*
+	 * cachevol size 8M to 16M  -> metadata size 4M
+	 *
+	 * cachevol size 16M to 4G  -> metadata size 8M
+	 *
+	 * cachevol size 4G to 16G  -> metadata size 16M
+	 *
+	 * cachevol size 16G to 32G -> metadata size 32M
+	 *
+	 * cachevol size 32G and up -> metadata size 64M
+	 */
 	if (!meta_size) {
-		if (pool_lv->size < (128 * ONE_MB_S))
-			meta_size = 16 * ONE_MB_S;
+		if (pool_lv->size <= (16 * ONE_MB_IN_SECTORS))
+			meta_size = 4 * ONE_MB_IN_SECTORS;
+
+		else if (pool_lv->size <= (4 * ONE_GB_IN_SECTORS))
+			meta_size = 8 * ONE_MB_IN_SECTORS;
 
-		else if (pool_lv->size < ONE_GB_S)
-			meta_size = 32 * ONE_MB_S;
+		else if (pool_lv->size <= (16 * ONE_GB_IN_SECTORS))
+			meta_size = 16 * ONE_MB_IN_SECTORS;
 
-		else if (pool_lv->size < (128 * ONE_GB_S))
-			meta_size = 64 * ONE_MB_S;
+		else if (pool_lv->size <= (32 * ONE_GB_IN_SECTORS))
+			meta_size = 32 * ONE_MB_IN_SECTORS;
 
-		if (meta_size > (pool_lv->size / 2))
-			meta_size = pool_lv->size / 2;
+		else
+			meta_size = 64 * ONE_MB_IN_SECTORS;
 
 		if (meta_size < min_meta_size)
 			meta_size = min_meta_size;


