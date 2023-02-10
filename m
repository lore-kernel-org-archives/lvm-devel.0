From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:28 +0000 (GMT)
Subject: main - makefiles: keep removing anchient files
Message-ID: <20230210165328.612F9385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a032e07578ecdb459470cced8e118ce57088d033
Commit:        a032e07578ecdb459470cced8e118ce57088d033
Parent:        35e1f15e0386341617c5810c481a2c8d227026d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 9 22:50:59 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

makefiles: keep removing anchient files

Commit dropping lvmetad support 117160b27e510dceb1ed6acf995115c040acd88d
also removed cleaning of its generated files. However we need to keep
this functionality, otherwise we can leak them during various bisect.
Easier is to keep such rules forever.

Also commit c1ab9fb37faee56cee278ccd94cb958d30d61b94 moved cmds.h to
include, so again keep it removed so it's not left there and in any
case could not misslead anyone.
---
 include/Makefile.in | 2 ++
 tools/Makefile.in   | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/Makefile.in b/include/Makefile.in
index 88a06a934..fc184ed09 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -86,6 +86,8 @@ CLEAN_TARGETS += \
  lvm2app.h \
  lvm2cmd.h \
  lvmcache.h \
+ lvmetad-client.h \
+ lvmetad.h \
  lvmlockd-client.h \
  lvmlockd.h \
  lvmnotify.h \
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 49d9b89c7..4e196ab1e 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -97,7 +97,7 @@ INCLUDES = -I$(top_builddir)/tools
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \
 	liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) lvm-static.o \
 	liblvm2cmd-static.a lvm.static \
-	$(LDDEPS) .exported_symbols_generated \
+	$(LDDEPS) .exported_symbols_generated cmds.h \
 	command-lines-input.h command-count.h man-generator.c
 
 ifeq ("@CMDLIB@", "yes")

