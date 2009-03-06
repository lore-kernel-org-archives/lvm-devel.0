From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri,  6 Mar 2009 03:49:14 -0500
Subject: [PATCH 2/2] Add new liblvm build directory and move lvm_base.c.
In-Reply-To: <1236329354-26253-2-git-send-email-dwysocha@redhat.com>
References: <1236329354-26253-1-git-send-email-dwysocha@redhat.com>
	<1236329354-26253-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1236329354-26253-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The original liblvm.a has been moved to liblvm-internal.a.
We now use liblvm.a for the new application library and build
it inside liblvm directory.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 Makefile.in        |    2 +-
 WHATS_NEW          |    1 +
 configure          |    3 +-
 configure.in       |    1 +
 lib/Makefile.in    |    3 +-
 lib/lvm_base.c     |   64 ----------------------------------------------------
 liblvm/Makefile.in |   36 +++++++++++++++++++++++++++++
 liblvm/lvm_base.c  |   64 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 8 files changed, 106 insertions(+), 68 deletions(-)
 delete mode 100644 lib/lvm_base.c
 create mode 100644 liblvm/Makefile.in
 create mode 100644 liblvm/lvm_base.c

diff --git a/Makefile.in b/Makefile.in
index 07f22c6..38835eb 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -22,7 +22,7 @@ ifeq ("@INTL@", "yes")
   SUBDIRS += po
 endif
 
-SUBDIRS += lib tools daemons libdm
+SUBDIRS += lib tools daemons libdm liblvm
 
 ifeq ($(MAKECMDGOALS),distclean)
   SUBDIRS += daemons/clvmd \
diff --git a/WHATS_NEW b/WHATS_NEW
index e039108..0b96651 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.46 - 
 ================================
+  Rename liblvm.a to liblvm-internal.a and build new application library.
   Flush memory pool and fix locking in clvmd refresh and backup command.
   Fix unlocks in clvmd-corosync. Broken in 2.02.45.
 
diff --git a/configure b/configure
index 64afd3c..dbc9263 100755
--- a/configure
+++ b/configure
@@ -12659,7 +12659,7 @@ LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -13278,6 +13278,7 @@ do
     "lib/snapshot/Makefile") CONFIG_FILES="$CONFIG_FILES lib/snapshot/Makefile" ;;
     "libdm/Makefile") CONFIG_FILES="$CONFIG_FILES libdm/Makefile" ;;
     "libdm/libdevmapper.pc") CONFIG_FILES="$CONFIG_FILES libdm/libdevmapper.pc" ;;
+    "liblvm/Makefile") CONFIG_FILES="$CONFIG_FILES liblvm/Makefile" ;;
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
diff --git a/configure.in b/configure.in
index 1eaa2a0..f84d589 100644
--- a/configure.in
+++ b/configure.in
@@ -835,6 +835,7 @@ lib/misc/lvm-version.h
 lib/snapshot/Makefile
 libdm/Makefile
 libdm/libdevmapper.pc
+liblvm/Makefile
 man/Makefile
 po/Makefile
 scripts/clvmd_init_red_hat
diff --git a/lib/Makefile.in b/lib/Makefile.in
index 0d5ee94..ee1f8ff 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -86,8 +86,7 @@ SOURCES =\
 	report/report.c \
 	striped/striped.c \
 	uuid/uuid.c \
-	zero/zero.c \
-	lvm_base.c
+	zero/zero.c
 
 ifeq ("@LVM1@", "internal")
   SOURCES +=\
diff --git a/lib/lvm_base.c b/lib/lvm_base.c
deleted file mode 100644
index f917533..0000000
--- a/lib/lvm_base.c
+++ /dev/null
@@ -1,64 +0,0 @@
-/*
- * Copyright (C) 2008,2009 Red Hat, Inc. All rights reserved.
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
-#include "lib.h"
-#include "lvm.h"
-#include "toolcontext.h"
-#include "locking.h"
-#include "metadata-exported.h"
-#include "report.h"
-
-lvm_t lvm_create(const char *system_dir)
-{
-	struct cmd_context *cmd;
-
-	/* FIXME: logging bound to handle
-	 */
-
-	/* create context */
-	/* FIXME: split create_toolcontext */
-	cmd = create_toolcontext(1, system_dir);
-	if (!cmd)
-		return NULL;
-	/*
-	 * FIXME: if an non memory error occured, return the cmd (maybe some
-	 * cleanup needed).
-	 */
-
-	/* initialization from lvm_run_command */
-	init_error_message_produced(0);
-
-	/* FIXME: locking_type config option needed? */
-	/* initialize locking */
-	if (!init_locking(-1, cmd)) {
-		/* FIXME: use EAGAIN as error code here */
-		log_error("Locking initialisation failed.");
-		lvm_destroy((lvm_t) cmd);
-		return NULL;
-	}
-
-	return (lvm_t) cmd;
-}
-
-void lvm_destroy(lvm_t libh)
-{
-	/* FIXME: error handling */
-	destroy_toolcontext((struct cmd_context *)libh);
-}
-
-int lvm_reload_config(lvm_t libh)
-{
-	/* FIXME: re-init locking needed here? */
-	return refresh_toolcontext((struct cmd_context *)libh);
-}
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
new file mode 100644
index 0000000..6f90f6a
--- /dev/null
+++ b/liblvm/Makefile.in
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
diff --git a/liblvm/lvm_base.c b/liblvm/lvm_base.c
new file mode 100644
index 0000000..f917533
--- /dev/null
+++ b/liblvm/lvm_base.c
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
-- 
1.6.0.6


