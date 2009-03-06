From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 6 Mar 2009 16:19:56 -0000
Subject: LVM2 ./Makefile.in ./WHATS_NEW ./configure ./c ...
Message-ID: <20090306161956.19858.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-03-06 16:19:53

Modified files:
	.              : Makefile.in WHATS_NEW configure configure.in 
	lib            : Makefile.in 
Added files:
	liblvm         : Makefile.in lvm_base.c 
Removed files:
	lib            : lvm_base.c 

Log message:
	Add new liblvm build directory and move lvm_base.c.
	
	The original liblvm.a has been moved to liblvm-internal.a.
	We now use liblvm.a for the new application library and build
	it inside liblvm directory.
	
	Change dependencies so tools depend on liblvm application library,
	and application library depends on liblvm internal.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1063&r2=1.1064
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.91&r2=1.92
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.96&r2=1.97
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/lvm_base.c.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/Makefile.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_base.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/Makefile.in	2008/11/18 13:16:03	1.30
+++ LVM2/Makefile.in	2009/03/06 16:19:52	1.31
@@ -22,7 +22,7 @@
   SUBDIRS += po
 endif
 
-SUBDIRS += lib tools daemons libdm
+SUBDIRS += lib tools daemons libdm liblvm
 
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS += daemons/clvmd \
@@ -42,8 +42,9 @@
 
 libdm: include
 lib: libdm
+liblvm: lib
 daemons: lib tools
-tools: lib device-mapper
+tools: lib device-mapper liblvm
 po: tools daemons
 
 libdm.device-mapper: include.device-mapper
--- LVM2/WHATS_NEW	2009/03/06 11:29:38	1.1063
+++ LVM2/WHATS_NEW	2009/03/06 16:19:52	1.1064
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Rename liblvm.a to liblvm-internal.a and build new application library.
   Flush memory pool and fix locking in clvmd refresh and backup command.
   Fix unlocks in clvmd-corosync. Broken in 2.02.45.
 
--- LVM2/configure	2009/02/25 23:33:30	1.91
+++ LVM2/configure	2009/03/06 16:19:52	1.92
@@ -12659,7 +12659,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -13278,6 +13278,7 @@
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
     "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
+    "liblvm/Makefile") CONFIG_FILES="$CONFIG_FILES liblvm/Makefile" ;;
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
--- LVM2/configure.in	2009/02/25 22:41:12	1.96
+++ LVM2/configure.in	2009/03/06 16:19:53	1.97
@@ -835,6 +835,7 @@
 lib/snapshot/Makefile
 libdm/Makefile
 libdm/libdevmapper.pc
+liblvm/Makefile
 man/Makefile
 po/Makefile
 scripts/clvmd_init_red_hat
--- LVM2/lib/Makefile.in	2009/03/06 16:17:28	1.89
+++ LVM2/lib/Makefile.in	2009/03/06 16:19:53	1.90
@@ -86,8 +86,7 @@
 	report/report.c \
 	striped/striped.c \
 	uuid/uuid.c \
-	zero/zero.c \
-	lvm_base.c
+	zero/zero.c
 
 ifeq ("@LVM1@", "internal")
   SOURCES +=\
/cvs/lvm2/LVM2/liblvm/Makefile.in,v  -->  standard output
revision 1.1
--- LVM2/liblvm/Makefile.in
+++ -	2009-03-06 16:19:56.299072000 +0000
@@ -0,0 +1,36 @@
+#
+# Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
+# Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+#
+# This file is part of LVM2.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+srcdir = @srcdir@
+top_srcdir = @top_srcdir@
+VPATH = @srcdir@
+
+SOURCES =\
+	lvm_base.c
+
+LIB_STATIC = liblvm.a
+
+$(SUBDIRS): $(LIB_STATIC)
+
+CLEAN_TARGETS += liblvm.cflow
+
+include $(top_srcdir)/make.tmpl
+
+liblvm.cflow: $(SOURCES)
+	set -e; (echo -n "SOURCES += "; \
+		 echo $(SOURCES) | \
+		 sed "s/^/ /;s/ / $(top_srcdir)\/lib\//g;s/$$//"; \
+		 ) > $@
+
+cflow: liblvm.cflow
/cvs/lvm2/LVM2/liblvm/lvm_base.c,v  -->  standard output
revision 1.1
--- LVM2/liblvm/lvm_base.c
+++ -	2009-03-06 16:19:56.398515000 +0000
@@ -0,0 +1,64 @@
+/*
+ * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
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
+#include "lib.h"
+#include "lvm.h"
+#include "toolcontext.h"
+#include "locking.h"
+#include "metadata-exported.h"
+#include "report.h"
+
+lvm_t lvm_create(const char *system_dir)
+{
+	struct cmd_context *cmd;
+
+	/* FIXME: logging bound to handle
+	 */
+
+	/* create context */
+	/* FIXME: split create_toolcontext */
+	cmd = create_toolcontext(1, system_dir);
+	if (!cmd)
+		return NULL;
+	/*
+	 * FIXME: if an non memory error occured, return the cmd (maybe some
+	 * cleanup needed).
+	 */
+
+	/* initialization from lvm_run_command */
+	init_error_message_produced(0);
+
+	/* FIXME: locking_type config option needed? */
+	/* initialize locking */
+	if (!init_locking(-1, cmd)) {
+		/* FIXME: use EAGAIN as error code here */
+		log_error("Locking initialisation failed.");
+		lvm_destroy((lvm_t) cmd);
+		return NULL;
+	}
+
+	return (lvm_t) cmd;
+}
+
+void lvm_destroy(lvm_t libh)
+{
+	/* FIXME: error handling */
+	destroy_toolcontext((struct cmd_context *)libh);
+}
+
+int lvm_reload_config(lvm_t libh)
+{
+	/* FIXME: re-init locking needed here? */
+	return refresh_toolcontext((struct cmd_context *)libh);
+}


