From: meyering@sourceware.org <meyering@sourceware.org>
Date: Fri, 20 Jul 2007 16:01:05 -0000
Subject: LVM2 ./WHATS_NEW include/.symlinks lib/Makefil ...
Message-ID: <20070720154840.19510.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-07-20 15:48:40

Modified files:
	.              : WHATS_NEW 
	include        : .symlinks 
	lib            : Makefile.in 
	lib/misc       : lib.h 
	tools          : lvmcmdline.c 
	tools/fsadm    : fsadm.c 
Added files:
	lib/misc       : util.c util.h 

Log message:
	Eliminate uses of strdup+basename. Use last_path_component instead.
	* lib/misc/util.c, lib/misc/util.h (last_path_component): New files.
	* lib/Makefile.in (SOURCES): Add misc/util.c.
	* lib/misc/lib.h: Include "util.h".
	* tools/fsadm/fsadm.c: Include "util.h". (_usage): Use last_path_component,
	not basename.
	* tools/lvmcmdline.c (_find_command, lvm2_main): Likewise.
	* include/.symlinks: Add lib/misc/util.h.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.665&r2=1.666
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/.symlinks.diff?cvsroot=lvm2&r1=1.45&r2=1.46
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/lib.h.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.44&r2=1.45
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/fsadm/fsadm.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2007/07/20 15:38:19	1.665
+++ LVM2/WHATS_NEW	2007/07/20 15:48:39	1.666
@@ -1,4 +1,5 @@
 Version 2.02.28 -
+  Eliminate uses of strdup+basename.  Use last_path_component instead.
   Use gcc's printf attribute wherever possible.
   In _line_append, use "sizeof buf - 1" rather than equivalent "4095"
   Introduce is_same_inode macro, now including a comparison of st_dev.
--- LVM2/include/.symlinks	2007/07/18 15:38:57	1.45
+++ LVM2/include/.symlinks	2007/07/20 15:48:39	1.46
@@ -38,6 +38,7 @@
 ../lib/misc/configure.h
 ../lib/misc/crc.h
 ../lib/misc/intl.h
+../lib/misc/util.h
 ../lib/misc/lib.h
 ../lib/misc/lvm-exec.h
 ../lib/misc/lvm-file.h
--- LVM2/lib/Makefile.in	2007/04/27 18:52:05	1.81
+++ LVM2/lib/Makefile.in	2007/07/20 15:48:39	1.82
@@ -80,6 +80,7 @@
 	misc/lvm-string.c \
 	misc/lvm-wrappers.c \
 	misc/timestamp.c \
+	misc/util.c \
 	mm/memlock.c \
 	report/report.c \
 	striped/striped.c \
/cvs/lvm2/LVM2/lib/misc/util.c,v  -->  standard output
revision 1.1
--- LVM2/lib/misc/util.c
+++ -	2007-07-20 15:48:40.520121000 +0000
@@ -0,0 +1,24 @@
+/*
+ * Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * Return the address of the last file name component of NAME.
+ * If NAME ends in a slash, return the empty string.
+ */
+char *last_path_component(char const *name)
+{
+	char const *slash = strrchr (name, '/');
+	char const *res = slash ? slash + 1 : name;
+	return (char *) res;
+}
/cvs/lvm2/LVM2/lib/misc/util.h,v  -->  standard output
revision 1.1
--- LVM2/lib/misc/util.h
+++ -	2007-07-20 15:48:40.598043000 +0000
@@ -0,0 +1,20 @@
+/*
+ * Copyright (C) 2007 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU General Public License v.2.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _LVM_UTIL_H
+#define _LVM_UTIL_H
+
+char *last_path_component(char const *name);
+
+#endif
--- LVM2/lib/misc/lib.h	2007/04/27 17:46:16	1.11
+++ LVM2/lib/misc/lib.h	2007/07/20 15:48:39	1.12
@@ -29,6 +29,7 @@
 #include "intl.h"
 #include "lvm-types.h"
 #include "lvm-wrappers.h"
+#include "util.h"
 
 #include <libdevmapper.h>
 
--- LVM2/tools/lvmcmdline.c	2007/06/28 17:33:44	1.44
+++ LVM2/tools/lvmcmdline.c	2007/07/20 15:48:39	1.45
@@ -479,18 +479,15 @@
 static struct command *_find_command(const char *name)
 {
 	int i;
-	char *namebase, *base;
+	char *base;
 
-	namebase = strdup(name);
-	base = basename(namebase);
+	base = last_path_component(name);
 
 	for (i = 0; i < _cmdline.num_commands; i++) {
 		if (!strcmp(base, _cmdline.commands[i].name))
 			break;
 	}
 
-	free(namebase);
-
 	if (i >= _cmdline.num_commands)
 		return 0;
 
@@ -1138,14 +1135,13 @@
 
 int lvm2_main(int argc, char **argv, unsigned is_static)
 {
-	char *namebase, *base;
+	char *base;
 	int ret, alias = 0;
 	struct cmd_context *cmd;
 
 	_close_stray_fds();
 
-	namebase = strdup(argv[0]);
-	base = basename(namebase);
+	base = last_path_component(argv[0]);
 	while (*base == '/')
 		base++;
 	if (strcmp(base, "lvm") && strcmp(base, "lvm.static") &&
@@ -1160,8 +1156,6 @@
 		unsetenv("LVM_DID_EXEC");
 	}
 
-	free(namebase);
-
 	if (!(cmd = init_lvm(is_static)))
 		return -1;
 
--- LVM2/tools/fsadm/fsadm.c	2004/06/15 17:29:20	1.1
+++ LVM2/tools/fsadm/fsadm.c	2007/07/20 15:48:39	1.2
@@ -32,6 +32,8 @@
 #include <sys/mount.h>
 #include <sys/vfs.h>
 
+#include "util.h"
+
 #define log_error(str, x...) fprintf(stderr, "%s(%u):  " str "\n", __FILE__, __LINE__, x)
 
 /* Filesystem related information */
@@ -45,7 +47,7 @@
 static void _usage(const char *cmd)
 {
 	log_error("Usage: %s [check <filesystem> | resize <filesystem> <size>]",
-		  basename(cmd));
+		  last_path_component(cmd));
 }
 
 /* FIXME Make this more robust - /proc, multiple mounts, TMPDIR + security etc. */


