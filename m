From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri,  7 May 2010 16:14:56 +0200
Subject: [PATCH 9/9] Use pkgconfigdir for placement of .pc files
In-Reply-To: <cover.1273241256.git.zkabelac@redhat.com>
References: <cover.1273241256.git.zkabelac@redhat.com>
Message-ID: <b604b8be8d1e1926f9182ebb98c1399fbfbc1752.1273241256.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use easily replaceable make install pkgconfigdir variable.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 daemons/dmeventd/Makefile.in |    2 +-
 libdm/Makefile.in            |    2 +-
 liblvm/Makefile.in           |    2 +-
 make.tmpl.in                 |    1 +
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/daemons/dmeventd/Makefile.in b/daemons/dmeventd/Makefile.in
index f9afdb6..0850a19 100644
--- a/daemons/dmeventd/Makefile.in
+++ b/daemons/dmeventd/Makefile.in
@@ -81,7 +81,7 @@ install_include: $(srcdir)/libdevmapper-event.h
 	$(INSTALL_DATA) -D $< $(includedir)/$(<F)
 
 install_pkgconfig: libdevmapper-event.pc
-	$(INSTALL_DATA) -D $< $(usrlibdir)/pkgconfig/devmapper-event.pc
+	$(INSTALL_DATA) -D $< $(pkgconfigdir)/devmapper-event.pc
 
 install_lib_dynamic: install_lib_shared
 
diff --git a/libdm/Makefile.in b/libdm/Makefile.in
index ba62984..6e24eb7 100644
--- a/libdm/Makefile.in
+++ b/libdm/Makefile.in
@@ -85,7 +85,7 @@ install_static: install_@interface@_static
 install_ioctl: install_lib_shared
 
 install_pkgconfig: libdevmapper.pc
-	$(INSTALL_DATA) -D $< $(usrlibdir)/pkgconfig/devmapper.pc
+	$(INSTALL_DATA) -D $< $(pkgconfigdir)/devmapper.pc
 
 install_ioctl_static: $(LIB_STATIC)
 	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 6690429..197f1d1 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -65,7 +65,7 @@ install_static: $(LIB_STATIC)
 	$(INSTALL_DATA) -D $< $(usrlibdir)/$(<F)
 
 install_pkgconfig: $(LIB_NAME).pc
-	$(INSTALL_DATA) -D $< $(usrlibdir)/pkgconfig/lvm2app.pc
+	$(INSTALL_DATA) -D $< $(pkgconfigdir)/lvm2app.pc
 
 liblvm.cflow: $(SOURCES)
 	set -e; (echo -n "SOURCES += "; \
diff --git a/make.tmpl.in b/make.tmpl.in
index 6d9f681..c22a6d1 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -63,6 +63,7 @@ mandir = $(datarootdir)/man
 localedir = $(DESTDIR)@LOCALEDIR@
 staticdir = $(DESTDIR)@STATICDIR@
 udevdir = $(DESTDIR)@udevdir@
+pkgconfigdir = $(usrlibdir)/pkgconfig
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
 
-- 
1.7.0.1


