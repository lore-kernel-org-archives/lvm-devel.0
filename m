From: Alessio Balsini <balsini@android.com>
Date: Tue, 30 Jul 2019 17:39:54 +0100
Subject: [PATCH] filters/sysfs: Fix missing sys/sysmacros.h
Message-ID: <20190730163954.144621-1-balsini@android.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The missing sys/sysmacros.h header was causing building issues.  Fixed.

Signed-off-by: Alessio Balsini <balsini@android.com>
---
 lib/filters/filter-sysfs.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index ebd16a2b..192d3da2 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -18,6 +18,7 @@
 #ifdef linux
 
 #include <dirent.h>
+#include <sys/sysmacros.h>
 
 static int _locate_sysfs_blocks(const char *sysfs_dir, char *path, size_t len,
 				unsigned *sysfs_depth)
-- 
2.22.0.709.g102302147b-goog


