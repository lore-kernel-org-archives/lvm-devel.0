From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:34 +0000 (UTC)
Subject: master - cleanup: remove unneeded header files
Message-ID: <20140211180134.2BD8060FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d69585b82d8bc2305f7ac197ef22751f9821a5f
Commit:        9d69585b82d8bc2305f7ac197ef22751f9821a5f
Parent:        e5d59d96187d4ba6efa88cca53f608cd646f461a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 9 21:32:57 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 19:00:06 2014 +0100

cleanup: remove unneeded header files

---
 lib/cache_segtype/cache.c |    1 -
 lib/label/label.c         |    1 -
 lib/metadata/pool_manip.c |    1 -
 lib/metadata/thin_manip.c |    1 -
 lib/misc/lvm-exec.c       |    1 -
 5 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 3e74495..7557a7d 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -17,7 +17,6 @@
 #include "segtype.h"
 #include "display.h"
 #include "text_export.h"
-#include "text_import.h"
 #include "config.h"
 #include "str_list.h"
 #include "targets.h"
diff --git a/lib/label/label.c b/lib/label/label.c
index 25e5f2c..703fef7 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -19,7 +19,6 @@
 #include "xlate.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
-#include "metadata.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index afb77d6..0c7bf96 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -23,7 +23,6 @@
 #include "segtype.h"
 #include "lv_alloc.h"
 #include "defaults.h"
-#include "display.h"
 
 int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 			    struct logical_volume *metadata_lv)
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 0449b45..c3f8e56 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -17,7 +17,6 @@
 #include "locking.h"
 #include "metadata.h"
 #include "segtype.h"
-#include "lv_alloc.h"
 #include "defaults.h"
 #include "display.h"
 
diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index 01704ad..e862bad 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -18,7 +18,6 @@
 #include "locking.h"
 #include "lvm-exec.h"
 #include "toolcontext.h"
-#include "activate.h"
 
 #include <unistd.h>
 #include <sys/wait.h>


