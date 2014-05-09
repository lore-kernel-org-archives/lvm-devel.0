From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:56:35 +0000 (UTC)
Subject: dev-prajnoha-selout - cleanup: drop uneeded headers
Message-ID: <20140509065635.2C4C060774@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d88fab8d3a64cb492c808a50d247686febedc9e3
Commit:        d88fab8d3a64cb492c808a50d247686febedc9e3
Parent:        bcd6deea18673cedfa833fc40399949955e7f834
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 7 10:50:06 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 7 14:17:45 2014 +0200

cleanup: drop uneeded headers

---
 daemons/clvmd/clvmd-singlenode.c |    1 -
 lib/locking/external_locking.c   |    1 -
 lib/locking/file_locking.c       |    2 --
 lib/metadata/cache_manip.c       |    6 ------
 4 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index e65ab28..e6d2b0d 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -19,7 +19,6 @@
 #include "locking.h"
 #include "clvm.h"
 #include "clvmd-comms.h"
-#include "lvm-functions.h"
 #include "clvmd.h"
 
 #include <sys/un.h>
diff --git a/lib/locking/external_locking.c b/lib/locking/external_locking.c
index 1e669bb..bc597ff 100644
--- a/lib/locking/external_locking.c
+++ b/lib/locking/external_locking.c
@@ -19,7 +19,6 @@
 #include "sharedlib.h"
 #include "toolcontext.h"
 #include "activate.h"
-#include "locking.h"
 
 static void *_locking_lib = NULL;
 static void (*_reset_fn) (void) = NULL;
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index d79d7a9..10431ab 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -19,7 +19,6 @@
 #include "activate.h"
 #include "config.h"
 #include "defaults.h"
-#include "lvm-file.h"
 #include "lvm-string.h"
 #include "lvm-flock.h"
 #include "lvmcache.h"
@@ -28,7 +27,6 @@
 #include <limits.h>
 #include <unistd.h>
 #include <sys/stat.h>
-#include <sys/file.h>
 #include <fcntl.h>
 #include <signal.h>
 
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index deae6f2..6a0f0f6 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -15,18 +15,12 @@
 #include "lib.h"
 #include "metadata.h"
 #include "locking.h"
-#include "pv_map.h"
 #include "lvm-string.h"
 #include "toolcontext.h"
-#include "lv_alloc.h"
-#include "pv_alloc.h"
 #include "display.h"
 #include "segtype.h"
-#include "archiver.h"
 #include "activate.h"
-#include "str_list.h"
 #include "defaults.h"
-#include "lvm-exec.h"
 
 int update_cache_pool_params(struct volume_group *vg, unsigned attr,
 			     int passed_args,


