From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:18 +0000 (GMT)
Subject: main - cov: make it aware we need these headers for muslC
Message-ID: <20210913103618.471BF3858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3b2a4e3e6f081002ab92f5f78326d2c1dfa879bf
Commit:        3b2a4e3e6f081002ab92f5f78326d2c1dfa879bf
Parent:        a14371e4952f7a1b079a795c13927cea2eb196b6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 9 23:06:45 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

cov: make it aware we need these headers for muslC

---
 daemons/dmeventd/plugins/vdo/dmeventd_vdo.c | 1 +
 lib/device/dev-cache.c                      | 1 +
 lib/report/report.c                         | 3 +++
 tools/lvmcmdline.c                          | 1 +
 tools/lvmdevices.c                          | 1 +
 5 files changed, 7 insertions(+)

diff --git a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
index 399b737ee..d3f1ba4b9 100644
--- a/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
+++ b/daemons/dmeventd/plugins/vdo/dmeventd_vdo.c
@@ -22,6 +22,7 @@
  * in runtime we are linked agains systems libdm 'older' library
  * which does not provide this symbol and plugin fails to load
  */
+/* coverity[unnecessary_header] used for parsing */
 #include "device_mapper/vdo/status.c"
 
 #include <sys/wait.h>
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 3918afba0..0d1d4e36f 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -29,6 +29,7 @@
 #include <unistd.h>
 #include <dirent.h>
 #include <locale.h>
+/* coverity[unnecessary_header] needed for MuslC */
 #include <sys/file.h>
 
 struct dev_iter {
diff --git a/lib/report/report.c b/lib/report/report.c
index efe103f43..a28744a49 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -47,6 +47,7 @@ static uint32_t _log_seqnum = 1;
  */
 #define FIELD(type, strct, sorttype, head, field_name, width, func, id, desc, writeable) field_ ## id,
 enum {
+/* coverity[unnecessary_header] */
 #include "columns.h"
 };
 #undef FIELD
@@ -4340,6 +4341,7 @@ typedef struct label type_label;
 typedef dev_known_type_t type_devtype;
 
 static const struct dm_report_field_type _fields[] = {
+/* coverity[unnecessary_header] */
 #include "columns.h"
 {0, 0, 0, 0, "", "", NULL, NULL},
 };
@@ -4350,6 +4352,7 @@ static const struct dm_report_field_type _devtypes_fields[] = {
 };
 
 static const struct dm_report_field_type _log_fields[] = {
+/* coverity[unnecessary_header] */
 #include "columns-cmdlog.h"
 {0, 0, 0, 0, "", "", NULL, NULL},
 };
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 1fb593d84..f9eab8ec8 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -22,6 +22,7 @@
 #include "lib/locking/lvmlockd.h"
 #include "lib/datastruct/str_list.h"
 
+/* coverity[unnecessary_header] */
 #include "stub.h"
 #include "lib/misc/last-path-component.h"
 
diff --git a/tools/lvmdevices.c b/tools/lvmdevices.c
index 73c33c932..367536d6a 100644
--- a/tools/lvmdevices.c
+++ b/tools/lvmdevices.c
@@ -17,6 +17,7 @@
 #include "lib/device/device_id.h"
 #include "lib/device/dev-type.h"
 
+/* coverity[unnecessary_header] needed for MuslC */
 #include <sys/file.h>
 
 static void _search_devs_for_pvids(struct cmd_context *cmd, struct dm_list *search_pvids, struct dm_list *found_devs)


