From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:30 +0000 (GMT)
Subject: main - cov: remove unneeded includes
Message-ID: <20210727225030.BAF67383B82C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=69379df8f35404269e5aa4a275a7686a87076f27
Commit:        69379df8f35404269e5aa4a275a7686a87076f27
Parent:        ec9dd728aa00de692f4b003e12394aa9cdda9446
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 15:04:09 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:28 2021 +0200

cov: remove unneeded includes

---
 lib/filters/filter-mpath.c | 2 --
 lib/metadata/lv_manip.c    | 1 -
 lib/metadata/pv_manip.c    | 1 -
 3 files changed, 4 deletions(-)

diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index ebd40a457..982e23400 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -15,8 +15,6 @@
 #include "base/memory/zalloc.h"
 #include "lib/misc/lib.h"
 #include "lib/filters/filter.h"
-#include "lib/activate/activate.h"
-#include "lib/commands/toolcontext.h"
 
 #ifdef __linux__
 
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7e66afd9c..a26d3d533 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -23,7 +23,6 @@
 #include "lib/metadata/pv_alloc.h"
 #include "lib/display/display.h"
 #include "lib/metadata/segtype.h"
-#include "lib/format_text/archiver.h"
 #include "lib/activate/activate.h"
 #include "lib/datastruct/str_list.h"
 #include "lib/config/defaults.h"
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index cfc983174..2b970f0ba 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -20,7 +20,6 @@
 #include "lib/locking/locking.h"
 #include "lib/config/defaults.h"
 #include "lib/display/display.h"
-#include "lib/format_text/archiver.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,


