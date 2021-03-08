From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:46:40 +0000 (GMT)
Subject: main - makefiles: fix location of basedir
Message-ID: <20210308144640.D865F3950400@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ee9488488f1b97e7e3257e6490188d7ad5afafe0
Commit:        ee9488488f1b97e7e3257e6490188d7ad5afafe0
Parent:        7df4a13282a32029ab51b01d0ace14c296c0e8e3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 3 14:45:25 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:22:27 2021 +0100

makefiles: fix location of basedir

---
 daemons/lvmdbusd/Makefile.in | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index dee37122a..d9cf5d886 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -15,7 +15,8 @@ srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
 
-lvmdbusdir = $(python3dir)/lvmdbusd
+lvmdbuspydir = $(python3dir)/lvmdbusd
+lvmdbusdir = $(DESTDIR)$(lvmdbuspydir)
 
 LVMDBUS_SRCDIR_FILES = \
 	automatedproperties.py \
@@ -57,12 +58,12 @@ install_lvmdbusd: $(LVMDBUSD)
 	@echo "    [INSTALL] $<"
 	$(Q) $(INSTALL_DIR) $(sbindir)
 	$(Q) $(INSTALL_SCRIPT) $(LVMDBUSD) $(sbindir)
-	$(Q) $(INSTALL_DIR) $(DESTDIR)$(lvmdbusdir)
-	$(Q) (cd $(srcdir); $(INSTALL_DATA) $(LVMDBUS_SRCDIR_FILES) $(DESTDIR)$(lvmdbusdir))
-	$(Q) $(INSTALL_DATA) $(LVMDBUS_BUILDDIR_FILES) $(DESTDIR)$(lvmdbusdir)
-	$(Q) PYTHON=$(PYTHON3) $(PYCOMPILE) --destdir "$(DESTDIR)" --basedir "$(lvmdbusdir)" $(LVMDBUS_SRCDIR_FILES) $(LVMDBUS_BUILDDIR_FILES)
-	$(Q) $(CHMOD) 755 $(DESTDIR)$(lvmdbusdir)/__pycache__
-	$(Q) $(CHMOD) 444 $(DESTDIR)$(lvmdbusdir)/__pycache__/*.py[co]
+	$(Q) $(INSTALL_DIR) $(lvmdbusdir)
+	$(Q) (cd $(srcdir); $(INSTALL_DATA) $(LVMDBUS_SRCDIR_FILES) $(lvmdbusdir))
+	$(Q) $(INSTALL_DATA) $(LVMDBUS_BUILDDIR_FILES) $(lvmdbusdir)
+	$(Q) PYTHON=$(PYTHON3) $(PYCOMPILE) --destdir "$(DESTDIR)" --basedir "$(lvmdbuspydir)" $(LVMDBUS_SRCDIR_FILES) $(LVMDBUS_BUILDDIR_FILES)
+	$(Q) $(CHMOD) 755 $(lvmdbusdir)/__pycache__
+	$(Q) $(CHMOD) 444 $(lvmdbusdir)/__pycache__/*.py[co]
 
 install_lvm2: install_lvmdbusd
 


