From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:25 +0000 (UTC)
Subject: master - cleanup: drop unneeded included header files
Message-ID: <20120823124225.349D4A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=286cd2006bd6426f19d2dd312441755624ed260e
Commit:        286cd2006bd6426f19d2dd312441755624ed260e
Parent:        6d0abc6b484f1441c6a0a65fd3c82bc09e9d2104
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 16 19:24:09 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:20 2012 +0200

cleanup: drop unneeded included header files

This headers were not resolving anything used for compiled .c files.
Remove unused util.c file.
---
 daemons/clvmd/clvmd-command.c                      |    3 --
 daemons/dmeventd/dmeventd.c                        |    2 -
 daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c       |    2 -
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |    2 -
 daemons/dmeventd/plugins/thin/dmeventd_thin.c      |    2 -
 daemons/lvmetad/lvmetad-core.c                     |    1 -
 lib/Makefile.in                                    |    1 -
 lib/activate/dev_manager.c                         |    1 -
 lib/cache/lvmetad.c                                |    1 -
 lib/config/config.c                                |    2 -
 lib/device/dev-swap.c                              |    2 -
 lib/error/errseg.c                                 |    5 ----
 lib/filters/filter-md.c                            |    1 -
 lib/filters/filter-sysfs.c                         |    1 -
 lib/format1/import-export.c                        |    1 -
 lib/format_pool/import_export.c                    |    1 -
 lib/format_pool/pool_label.c                       |    1 -
 lib/format_text/archive.c                          |    1 -
 lib/format_text/archiver.c                         |    1 -
 lib/format_text/format-text.c                      |    2 -
 lib/format_text/import.c                           |    3 --
 lib/format_text/text_label.c                       |    1 -
 lib/freeseg/freeseg.c                              |   10 ---------
 lib/log/log.c                                      |    3 --
 lib/metadata/merge.c                               |    1 -
 lib/metadata/metadata.c                            |    1 -
 lib/metadata/mirror.c                              |    1 -
 lib/metadata/pv_manip.c                            |    2 -
 lib/metadata/pv_map.c                              |    1 -
 lib/metadata/raid_manip.c                          |    3 --
 lib/mirror/mirrored.c                              |    1 -
 lib/misc/lvm-file.c                                |    1 -
 lib/misc/lvm-globals.c                             |    1 -
 lib/misc/sharedlib.c                               |    2 -
 lib/misc/util.c                                    |   22 --------------------
 lib/replicator/replicator.c                        |    3 --
 lib/report/report.c                                |    1 -
 lib/thin/thin.c                                    |    2 -
 lib/unknown/unknown.c                              |    6 -----
 lib/zero/zero.c                                    |    5 ----
 libdm/libdm-deptree.c                              |    1 -
 tools/dmsetup.c                                    |    1 -
 tools/lvcreate.c                                   |    1 -
 tools/lvmcmdlib.c                                  |    3 --
 tools/lvmcmdline.c                                 |    3 --
 tools/toollib.c                                    |    4 ---
 tools/vgreduce.c                                   |    1 -
 47 files changed, 0 insertions(+), 117 deletions(-)

diff --git a/daemons/clvmd/clvmd-command.c b/daemons/clvmd/clvmd-command.c
index 0494ee4..c5cd461 100644
--- a/daemons/clvmd/clvmd-command.c
+++ b/daemons/clvmd/clvmd-command.c
@@ -51,9 +51,6 @@
 */
 
 #include "clvmd-common.h"
-
-#include <pthread.h>
-
 #include "clvmd-comms.h"
 #include "clvm.h"
 #include "clvmd.h"
diff --git a/daemons/dmeventd/dmeventd.c b/daemons/dmeventd/dmeventd.c
index 2ffe7f4..13148c3 100644
--- a/daemons/dmeventd/dmeventd.c
+++ b/daemons/dmeventd/dmeventd.c
@@ -39,8 +39,6 @@
 #include <arpa/inet.h>		/* for htonl, ntohl */
 
 #ifdef linux
