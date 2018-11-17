From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 19:02:15 -0500
Subject: master - tests: still more libs needs
Message-ID: <201811170002.wAH02Fh9019092@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ea001426af94d07ba1e787b36a0c325e33c6a3d9
Commit:        ea001426af94d07ba1e787b36a0c325e33c6a3d9
Parent:        2d89192935228cce019f8fc190a0060ca13b704e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 17 01:00:06 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 01:01:48 2018 +0100

tests: still more libs needs

---
 test/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index ba8eea8..df61f0a 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -238,7 +238,7 @@ lib/runner: lib/runner.o .lib-dir-stamp
 	$(CXX) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $<
 
 lib/dmsecuretest: lib/dmsecuretest.o .lib-dir-stamp $(INTERNAL_LIBS)
-	$(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(UDEV_LIBS) -lm
+	$(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< $(INTERNAL_LIBS) $(LIBS)
 
 lib/securetest: lib/dmsecuretest.o .lib-dir-stamp
 	$(CC) -g $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) -o $@ $< -L$(top_builddir)/libdm/ioctl -ldevmapper $(LIBS)


