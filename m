From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:41 +0000 (GMT)
Subject: main - cov: remove unnecessary headers
Message-ID: <20210310003641.1DC483857C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d95c0e977cb69b04467d650a8be9b0efa2c71688
Commit:        d95c0e977cb69b04467d650a8be9b0efa2c71688
Parent:        a6075fe2f259c4b2abd946cf06f9b507f9a7a49e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 15:04:22 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:29:44 2021 +0100

cov: remove unnecessary headers

---
 lib/device/device_id.c  | 1 -
 tools/command.c         | 1 -
 tools/lvmdevices.c      | 1 -
 tools/vgimportclone.c   | 1 -
 tools/vgimportdevices.c | 1 -
 5 files changed, 5 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 74edae05c..1c4ba78f6 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -18,7 +18,6 @@
 #include "lib/device/device.h"
 #include "lib/device/device_id.h"
 #include "lib/device/dev-type.h"
-#include "lib/device/device-types.h"
 #include "lib/label/label.h"
 #include "lib/metadata/metadata.h"
 #include "lib/format_text/layout.h"
diff --git a/tools/command.c b/tools/command.c
index 282c9fa43..81720acf1 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -21,7 +21,6 @@
 #include <sys/wait.h>
 #include <fcntl.h>
 #include <stdio.h>
-#include <errno.h>
 #include <string.h>
 #include <stdlib.h>
 #include <stddef.h>
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 42fa189c3..b67db7464 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -14,7 +14,6 @@
 
 #include "tools.h"
 #include "lib/cache/lvmcache.h"
-#include "lib/filters/filter.h"
 #include "lib/device/device_id.h"
 
 static void _search_devs_for_pvids(struct cmd_context *cmd, struct dm_list *search_pvids, struct dm_list *found_devs)
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 18f10f49a..1e6bb2d69 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -14,7 +14,6 @@
 
 #include "tools.h"
 #include "lib/cache/lvmcache.h"
-#include "lib/filters/filter.h"
 #include "lib/device/device_id.h"
 
 struct vgimportclone_params {
diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
index b7b363369..88435af92 100644
--- a/tools/vgimportdevices.c
+++ b/tools/vgimportdevices.c
@@ -14,7 +14,6 @@
 
 #include "tools.h"
 #include "lib/cache/lvmcache.h"
-#include "lib/filters/filter.h"
 #include "lib/device/device_id.h"
 
 struct vgimportdevices_params {


