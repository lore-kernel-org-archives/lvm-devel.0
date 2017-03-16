From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 16 Mar 2017 19:15:04 -0400
Subject: master - man: Build man-generator in tools dir.
Message-ID: <201703162315.v2GNF4YL030402@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5e7bc8d854bb6752e6987692791750a48e871442
Commit:        5e7bc8d854bb6752e6987692791750a48e871442
Parent:        270ed9bc9038b1cd2ff4f4a7177292621c591ede
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Mar 16 23:10:40 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Mar 16 23:10:40 2017 +0000

man: Build man-generator in tools dir.

Use ln to make a copy of command.c for compilation with different DEFS
then handle dependencies the normal way.
---
 man/Makefile.in   |    9 +++------
 tools/Makefile.in |   16 +++++++++++++---
 2 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index b3f287b..57d9627 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -117,13 +117,13 @@ MAN5DIR=$(mandir)/man5
 MAN7DIR=$(mandir)/man7
 MAN8DIR=$(mandir)/man8
 
-MANGENERATOR=./man-generator
+MANGENERATOR=$(top_builddir)/tools/man-generator
 TESTMAN=test.gen
 
 include $(top_builddir)/make.tmpl
 
 CLEAN_TARGETS+=$(MAN5) $(MAN7) $(MAN8) $(MAN8:%.8=%.8_gen) $(MAN8CLUSTER) \
-	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM) $(MANGENERATOR) $(TESTMAN)
+	$(MAN8SYSTEMD_GENERATORS) $(MAN8DM) $(TESTMAN)
 DISTCLEAN_TARGETS+=$(FSADMMAN) $(BLKDEACTIVATEMAN) $(DMEVENTDMAN) \
 	$(LVMETADMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(CLVMDMAN) $(CMIRRORDMAN) \
 	$(LVMCACHEMAN) $(LVMTHINMAN) $(LVMDBUSDMAN) $(LVMRAIDMAN) \
@@ -141,11 +141,8 @@ all_man: man
 
 $(MAN5) $(MAN7) $(MAN8) $(MAN8DM) $(MAN8CLUSTER) $(MAN8SYSTEMD_GENERATORS): Makefile
 
-$(MANGENERATOR): Makefile
-	$(CC) -DMAN_PAGE_GENERATOR -I$(top_builddir)/tools $(CFLAGS) $(top_srcdir)/tools/command.c -o $@
-
 # Test whether or not the man page generator works
-$(TESTMAN): $(MANGENERATOR)
+$(TESTMAN): $(MANGENERATOR) Makefile
 	- $(MANGENERATOR) --primary lvmconfig > $@
 
 SEE_ALSO=$(srcdir)/see_also.end
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 6312c9e..8ea6801 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -72,12 +72,14 @@ SOURCES2 =\
 	lvm.c \
 	lvm2cmd-static.c \
 	lvm2cmd.c \
-	lvmcmdlib.c
+	lvmcmdlib.c \
+	man-generator.c
 
 TARGETS =\
 	.commands \
 	liblvm2cmd.a \
-	lvm
+	lvm \
+	man-generator
 
 TARGETS_DM = dmsetup
 
@@ -100,7 +102,7 @@ CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \
 	liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) lvm-static.o \
 	liblvm2cmd-static.a dmsetup.static lvm.static \
 	$(LDDEPS) .exported_symbols_generated \
-	cmds.h command-lines-input.h command-count.h
+	cmds.h command-lines-input.h command-count.h man-generator.c
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
@@ -145,6 +147,14 @@ lvm: $(OBJECTS) lvm.o $(top_builddir)/lib/liblvm-internal.a
 	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $(OBJECTS) lvm.o \
 		$(LVMLIBS) $(READLINE_LIBS) $(LIBS) -rdynamic
 
+DEFS_man-generator.o += -DMAN_PAGE_GENERATOR
+
+man-generator.c: command.c
+	$(LN_S) -f $< $@
+
+man-generator: man-generator.o
+	$(CC) $(CFLAGS) -o $@ $<
+
 ifeq ("@BUILD_LVMETAD@", "yes")
 lvm: $(top_builddir)/libdaemon/client/libdaemonclient.a
 endif


