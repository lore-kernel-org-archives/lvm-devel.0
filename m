From: meyering@sourceware.org <meyering@sourceware.org>
Date: 3 Oct 2007 16:10:05 -0000
Subject: LVM2 include/.symlinks lib/misc/util.c lib/mis ...
Message-ID: <20071003161005.15585.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-10-03 16:10:04

Modified files:
	include        : .symlinks 
	lib/misc       : util.c util.h 
	tools/fsadm    : fsadm.c 
	tools          : lvmcmdline.c 
Added files:
	lib/misc       : last-path-component.h 

Log message:
	Fix the fsadm build failure without using -llvm.
	
	* lib/misc/util.c (last_path_component): Move definition to ...
	* lib/misc/last-path-component.h (last_path_component): ...here.
	New file.  Make the function "static inline".
	* include/.symlinks: Add last-path-component.h.
	* lib/misc/util.h (last_path_component): Remove declaration.
	* tools/fsadm/fsadm.c: Include "last-path-component.h".
	* tools/lvmcmdline.c: Likewise.
	
	Author: Jim Meyering <meyering@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.46&r2=1.47
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/last-path-component.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.h.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/fsadm/fsadm.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/include/.symlinks	2007/07/20 15:48:39	1.46
+++ LVM2/include/.symlinks	2007/10/03 16:10:04	1.47
@@ -39,6 +39,7 @@
 ../lib/misc/crc.h
 ../lib/misc/intl.h
 ../lib/misc/util.h
+../lib/misc/last-path-component.h
 ../lib/misc/lib.h
 ../lib/misc/lvm-exec.h
 ../lib/misc/lvm-file.h
/cvs/lvm2/LVM2/lib/misc/last-path-component.h,v  -->  standard output
revision 1.1
--- LVM2/lib/misc/last-path-component.h
+++ -	2007-10-03 16:10:04.885244000 +0000
@@ -0,0 +1,27 @@
+/*
+ * Copyright (C) 2007 Red Hat, Inc. All rights reserved.
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
+ * Return the address of the last file name component of NAME.
+ * If NAME ends in a slash, return the empty string.
+ */
+
+#include <string.h>
+
+static inline char *last_path_component(char const *name)
+{
+	char const *slash = strrchr (name, '/');
+	char const *res = slash ? slash + 1 : name;
+	return (char *) res;
+}
--- LVM2/lib/misc/util.c	2007/08/20 20:55:27	1.3
+++ LVM2/lib/misc/util.c	2007/10/03 16:10:04	1.4
@@ -19,9 +19,4 @@
 
 #include "lib.h"
 
-char *last_path_component(char const *name)
-{
-	char const *slash = strrchr (name, '/');
-	char const *res = slash ? slash + 1 : name;
-	return (char *) res;
-}
+/* empty for now.  */
--- LVM2/lib/misc/util.h	2007/09/20 21:39:07	1.3
+++ LVM2/lib/misc/util.h	2007/10/03 16:10:04	1.4
@@ -25,6 +25,4 @@
 		     (void) (&_a == &_b); \
 		     _a > _b ? _a : _b; })
 
-char *last_path_component(char const *name);
-
 #endif
--- LVM2/tools/fsadm/fsadm.c	2007/08/20 20:55:30	1.3
+++ LVM2/tools/fsadm/fsadm.c	2007/10/03 16:10:04	1.4
@@ -39,6 +39,7 @@
 #include <sys/vfs.h>
 
 #include "util.h"
+#include "last-path-component.h"
 
 #define log_error(str, x...) fprintf(stderr, "%s(%u):  " str "\n", __FILE__, __LINE__, x)
 
--- LVM2/tools/lvmcmdline.c	2007/09/21 18:43:55	1.52
+++ LVM2/tools/lvmcmdline.c	2007/10/03 16:10:04	1.53
@@ -20,6 +20,7 @@
 
 #include "stub.h"
 #include "lvm2cmd.h"
+#include "last-path-component.h"
 
 #include <signal.h>
 #include <syslog.h>


