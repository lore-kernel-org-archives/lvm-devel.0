From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 18:53:15 -0500
Subject: master - tests: makefile fixes
Message-ID: <201811162353.wAGNrFBn018322@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2d89192935228cce019f8fc190a0060ca13b704e
Commit:        2d89192935228cce019f8fc190a0060ca13b704e
Parent:        a23ed35f6c14e2f914796c34fea2404d54b08302
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 17 00:52:19 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 00:52:59 2018 +0100

tests: makefile fixes

New tests needs more options and libs.
---
 test/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 6b6749a..ba8eea8 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -238,10 +238,10 @@ lib/runner: lib/runner.o .lib-dir-stamp
 	$(CXX) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $<
 
 lib/dmsecuretest: lib/dmsecuretest.o .lib-dir-stamp $(INTERNAL_LIBS)
-	$(CC) -g $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(UDEV_LIBS) -lm
+	$(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(UDEV_LIBS) -lm
 
 lib/securetest: lib/dmsecuretest.o .lib-dir-stamp
-	$(CC) -g $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(top_builddir)/libdm/ioctl -ldevmapper
+	$(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(top_builddir)/libdm/ioctl -ldevmapper $(LIBS)
 
 lib/runner.o: $(wildcard $(srcdir)/lib/*.h)
 