-#  include <malloc.h>
-
 /*
  * Kernel version 2.6.36 and higher has
  * new OOM killer adjustment interface.
diff --git a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
index 1bde50e..5d5a46b 100644
--- a/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
+++ b/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c
@@ -16,8 +16,6 @@
 #include "log.h"
 
 #include "lvm2cmd.h"
-#include "errors.h"
-#include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
 #include <pthread.h>
diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index 0c59e34..205218a 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -19,8 +19,6 @@
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
-#include "lvm-string.h"
-
 #include <sys/wait.h>
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 4bdad23..5a408a8 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -19,8 +19,6 @@
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
-#include "lvm-string.h"
-
 #include <sys/wait.h>
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index d06ff46..3ca3fd5 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -21,7 +21,6 @@
 
 #include <assert.h>
 #include <pthread.h>
-#include <malloc.h>
 #include <stdint.h>
 #include <unistd.h>
 
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 5252658..82f700b 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -103,7 +103,6 @@ SOURCES =\
 	misc/lvm-string.c \
 	misc/lvm-wrappers.c \
 	misc/lvm-percent.c \
-	misc/util.c \
 	mm/memlock.c \
 	report/properties.c \
 	report/report.c \
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 40b0edc..122741c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -14,7 +14,6 @@
  */
 
 #include "lib.h"
-#include "str_list.h"
 #include "dev_manager.h"
 #include "lvm-string.h"
 #include "fs.h"
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 3384ec4..bb949b5 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -20,7 +20,6 @@
 #include "lvmcache.h"
 #include "lvmetad-client.h"
 #include "format-text.h" // TODO for disk_locn, used as a DA representation
-#include "filter.h"
 
 static int _using_lvmetad = 0;
 static daemon_handle _lvmetad;
diff --git a/lib/config/config.c b/lib/config/config.c
index 60ae6c8..a7bda97 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -21,14 +21,12 @@
 #include "device.h"
 #include "str_list.h"
 #include "toolcontext.h"
-#include "lvm-string.h"
 #include "lvm-file.h"
 
 #include <sys/stat.h>
 #include <sys/mman.h>
 #include <unistd.h>
 #include <fcntl.h>
