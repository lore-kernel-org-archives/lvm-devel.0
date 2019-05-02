From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 May 2019 14:27:05 -0400
Subject: master - remove unused string writecache
Message-ID: <201905021827.x42IR5mY007533@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=adfb9bf20cd7483785bd3156f5f616b0906cd895
Commit:        adfb9bf20cd7483785bd3156f5f616b0906cd895
Parent:        90b94ead12d739a3221e179bdcf1c482978f0f0f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed May 1 16:50:14 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed May 1 16:50:14 2019 -0500

remove unused string writecache

---
 lib/writecache/writecache.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/writecache/writecache.c b/lib/writecache/writecache.c
index e9d337b..53619c3 100644
--- a/lib/writecache/writecache.c
+++ b/lib/writecache/writecache.c
@@ -26,8 +26,6 @@
 #include "lib/metadata/lv_alloc.h"
 #include "lib/config/defaults.h"
 
-static const char _writecache_module[] = "writecache";
-
 #define SEG_LOG_ERROR(t, p...) \
         log_error(t " segment %s of logical volume %s.", ## p,	\
                   dm_config_parent_name(sn), seg->lv->name), 0;


