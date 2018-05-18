From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 18 May 2018 10:28:01 -0400
Subject: master - tests; make sure python_lvm_unit.py is executable
Message-ID: <201805181428.w4IES1TW012377@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fbf64fe730ffa27ee94867017742174f270d3fa0
Commit:        fbf64fe730ffa27ee94867017742174f270d3fa0
Parent:        43fb32e761a2c4d1ebaec5eff9d9f0f372563cf9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 18 16:16:09 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 18 16:25:44 2018 +0200

tests; make sure python_lvm_unit.py is executable

---
 test/api/Makefile.in |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index e953675..1659b87 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -38,6 +38,8 @@ SOURCES2 = \
 
 endif
 
+PYTEST = python_lvm_unit.py
+
 include $(top_builddir)/make.tmpl
 
 DEFS += -D_REENTRANT
@@ -48,6 +50,9 @@ LIBS += @LVM2APP_LIB@ $(DMEVENT_LIBS) -ldevmapper
 %.t: %.o $(DEPLIBS)
 	$(CC) -o $@ $(<) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) $(LIBS)
 
+all:
+	test -x $(PYTEST) || chmod 755 $(PYTEST)
+
 test: $(OBJECTS) $(DEPLIBS)
 	$(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(ELDFLAGS) $(LIBS) $(READLINE_LIBS)
 


