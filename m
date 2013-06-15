From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Jun 2013 22:16:25 +0000 (UTC)
Subject: master - cleanup: drop unused headers
Message-ID: <20130615221625.9BD1860D69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17a3ddf89e4148b4fdfe32c2da22beff7b1ca465
Commit:        17a3ddf89e4148b4fdfe32c2da22beff7b1ca465
Parent:        02405219424619a56e7e3a3619e157f942e4fdb4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 14 09:52:02 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 16 00:07:32 2013 +0200

cleanup: drop unused headers

Drop heades which do not provide any used symbols.
---
 lib/activate/activate.c     |    1 -
 lib/activate/dev_manager.c  |    1 -
 lib/cache/lvmcache.c        |    2 --
 lib/device/dev-luks.c       |    1 -
 lib/device/dev-swap.c       |    1 -
 lib/filters/filter.c        |    4 ----
 lib/format1/disk-rep.c      |    1 -
 lib/format1/import-export.c |    1 -
 lib/format_pool/disk_rep.c  |    1 -
 9 files changed, 0 insertions(+), 13 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index a69b725..342a474 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -26,7 +26,6 @@
 #include "dev_manager.h"
 #include "str_list.h"
 #include "config.h"
-#include "filter.h"
 #include "segtype.h"
 #include "sharedlib.h"
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 9855bc9..e471f95 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -23,7 +23,6 @@
 #include "toolcontext.h"
 #include "targets.h"
 #include "config.h"
-#include "filter.h"
 #include "activate.h"
 #include "lvm-exec.h"
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c0b3299..2da09d1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -19,8 +19,6 @@
 #include "dev-cache.h"
 #include "locking.h"
 #include "metadata.h"
-#include "filter.h"
-#include "filter-persistent.h"
 #include "memlock.h"
 #include "str_list.h"
 #include "format-text.h"
diff --git a/lib/device/dev-luks.c b/lib/device/dev-luks.c
index 2c79a2b..2671d62 100644
--- a/lib/device/dev-luks.c
+++ b/lib/device/dev-luks.c
@@ -14,7 +14,6 @@
 
 #include "lib.h"
 #include "dev-type.h"
-#include "metadata.h"
 
 #define LUKS_SIGNATURE "LUKS\xba\xbe"
 #define LUKS_SIGNATURE_SIZE 6
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index c3b121b..6faa810 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -14,7 +14,6 @@
 
 #include "lib.h"
 #include "dev-type.h"
-#include "metadata.h"
 
 #ifdef linux
 
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index cf06f88..56935f9 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -15,10 +15,6 @@
 
 #include "lib.h"
 #include "filter.h"
-#include "lvm-string.h"
-#include "config.h"
-#include "metadata.h"
-#include "activate.h"
 
 static int _passes_lvm_type_device_filter(struct dev_filter *f, struct device *dev)
 {
diff --git a/lib/format1/disk-rep.c b/lib/format1/disk-rep.c
index bbce317..f42d344 100644
--- a/lib/format1/disk-rep.c
+++ b/lib/format1/disk-rep.c
@@ -16,7 +16,6 @@
 #include "lib.h"
 #include "disk-rep.h"
 #include "xlate.h"
-#include "filter.h"
 #include "lvmcache.h"
 #include "metadata-exported.h"
 
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 5c5d890..5ef19ef 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -20,7 +20,6 @@
 #include "lib.h"
 #include "disk-rep.h"
 #include "lvm-string.h"
-#include "filter.h"
 #include "toolcontext.h"
 #include "segtype.h"
 #include "pv_alloc.h"
diff --git a/lib/format_pool/disk_rep.c b/lib/format_pool/disk_rep.c
index f696463..fef0451 100644
--- a/lib/format_pool/disk_rep.c
+++ b/lib/format_pool/disk_rep.c
@@ -17,7 +17,6 @@
 #include "label.h"
 #include "metadata.h"
 #include "lvmcache.h"
-#include "filter.h"
 #include "xlate.h"
 #include "disk_rep.h"
 #include "toolcontext.h"


