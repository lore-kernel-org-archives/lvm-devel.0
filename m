From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 10 Jul 2022 23:22:25 +0000 (GMT)
Subject: main - cov: remove unused headers
Message-ID: <20220710232225.3180D385737B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5c463584f6b0541cc0144335b49afd2d94745928
Commit:        5c463584f6b0541cc0144335b49afd2d94745928
Parent:        493acb9195cef185b38ae4e4ffb84b984e5cc08c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 9 02:45:21 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 11 01:18:24 2022 +0200

cov: remove unused headers

---
 lib/device/online.c              | 1 -
 lib/label/hints.c                | 1 -
 libdaemon/server/daemon-server.c | 1 -
 libdm/libdm-deptree.c            | 1 -
 4 files changed, 4 deletions(-)

diff --git a/lib/device/online.c b/lib/device/online.c
index 024485bb3..79652d990 100644
--- a/lib/device/online.c
+++ b/lib/device/online.c
@@ -16,7 +16,6 @@
 #include "lib/misc/lib.h"
 #include "lib/commands/toolcontext.h"
 #include "lib/device/device.h"
-#include "lib/device/device_id.h"
 #include "lib/device/online.h"
 
 #include <dirent.h>
diff --git a/lib/label/hints.c b/lib/label/hints.c
index edce6f517..825788369 100644
--- a/lib/label/hints.c
+++ b/lib/label/hints.c
@@ -146,7 +146,6 @@
 #include "lib/label/hints.h"
 #include "lib/device/dev-type.h"
 #include "lib/device/device_id.h"
-#include "lib/device/online.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
diff --git a/libdaemon/server/daemon-server.c b/libdaemon/server/daemon-server.c
index 96cfc392e..dde7f5982 100644
--- a/libdaemon/server/daemon-server.c
+++ b/libdaemon/server/daemon-server.c
@@ -20,7 +20,6 @@
 #include <errno.h>
 #include <fcntl.h> /* help musl C */
 #include <pthread.h>
-#include <sys/file.h>
 #include <sys/stat.h>
 #include <sys/wait.h>
 #include <sys/time.h>
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index c14b6ef56..33a80cf4d 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -19,7 +19,6 @@
 #include "libdm/misc/dm-ioctl.h"
 
 #include <stdarg.h>
-#include <sys/param.h>
 #include <sys/utsname.h>
 
 #define MAX_TARGET_PARAMSIZE 500000

