From: Thomas Woerner <twoerner@redhat.com>
Date: Thu, 11 Dec 2008 17:43:39 +0100
Subject: [PATCH] Use struct cmd_context* as type for lvm2_handle_t with hidden cmd_context. Accessors and mutators have to be used. (lib/lvm2.h)
Message-ID: <1229013822-10809-1-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 lib/lvm2.h      |   23 +++++++++++------------
 test/api/test.c |   13 ++++++-------
 2 files changed, 17 insertions(+), 19 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index 8ddaf68..b131fd7 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -1,5 +1,4 @@
 /*
- * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
  * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
@@ -17,37 +16,37 @@
 
 #include <stdint.h>
 
+/*** Library Initialisation ***/
+
 /*
- * Library Initialisation
- * FIXME: For now just #define lvm2_create() and lvm2_destroy() to 
- * create_toolcontext() and destroy_toolcontext()
+ * lvm2_handle_t
  */
-struct arg;
-struct cmd_context;
-struct cmd_context *create_toolcontext(struct arg *the_args, unsigned is_static, unsigned is_long_lived);
-void destroy_toolcontext(struct cmd_context *cmd);
+struct cmd_context; /* private context */
+typedef struct cmd_context* lvm2_handle_t;
 
 /*
  * lvm2_create
-lvm_handle_t lvm2_create(void);
  *
  * Description: Create an LVM2 handle used in many other APIs.
  *
+ * Parameters:
+ * - sys_dir: Directory containing lvm.conf and other LVM system files,
+ *            overwritten by LVM_SYSTEM_DIR environment variable (if set)
+ *
  * Returns:
  * NULL: Fail - unable to initialise handle.
  * non-NULL: Success - valid LVM2 handle returned
  */
-#define lvm2_create(X) create_toolcontext(NULL,0,1)
+lvm2_handle_t lvm2_create(const char *sys_dir);
 
 /*
  * lvm2_destroy
-void lvm2_destroy(lvm_handle_t h);
  *
  * Description: Destroy an LVM2 handle allocated with lvm2_create
  *
  * Parameters:
  * - h (IN): handle obtained from lvm2_create
  */
-#define lvm2_destroy(X) destroy_toolcontext(X)
+void lvm2_destroy(lvm2_handle_t h);
 
 #endif
diff --git a/test/api/test.c b/test/api/test.c
index de53c46..866be8f 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -48,7 +48,7 @@ static int lvm_split(char *str, int *argc, char **argv, int max)
 	return *argc;
 }
 
-static int lvmapi_test_shell(void *h)
+static int lvmapi_test_shell(lvm2_handle_t libh)
 {
 	int argc, i;
 	char *input = NULL, *args[MAX_ARGS], **argv;
@@ -99,18 +99,17 @@ static int lvmapi_test_shell(void *h)
 		      
 int main (int argc, char *argv[])
 {
-	void *h;
+	lvm2_handle_t libh;
 
-	h = lvm2_create();
-	if (!h) {
+	libh = lvm2_create(NULL);
+	if (!libh) {
 		printf("Unable to open lvm library instance\n");
 		return 1;
 	}
 
-	lvmapi_test_shell(h);
+	lvmapi_test_shell(libh);
 
-	if (h)
-		lvm2_destroy(h);
+	lvm2_destroy(libh);
 	return 0;
 }
 
-- 
1.6.0.4


