From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Apr 2010 08:01:53 -0000
Subject: LVM2/old-tests/regex Makefile.in matcher_t.c p ...
Message-ID: <20100421080153.30933.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-21 08:01:52

Modified files:
	old-tests/regex: Makefile.in matcher_t.c parse_t.c 

Log message:
	Make matcher_t and parse_t compilable
	
	These two old-test/regex utils are usable for testing output of regex
	processing at core level. For getting them usable configure need to create
	Makefile. This is currently disable by default.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/regex/Makefile.in.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/regex/matcher_t.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/regex/parse_t.c.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/old-tests/regex/Makefile.in	2010/03/04 09:51:41	1.6
+++ LVM2/old-tests/regex/Makefile.in	2010/04/21 08:01:51	1.7
@@ -1,6 +1,6 @@
 #
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
-# Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
 #
 # This file is part of LVM2.
 #
@@ -15,7 +15,6 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
-VPATH = @srcdir@
 
 SOURCES=\
 	parse_t.c \
@@ -27,9 +26,12 @@
 
 include $(top_builddir)/make.tmpl
 
-parse_t: parse_t.o $(top_builddir)/lib/liblvm.a
-	$(CC) -o parse_t parse_t.o -L$(top_builddir)/lib -llvm
+INCLUDES += -I$(top_srcdir)/libdm
+DM_DEPS = $(top_builddir)/libdm/libdevmapper.so
+DM_LIBS = -ldevmapper $(LIBS)
 
-matcher_t: matcher_t.o $(top_builddir)/lib/liblvm.a
-	$(CC) -o matcher_t matcher_t.o -L$(top_builddir)/lib -llvm
+parse_t: parse_t.o $(DM_DEPS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ parse_t.o $(DM_LIBS)
 
+matcher_t: matcher_t.o $(DM_DEPS)
+	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ matcher_t.o $(DM_LIBS)
--- LVM2/old-tests/regex/matcher_t.c	2005/10/16 23:03:59	1.4
+++ LVM2/old-tests/regex/matcher_t.c	2010/04/21 08:01:51	1.5
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -13,7 +13,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "matcher.h"
+#include "libdevmapper.h"
 #include "log.h"
 
 #include <stdio.h>
@@ -31,7 +31,7 @@
 	char buffer[1024], *start, *ptr;
 	FILE *fp = fopen(file, "r");
 	int asize = 100;
-	char **rx = dbg_malloc(sizeof(*rx) * asize);
+	char **rx = dm_malloc(sizeof(*rx) * asize);
 	int nr = 0;
 
 	if (!fp)
@@ -60,7 +60,7 @@
 				return 0;
 			}
 
-			rx[nr] = dbg_malloc((ptr - start) + 1);
+			rx[nr] = dm_malloc((ptr - start) + 1);
 			strncpy(rx[nr], start, ptr - start);
 			rx[nr][ptr - start] = '\0';
 			nr++;
@@ -81,12 +81,12 @@
 {
 	int i;
 	for (i = 0; i < nregex; i++)
-		dbg_free(regex[i]);
+		dm_free(regex[i]);
 
-	dbg_free(regex);
+	dm_free(regex);
 }
 
-static void _scan_input(struct matcher *m, char **regex)
+static void _scan_input(struct dm_regex *m, char **regex)
 {
 	char buffer[256], *ptr;
 	int r;
@@ -95,7 +95,7 @@
 		if ((ptr = strchr(buffer, '\n')))
 			*ptr = '\0';
 
-		r = matcher_run(m, buffer);
+		r = dm_regex_match(m, buffer);
 
 		if (r >= 0)
 			printf("%s : %s\n", buffer, regex[r]);
@@ -105,39 +105,41 @@
 int main(int argc, char **argv)
 {
 	struct dm_pool *mem;
-	struct matcher *scanner;
+	struct dm_regex *scanner;
 	char **regex;
 	int nregex;
+	int ret = 0;
 
 	if (argc < 2) {
 		fprintf(stderr, "Usage : %s <pattern_file>\n", argv[0]);
 		exit(1);
 	}
 
-	init_log(stderr);
-	init_debug(_LOG_DEBUG);
+	dm_log_init_verbose(_LOG_DEBUG);
 
-	if (!(mem = dm_pool_create(10 * 1024))) {
+	if (!(mem = dm_pool_create("match_regex", 10 * 1024))) {
 		fprintf(stderr, "Couldn't create pool\n");
-		exit(2);
+		ret = 2;
+		goto err;
 	}
 
 	if (!_read_spec(argv[1], &regex, &nregex)) {
 		fprintf(stderr, "Couldn't read the lex specification\n");
-		exit(3);
+		ret = 3;
+		goto err;
 	}
 
-	if (!(scanner = matcher_create(mem, (const char **) regex, nregex))) {
+	if (!(scanner = dm_regex_create(mem, (const char **)regex, nregex))) {
 		fprintf(stderr, "Couldn't build the lexer\n");
-		exit(4);
+		ret = 4;
+		goto err;
 	}
 
 	_scan_input(scanner, regex);
 	_free_regex(regex, nregex);
+
+    err:
 	dm_pool_destroy(mem);
 
-	dump_memory();
-	fin_log();
-	return 0;
+	return ret;
 }
-
--- LVM2/old-tests/regex/parse_t.c	2005/10/16 23:03:59	1.3
+++ LVM2/old-tests/regex/parse_t.c	2010/04/21 08:01:51	1.4
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -13,8 +13,8 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include "log.h"
-#include "../../lib/regex/parse_rx.h"
+/* hack - using unexported internal function */
+#include "regex/parse_rx.c"
 
 #include <stdio.h>
 #include <ctype.h>
@@ -50,7 +50,7 @@
 	case CHARSET:
 		printf("Charset : ");
 		for (i = 0; i < 256; i++) {
-			if (bit(rx->charset, i) && isprint(i))
+			if (dm_bit(rx->charset, i) && isprint(i))
 				printf("%c", (char) i);
 		}
 		break;
@@ -67,7 +67,6 @@
 		_pretty_print(rx->right, depth + 1);
 }
 
-
 int main(int argc, char **argv)
 {
 	struct dm_pool *mem;
@@ -78,15 +77,15 @@
 		exit(0);
 	}
 
-	init_log(stderr);
-	init_debug(_LOG_INFO);
+	dm_log_init_verbose(_LOG_DEBUG);
 
-	if (!(mem = dm_pool_create(1024))) {
+	if (!(mem = dm_pool_create("parse_regex", 1024))) {
 		fprintf(stderr, "Couldn't create pool\n");
 		exit(1);
 	}
 
 	if (!(rx = rx_parse_str(mem, argv[1]))) {
+		dm_pool_destroy(mem);
 		fprintf(stderr, "Couldn't parse regex\n");
 		exit(1);
 	}
@@ -94,7 +93,5 @@
 	_pretty_print(rx, 0);
 	dm_pool_destroy(mem);
 
-	dump_memory();
-	fin_log();
 	return 0;
 }


