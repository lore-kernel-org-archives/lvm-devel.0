From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  7 Dec 2008 10:39:28 -0500
Subject: [PATCH] Add liblvm interactive test infrastructure to build.
In-Reply-To: <20081207125021.GL26097@agk.fab.redhat.com>
References: <20081207125021.GL26097@agk.fab.redhat.com>
Message-ID: <1228664368-27613-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 configure            |    3 +-
 configure.in         |    1 +
 include/.symlinks    |    1 +
 lib/lvm2.h           |   53 +++++++++++++++++++++++
 test/api/Makefile.in |   39 +++++++++++++++++
 test/api/test.c      |  116 ++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 212 insertions(+), 1 deletions(-)
 create mode 100644 lib/lvm2.h
 create mode 100644 test/api/Makefile.in
 create mode 100644 test/api/test.c

diff --git a/configure b/configure
index 2fe92fd..5d2ed22 100755
--- a/configure
+++ b/configure
@@ -11720,7 +11720,7 @@ LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile tools/Makefile tools/version.h"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile tools/version.h"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -12301,6 +12301,7 @@ do
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
+    "test/api/Makefile") CONFIG_FILES="$CONFIG_FILES test/api/Makefile" ;;
     "tools/Makefile") CONFIG_FILES="$CONFIG_FILES tools/Makefile" ;;
     "tools/version.h") CONFIG_FILES="$CONFIG_FILES tools/version.h" ;;
 
diff --git a/configure.in b/configure.in
index d18d5fd..0a05406 100644
--- a/configure.in
+++ b/configure.in
@@ -806,6 +806,7 @@ po/Makefile
 scripts/clvmd_init_red_hat
 scripts/Makefile
 test/Makefile
+test/api/Makefile
 tools/Makefile
 tools/version.h
 ])
diff --git a/include/.symlinks b/include/.symlinks
index b70b96d..1a4bd93 100644
--- a/include/.symlinks
+++ b/include/.symlinks
@@ -1,5 +1,6 @@
 ../daemons/clvmd/clvm.h
 ../daemons/dmeventd/libdevmapper-event.h
+../lib/lvm2.h
 ../lib/activate/activate.h
 ../lib/activate/targets.h
 ../lib/cache/lvmcache.h
diff --git a/lib/lvm2.h b/lib/lvm2.h
new file mode 100644
index 0000000..8ddaf68
--- /dev/null
+++ b/lib/lvm2.h
@@ -0,0 +1,53 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
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
+#ifndef _LIB_LVM2_H
+#define _LIB_LVM2_H
+
+#include <stdint.h>
+
+/*
+ * Library Initialisation
+ * FIXME: For now just #define lvm2_create() and lvm2_destroy() to 
+ * create_toolcontext() and destroy_toolcontext()
+ */
+struct arg;
+struct cmd_context;
+struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static, unsigned is_long_lived);
+void destroy_toolcontext(struct cmd_context *cmd);
+
+/*
+ * lvm2_create
+lvm_handle_t lvm2_create(void);
+ *
+ * Description: Create an LVM2 handle used in many other APIs.
+ *
+ * Returns:
+ * NULL: Fail - unable to initialise handle.
+ * non-NULL: Success - valid LVM2 handle returned
+ */
+#define lvm2_create(X) create_toolcontext(NULL,0,1)
+
+/*
+ * lvm2_destroy
+void lvm2_destroy(lvm_handle_t h);
+ *
+ * Description: Destroy an LVM2 handle allocated with lvm2_create
+ *
+ * Parameters:
+ * - h (IN): handle obtained from lvm2_create
+ */
+#define lvm2_destroy(X) destroy_toolcontext(X)
+
+#endif
diff --git a/test/api/Makefile.in b/test/api/Makefile.in
new file mode 100644
index 0000000..4032a78
--- /dev/null
+++ b/test/api/Makefile.in
@@ -0,0 +1,39 @@
+#
+# Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+# Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
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
+SOURCES = test.c
+INCLUDES += -I${top_srcdir}/lib
+
+ifeq ("@DEBUG@", "yes")
+	DEFS += -DDEBUG
+endif
+
+TARGETS = test
+
+LVMLIBS = -llvm -ldevmapper
+
+DEFS += -D_REENTRANT
+CFLAGS += -fno-strict-aliasing
+
+LDFLAGS += -L$(top_srcdir)/api/lib
+
+include $(top_srcdir)/make.tmpl
+
+test: $(OBJECTS) $(top_srcdir)/lib/liblvm.a $(top_srcdir)/libdm/libdevmapper.so
+	$(CC) -o test $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
+
diff --git a/test/api/test.c b/test/api/test.c
new file mode 100644
index 0000000..de53c46
--- /dev/null
+++ b/test/api/test.c
@@ -0,0 +1,116 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
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
+#include <stdio.h>
+#include <string.h>
+#include <stdlib.h>
+#include <readline/readline.h>
+#include "lvm2.h"
+
+#define MAX_ARGS 64
+
+static int lvm_split(char *str, int *argc, char **argv, int max)
+{
+	char *b = str, *e;
+	*argc = 0;
+
+	while (*b) {
+		while (*b && isspace(*b))
+			b++;
+
+		if ((!*b) || (*b == '#'))
+			break;
+
+		e = b;
+		while (*e && !isspace(*e))
+			e++;
+
+		argv[(*argc)++] = b;
+		if (!*e)
+			break;
+		*e++ = '\0';
+		b = e;
+		if (*argc == max)
+			break;
+	}
+
+	return *argc;
+}
+
+static int lvmapi_test_shell(void *h)
+{
+	int argc, i;
+	char *input = NULL, *args[MAX_ARGS], **argv;
+
+	while (1) {
+		free(input);
+		input = readline("lvm> ");
+
+		/* EOF */
+		if (!input) {
+			printf("\n");
+			break;
+		}
+
+		/* empty line */
+		if (!*input)
+			continue;
+
+		argv = args;
+
+		if (lvm_split(input, &argc, argv, MAX_ARGS) == MAX_ARGS) {
+			printf("Too many arguments, sorry.");
+			continue;
+		}
+
+		if (!strcmp(argv[0], "lvm")) {
+			argv++;
+			argc--;
+		}
+
+		if (!argc)
+			continue;
+
+		if (!strcmp(argv[0], "quit") || !strcmp(argv[0], "exit")) {
+			printf("Exiting.\n");
+			break;
+		} else if (!strcmp(argv[0], "?") || !strcmp(argv[0], "help")) {
+			printf("No commands defined\n");
+		} else if (!strcmp(argv[0], "scan")) {
+			for (i=1; i < argc; i++)
+				printf("Scan a path!\n");
+		}
+	}
+
+	free(input);
+	return 0;
+}
+		      
+int main (int argc, char *argv[])
+{
+	void *h;
+
+	h = lvm2_create();
+	if (!h) {
+		printf("Unable to open lvm library instance\n");
+		return 1;
+	}
+
+	lvmapi_test_shell(h);
+
+	if (h)
+		lvm2_destroy(h);
+	return 0;
+}
+
-- 
1.5.5.1


