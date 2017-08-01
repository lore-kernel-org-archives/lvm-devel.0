From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 1 Aug 2017 12:59:31 -0400
Subject: master - tests: update makefiles
Message-ID: <201708011659.v71GxVqf022960@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=19bd65207e2aec48a8d6194aefac9be05a13d944
Commit:        19bd65207e2aec48a8d6194aefac9be05a13d944
Parent:        3232b210ab750bb21b9032d41cf20aee2bb33288
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 1 18:53:25 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 1 18:53:25 2017 +0200

tests: update makefiles

---
 test/Makefile.in     |    4 ++--
 test/api/Makefile.in |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index eee9bf2..c3285e4 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -256,14 +256,14 @@ lib/fail: lib/not
 	$(LN_S) -f not lib/fail
 
 lib/runner: lib/runner.o .lib-dir-stamp
-	$(CXX) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) -o $@ $<
+	$(CXX) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $<
 
 lib/runner.o: $(wildcard $(srcdir)/lib/*.h)
 
 CFLAGS_runner.o += $(EXTRA_EXEC_CFLAGS)
 
 lib/%: lib/%.o .lib-dir-stamp
-	$(CC) $(LDFLAGS) -o $@ $<
+	$(CC) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) -o $@ $<
 
 lib/%: $(srcdir)/lib/%.sh .lib-dir-stamp
 	cp $< $@
diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index cc237df..e953675 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -46,10 +46,10 @@ LDFLAGS += -L$(top_builddir)/liblvm -L$(top_builddir)/daemons/dmeventd
 LIBS += @LVM2APP_LIB@ $(DMEVENT_LIBS) -ldevmapper
 
 %.t: %.o $(DEPLIBS)
-	$(CC) -o $@ $(<) $(LDFLAGS) $(LIBS)
+	$(CC) -o $@ $(<) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) $(LIBS)
 
 test: $(OBJECTS) $(DEPLIBS)
-	$(CC) -o $@ $(OBJECTS) $(LDFLAGS) $(LIBS) $(READLINE_LIBS)
+	$(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) $(LIBS) $(READLINE_LIBS)
 
 Makefile: $(srcdir)/Makefile.in $(top_builddir)/config.status
 	cd $(top_builddir) && $(SHELL) ./config.status test/api/Makefile


