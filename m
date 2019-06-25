From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 25 Jun 2019 11:45:49 -0400
Subject: stable-2.02 - cov: remove unused headers
Message-ID: <201906251545.x5PFjnCS013798@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b62c0787debeb3a66a2e3658d1edb8a61a6f247b
Commit:        b62c0787debeb3a66a2e3658d1edb8a61a6f247b
Parent:        ff2bf113604882a0f21f118a5bb16076399bb67a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 25 15:19:07 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 25 17:34:56 2019 +0200

cov: remove unused headers

---
 lib/device/bcache.c           |    1 -
 lib/device/dev-io.c           |    1 -
 lib/device/dev-type.c         |    1 -
 lib/format_text/archiver.c    |    1 -
 lib/format_text/format-text.c |    1 -
 lib/label/label.c             |    1 -
 lib/metadata/vg.c             |    1 -
 lib/misc/lvm-file.c           |    1 -
 tools/lvmcmdline.c            |    1 -
 9 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index ccf0046..261164e 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -29,7 +29,6 @@
 #include <libaio.h>
 #include <unistd.h>
 #include <linux/fs.h>
-#include <sys/ioctl.h>
 #include <sys/user.h>
 
 #define SECTOR_SHIFT 9L
diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 4590232..99ff803 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -17,7 +17,6 @@
 #include "device.h"
 #include "metadata.h"
 #include "memlock.h"
-#include "locking.h"
 
 #include <limits.h>
 #include <sys/stat.h>
diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index ce4a05b..14a28dc 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -17,7 +17,6 @@
 #include "xlate.h"
 #include "config.h"
 #include "metadata.h"
-#include "bcache.h"
 #include "label.h"
 
 #include <libgen.h>
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index c8aeb47..467968a 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -18,7 +18,6 @@
 #include "format-text.h"
 #include "lvm-string.h"
 #include "lvmcache.h"
-#include "lvmetad.h"
 #include "memlock.h"
 #include "toolcontext.h"
 #include "locking.h"
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index a09c349..f39051c 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -29,7 +29,6 @@
 #include "label.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
-#include "memlock.h"
 
 #include <unistd.h>
 #include <sys/param.h>
diff --git a/lib/label/label.c b/lib/label/label.c
index 83b4d99..d6212b1 100644
--- a/lib/label/label.c
+++ b/lib/label/label.c
@@ -26,7 +26,6 @@
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <unistd.h>
-#include <sys/time.h>
 
 int use_full_md_check;
 
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index b8b1501..42801b9 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -18,7 +18,6 @@
 #include "display.h"
 #include "activate.h"
 #include "toolcontext.h"
-#include "lvmcache.h"
 #include "archiver.h"
 #include "lvmetad.h"
 
diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index 36caaa7..7b789e5 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -14,7 +14,6 @@
  */
 
 #include "lib.h"
-#include "lvm-file.h"
 
 #include <unistd.h>
 #include <sys/stat.h>
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index a9c3e41..0840c65 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -19,7 +19,6 @@
 #include "label.h"
 #include "lvm-version.h"
 #include "lvmlockd.h"
-#include "lvmetad-client.h"
 
 #include "stub.h"
 #include "last-path-component.h"


