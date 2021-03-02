From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:22 +0000 (GMT)
Subject: main - makefiles: integrate DESTDIR
Message-ID: <20210302215822.40FC23834402@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=456b659b4edfc758b5aa0b72af25677a4f5042ea
Commit:        456b659b4edfc758b5aa0b72af25677a4f5042ea
Parent:        8bfa4439e1c9a342d8e0d9ee36932f2a89721342
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 2 16:29:07 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: integrate  DESTDIR

Always use lvmdbusdir with DESTDIR.
---
 daemons/lvmdbusd/Makefile.in | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index da96c344b..56d5c6602 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -15,7 +15,7 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-lvmdbusdir = $(python3dir)/lvmdbusd
+lvmdbusdir = $(DESTDIR)$(python3dir)/lvmdbusd
 
 LVMDBUS_SRCDIR_FILES = \
 	automatedproperties.py \
@@ -53,16 +53,16 @@ include $(top_builddir)/make.tmpl
 all:
 	$(Q) test -x $(LVMDBUSD) || chmod 755 $(LVMDBUSD)
 
-install_lvmdbusd:
+install_lvmdbusd: $(LVMDBUSD)
 	@echo "    [INSTALL] $<"
 	$(Q) $(INSTALL_DIR) $(sbindir)
 	$(Q) $(INSTALL_SCRIPT) $(LVMDBUSD) $(sbindir)
-	$(Q) $(INSTALL_DIR) $(DESTDIR)$(lvmdbusdir)
-	$(Q) (cd $(srcdir); $(INSTALL_DATA) $(LVMDBUS_SRCDIR_FILES) $(DESTDIR)$(lvmdbusdir))
-	$(Q) $(INSTALL_DATA) $(LVMDBUS_BUILDDIR_FILES) $(DESTDIR)$(lvmdbusdir)
+	$(Q) $(INSTALL_DIR) $(lvmdbusdir)
+	$(Q) (cd $(srcdir); $(INSTALL_DATA) $(LVMDBUS_SRCDIR_FILES) $(lvmdbusdir))
+	$(Q) $(INSTALL_DATA) $(LVMDBUS_BUILDDIR_FILES) $(lvmdbusdir)
 	$(Q) PYTHON=$(PYTHON3) $(PYCOMPILE) --destdir "$(DESTDIR)" --basedir "$(lvmdbusdir)" $(LVMDBUS_SRCDIR_FILES) $(LVMDBUS_BUILDDIR_FILES)
-	$(Q) $(CHMOD) 755 $(DESTDIR)$(lvmdbusdir)/__pycache__
-	$(Q) $(CHMOD) 444 $(DESTDIR)$(lvmdbusdir)/__pycache__/*.py[co]
+	$(Q) $(CHMOD) 755 $(lvmdbusdir)/__pycache__
+	$(Q) $(CHMOD) 444 $(lvmdbusdir)/__pycache__/*.py[co]
 
 install_lvm2: install_lvmdbusd
 


