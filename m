From: Thomas Woerner <twoerner@redhat.com>
Date: Fri, 20 Feb 2009 12:24:13 +0100
Subject: [PATCH 3/3] New base files needed for liblvm with doxygen style descriptions.
In-Reply-To: <1235129053-5967-1-git-send-email-twoerner@redhat.com>
References: <1235129053-5967-1-git-send-email-twoerner@redhat.com>
Message-ID: <1235129053-5967-2-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Added files lib/lvm.h and lib/lvm_base.c:
New structure lvm (used as an alias to cmd_context), new type definition lvm_t
for the lvm handle. Added functions lvm_create, lvm_destroy and
lvm_reload_config using the new handle.

Modified test/api/test.c:
Use new lvm.h header file and lvm_t handle.

Removed lib/lvm2.h

Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 lib/Makefile.in |    5 ++-
 lib/lvm.h       |   57 +++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/lvm2.h      |   53 -----------------------------------------------
 lib/lvm_base.c  |   61 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 test/api/test.c |   17 +++++++--------
 5 files changed, 129 insertions(+), 64 deletions(-)
 create mode 100644 lib/lvm.h
 delete mode 100644 lib/lvm2.h
 create mode 100644 lib/lvm_base.c

diff --git a/lib/Makefile.in b/lib/Makefile.in
index 54092cd..47786a7 100644
--- a/lib/Makefile.in
+++ b/lib/Makefile.in
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -86,7 +86,8 @@ SOURCES =\
 	report/report.c \
 	striped/striped.c \
 	uuid/uuid.c \
-	zero/zero.c
+	zero/zero.c \
+	lvm_base.c
 
 ifeq ("@LVM1@", "internal")
   SOURCES +=\
diff --git a/lib/lvm.h b/lib/lvm.h
new file mode 100644
index 0000000..09ff680
--- /dev/null
+++ b/lib/lvm.h
@@ -0,0 +1,57 @@
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
+#ifndef _LIB_LVM_H
+#define _LIB_LVM_H
+
+#include "version.h"
+
+#include <stdint.h>
+
+struct lvm; /* internal data */
+
+/**
+ * The lvm handle.
+ */
+typedef struct lvm *lvm_t;
+
+/**
+ * Create a LVM handle.
+ *
+ * \param   system_dir
+ *          Set an alternative system path or NULL for the default value. If
+ *          the environment variable LVM_SYSTEM_DIR is set, it will overwrite
+ *          this value.
+ * \return  A valid LVM handle is returned or NULL if there has been a
+ *          memory allocation problem. You have to check if an error occured
+ *          with the lvm_error function.
+ */
+lvm_t lvm_create(const char *system_dir);
+
+/**
+ * Destroy a LVM handle allocated with lvm_create.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ */
+void lvm_destroy(lvm_t libh);
+
+/**
+ * Reload the original configuration from the system directory.
+ *
+ * \param   libh
+ *          Handle obtained from lvm_create.
+ */
+int lvm_reload_config(lvm_t libh);
+
+#endif /* _LIB_LVM_H */
diff --git a/lib/lvm2.h b/lib/lvm2.h
deleted file mode 100644
index b18cead..0000000
--- a/lib/lvm2.h
+++ /dev/null
@@ -1,53 +0,0 @@
-/*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
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
-#ifndef _LIB_LVM2_H
-#define _LIB_LVM2_H
-
-#include <stdint.h>
-
-/*
- * Library Initialisation
- * FIXME: For now just #define lvm2_create() and lvm2_destroy() to 
- * create_toolcontext() and destroy_toolcontext()
- */
-struct arg;
-struct cmd_context;
-struct cmd_context *create_toolcontext(unsigned is_long_lived);
-void destroy_toolcontext(struct cmd_context *cmd);
-
-/*
- * lvm2_create
-lvm_handle_t lvm2_create(void);
- *
- * Description: Create an LVM2 handle used in many other APIs.
- *
- * Returns:
- * NULL: Fail - unable to initialise handle.
- * non-NULL: Success - valid LVM2 handle returned
- */
-#define lvm2_create(X) create_toolcontext(1)
-
-/*
- * lvm2_destroy
-void lvm2_destroy(lvm_handle_t h);
- *
- * Description: Destroy an LVM2 handle allocated with lvm2_create
- *
- * Parameters:
- * - h (IN): handle obtained from lvm2_create
- */
-#define lvm2_destroy(X) destroy_toolcontext(X)
-
-#endif
diff --git a/lib/lvm_base.c b/lib/lvm_base.c
new file mode 100644
index 0000000..e76ee15
--- /dev/null
+++ b/lib/lvm_base.c
@@ -0,0 +1,61 @@
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
+
+	/* initilize remaining */
+	if (cmd) {
+		/* initilization from lvm_run_command */
+		init_error_message_produced(0);
+
+		/* FIXME: locking_type config option needed? */
+		/* initialize locking */
+		if (!init_locking(-1, cmd)) {
+			/* FIXME: use EAGAIN as error code here */
+			log_error("Locking initialisation failed.");
+			lvm_destroy((lvm_t) cmd);
+			return NULL;
+		}
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
diff --git a/test/api/test.c b/test/api/test.c
index de53c46..b742976 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -16,7 +16,7 @@
 #include <string.h>
 #include <stdlib.h>
 #include <readline/readline.h>
-#include "lvm2.h"
+#include "lvm.h"
 
 #define MAX_ARGS 64
 
@@ -48,7 +48,7 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 	return *argc;
 }
 
-static int lvmapi_test_shell(void *h)
+static int lvmapi_test_shell(lvm_t libh)
 {
 	int argc, i;
 	char *input = NULL, *args[MAX_ARGS], **argv;
@@ -99,18 +99,17 @@ static int lvmapi_test_shell(void *h)
 		      
 int main (int argc, char *argv[])
 {
-	void *h;
+	lvm_t libh;
 
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
1.6.1.3


