From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2011 23:18:41 -0000
Subject: LVM2/test/api test.c
Message-ID: <20110301231841.10338.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-01 23:18:40

Modified files:
	test/api       : test.c 

Log message:
	Build test.c also without readline library
	
	Allow bulding of this testing tool also without readline library.
	Outputs message about build without readline library then.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/test.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/test/api/test.c	2010/11/25 14:35:46	1.34
+++ LVM2/test/api/test.c	2011/03/01 23:18:40	1.35
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -12,13 +12,18 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
+
 #include <stdio.h>
 #include <string.h>
 #include <stdlib.h>
-#include <readline/readline.h>
+#include <ctype.h>
 
+#include "configure.h"
 #include "lvm2app.h"
 
+#ifndef READLINE_SUPPORT
+#include <readline/readline.h>
+
 #define MAX_ARGS 64
 
 static int lvm_split(char *str, int *argc, char **argv, int max)
@@ -1071,6 +1076,13 @@
 	free(input);
 	return 0;
 }
+#else /* !READLINE_SUPPORT */
+static int lvmapi_test_shell(lvm_t libh)
+{
+	printf("Build without readline library, no interactive testing.\n");
+	return 1;
+}
+#endif
 
 int main (int argc, char *argv[])
 {


