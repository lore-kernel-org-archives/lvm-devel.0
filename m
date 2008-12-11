From: Thomas Woerner <twoerner@redhat.com>
Date: Thu, 11 Dec 2008 17:43:41 +0100
Subject: [PATCH] New lib/lvm2.c for base library functions
In-Reply-To: <1229013822-10809-2-git-send-email-twoerner@redhat.com>
References: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
	<1229013822-10809-2-git-send-email-twoerner@redhat.com>
Message-ID: <1229013822-10809-3-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/Makefile.in |    3 ++-
 lib/lvm2.c      |   42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 44 insertions(+), 1 deletions(-)
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
index 0000000..daf9a79
--- /dev/null
+++ b/lib/lvm2.c
@@ -0,0 +1,42 @@
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
+
+
+lvm2_handle_t lvm2_create(const char *sys_dir)
+{
+  struct cmd_context *cmd;
+
+  /* use internal version with system_dir */
+  cmd = create_librarycontext(sys_dir);
+  if (! cmd)
+    return NULL;
+
+  /* TODO:
+   * - bind logging to handle
+   */
+
+  return (lvm2_handle_t) cmd;
+}
+
+
+void lvm2_destroy(lvm2_handle_t libh)
+{
+  destroy_toolcontext((struct cmd_context *) libh); /* no error handling here */
+
+  return 1;
+}
-- 
1.6.0.4


