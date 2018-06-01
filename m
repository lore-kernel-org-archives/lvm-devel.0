From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 14:19:52 -0400
Subject: master - build: get clvmd building again
Message-ID: <201806011819.w51IJqmM003740@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02c4901d893a1b833260a7cbb66b9ad285d7ce39
Commit:        02c4901d893a1b833260a7cbb66b9ad285d7ce39
Parent:        c4497ee9e849d2d6c74412de21c6c3823d4de5f1
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri Jun 1 19:18:36 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri Jun 1 19:18:36 2018 +0100

build: get clvmd building again

---
 daemons/clvmd/Makefile.in |    4 ++--
 make.tmpl.in              |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/daemons/clvmd/Makefile.in b/daemons/clvmd/Makefile.in
index 47a3411..9e096b5 100644
--- a/daemons/clvmd/Makefile.in
+++ b/daemons/clvmd/Makefile.in
@@ -80,9 +80,9 @@ CFLAGS += -fno-strict-aliasing $(EXTRA_EXEC_CFLAGS)
 INSTALL_TARGETS = \
 	install_clvmd
 
-clvmd: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a
+clvmd: $(OBJECTS) $(top_builddir)/lib/liblvm-internal.a $(top_builddir)/device_mapper/libdevice-mapper.a
 	$(CC) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) \
-	      -o clvmd $(OBJECTS) $(LMLIBS) $(LIBS)
+	      -o clvmd $+ $(LMLIBS) $(LIBS)
 
 .PHONY: install_clvmd
 
diff --git a/make.tmpl.in b/make.tmpl.in
index ad927b0..16a8571 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -58,7 +58,7 @@ PYTHON3 = @PYTHON3@
 PYCOMPILE = $(top_srcdir)/autoconf/py-compile
 
 LIBS = @LIBS@
-LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS) $(RT_LIBS)
+LIBS += $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS) $(RT_LIBS) -lm
 # Extra libraries always linked with static binaries
 STATIC_LIBS = $(SELINUX_LIBS) $(UDEV_LIBS) $(BLKID_LIBS)
 DEFS += @DEFS@


