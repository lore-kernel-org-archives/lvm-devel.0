From: twoerner@sourceware.org <twoerner@sourceware.org>
Date: 24 Feb 2009 13:03:46 -0000
Subject: LVM2 ./WHATS_NEW lib/Makefile.in test/api/test ...
Message-ID: <20090224130346.17777.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	twoerner at sourceware.org	2009-02-24 13:03:45

Modified files:
	.              : WHATS_NEW 
	lib            : Makefile.in 
	test/api       : test.c 
Added files:
	lib            : lvm.h lvm_base.c 
Removed files:
	lib            : lvm2.h 

Log message:
	Added files lib/lvm.h and lib/lvm_base.c:
	New structure lvm (used as an alias to cmd_context), new type definition lvm_t
	for the lvm handle. Added functions lvm_create, lvm_destroy and
	lvm_reload_config using the new handle.
	
	Modified test/api/test.c:
	Use new lvm.h header file and lvm_t handle.
	
	Removed lib/lvm2.h
	
	Author: Thomas Woerner <twoerner@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1050&r2=1.1051
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/lvm.h.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/lvm_base.c.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.87&r2=1.88
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/lvm2.h.diff?cvsroot=lvm2&r1=1.3&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2009/02/22 22:11:58	1.1050
+++ LVM2/WHATS_NEW	2009/02/24 13:03:45	1.1051
@@ -1,5 +1,6 @@
 Version 2.02.45 - 
 ===================================
+  Add lib/lvm.h and lib/lvm_base.c for the new library interface.
   Move tools/version.h to lib/misc/lvm-version.h.
   Split LVM_VERSION into MAJOR, MINOR, PATCHLEVEL, RELEASE and RELEASE_DATE.
   Add system_dir parameter to create_toolcontext().
/cvs/lvm2/LVM2/lib/lvm.h,v  -->  standard output
revision 1.1
--- LVM2/lib/lvm.h
+++ -	2009-02-24 13:03:46.260800000 +0000
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
+#include "lvm-version.h"
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
+ *          Set an alternative LVM system directory. Use NULL to use the 
+ *          default value. If the environment variable LVM_SYSTEM_DIR is set, 
+ *          it will override any LVM system directory setting.
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
/cvs/lvm2/LVM2/lib/lvm_base.c,v  -->  standard output
revision 1.1
--- LVM2/lib/lvm_base.c
+++ -	2009-02-24 13:03:46.339748000 +0000
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
--- LVM2/lib/Makefile.in	2008/11/03 18:59:58	1.87
+++ LVM2/lib/Makefile.in	2009/02/24 13:03:45	1.88
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -86,7 +86,8 @@
 	report/report.c \
 	striped/striped.c \
 	uuid/uuid.c \
-	zero/zero.c
+	zero/zero.c \
+	lvm_base.c
 
 ifeq ("@LVM1@", "internal")
   SOURCES +=\
--- LVM2/test/api/test.c	2008/12/07 19:37:07	1.1
+++ LVM2/test/api/test.c	2009/02/24 13:03:45	1.2
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
 
@@ -48,7 +48,7 @@
 	return *argc;
 }
 
-static int lvmapi_test_shell(void *h)
+static int lvmapi_test_shell(lvm_t libh)
 {
 	int argc, i;
 	char *input = NULL, *args[MAX_ARGS], **argv;
@@ -99,18 +99,17 @@
 		      
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
 


