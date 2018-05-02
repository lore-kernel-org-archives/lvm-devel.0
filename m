From: Joe Thornber <thornber@sourceware.org>
Date: Wed, 2 May 2018 13:42:40 -0400
Subject: master - build: add -D_FILE_OFFSET_BITS=64
Message-ID: <201805021742.w42HgeaR029690@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=972b535220d2d9f4df583bcc5e67e8cc14ca6294
Commit:        972b535220d2d9f4df583bcc5e67e8cc14ca6294
Parent:        9fe0be871c916c1105212f916d8c6904d12ea5b4
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Wed May 2 18:40:38 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Wed May 2 18:40:38 2018 +0100

build: add -D_FILE_OFFSET_BITS=64

I don't like having this in a common header because it means you end
up including too much and causing unneccessary dependencies.  eg,
lib/misc/lib.h includes libdevmapper.h, internationalisation, and
logging stuff.
---
 daemons/cmirrord/logging.h |    1 -
 lib/misc/lib.h             |    1 -
 make.tmpl.in               |    3 +++
 tools/tool.h               |    1 -
 4 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/cmirrord/logging.h b/daemons/cmirrord/logging.h
index 3ede0c7..13e6b39 100644
--- a/daemons/cmirrord/logging.h
+++ b/daemons/cmirrord/logging.h
@@ -14,7 +14,6 @@
 #define _LVM_CLOG_LOGGING_H
 
 #define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
 
 #include "configure.h"
 #include <stdio.h>
diff --git a/lib/misc/lib.h b/lib/misc/lib.h
index 8ed06f8..d7fa5c7 100644
--- a/lib/misc/lib.h
+++ b/lib/misc/lib.h
@@ -23,7 +23,6 @@
 
 #define _REENTRANT
 #define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
 
 /*
  * Symbol export control macros
diff --git a/make.tmpl.in b/make.tmpl.in
index 3a9f450..d3a80ef 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -444,6 +444,9 @@ endif
 
 DEPFLAGS=-MT $@ -MMD -MP -MF $*.d
 
+# still needed in 2018 for 32bit builds
+DEFS+=-D_FILE_OFFSET_BITS=64
+
 %.o: %.c
 	@echo "    [CC] $<"
 	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
diff --git a/tools/tool.h b/tools/tool.h
index 79b30bc..a2c8572 100644
--- a/tools/tool.h
+++ b/tools/tool.h
@@ -19,7 +19,6 @@
 #define _LVM_TOOL_H
 
 #define _GNU_SOURCE
-#define _FILE_OFFSET_BITS 64
 
 #include "configure.h"
 