-#include <ctype.h>
 #include <assert.h>
 
 struct config_file {
diff --git a/lib/device/dev-swap.c b/lib/device/dev-swap.c
index f742bfe..346b60a 100644
--- a/lib/device/dev-swap.c
+++ b/lib/device/dev-swap.c
@@ -14,8 +14,6 @@
 
 #include "lib.h"
 #include "metadata.h"
-#include "xlate.h"
-#include "filter.h"
 
 #ifdef linux
 
diff --git a/lib/error/errseg.c b/lib/error/errseg.c
index a2fbc4d..179f1a6 100644
--- a/lib/error/errseg.c
+++ b/lib/error/errseg.c
@@ -16,15 +16,10 @@
 #include "toolcontext.h"
 #include "segtype.h"
 #include "display.h"
-#include "text_export.h"
-#include "text_import.h"
 #include "config.h"
 #include "str_list.h"
-#include "targets.h"
-#include "lvm-string.h"
 #include "activate.h"
 #include "str_list.h"
-#include "metadata.h"
 
 static const char *_errseg_name(const struct lv_segment *seg)
 {
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index 5cd8fb2..e3e88f1 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -15,7 +15,6 @@
 
 #include "lib.h"
 #include "filter-md.h"
-#include "metadata.h"
 
 #ifdef linux
 
diff --git a/lib/filters/filter-sysfs.c b/lib/filters/filter-sysfs.c
index 112e77c..ebd16a2 100644
--- a/lib/filters/filter-sysfs.c
+++ b/lib/filters/filter-sysfs.c
@@ -14,7 +14,6 @@
 
 #include "lib.h"
 #include "filter-sysfs.h"
-#include "lvm-string.h"
 
 #ifdef linux
 
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 1370d12..5c5d890 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -25,7 +25,6 @@
 #include "segtype.h"
 #include "pv_alloc.h"
 #include "display.h"
-#include "lvmcache.h"
 #include "metadata.h"
 
 #include <time.h>
diff --git a/lib/format_pool/import_export.c b/lib/format_pool/import_export.c
index f7f619e..480fa1c 100644
--- a/lib/format_pool/import_export.c
+++ b/lib/format_pool/import_export.c
@@ -16,7 +16,6 @@
 #include "lib.h"
 #include "label.h"
 #include "metadata.h"
-#include "lvmcache.h"
 #include "disk_rep.h"
 #include "sptype_names.h"
 #include "lv_alloc.h"
diff --git a/lib/format_pool/pool_label.c b/lib/format_pool/pool_label.c
index 2d34e60..7059b98 100644
--- a/lib/format_pool/pool_label.c
+++ b/lib/format_pool/pool_label.c
@@ -16,7 +16,6 @@
 #include "lib.h"
 #include "label.h"
 #include "metadata.h"
-#include "xlate.h"
 #include "disk_rep.h"
 #include "pool_label.h"
 
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index c961150..18fe577 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -25,7 +25,6 @@
 #include <dirent.h>
 #include <unistd.h>
 #include <sys/stat.h>
-#include <sys/file.h>
 #include <fcntl.h>
 #include <time.h>
 
diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 13d242a..ccefb4c 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -16,7 +16,6 @@
 #include "lib.h"
 #include "archiver.h"
 #include "format-text.h"
-#include "lvm-file.h"
 #include "lvm-string.h"
 #include "lvmcache.h"
 #include "toolcontext.h"
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index aea03c9..d706c2b 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -27,12 +27,10 @@
 #include "crc.h"
 #include "xlate.h"
 #include "label.h"
-#include "memlock.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
 
 #include <unistd.h>
-#include <sys/file.h>
 #include <sys/param.h>
 #include <limits.h>
 #include <dirent.h>
diff --git a/lib/format_text/import.c b/lib/format_text/import.c
index 3d2f496..8a05ca9 100644
--- a/lib/format_text/import.c
+++ b/lib/format_text/import.c
@@ -16,9 +16,6 @@
 #include "lib.h"
 #include "metadata.h"
 #include "import-export.h"
-#include "display.h"
-#include "toolcontext.h"
-#include "lvmcache.h"
 
 /* FIXME Use tidier inclusion method */
 static struct text_vg_version_ops *(_text_vsn_list[2]);
diff --git a/lib/format_text/text_label.c b/lib/format_text/text_label.c
index 7b2659c..f53aa0d 100644
--- a/lib/format_text/text_label.c
+++ b/lib/format_text/text_label.c
@@ -19,7 +19,6 @@
 #include "label.h"
 #include "xlate.h"
 #include "lvmcache.h"
-#include "lvmetad.h"
 
 #include <sys/stat.h>
 #include <fcntl.h>
diff --git a/lib/freeseg/freeseg.c b/lib/freeseg/freeseg.c
index 6fbad7e..1dce243 100644
--- a/lib/freeseg/freeseg.c
+++ b/lib/freeseg/freeseg.c
@@ -15,16 +15,6 @@
 #include "lib.h"
 #include "toolcontext.h"
 #include "segtype.h"
-#include "display.h"
-#include "text_export.h"
-#include "text_import.h"
-#include "config.h"
-#include "str_list.h"
-#include "targets.h"
-#include "lvm-string.h"
-#include "activate.h"
-#include "str_list.h"
-#include "metadata.h"
 
 static const char *_freeseg_name(const struct lv_segment *seg)
 {
diff --git a/lib/log/log.c b/lib/log/log.c
index c36f1e7..d50cb4a 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -16,10 +16,7 @@
 #include "lib.h"
 #include "device.h"
 #include "memlock.h"
-#include "lvm-string.h"
-#include "lvm-file.h"
 #include "defaults.h"
-#include "config.h"
 
 #include <stdarg.h>
 #include <syslog.h>
diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 4183046..cc906d1 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -15,7 +15,6 @@
 
 #include "lib.h"
 #include "metadata.h"
-#include "toolcontext.h"
 #include "lv_alloc.h"
 #include "pv_alloc.h"
 #include "str_list.h"
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c14125a..dd029ac 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -30,7 +30,6 @@
 #include "locking.h"
 #include "archiver.h"
 #include "defaults.h"
-#include "filter-persistent.h"
 
 #include <math.h>
 #include <sys/param.h>
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 0997c58..ac885d6 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -24,7 +24,6 @@
 #include "lvm-string.h"
 #include "str_list.h"
 #include "locking.h"	/* FIXME Should not be used in this file */
-#include "memlock.h"
 
 #include "defaults.h" /* FIXME: should this be defaults.h? */
 
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index e3fe272..e85a2bc 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -17,9 +17,7 @@
 #include "metadata.h"
 #include "pv_alloc.h"
 #include "toolcontext.h"
-#include "archiver.h"
 #include "locking.h"
-#include "lvmcache.h"
 #include "defaults.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
diff --git a/lib/metadata/pv_map.c b/lib/metadata/pv_map.c
index 29d235f..48a601e 100644
--- a/lib/metadata/pv_map.c
+++ b/lib/metadata/pv_map.c
@@ -15,7 +15,6 @@
 
 #include "lib.h"
 #include "pv_map.h"
-#include "pv_alloc.h"
 
 #include <assert.h>
 
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index a3d6709..c86bb9a 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -17,12 +17,9 @@
 #include "toolcontext.h"
 #include "segtype.h"
 #include "display.h"
-#include "archiver.h"
 #include "activate.h"
 #include "lv_alloc.h"
 #include "lvm-string.h"
-#include "str_list.h"
-#include "memlock.h"
 
 #define RAID_REGION_SIZE 1024
 
diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 28e4a1d..7ce8475 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -25,7 +25,6 @@
 #include "lvm-string.h"
 #include "targets.h"
 #include "activate.h"
-#include "sharedlib.h"
 #include "str_list.h"
 
 #include <sys/utsname.h>
diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index d71737b..b8e49cb 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -15,7 +15,6 @@
 
 #include "lib.h"
 #include "lvm-file.h"
-#include "lvm-string.h"
 
 #include <unistd.h>
 #include <sys/stat.h>
diff --git a/lib/misc/lvm-globals.c b/lib/misc/lvm-globals.c
index e1512f9..1c72f85 100644
--- a/lib/misc/lvm-globals.c
+++ b/lib/misc/lvm-globals.c
@@ -17,7 +17,6 @@
 #include "device.h"
 #include "memlock.h"
 #include "lvm-string.h"
-#include "lvm-file.h"
 #include "defaults.h"
 #include "metadata-exported.h"
 
diff --git a/lib/misc/sharedlib.c b/lib/misc/sharedlib.c
index 48fa522..4c2d178 100644
--- a/lib/misc/sharedlib.c
+++ b/lib/misc/sharedlib.c
@@ -15,9 +15,7 @@
 
 #include "lib.h"
 #include "config.h"
-#include "lvm-string.h"
 #include "sharedlib.h"
-#include "toolcontext.h"
 
 #include <limits.h>
 #include <sys/stat.h>
diff --git a/lib/misc/util.c b/lib/misc/util.c
deleted file mode 100644
index 75c7afa..0000000
--- a/lib/misc/util.c
+++ /dev/null
@@ -1,22 +0,0 @@
-/*
- * Copyright (C) 2007 Red Hat, Inc. All rights reserved.
- *
- * This file is part of LVM2.
- *
- * This copyrighted material is made available to anyone wishing to use,
- * modify, copy, or redistribute it subject to the terms and conditions
- * of the GNU Lesser General Public License v.2.1.
- *
- * You should have received a copy of the GNU Lesser General Public License
- * along with this program; if not, write to the Free Software Foundation,
- * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
- */
-
-/*
- * Return the address of the last file name component of NAME.
- * If NAME ends in a slash, return the empty string.
- */
-
-#include "lib.h"
-
-/* empty for now.  */
diff --git a/lib/replicator/replicator.c b/lib/replicator/replicator.c
index 2571e81..76bdbca 100644
--- a/lib/replicator/replicator.c
+++ b/lib/replicator/replicator.c
@@ -17,12 +17,9 @@
 #include "metadata.h"
 #include "segtype.h"
 #include "text_export.h"
-#include "text_import.h"
-#include "config.h"
 #include "activate.h"
 #include "str_list.h"
 #ifdef DMEVENTD
-#  include "sharedlib.h"
 #  include "libdevmapper-event.h"
 #endif
 
diff --git a/lib/report/report.c b/lib/report/report.c
index a8553d2..eeca282 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -21,7 +21,6 @@
 #include "display.h"
 #include "activate.h"
 #include "segtype.h"
-#include "str_list.h"
 #include "lvmcache.h"
 
 #include <stddef.h> /* offsetof() */
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index d95b68e..8aa8121 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -17,14 +17,12 @@
 #include "metadata.h"
 #include "segtype.h"
 #include "text_export.h"
-#include "text_import.h"
 #include "config.h"
 #include "activate.h"
 #include "str_list.h"
 #include "defaults.h"
 
 #ifdef DMEVENTD
-#  include "sharedlib.h"
 #  include "libdevmapper-event.h"
 #endif
 
diff --git a/lib/unknown/unknown.c b/lib/unknown/unknown.c
index 8f5c809..f2a65eb 100644
--- a/lib/unknown/unknown.c
+++ b/lib/unknown/unknown.c
@@ -17,14 +17,8 @@
 #include "segtype.h"
 #include "display.h"
 #include "text_export.h"
-#include "text_import.h"
 #include "config.h"
-#include "str_list.h"
-#include "targets.h"
-#include "lvm-string.h"
 #include "activate.h"
-#include "str_list.h"
-#include "metadata.h"
 
 static const char *_unknown_name(const struct lv_segment *seg)
 {
diff --git a/lib/zero/zero.c b/lib/zero/zero.c
index 9611e9b..473daa0 100644
--- a/lib/zero/zero.c
+++ b/lib/zero/zero.c
@@ -16,14 +16,9 @@
 #include "toolcontext.h"
 #include "segtype.h"
 #include "display.h"
-#include "text_export.h"
-#include "text_import.h"
 #include "config.h"
 #include "str_list.h"
-#include "targets.h"
-#include "lvm-string.h"
 #include "activate.h"
-#include "metadata.h"
 
 static const char *_zero_name(const struct lv_segment *seg)
 {
diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 031ce5e..503b240 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -16,7 +16,6 @@
 #include "libdm-targets.h"
 #include "libdm-common.h"
 #include "kdev_t.h"
-#include "dm-ioctl.h"
 
 #include <stdarg.h>
 #include <sys/param.h>
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 7d1f2a1..0734ded 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -30,7 +30,6 @@
 #include <dirent.h>
 #include <errno.h>
 #include <unistd.h>
-#include <libgen.h>
 #include <sys/wait.h>
 #include <unistd.h>
 #include <sys/param.h>
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 6aecf1d..769ac8c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -14,7 +14,6 @@
  */
 
 #include "tools.h"
-#include "lv_alloc.h"
 
 #include <fcntl.h>
 
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 47bf1c8..6b641c2 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -17,13 +17,10 @@
 #include "lvm2cmdline.h"
 #include "label.h"
 #include "memlock.h"
-#include "lvm-version.h"
 
 #include "lvm2cmd.h"
 
 #include <signal.h>
-#include <syslog.h>
-#include <libgen.h>
 #include <sys/stat.h>
 #include <time.h>
 #include <sys/resource.h>
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 9964817..eea874e 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -19,12 +19,9 @@
 #include "lvm-version.h"
 
 #include "stub.h"
-#include "lvm2cmd.h"
 #include "last-path-component.h"
 
 #include <signal.h>
-#include <syslog.h>
-#include <libgen.h>
 #include <sys/stat.h>
 #include <time.h>
 #include <sys/resource.h>
diff --git a/tools/toollib.c b/tools/toollib.c
index 0f6810b..d6fc951 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -14,11 +14,7 @@
  */
 
 #include "tools.h"
-#include "lv_alloc.h"
-#include "xlate.h"
-
 #include <sys/stat.h>
-#include <sys/wait.h>
 
 const char *command_name(struct cmd_context *cmd)
 {
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index ab448e0..9696651 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -14,7 +14,6 @@
  */
 
 #include "tools.h"
-#include "lv_alloc.h"
 
 static int _remove_pv(struct volume_group *vg, struct pv_list *pvl, int silent)
 {


