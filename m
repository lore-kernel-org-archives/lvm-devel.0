From: Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
Date: Fri, 20 Aug 2021 10:15:54 -0400
Subject: [PATCH] add missing sys/file.h include
References: <20210820141554.134411-1-alex_y_xu.ref@yahoo.ca>
Message-ID: <20210820141554.134411-1-alex_y_xu@yahoo.ca>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

required for LOCK_EX etc on musl
---
 lib/device/dev-cache.c | 1 +
 tools/lvmdevices.c     | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index d7fa93fd6..d54a63fbe 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -29,6 +29,7 @@
 #include <unistd.h>
 #include <dirent.h>
 #include <locale.h>
+#include <sys/file.h>
 
 struct dev_iter {
 	struct btree_iter *current;
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 3448bdd14..aa793f2e4 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -16,6 +16,8 @@
 #include "lib/cache/lvmcache.h"
 #include "lib/device/device_id.h"
 
+#include <sys/file.h>
+
 static void _search_devs_for_pvids(struct cmd_context *cmd, struct dm_list *search_pvids, struct dm_list *found_devs)
 {
 	struct dev_iter *iter;
-- 
2.33.0


