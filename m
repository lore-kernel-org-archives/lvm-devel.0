From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:08:05 -0500
Subject: master - cov: remove unused headers
Message-ID: <11655.119111412080202397@us-mta-224.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad0343d8cb9644912961a72760df083378104078
Commit:        ad0343d8cb9644912961a72760df083378104078
Parent:        9ee3af7efc4bece83769a75586ffcb0f07a74d16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 16:55:09 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:06:42 2019 +0100

cov: remove unused headers

---
 lib/cache/lvmcache.c            |    1 -
 lib/metadata/cache_manip.c      |    1 -
 lib/metadata/writecache_manip.c |    2 --
 3 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 25d110d..6224fe0 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -21,7 +21,6 @@
 #include "lib/locking/locking.h"
 #include "lib/metadata/metadata.h"
 #include "lib/mm/memlock.h"
-#include "lib/datastruct/str_list.h"
 #include "lib/format_text/format-text.h"
 #include "lib/config/config.h"
 
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 2f35d83..5613a22 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -23,7 +23,6 @@
 #include "lib/config/defaults.h"
 #include "lib/metadata/lv_alloc.h"
 #include "lib/misc/lvm-signal.h"
-#include "lib/activate/dev_manager.h"
 
 /* https://github.com/jthornber/thin-provisioning-tools/blob/master/caching/cache_metadata_size.cc */
 #define DM_TRANSACTION_OVERHEAD		4096  /* KiB */
diff --git a/lib/metadata/writecache_manip.c b/lib/metadata/writecache_manip.c
index 73fbd2e..5a5a759 100644
--- a/lib/metadata/writecache_manip.c
+++ b/lib/metadata/writecache_manip.c
@@ -21,8 +21,6 @@
 #include "lib/metadata/segtype.h"
 #include "lib/activate/activate.h"
 #include "lib/config/defaults.h"
-#include "lib/metadata/lv_alloc.h"
-#include "lib/misc/lvm-signal.h"
 #include "lib/activate/dev_manager.h"
 
 int lv_is_writecache_origin(const struct logical_volume *lv)



