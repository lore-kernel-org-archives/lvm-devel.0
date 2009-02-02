From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon,  2 Feb 2009 15:49:58 -0500
Subject: [PATCH 02/13] Add lvm_create, lvm_destroy, lvm_reload_config() APIs.
In-Reply-To: <1233607809-1087-2-git-send-email-dwysocha@redhat.com>
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
Message-ID: <1233607809-1087-3-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add lvm2.c file.
Update test code.

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/Makefile.in |    3 +-
 lib/lvm2.c      |   70 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/lvm2.h      |   44 +++++++++++++++++++++-------------
 test/api/test.c |   13 ++++-----
 4 files changed, 105 insertions(+), 25 deletions(-)
 create mode 100644 lib/lvm2.c

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 54092cd..c0b58b9 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -86,7 +86,8 @@ SOURCES =\
 	report/report.c \
 	striped/striped.c \
 	uuid/uuid.c \
-	zero/zero.c
+	zero/zero.c \
+	lvm2.c
 
 ifeq ("@LVM1@", "internal")
   SOURCES +=\
diff --git a/lib/lvm2.c b/lib/lvm2.c
new file mode 100644
index 0000000..bb8f295
--- /dev/null
+++ b/lib/lvm2.c
@@ -0,0 +1,70 @@
+/*
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
+
+#include "lvm2.h"
+#include "lib.h"
+#include "toolcontext.h"
+#include "locking.h"
+#include "metadata-exported.h"
+#include "report.h"
+
+
+lvm_handle_t lvm_create(const char *system_dir)
+{
+	struct cmd_context *cmd;
+
+	/* To be done:
+	 * logging bound to handle
+	 */
+
+	/* create context */
+	cmd = create_toolcontext(1, system_dir);
+
+	/* initilize remaining */
+	if (cmd) {
+		int locking_type;
+
+		/* initilization from lvm_run_command */
+		init_error_message_produced(0);
+		sigint_clear();
+
+		/* get locking type from config tree */
+		/* FIXME: config option needed? */
+		locking_type = find_config_tree_int(cmd, "global/locking_type",
+						    1);
+
+		/* initialize locking */
+		if (! init_locking(locking_type, cmd)) {
+			printf("Locking type %d initialisation failed.",
+			       locking_type);
+			lvm_destroy((lvm_handle_t) cmd);
+			return NULL;
+		}
+	}
+
+	return (lvm_handle_t) cmd;
+}
+
+
+void lvm_destroy(lvm_handle_t libh)
+{
+	destroy_toolcontext((struct cmd_context *)libh);
+	/* no error handling here */
+}
+
+
+int lvm_reload_config(lvm_handle_t libh)
+{
+	return refresh_toolcontext((struct cmd_context *)libh);
+}
diff --git a/lib/lvm2.h b/lib/lvm2.h
index b18cead..f348035 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -18,36 +18,46 @@
 #include <stdint.h>
 
 /*
- * Library Initialisation
- * FIXME: For now just #define lvm2_create() and lvm2_destroy() to 
- * create_toolcontext() and destroy_toolcontext()
+ * lvm_handle_t
  */
-struct arg;
-struct cmd_context;
-struct cmd_context *create_toolcontext(unsigned is_long_lived);
-void destroy_toolcontext(struct cmd_context *cmd);
+struct lib_context; /* internal context data */
+typedef struct lib_context *lvm_handle_t;
 
+#ifdef FUTURE_FEATURE
 /*
- * lvm2_create
-lvm_handle_t lvm2_create(void);
+ * lvm_config_t
+ */
+struct lvm_config {
+	const char *system_dir;
+	unsigned is_long_lived;
+};
+#endif /* FUTURE_FEATURE */
+
+/*
+ * lvm_create
  *
- * Description: Create an LVM2 handle used in many other APIs.
+ * Description: Create an LVM handle used in many other APIs.
  *
  * Returns:
  * NULL: Fail - unable to initialise handle.
- * non-NULL: Success - valid LVM2 handle returned
+ * non-NULL: Success - valid LVM handle returned
  */
-#define lvm2_create(X) create_toolcontext(1)
+lvm_handle_t lvm_create(const char *system_dir);
 
 /*
- * lvm2_destroy
-void lvm2_destroy(lvm_handle_t h);
+ * lvm_destroy
  *
- * Description: Destroy an LVM2 handle allocated with lvm2_create
+ * Description: Destroy an LVM handle allocated with lvm_create
  *
  * Parameters:
- * - h (IN): handle obtained from lvm2_create
+ * - h (IN): handle obtained from lvm_create
+ */
+void lvm_destroy(lvm_handle_t libh);
+
+/*
+ * lvm_reload_config
+ * Reload configuration files
  */
-#define lvm2_destroy(X) destroy_toolcontext(X)
+int lvm_reload_config(lvm_handle_t libh);
 
 #endif
diff --git a/test/api/test.c b/test/api/test.c
index de53c46..9411663 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -48,7 +48,7 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 	return *argc;
 }
 
-static int lvmapi_test_shell(void *h)
+static int lvmapi_test_shell(lvm_handle_t libh)
 {
 	int argc, i;
 	char *input = NULL, *args[MAX_ARGS], **argv;
@@ -99,18 +99,17 @@ static int lvmapi_test_shell(void *h)
 		      
 int main (int argc, char *argv[])
 {
-	void *h;
+	lvm_handle_t libh;
 
-	h = lvm2_create();
-	if (!h) {
+	libh = lvm_create(NULL);
+	if (!libh) {
 		printf("Unable to open lvm library instance\n");
 		return 1;
 	}
 
-	lvmapi_test_shell(h);
+	lvmapi_test_shell(libh);
 
-	if (h)
-		lvm2_destroy(h);
+	lvm_destroy(libh);
 	return 0;
 }
 
-- 
1.5.5.1


