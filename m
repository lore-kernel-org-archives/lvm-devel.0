From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Aug 2021 14:25:23 +0000 (GMT)
Subject: main - add missing sys/file.h include
Message-ID: <20210823142523.461AF385842C@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a6a8443a07f891246fa68bda9cc8e3937b6ddbb6
Commit:        a6a8443a07f891246fa68bda9cc8e3937b6ddbb6
Parent:        72af1cb0857afffd56f71847fcb9504d491c13e4
Author:        Alex Xu (Hello71) <alex_y_xu@yahoo.ca>
AuthorDate:    Mon Aug 23 09:24:45 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 23 09:24:45 2021 -0500

add missing sys/file.h include

required for LOCK_EX etc on musl
---
 lib/device/dev-cache.c | 1 +
 tools/lvmdevices.c     | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 4727ea652..d9227dfd5 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -29,6 +29,7 @@
 #include <unistd.h>
 #include <dirent.h>
 #include <locale.h>
+#include <sys/file.h>
 
 struct dev_iter {
 	struct btree_iter *current;
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 87c39eec4..73c33c932 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -17,6 +17,8 @@
 #include "lib/device/device_id.h"
 #include "lib/device/dev-type.h"
 
+#include <sys/file.h>
+
 static void _search_devs_for_pvids(struct cmd_context *cmd, struct dm_list *search_pvids, struct dm_list *found_devs)
 {
 	struct dev_iter *iter;


