From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  1 Aug 2012 13:51:35 +0000 (UTC)
Subject: master - make: fix make in scripts dir for --disable-applib
Message-ID: <20120801135135.4A14E2B36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9952331d5d58a4cc2580eddec34defa9cfe141c9
Commit:        9952331d5d58a4cc2580eddec34defa9cfe141c9
Parent:        286f298bb79a43b61baab36582481df93e84137b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 1 15:48:53 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 1 15:48:53 2012 +0200

make: fix make in scripts dir for --disable-applib

---
 scripts/Makefile.in |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 2298f0c..df13c3d 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -15,14 +15,18 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-SOURCES = lvm2_activation_generator_systemd_red_hat.c
-TARGETS = lvm2_activation_generator_systemd_red_hat
+ifeq ("@APPLIB@", "yes")
+	SOURCES = lvm2_activation_generator_systemd_red_hat.c
+	TARGETS = lvm2_activation_generator_systemd_red_hat
+endif
 
 include $(top_builddir)/make.tmpl
 
-DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
-LDFLAGS += -L$(top_builddir)/liblvm
-LVMLIBS = @LVM2APP_LIB@ -ldevmapper
+ifeq ("@APPLIB@", "yes")
+	DEPLIBS += $(top_builddir)/liblvm/liblvm2app.so $(top_builddir)/libdm/libdevmapper.so
+	LDFLAGS += -L$(top_builddir)/liblvm
+	LVMLIBS = @LVM2APP_LIB@ -ldevmapper
+endif
 
 ifeq ("@DMEVENTD@", "yes")
 	LVMLIBS += -ldevmapper-event
@@ -76,7 +80,12 @@ lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS)
 
 install_systemd_generators:
 	$(INSTALL_DIR) $(systemd_generator_dir)
+ifeq ("@APPLIB@", "yes")
 	$(INSTALL_PROGRAM) lvm2_activation_generator_systemd_red_hat $(systemd_generator_dir)/lvm2-activation-generator
+else
+	@echo "WARNING: LVM2 activation systemd generator not installed." \
+	      "It requires the LVM2 application library to be built as well."
+endif
 
 install_systemd_units:
 	$(INSTALL_DIR) $(systemd_unit_dir)


