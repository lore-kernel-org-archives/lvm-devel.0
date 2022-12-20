From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Dec 2022 15:23:34 +0000 (GMT)
Subject: main - cov: remove unused header files
Message-ID: <20221220152334.40FF23857B9B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=44a2f2df9281ac0f5aef67d5f3c32fc2ee6ad0e9
Commit:        44a2f2df9281ac0f5aef67d5f3c32fc2ee6ad0e9
Parent:        b6b1c19365d20d926d8aa39bf591731a7f9bb75a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 20 13:54:59 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 20 15:04:36 2022 +0100

cov: remove unused header files

---
 lib/device/filesystem.c | 1 -
 lib/device/online.c     | 1 -
 lib/device/parse_vpd.c  | 1 -
 3 files changed, 3 deletions(-)

diff --git a/lib/device/filesystem.c b/lib/device/filesystem.c
index bdc230175..61e4d805e 100644
--- a/lib/device/filesystem.c
+++ b/lib/device/filesystem.c
@@ -22,7 +22,6 @@
 
 #include <dirent.h>
 #include <mntent.h>
-#include <sys/ioctl.h>
 
 static const char *_lvresize_fs_helper_path;
 
diff --git a/lib/device/online.c b/lib/device/online.c
index 7ffe14b18..b97b71d92 100644
--- a/lib/device/online.c
+++ b/lib/device/online.c
@@ -17,7 +17,6 @@
 #include "lib/commands/toolcontext.h"
 #include "lib/device/device.h"
 #include "lib/device/online.h"
-#include "lib/metadata/metadata.h"
 
 #include <dirent.h>
 
diff --git a/lib/device/parse_vpd.c b/lib/device/parse_vpd.c
index 23b0c6efa..bea8834d4 100644
--- a/lib/device/parse_vpd.c
+++ b/lib/device/parse_vpd.c
@@ -26,7 +26,6 @@
 #include <string.h>
 #include <inttypes.h>
 #include <sys/types.h>
-#include <sys/ioctl.h>
 #include <sys/stat.h>
 #include <fcntl.h>
 #include <ctype.h>

