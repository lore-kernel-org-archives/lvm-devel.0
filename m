From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 13 Nov 2014 16:53:40 +0000 (UTC)
Subject: master - cleanup: remove unused headers
Message-ID: <20141113165340.131306105D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88e944b5a3c8633f9c6b3994743159801f1a7147
Commit:        88e944b5a3c8633f9c6b3994743159801f1a7147
Parent:        428b9fcd87d1c79cd4349c884a68de7ccac51981
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 13 14:36:20 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 13 17:49:42 2014 +0100

cleanup: remove unused headers

---
 lib/cache_segtype/cache.c       |    1 -
 lib/device/dev-md.c             |    1 -
 lib/filters/filter-persistent.c |    1 -
 lib/zero/zero.c                 |    2 --
 4 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 02ac198..73839f4 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -19,7 +19,6 @@
 #include "text_export.h"
 #include "config.h"
 #include "str_list.h"
-#include "targets.h"
 #include "lvm-string.h"
 #include "activate.h"
 #include "metadata.h"
diff --git a/lib/device/dev-md.c b/lib/device/dev-md.c
index 91cc322..76e3093 100644
--- a/lib/device/dev-md.c
+++ b/lib/device/dev-md.c
@@ -15,7 +15,6 @@
 
 #include "lib.h"
 #include "dev-type.h"
-#include "metadata.h"
 #include "xlate.h"
 
 #ifdef __linux__
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 3c1701b..b4a7683 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -17,7 +17,6 @@
 #include "filter.h"
 #include "config.h"
 #include "lvm-file.h"
-#include "activate.h"
 
 struct pfilter {
 	char *file;
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index f07f288..4efa0ce 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -14,8 +14,6 @@
 
 #include "lib.h"
 #include "segtype.h"
-#include "display.h"
-#include "config.h"
 #include "str_list.h"
 #include "activate.h"
 


