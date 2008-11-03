From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Nov 2008 19:00:04 -0000
Subject: LVM2 ./WHATS_NEW include/.symlinks lib/Makefil ...
Message-ID: <20081103190004.19431.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-03 18:59:59

Modified files:
	.              : WHATS_NEW 
	include        : .symlinks 
	lib            : Makefile.in 
	lib/display    : display.c 
	lib/log        : lvm-logging.h 
	lib/misc       : lib.h lvm-globals.h 
	libdm          : Makefile.in libdm-common.c libdm-deptree.c 
	                 libdm-file.c libdm-report.c libdm-string.c 
	libdm/datastruct: bitset.c hash.c 
	libdm/ioctl    : libdm-iface.c 
	libdm/mm       : dbg_malloc.c pool-debug.c pool-fast.c pool.c 
	libdm/regex    : matcher.c parse_rx.c ttree.c 
Added files:
	libdm/misc     : dmlib.h 

Log message:
	more tweaking to get things to compile - dmlib.h for log fns, list.h

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.989&r2=1.990
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.52&r2=1.53
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.92&r2=1.93
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/lvm-logging.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lib.h.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lvm-globals.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/Makefile.in.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.60&r2=1.61
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-file.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-string.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/bitset.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/datastruct/hash.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dmlib.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/dbg_malloc.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-debug.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool-fast.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/matcher.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/parse_rx.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/regex/ttree.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2008/11/03 16:26:26	1.989
+++ LVM2/WHATS_NEW	2008/11/03 18:59:58	1.990
@@ -1,5 +1,6 @@
 Version 2.02.43 -
 ===================================
+  Move list.c into libdevmapper and rename functions.
   Rename a couple of variables that matched function names.
   Use simplified x.y.z version number in libdevmapper.pc.
   Merge device-mapper into the lvm2 tree.
--- LVM2/include/.symlinks	2008/10/31 22:41:51	1.52
+++ LVM2/include/.symlinks	2008/11/03 18:59:58	1.53
@@ -8,7 +8,6 @@
 ../lib/config/config.h
 ../lib/config/defaults.h
 ../lib/datastruct/btree.h
-../lib/datastruct/list.h
 ../lib/datastruct/lvm-types.h
 ../lib/datastruct/str_list.h
 ../lib/device/dev-cache.h
@@ -52,8 +51,10 @@
 ../lib/report/report.h
 ../lib/uuid/uuid.h
 ../libdm/libdevmapper.h
+../libdm/datastruct/list.h
 ../libdm/misc/dm-ioctl.h
 ../libdm/misc/dm-logging.h
+../libdm/misc/dmlib.h
 ../libdm/misc/kdev_t.h
 ../po/pogen.h
 ../tools/version.h
--- LVM2/lib/Makefile.in	2008/10/30 17:27:28	1.86
+++ LVM2/lib/Makefile.in	2008/11/03 18:59:58	1.87
@@ -38,7 +38,6 @@
 	commands/toolcontext.c \
 	config/config.c \
 	datastruct/btree.c \
-	datastruct/list.c \
 	datastruct/str_list.c \
 	device/dev-cache.c \
 	device/dev-io.c \
--- LVM2/lib/display/display.c	2008/09/19 06:41:58	1.92
+++ LVM2/lib/display/display.c	2008/11/03 18:59:58	1.93
@@ -572,7 +572,7 @@
 
 void vgdisplay_full(const struct volume_group *vg)
 {
-	uint32_t access;
+	uint32_t access_str;
 	uint32_t active_pvs;
 	uint32_t lv_count = 0;
 	struct lv_list *lvl;
@@ -589,12 +589,12 @@
 			  list_size(&vg->fid->metadata_areas));
 		log_print("Metadata Sequence No  %d", vg->seqno);
 	}
-	access = vg->status & (LVM_READ | LVM_WRITE);
+	access_str = vg->status & (LVM_READ | LVM_WRITE);
 	log_print("VG Access             %s%s%s%s",
-		  access == (LVM_READ | LVM_WRITE) ? "read/write" : "",
-		  access == LVM_READ ? "read" : "",
-		  access == LVM_WRITE ? "write" : "",
-		  access == 0 ? "error" : "");
+		  access_str == (LVM_READ | LVM_WRITE) ? "read/write" : "",
+		  access_str == LVM_READ ? "read" : "",
+		  access_str == LVM_WRITE ? "write" : "",
+		  access_str == 0 ? "error" : "");
 	log_print("VG Status             %s%sresizable",
 		  vg->status & EXPORTED_VG ? "exported/" : "",
 		  vg->status & RESIZEABLE_VG ? "" : "NOT ");
@@ -658,7 +658,7 @@
 	uint32_t active_pvs;
 	uint32_t lv_count;
 	struct lv_list *lvl;
-	const char *access;
+	const char *access_str;
 	char uuid[64] __attribute((aligned(8)));
 
 	active_pvs = vg->pv_count - vg_missing_pv_count(vg);
@@ -669,16 +669,16 @@
 
 	switch (vg->status & (LVM_READ | LVM_WRITE)) {
 		case LVM_READ | LVM_WRITE:
-			access = "r/w";
+			access_str = "r/w";
 			break;
 		case LVM_READ:
-			access = "r";
+			access_str = "r";
 			break;
 		case LVM_WRITE:
-			access = "w";
+			access_str = "w";
 			break;
 		default:
-			access = "";
+			access_str = "";
 	}
 
 	if (!id_write_format(&vg->id, uuid, sizeof(uuid))) {
@@ -689,7 +689,7 @@
 	log_print("%s:%s:%d:-1:%u:%u:%u:-1:%u:%u:%u:%" PRIu64 ":%" PRIu32
 		  ":%u:%u:%u:%s",
 		vg->name,
-		access,
+		access_str,
 		vg->status,
 		/* internal volume group number; obsolete */
 		vg->max_lv,
--- LVM2/lib/log/lvm-logging.h	2008/10/30 17:27:27	1.1
+++ LVM2/lib/log/lvm-logging.h	2008/11/03 18:59:58	1.2
@@ -16,8 +16,6 @@
 #ifndef _LVM_LOGGING_H
 #define _LVM_LOGGING_H
 
-#include "lvm-globals.h"
-
 void print_log(int level, const char *file, int line, const char *format, ...)
     __attribute__ ((format(printf, 4, 5)));
 
--- LVM2/lib/misc/lib.h	2008/11/01 02:19:17	1.15
+++ LVM2/lib/misc/lib.h	2008/11/03 18:59:58	1.16
@@ -27,11 +27,17 @@
 
 #include "intl.h"
 #include "libdevmapper.h"
-#include "lvm-logging.h"
-#include "lvm-types.h"
+#include "lvm-globals.h"
 #include "lvm-wrappers.h"
+#include "lvm-types.h"
 #include "util.h"
 
+#ifdef DM
+#  include "dm-logging.h"
+#else
+#  include "lvm-logging.h"
+#endif
+
 #include <errno.h>
 #include <stdio.h>
 #include <stdlib.h>
--- LVM2/lib/misc/lvm-globals.h	2008/10/30 17:40:00	1.1
+++ LVM2/lib/misc/lvm-globals.h	2008/11/03 18:59:58	1.2
@@ -35,7 +35,7 @@
 void init_mirror_in_sync(int in_sync);
 void init_dmeventd_monitor(int reg);
 void init_ignore_suspended_devices(int ignore);
-void init_error_message_produced(int error_message_produced);
+void init_error_message_produced(int produced);
 
 void set_cmd_name(const char *cmd_name);
 
--- LVM2/libdm/Makefile.in	2008/11/01 02:19:18	1.39
+++ LVM2/libdm/Makefile.in	2008/11/03 18:59:59	1.40
@@ -20,6 +20,7 @@
 SOURCES =\
 	datastruct/bitset.c \
 	datastruct/hash.c \
+	datastruct/list.c \
 	libdm-common.c \
 	libdm-file.c \
 	libdm-deptree.c \
--- LVM2/libdm/libdm-common.c	2008/11/01 02:19:18	1.60
+++ LVM2/libdm/libdm-common.c	2008/11/03 18:59:59	1.61
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 #include "libdm-targets.h"
 #include "libdm-common.h"
 #include "list.h"
--- LVM2/libdm/libdm-deptree.c	2008/11/01 02:19:18	1.44
+++ LVM2/libdm/libdm-deptree.c	2008/11/03 18:59:59	1.45
@@ -12,7 +12,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 #include "libdm-targets.h"
 #include "libdm-common.h"
 #include "list.h"
--- LVM2/libdm/libdm-file.c	2007/08/21 16:26:06	1.9
+++ LVM2/libdm/libdm-file.c	2008/11/03 18:59:59	1.10
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 
 #include <sys/file.h>
 #include <fcntl.h>
--- LVM2/libdm/libdm-report.c	2008/10/30 17:24:04	1.24
+++ LVM2/libdm/libdm-report.c	2008/11/03 18:59:59	1.25
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 
 #include <ctype.h>
 
--- LVM2/libdm/libdm-string.c	2007/08/21 16:26:06	1.9
+++ LVM2/libdm/libdm-string.c	2008/11/03 18:59:59	1.10
@@ -12,7 +12,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 #include "libdevmapper.h"
 
 #include <ctype.h>
--- LVM2/libdm/datastruct/bitset.c	2007/08/21 16:26:06	1.4
+++ LVM2/libdm/datastruct/bitset.c	2008/11/03 18:59:59	1.5
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 
 /* FIXME: calculate this. */
 #define INT_SHIFT 5
--- LVM2/libdm/datastruct/hash.c	2008/05/21 16:14:45	1.8
+++ LVM2/libdm/datastruct/hash.c	2008/11/03 18:59:59	1.9
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 
 struct dm_hash_node {
 	struct dm_hash_node *next;
--- LVM2/libdm/ioctl/libdm-iface.c	2008/11/01 02:19:18	1.53
+++ LVM2/libdm/ioctl/libdm-iface.c	2008/11/03 18:59:59	1.54
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 #include "libdm-targets.h"
 #include "libdm-common.h"
 
/cvs/lvm2/LVM2/libdm/misc/dmlib.h,v  -->  standard output
revision 1.1
--- LVM2/libdm/misc/dmlib.h
+++ -	2008-11-03 19:00:02.251494000 +0000
@@ -0,0 +1,26 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * This file must be included first by every device-mapper library source file.
+ */
+#ifndef _DM_LIB_H
+#define _DM_LIB_H
+
+#define DM
+
+#include "lib.h"
+
+#endif
--- LVM2/libdm/mm/dbg_malloc.c	2008/06/25 14:10:33	1.12
+++ LVM2/libdm/mm/dbg_malloc.c	2008/11/03 18:59:59	1.13
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 
 #include <assert.h>
 #include <stdarg.h>
--- LVM2/libdm/mm/pool-debug.c	2008/04/19 15:50:18	1.4
+++ LVM2/libdm/mm/pool-debug.c	2008/11/03 18:59:59	1.5
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 
 struct block {
 	struct block *next;
--- LVM2/libdm/mm/pool-fast.c	2008/04/19 15:50:18	1.5
+++ LVM2/libdm/mm/pool-fast.c	2008/11/03 18:59:59	1.6
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 
 struct chunk {
 	char *begin, *end;
--- LVM2/libdm/mm/pool.c	2007/08/21 16:26:07	1.3
+++ LVM2/libdm/mm/pool.c	2008/11/03 18:59:59	1.4
@@ -13,6 +13,8 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "dmlib.h"
+
 #ifdef DEBUG_POOL
 #include "pool-debug.c"
 #else
--- LVM2/libdm/regex/matcher.c	2007/08/21 16:26:07	1.2
+++ LVM2/libdm/regex/matcher.c	2008/11/03 18:59:59	1.3
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 #include "parse_rx.h"
 #include "ttree.h"
 #include "assert.h"
--- LVM2/libdm/regex/parse_rx.c	2007/08/21 16:26:07	1.2
+++ LVM2/libdm/regex/parse_rx.c	2008/11/03 18:59:59	1.3
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 #include "parse_rx.h"
 
 struct parse_sp {		/* scratch pad for the parsing process */
--- LVM2/libdm/regex/ttree.c	2007/08/21 16:26:07	1.2
+++ LVM2/libdm/regex/ttree.c	2008/11/03 18:59:59	1.3
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "lib.h"
+#include "dmlib.h"
 #include "ttree.h"
 
 struct node {


